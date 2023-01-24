//
//  Model.swift
//  TranslatorProject
//
//  Created by Олеся on 21.01.2023.
//

import Foundation
// для того, чтобы использовать JSON Encodable (закодировать наши данные для отправки и запроса)создадим структуру
struct Parameters: Encodable {
    var text: String
}

/*
 [
 {
 "detectedLanguage": {
 "language": "en",
 "score": 1
 },
 "translations": [
 {
 "text": "Мне бы очень хотелось несколько раз проехать на вашей машине по кварталу.",
 "to": "ru"
 }
 ]
 }
 ]
 */

struct DetectedLanguage: Decodable {
    var language: String
}

struct Translation: Decodable {
    var text: String
    var to: String
}

struct Answer: Decodable {
    var detectedLanguage: DetectedLanguage
    var translations: [Translation]
}

struct Model {
    func translate(text: String, toLanguage: String, completion: ((_ translatedText: String?, _ errorFunc: Error?)-> Void)?) {
        
        let headers = [
            "content-type": "application/json",
            "X-RapidAPI-Key": "faeee96b5cmsh1f02c9ad3ed5f6fp193e5djsn32e65654d822",
            "X-RapidAPI-Host": "microsoft-translator-text.p.rapidapi.com"
        ]
        //        тут две даты поскольку двумя вариантами запрос отправляем(кодируем дату)
        let postData = try! JSONEncoder().encode([Parameters(text: text)])
        //        let parameters = [["Text": text]] as [[String : Any]]
        //        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://microsoft-translator-text.p.rapidapi.com/translate?to%5B0%5D=\(toLanguage)&api-version=3.0&profanityAction=NoAction&textType=plain")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if let error {
                print(error.localizedDescription)
                completion?(nil, error)
                return
            }
            
            if (response as? HTTPURLResponse)?.statusCode != 200 {
                print("Status code != 200")
                completion?(nil, error)
                return
            }
            
            guard let data else {
                print("data = nil")
                completion?(nil, error)
                return
            }
            
            do {
                let answer = try JSONDecoder().decode([Answer].self, from: data)
                if let translationText = answer.first?.translations.first?.text {
                    completion?(translationText, nil)
                } else {
                    print("Json format Error")
                    completion?(nil, error)
                }
            } catch {
                print(data)
                print(error.localizedDescription)
                completion?(nil, error)
            }
            
        })
        dataTask.resume()
    }
}
