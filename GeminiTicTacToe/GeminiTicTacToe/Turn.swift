//
//  Turn.swift
//  GeminiTicTacToe
//
//  Created by Anup D'Souza on 28/05/24.
//  🕸️ https://www.anupdsouza.com
//  🔗 https://twitter.com/swift_odyssey
//  👨🏻‍💻 https://github.com/anupdsouza
//  ☕️ https://www.buymeacoffee.com/anupdsouza
//

import Foundation
import SwiftUI

struct Turn {
    let player: Player
    let position: Int
    var mark: String {
        player == .human ? "xmark" : "circle"
    }
    var markColor: Color {
        player == .human ? .green : .red
    }
}
