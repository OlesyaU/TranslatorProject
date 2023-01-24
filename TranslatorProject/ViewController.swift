//
//  ViewController.swift
//  TranslatorProject
//
//  Created by Олеся on 21.01.2023.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var forTranslateTextView: UITextView!
    @IBOutlet weak var translatedTextView: UITextView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var translateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden = true
        if forTranslateTextView.isFirstResponder {
            forTranslateTextView.text = ""
            translatedTextView.text = ""
        }
    }

    @IBAction func translateButtonAction(_ sender: Any) {
        indicator.isHidden = false
        indicator.startAnimating()
        translateButton.isEnabled =  false
        translatedTextView.text = "Magic is here ..."
        Model().translate(text: forTranslateTextView.text, toLanguage: "ru") { [weak self] translatedText, errorFunc in
            if let translatedText {
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()
                    self?.translatedTextView.text = translatedText
                    self?.translatedTextView.textColor = .black
                    self?.translateButton.isEnabled = true
                }
            } else {
                print(errorFunc)
                self?.translatedTextView.text = "Something wrong..."
                self?.translatedTextView.textColor = .red
            }
        }
        translatedTextView.textColor = .secondaryLabel
    }
}

//доделать ещё выбор языка  для пользователя через  UIMenu
