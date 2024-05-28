//
//  ContentView.swift
//  GeminiTicTacToe
//
//  Created by Anup D'Souza on 10/05/24.
//  🕸️ https://www.anupdsouza.com
//  🔗 https://twitter.com/swift_odyssey
//  👨🏻‍💻 https://github.com/anupdsouza
//  ☕️ https://www.buymeacoffee.com/anupdsouza
//

import SwiftUI

struct ContentView: View {
    private var columns = [GridItem].init(repeating: GridItem(.flexible()), count: 3)
    private let spacing: CGFloat = 20
    @State private var turns = [Turn?].init(repeating: nil, count: 9)
    @State private var currentPlayer: Player = .human

    var body: some View {
        VStack {
            Spacer()
            GeometryReader(content: { geometry in
                LazyVGrid(columns: columns, spacing: spacing, content: {
                    ForEach(0..<9) { index in
                        MarkerItemView(mark: turns[index]?.mark ?? "")
                            .frame(width: geometry.size.width/3 - spacing,
                                   height: geometry.size.width/3 - spacing)
                            .onTapGesture {
                                if isValidTurn(position: index) {
                                    updateTurn(position: index)
                                    // TODO: check if player won, end game
                                    changePlayer()
                                    
                                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 5) {
                                        guard let aiTurnPosition = aiTurn() else {
                                            return
                                        }
                                        updateTurn(position: aiTurnPosition)
                                        // TODO: check if ai won, end game
                                        changePlayer()
                                    }
                                }
                            }
                    }
                })
                .disabled(currentPlayer == .ai)
                .padding()
            })
            Spacer()
        }
    }
    
    private func isValidTurn(position: Int) -> Bool {
        !turns.contains { $0?.position == position }
    }
    
    private func updateTurn(position: Int) {
        turns[position] = .init(player: currentPlayer, position: position)
    }

    private func changePlayer() {
        currentPlayer = currentPlayer == .ai ? .human : .ai
    }
    
    private func aiTurn() -> Int? {
        let openPositions = turns.enumerated().compactMap { index, element in
            element == nil ? index : nil
        }
        return openPositions.randomElement()
    }
}

#Preview {
    ContentView()
}
