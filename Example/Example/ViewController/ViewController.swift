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
    
    @IBAction func convertToChain(_ sender: UIBarButtonItem) {
        
        convert(text: twLabel.text, type: .China) { text in
            Task { await MainActor.run { self.cnLabel.text = text }}
        }
    }
    
    @IBAction func convertToHK(_ sender: UIBarButtonItem) {
        
        convert(text: twLabel.text, type: .Hongkong) { text in
            Task { await MainActor.run { self.cnLabel.text = text }}
        }
    }
    
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
