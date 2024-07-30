//
//  WWZHConverter.swift
//  WWZHConverter
//
//  Created by William.Weng on 2024/7/22.
//

import UIKit
import WWNetworking

// MARK: - 兩岸三地用語轉換 (感謝「繁化姬」作者)
open class WWZHConverter {
    
    public static let shared = WWZHConverter()
            
    private init() {}
}

// MARK: - enum
extension WWZHConverter {
    
    /// [轉換的類型](https://docs.zhconvert.org/api/convert/)
    public enum ConverterType {
        
        case Simplified                                             // 簡體化
        case Traditional                                            // 繁體化
        case China                                                  // 中國化
        case Hongkong                                               // 香港化
        case Taiwan                                                 // 台灣化
        case Pinyin                                                 // 拼音化
        case Bopomofo                                               // 注音化
        case Mars                                                   // 火星文化
        case WikiSimplified                                         // 維基簡體化
        case WikiTraditional                                        // 維基繁體化
    }
    
    /// 日文的處理策略
    public enum JapaneseConversionStrategy {
        
        case style(_ style: ConversionStrategy)                     // 對於日文樣式該如何處理
        case text(_ text: ConversionStrategy)                       // 對於繁化姬自己發現的日文區域該如何處理
    }
    
    /// 處理策略
    public enum ConversionStrategy: String {
        
        case none                                                   // 無（當成中文處理）
        case protect                                                // 保護
        case protectOnlySameOrigin                                  // 僅保護原文與日文相同的字
        case fix                                                    // 修正
    }
    
    /// 輸出模板
    public enum TemplateType: String {
        
        case Inline
        case SideBySide
        case Unified
        case Context
        case JsonHtml
        case JsonText
    }
    
    /// 自定義錯誤
    public enum ConvertError: Error {
        
        case httpCode(_ code: Int)                                  // HTTP狀態碼
        case jsonObject                                             // JSON轉換錯誤
        case unknown                                                // 未知錯誤
    }
    
    /// 差異比較
    public enum DifferentType {
        
        case diffCharLevel(_ isEnable: Bool)                        // 是否使用字元級別的差異比較
        case diffContextLines(_ lines: Int)                         // 所輸出的結果要包含多少行上下文 (0 ~ 4)
        case diffEnable(_ isEnable: Bool)                           // 是否要啟用差異比較
        case diffIgnoreCase(_ isEnable: Bool)                       // 是否要忽略英文大小寫的差異
        case diffIgnoreWhiteSpaces(_ isIgnore: Bool)                // 是否要忽略空格的差異
        case diffTemplate(_ template: TemplateType)                 // 所要使用的輸出模板
    }
    
    /// 文本整理
    public enum TextType {
        
        case cleanUpText(_ isCleanUp: Bool)                         // 根據所偵測到的文本格式做出對應的文本清理
        case ensureNewlineAtEof(_ isEnsure: Bool)                   // 確保輸出的文本結尾處有一個且只有一個換行符
        case translateTabsToSpaces(_ spaces: Int)                   // 轉換每行開頭的 Tab 為數個空格 (-1 ~ 8)
        case trimTrailingWhiteSpaces(_ isTrim: Bool)                // 移除每行結尾的多餘空格
        case unifyLeadingHyphen(_ isUnify: Bool)                    // 將區分說話人用的連字號統一為半形減號
    }
    
    /// [自訂取代](https://filmora.wondershare.tw/animated-video/top-websites-to-download-anime-subtitles-for-free.html)
    public enum ReplaceType {
        
        case modules(_ dictionary: [String: Int])                   // 強制設定模組啟用／停用
        case userPostReplace(_ dictionary: [String: String])        // 轉換後再進行的額外取代
        case userPreReplace(_ dictionary: [String: String])         // 轉換前先進行的額外取代
        case userProtectReplace(_ dictionary: [String: String])     // 保護字詞不被繁化姬修改
        
        /// 轉換成可用的參數型
        /// - Returns: String?
        func paramater() -> String? {
            
            var paramater: String?
            
            switch self {
            case .modules(let dictionary): paramater = dictionary._jsonString(options: .fragmentsAllowed)
            case .userPostReplace(let dictionary): paramater = dictionary._queryString(separator: "\n")
            case .userPreReplace(let dictionary): paramater = dictionary._queryString(separator: "\n")
            case .userProtectReplace(let dictionary): paramater = dictionary._queryString(separator: "\n")
            }
            
            return paramater
        }
    }
}

// MARK: - 公開工具
public extension WWZHConverter {
    
    /// [取得API的相關資訊](https://zhconvert.org/)
    /// - Parameter result: (Result<Data?, Error>) -> Void
    func serviceInfo(result: @escaping (Result<Data?, Error>) -> Void) {
        
        _ = WWNetworking.shared.request(httpMethod: .GET, urlString: Constant.API.serviceInfo.url()) { [weak self] httpResult in
            
            guard let this = self else { result(.failure(ConvertError.unknown)); return }
            
            switch this.parseHtttpResult(httpResult) {
            case .failure(let error): result(.failure(error))
            case .success(let data): result(.success(data))
            }
        }
    }
    
    /// [文字轉換 (文字部分)](https://zh.wikipedia.org/zh-tw/汉语地区用词差异列表)
    /// - Parameters:
    ///   - text: String
    ///   - converterType: Constant.ConverterType
    ///   - replaces: [ReplaceType]?
    ///   - differents: [DifferentType]?
    ///   - texts: [TextType]?
    ///   - strategies: [JapaneseConversionStrategy]?
    ///   - result: (Result<String, Error>) -> Void
    func convertText(_ text: String, to converterType: ConverterType, replaces: [ReplaceType]? = nil, differents: [DifferentType]? = nil, texts: [TextType]? = nil, strategies: [JapaneseConversionStrategy]? = nil, result: @escaping (Result<String, Error>) -> Void) {
        
        convert(text: text, to: converterType, replaces: replaces, differents: differents, texts: texts, strategies: strategies) { convertResult in
            
            switch convertResult {
            case .failure(let error): result(.failure(error))
            case .success(let data):
                
                guard let dictionary = data?._jsonObject() as? [String: Any],
                      let data = dictionary["data"] as? [String: Any],
                      let convertText = data["text"] as? String
                else {
                    result(.failure(ConvertError.jsonObject)); return
                }
                
                result(.success(convertText))
            }
        }
    }
    
    /// [文字轉換 (完整資訊)](https://docs.zhconvert.org/)
    /// - Parameters:
    ///   - text: 文字
    ///   - converterType: 要轉換成什麼語言類型
    ///   - replaces: 自訂取代文字
    ///   - differents: 文字差異比較
    ///   - texts: 文本整理
    ///   - strategies: 日文的處理策略
    ///   - result: (Result<Data?, Error>) -> Void
    func convert(text: String, to converterType: ConverterType, replaces: [ReplaceType]? = nil, differents: [DifferentType]? = nil, texts: [TextType]? = nil, strategies: [JapaneseConversionStrategy]? = nil, result: @escaping (Result<Data?, Error>) -> Void) {
        
        var parameter: [String: Any] = [
            "text": text,
            "converter": "\(converterType)"
        ]
        
        parseReplaceTypes(replaces, parameter: &parameter)
        parseDifferentTypes(differents, parameter: &parameter)
        parseTextTypes(texts, parameter: &parameter)
        parseConversionStrategies(strategies, parameter: &parameter)
        
        _ = WWNetworking.shared.request(httpMethod: .POST, urlString: Constant.API.convert.url(), httpBodyType: .dictionary(parameter)) { [weak self] httpResult in
            
            guard let this = self else { result(.failure(ConvertError.unknown)); return }
            
            switch this.parseHtttpResult(httpResult) {
            case .failure(let error): result(.failure(error))
            case .success(let data): result(.success(data))
            }
        }
    }
}

// MARK: - 小工具
private extension WWZHConverter {
    
    /// 解析回傳的Http回應 (200)
    /// - Parameter result: Result<WWNetworking.ResponseInformation, Error>
    /// - Returns: Result<Data?, Error>
    func parseHtttpResult(_ result: Result<WWNetworking.ResponseInformation, Error>) -> Result<Data?, Error> {
        
        switch result {
        case .failure(let error): return .failure(error)
        case .success(let info):
            
            guard let statusCode = info.response?.statusCode,
                  let data = info.data
            else {
                return .failure(ConvertError.unknown)
            }
            
            if (statusCode != 200) { return .failure(ConvertError.httpCode(statusCode)) }
            return .success(data)
        }
    }
    
    /// 解析自訂取代文字參數
    /// - Parameters:
    ///   - replaces: [ReplaceType]?
    ///   - parameter: inout [String: Any]
    func parseReplaceTypes(_ replaces: [ReplaceType]?, parameter: inout [String: Any]) {
        
        guard let replaces = replaces else { return }
        
        replaces.forEach { replace in
            
            switch replace {
            case .modules(_): if let paramater = replace.paramater() { parameter["modules"] = replace.paramater() }
            case .userPostReplace(_): if let paramater = replace.paramater() { parameter["userPostReplace"] = replace.paramater() }
            case .userPreReplace(_): if let paramater = replace.paramater() { parameter["userPreReplace"] = replace.paramater() }
            case .userProtectReplace(_): if let paramater = replace.paramater() { parameter["userProtectReplace"] = replace.paramater() }
            }
        }
    }
    
    /// 解析文字差異比較
    /// - Parameters:
    ///   - differents: [DifferentType]?
    ///   - parameter: inout [String: Any]
    func parseDifferentTypes(_ differents: [DifferentType]?, parameter: inout [String: Any]) {
        
        guard let differents = differents else { return }
        
        differents.forEach { different in
            
            switch different {
            case .diffCharLevel(let isEnable): parameter["diffCharLevel"] = isEnable
            case .diffContextLines(let lines): parameter["diffContextLines"] = lines
            case .diffEnable(let isEnable): parameter["diffEnable"] = isEnable
            case .diffIgnoreCase(let isIgnore): parameter["diffIgnoreCase"] = isIgnore
            case .diffIgnoreWhiteSpaces(let isEnable): parameter["diffIgnoreWhiteSpaces"] = isEnable
            case .diffTemplate(let template): parameter["diffTemplate"] = template.rawValue
            }
        }
    }
    
    /// 解析文本整理
    /// - Parameters:
    ///   - texts: [TextType]?
    ///   - parameter: inout [String: Any]
    func parseTextTypes(_ texts: [TextType]?, parameter: inout [String: Any]) {
        
        guard let texts = texts else { return }
        
        texts.forEach { text in
            
            switch text {
            case .cleanUpText(let isCleanUp): parameter["cleanUpText"] = isCleanUp
            case .ensureNewlineAtEof(let isEnsure): parameter["ensureNewlineAtEof"] = isEnsure
            case .translateTabsToSpaces(let spaces): parameter["translateTabsToSpaces"] = spaces
            case .trimTrailingWhiteSpaces(let isTrim): parameter["trimTrailingWhiteSpaces"] = isTrim
            case .unifyLeadingHyphen(let isUnify): parameter["unifyLeadingHyphen"] = isUnify
            }
        }
    }
    
    /// 日文的處理策略
    /// - Parameters:
    ///   - strategies: [JapaneseConversionStrategy]?
    ///   - parameter: inout [String: Any]
    func parseConversionStrategies(_ strategies: [JapaneseConversionStrategy]?, parameter: inout [String: Any]) {
        
        guard let strategies = strategies else { return }
        
        strategies.forEach { strategy in
            
            switch strategy {
            case .style(let style): parameter["jpStyleConversionStrategy"] = style.rawValue
            case .text(let text): parameter["jpTextConversionStrategy"] = text.rawValue
            }
        }
    }
}

