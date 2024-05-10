//
//  APIKey.swift
//  GeminiTicTacToe
//
//  Created by Anup D'Souza on 10/05/24.
//  🕸️ https://www.anupdsouza.com
//  🔗 https://twitter.com/swift_odyssey
//  👨🏻‍💻 https://github.com/anupdsouza
//  ☕️ https://www.buymeacoffee.com/anupdsouza
//

import Foundation

enum APIKey {
    // Fetch the API keys from `GenerativeAI-Info.plist`
    static var gemini: String {
        configValue(key: "GEMINI_API_KEY",
                    setupErrorMessage: "Follow the instructions at https://ai.google.dev/tutorials/setup to get an API key.")
    }

    static private var configDict: NSDictionary? {
        guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist")
        else {
            fatalError("Couldn't find file 'GenerativeAI-Info.plist'.")
        }
        return NSDictionary(contentsOfFile: filePath)
    }

    static private func configValue(key: String, setupErrorMessage: String) -> String {
        guard let value = configDict?.object(forKey: key) as? String else {
            fatalError("Couldn't find key: \(key) in 'GenerativeAI-Info.plist'.")
        }
        if value.starts(with: "_") || value.isEmpty {
            fatalError(setupErrorMessage)
        }
        return value
    }
}
