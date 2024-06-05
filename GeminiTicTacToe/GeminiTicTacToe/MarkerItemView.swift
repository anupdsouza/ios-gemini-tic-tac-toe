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
                .fill(.tile)
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.yellow, lineWidth: 2.0)
                }
                .overlay(alignment: .bottomTrailing) {
                    aiSymbol
                        .padding([.bottom, .trailing], 5)
                }
            
            if let turn {
                markView(turn.mark)
                    .foregroundStyle(Color.black)
                    .offset(x: 2, y: 1)
                    .opacity(0.5)
                markView(turn.mark)
                    .foregroundStyle(turn.markColor)
            }
        }
    }
    
    @ViewBuilder private var aiSymbol: some View {
        if let turn {
            switch turn.player {
            case .ai:
                Image(.gemini)
                    .resizable()
                    .frame(width: 15, height: 15)
            case .computer:
                Text("🤖")
                    .font(.footnote)
            case .human:
                EmptyView()
            }
        }
    }
    
    @ViewBuilder private func markView(_ image: String) -> some View {
        Image(systemName: image)
            .resizable()
            .bold()
            .frame(width: 40, height: 40)
    }
}

#Preview {
    MarkerItemView(turn: nil)
}
