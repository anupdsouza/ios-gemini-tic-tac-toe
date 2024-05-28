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
    private let fontName = "Chalkboard SE Bold"
    @State private var turns = [Turn?](repeating: nil, count: 9)
    @State private var vacantPositions: [Int] = []
    @State private var currentPlayer: Player = .human
    @State private var winningPlayer: Player?
    @State private var isGameOver = false
    @State private var opacities = [Double](repeating: 1.0, count: 9)
    @State private var timers = [Timer?](repeating: nil, count: 9)
    

    var body: some View {
        VStack {
            Text("Tic Tac Toe")
                .font(.custom(fontName, fixedSize: 50))
                .padding(.bottom, 20)
            
            if isGameOver {
                if winningPlayer != nil {
                    Text("\(currentPlayerIcon()) Wins !")
                } else {
                    Text("It's a Draw !")
                }
            } else {
                Text("Current turn: \(currentPlayerIcon())")
            }

            GeometryReader(content: { geometry in
                LazyVGrid(columns: columns, spacing: spacing, content: {
                    ForEach(0..<9) { index in
                        
                        let mark = turns[index]?.mark ?? ""
                        let markColor = turns[index]?.player == .ai ? Color.red : Color.green
                        
                        MarkerItemView(mark: mark,
                                       color: markColor)
                        .frame(width: geometry.size.width/3 - spacing,
                               height: geometry.size.width/3 - spacing)
                        .opacity(turns[index] == nil ? opacities[index] : 1)
                        .onTapGesture {
                            if isValidTurn(position: index) {
                                
                                updateTurn(position: index)
                                
                                checkForResult()
                                
                                if isGameOver { return }
                                
                                changePlayer()
                                
                                startFlashing()
                                
                                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                                    
                                    stopFlashing()
                                    
                                    updateTurn(position: aiTurn())
                                    
                                    checkForResult()
                                    
                                    if isGameOver { return }
                                    
                                    changePlayer()
                                }
                            }
                        }
                    }
                })
                .disabled(currentPlayer == .ai || isGameOver)
                .padding()
            })
            
            if isGameOver {
                Button {
                    resetGame()
                } label: {
                    Text("Play again")
                        .font(.custom(fontName, fixedSize: 20))
                        .foregroundStyle(.black)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
        }
        .font(.custom(fontName, fixedSize: 20))
        .foregroundStyle(.white)
        .background {
            Color.black.ignoresSafeArea()
        }
    }
    
    private func currentPlayerIcon() -> String {
        currentPlayer == .ai ? "🤖" : "👤"
    }

    private func isValidTurn(position: Int) -> Bool {
        turns[position] == nil && !isGameOver
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
    
    private func checkForResult() {
        let winPatterns: [[Int]] = [
            [0, 1, 2], // top row
            [3, 4, 5], // middle row
            [6, 7, 8], // bottom row
            [0, 3, 6], // left column
            [1, 4, 7], // middle column
            [2, 5, 8], // right column
            [0, 4, 8], // top-left to bottom-right diagonal
            [2, 4, 6]  // top-right to bottom-left diagonal
        ]
        
        for pattern in winPatterns {
            let (a, b, c) = (pattern[0], pattern[1], pattern[2])
            if let firstPlayer = turns[a]?.player,
               turns[b]?.player == firstPlayer,
               turns[c]?.player == firstPlayer {
                winningPlayer = currentPlayer
                isGameOver = true
                return
            }
        }
        
        if turns.allSatisfy({ $0 != nil }) {
            // Draw
            isGameOver = true
        }
    }
    
    private func resetGame() {
        currentPlayer = .human
        winningPlayer = nil
        turns = [Turn?](repeating: nil, count: 9)
        isGameOver = false
    }
}

#Preview {
    ContentView()
}
