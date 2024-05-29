//
//  MarkerItemView.swift
//  GeminiTicTacToe
//
//  Created by Anup D'Souza on 14/05/24.
//  🕸️ https://www.anupdsouza.com
//  🔗 https://twitter.com/swift_odyssey
//  👨🏻‍💻 https://github.com/anupdsouza
//  ☕️ https://www.buymeacoffee.com/anupdsouza
//

import SwiftUI

struct MarkerItemView: View {
    let turn: Turn?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.2))
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.yellow, lineWidth: 2.0)
                }
                .overlay(alignment: .bottomTrailing, content: {
                    aiSymbol
                })

            if let turn {
                Image(systemName: turn.mark)
                    .resizable()
                    .bold()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.black)
                    .offset(x: 2, y: 1)
                    .opacity(0.5)
                Image(systemName: turn.mark)
                    .resizable()
                    .bold()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(turn.markColor)
            }
        }
    }
    
    @ViewBuilder var aiSymbol: some View {
        Group {
            if let turn {
                if turn.player == .ai {
                    Image(.gemini)
                        .resizable()
                        .frame(width: 15, height: 15)
                } else if turn.player == .computer {
                    Text("🤖")
                        .font(.footnote)
                }
            }
        }
        .padding([.bottom, .trailing], 5)
    }
}

#Preview {
    MarkerItemView(turn: nil)
}
