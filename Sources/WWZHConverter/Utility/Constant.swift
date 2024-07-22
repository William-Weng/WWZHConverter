//
//  Constant.swift
//  WWZHConverter
//
//  Created by William.Weng on 2024/7/22.
//

import UIKit

// MARK: - Constant
class Constant {
    
    private static let Host = "https://api.zhconvert.org/convert"
    
    enum API {
        
        case serviceInfo    // 系統資訊
        case convert        // 文字轉換
        
        func url() -> String {
            switch self {
            case .serviceInfo: return "\(Host)/service-info"
            case .convert: return "\(Host)/convert"
            }
        }
    }
}
