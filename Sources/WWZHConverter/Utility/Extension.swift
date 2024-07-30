//
//  Extension.swift
//  WWZHConverter
//
//  Created by William.Weng on 2024/7/22.
//

import Foundation

// MARK: - Dictionary (function)
extension Dictionary {
    
    /// Dictionary => JSON Data
    /// - ["name":"William"] => {"name":"William"} => 7b226e616d65223a2257696c6c69616d227d
    /// - Parameter options: JSONSerialization.WritingOptions
    /// - Returns: Data?
    func _jsonData(options: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions()) -> Data? {
        return JSONSerialization._data(with: self, options: options)
    }
    
    /// Dictionary => JSON Object
    /// - Parameters:
    ///   - options: JSONSerialization.WritingOptions
    /// - Returns: Any?
    func _jsonObject(options: JSONSerialization.WritingOptions = .prettyPrinted) -> Any? {
        
        guard let data = self._jsonData(options: options),
              let jsonObject = data._jsonObject()
        else {
            return nil
        }
        
        return jsonObject
    }
    
    /// Dictionary => JSON String
    /// - Parameter options: JSONSerialization.WritingOptions
    /// - Returns: String?
    func _jsonString(options: JSONSerialization.WritingOptions = .prettyPrinted) -> String? {
        
        guard let data = self._jsonData(options: options),
              let jsonString = data._string(using: .utf8)
        else {
            return nil
        }
        
        return jsonString
    }
    
    /// Dictionary => Key1=Value1&Key2=Value2
    /// - Parameter separator: 分隔號
    /// - Returns: String
    func _queryString(separator: String = "&") -> String {
        
        var string = ""
        var array: [String] = []
        
        for (key, value) in self { array.append("\(key)=\(value)") }
        string = array.joined(separator: separator)
        
        return string
    }
}

// MARK: - Dictionary (function)
extension Dictionary where Self.Key == String, Self.Value == String? {
    
    /// [將[String: String?] => [URLQueryItem]](https://medium.com/@jerrywang0420/urlsession-教學-swift-3-ios-part-2-a17b2d4cc056)
    /// - ["name": "William.Weng", "github": "https://william-weng.github.io/"] => ?name=William.Weng&github=https://william-weng.github.io/
    /// - Returns: [URLQueryItem]
    func _queryItems() -> [URLQueryItem]? {
        
        if self.isEmpty { return nil }
        
        var queryItems: [URLQueryItem] = []

        for (key, value) in self {
            
            guard let value = value else { continue }
            
            let queryItem = URLQueryItem(name: key, value: value)
            queryItems.append(queryItem)
        }
        
        return queryItems
    }
}

// MARK: - JSONSerialization (static function)
extension JSONSerialization {
    
    /// [JSONObject => JSON Data](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/利用-jsonserialization-印出美美縮排的-json-308c93b51643)
    /// - ["name":"William"] => {"name":"William"} => 7b226e616d65223a2257696c6c69616d227d
    /// - Parameters:
    ///   - object: Any
    ///   - options: JSONSerialization.WritingOptions
    /// - Returns: Data?
    static func _data(with object: Any, options: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions()) -> Data? {
        
        guard JSONSerialization.isValidJSONObject(object),
              let data = try? JSONSerialization.data(withJSONObject: object, options: options)
        else {
            return nil
        }
        
        return data
    }
}

// MARK: - Data
extension Data {
    
    /// [Data => JSON](https://blog.zhgchg.li/現實使用-codable-上遇到的-decode-問題場景總匯-下-cb00b1977537)
    /// - 7b2268747470223a2022626f6479227d => {"http": "body"}
    /// - Returns: Any?
    func _jsonObject(options: JSONSerialization.ReadingOptions = .allowFragments) -> Any? {
        let json = try? JSONSerialization.jsonObject(with: self, options: options)
        return json
    }
    
    /// Data => 字串
    /// - Parameter encoding: 字元編碼
    /// - Returns: String?
    func _string(using encoding: String.Encoding = .utf8) -> String? {
        return String(data: self, encoding: encoding)
    }
}
