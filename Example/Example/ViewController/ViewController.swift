//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2024/7/22.
//

import UIKit
import WWZHConverter

// MARK: - ViewController
final class ViewController: UIViewController {

    @IBOutlet weak var twLabel: UILabel!
    @IBOutlet weak var cnLabel: UILabel!
    @IBOutlet weak var hkLabel: UILabel!
    
    /// 轉成簡體中文用語
    /// - Parameter sender: UIBarButtonItem
    @IBAction func convertToChain(_ sender: UIBarButtonItem) {
        
        convert(text: twLabel.text, type: .China) { text in
            Task { await MainActor.run { self.cnLabel.text = text }}
        }
    }
    
    /// 轉成香港中文用語
    /// - Parameter sender: UIBarButtonItem
    @IBAction func convertToHK(_ sender: UIBarButtonItem) {
        
        convert(text: twLabel.text, type: .Hongkong) { text in
            Task { await MainActor.run { self.hkLabel.text = text }}
        }
    }
}

// MARK: - 小工具
private extension ViewController {
    
    /// 文字用語轉換
    /// - Parameters:
    ///   - text: String?
    ///   - type: WWZHConverter.ConverterType
    ///   - message: (String) -> Void
    func convert(text: String?, type: WWZHConverter.ConverterType, message: @escaping (String) -> Void) {
        
        guard let text = text else { return }
        
        WWZHConverter.shared.convertText(text, to: type) { result in
            
            switch result {
            case .failure(let error): message("\(error)")
            case .success(let text): message("\(text)")
            }
        }
    }
}
