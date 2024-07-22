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
    
    /// 能轉換的類型
    public enum ConverterType {
        
        case Simplified             // 簡體化
        case Traditional            // 繁體化
        case China                  // 中國化
        case Hongkong               // 香港化
        case Taiwan                 // 台灣化
        case Pinyin                 // 拼音化
        case Bopomofo               // 注音化
        case Mars                   // 火星文化
        case WikiSimplified         // 維基簡體化
        case WikiTraditional        // 維基繁體化
    }
    
    /// 自定義錯誤
    public enum ConvertError: Error {
        
        case httpCode(_ code: Int)  // HTTP狀態碼
        case jsonObject             // JSON轉換錯誤
        case unknown                // 未知錯誤
    }
    
    public static let shared = WWZHConverter()
            
    private init() {}
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
    ///   - result: (Result<String, Error>) -> Void
    func convertText(_ text: String, to converterType: ConverterType, result: @escaping (Result<String, Error>) -> Void) {
        
        convert(text: text, to: converterType) { convertResult in
            
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
    func convert(text: String, to converterType: ConverterType, result: @escaping (Result<Data?, Error>) -> Void) {
        
        let parameter: [String: Any] = [
            "text": text,
            "converter": "\(converterType)"
        ]
        
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
    
    /// 解析回傳的Http回應
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
}

