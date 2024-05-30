//
//  Player.swift
//  GeminiTicTacToe
//
//  Created by Anup D'Souza on 28/05/24.
//  🕸️ https://www.anupdsouza.com
//  🔗 https://twitter.com/swift_odyssey
//  👨🏻‍💻 https://github.com/anupdsouza
//  ☕️ https://www.buymeacoffee.com/anupdsouza
//

import Foundation

enum Player {
    case human
    case ai
    case computer
}

extension Player {
    var icon: String {
        switch self {
        case .human: return "👤"
        case .ai: return "gemini"
        case .computer: return "🤖"
        }
    }
}
