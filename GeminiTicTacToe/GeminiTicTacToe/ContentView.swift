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
    private var columns = [GridItem](repeating: GridItem(.flexible()), count: 3)
    private let spacing: CGFloat = 20
    @State private var turns = [Turn?](repeating: nil, count: 9)
    @State private var opacities = [Double](repeating: 1.0, count: 9)
    @State private var timers = [Timer?](repeating: nil, count: 9)
    @State private var currentPlayer: Player = .human
    @State private var vacantPositions: [Int] = []

    var body: some View {
        VStack {
            Spacer()
            GeometryReader(content: { geometry in
                LazyVGrid(columns: columns, spacing: spacing, content: {
                    ForEach(0..<9) { index in
                        MarkerItemView(mark: turns[index]?.mark ?? "")
                            .frame(width: geometry.size.width/3 - spacing,
                                   height: geometry.size.width/3 - spacing)
                            .opacity(turns[index] == nil ? opacities[index] : 1)
                            .onTapGesture {
                                if isValidTurn(position: index) {
                                    updateTurn(position: index)
                                    // TODO: check if player won, end game
                                    changePlayer()
                                    
                                    // Start flashing during AI turn
                                    startFlashing()
                                    
                                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 5) {
                                        let aiTurnPosition = aiTurn()
                                        
                                        stopFlashing()
                                        
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
        turns[position] == nil
    }
    
    private func updateTurn(position: Int) {
        turns[position] = .init(player: currentPlayer, position: position)
        updateVacantPositions()
    }

    private func changePlayer() {
        currentPlayer = currentPlayer == .ai ? .human : .ai
    }

    private func updateVacantPositions() {
        vacantPositions = turns.enumerated().compactMap { index, element in
            element == nil ? index : nil
        }
    }
    
    private func aiTurn() -> Int {
        vacantPositions.randomElement()!
    }
    
    private func startFlashing() {
        stopFlashing()
        
        for index in vacantPositions {
            timers[index] = Timer.scheduledTimer(withTimeInterval: Double.random(in: 0.3...0.6), repeats: true) { timer in
                withAnimation {
                    opacities[index] = (opacities[index] == 0.5) ? 1 : 0.5
                }
            }
        }
    }
    
    private func stopFlashing() {
        for index in timers.indices {
            timers[index]?.invalidate()
            timers[index] = nil
            opacities[index] = 1
        }
    }
    
    private func resetGame() {
        // TODO: reset states
    }
}

#Preview {
    ContentView()
}
