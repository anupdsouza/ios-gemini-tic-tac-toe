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
    @State private var gameService = GameService()

    var body: some View {
        VStack {
            
            titleView()
            
            turnOrResultView()
            
            GeometryReader(content: { geometry in
                LazyVGrid(columns: columns, spacing: spacing, content: {
                    ForEach(0..<9) { index in
                        MarkerItemView(turn: turns[index])
                            .frame(width: geometry.size.width / 3 - spacing,
                                   height: geometry.size.width / 3 - spacing)
                            .opacity(turns[index] == nil ? opacities[index] : 1)
                            .onTapGesture {
                                handleTap(at: index)
                            }
                    }
                })
                .disabled(currentPlayer == .ai || isGameOver)
                .padding()
            })

            if isGameOver {
                playAgainView()
            }
        }
        .font(.custom(fontName, fixedSize: 20))
        .foregroundStyle(.white)
        .background {
            Color.black.ignoresSafeArea()
        }
        .onChange(of: gameService.loadingAiTurn) { _, _ in
            if gameService.loadingAiTurn {
                startFlashing()
            } else {
                stopFlashing()
            }
        }
        .onChange(of: gameService.turnPosition) { _, _ in
            if let turnPosition = gameService.turnPosition {
                if gameService.receivedAiTurn == false {
                    currentPlayer = .computer
                }
                updateTurn(position: turnPosition)
                checkForResult()
                if !isGameOver {
                    changePlayer()
                }
            }
        }
        .onAppear {
            updateVacantPositions()
        }
    }

    @ViewBuilder private func titleView() -> some View {
        Text("Tic Tac Toe")
            .font(.custom(fontName, fixedSize: 50))
            .padding(.bottom, 20)
    }

    @ViewBuilder private func turnOrResultView() -> some View {
        Group {
            if isGameOver {
                if let winner = winningPlayer {
                    if winner == .ai {
                        HStack {
                            Image(.gemini)
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("Wins!")
                                .foregroundStyle(.yellow)
                        }
                    } else {
                        Text("\(winner.icon) Wins!")
                            .foregroundStyle(.yellow)
                    }
                } else {
                    Text("It's a Draw !")
                }
            } else {
                if currentPlayer == .ai {
                    HStack {
                        Text("Current turn:")
                        Image(.gemini)
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                } else {
                    Text("Current turn: \(currentPlayer.icon)")
                }
            }
        }
        .frame(height: 50)
    }

    @ViewBuilder private func playAgainView() -> some View {
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

    private func handleTap(at index: Int) {
        if isValidTurn(position: index) {
            updateTurn(position: index)
            checkForResult()

            if isGameOver { return }

            changePlayer()

            gameService.vacantPositions = vacantPositions
            let (humanIndices, aiIndices) = getTurnIndices()
            gameService.xPositions = humanIndices
            gameService.oPositions = aiIndices

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                gameService.loadAiTurn()
            }
        }
    }

    private func isValidTurn(position: Int) -> Bool {
        turns[position] == nil && !isGameOver
    }

    private func updateTurn(position: Int) {
        turns[position] = .init(player: currentPlayer, position: position)
        updateVacantPositions()
    }

    private func changePlayer() {
        currentPlayer = (currentPlayer == .ai || currentPlayer == .computer) ? .human : .ai
    }

    private func updateVacantPositions() {
        vacantPositions = turns.enumerated().compactMap { index, element in
            element == nil ? index : nil
        }
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

//        for pattern in winPatterns {
//            let (firstIndex, secondIndex, thirdIndex) = (pattern[0], pattern[1], pattern[2])
//            if let firstPlayer = turns[firstIndex]?.player,
//               turns[secondIndex]?.player == firstPlayer,
//               turns[thirdIndex]?.player == firstPlayer {
//                winningPlayer = firstPlayer
//                isGameOver = true
//                return
//            }
//        }
        for pattern in winPatterns {
            let (firstIndex, secondIndex, thirdIndex) = (pattern[0], pattern[1], pattern[2])
            if let firstPlayer = turns[firstIndex]?.player,
               (turns[secondIndex]?.player == firstPlayer || (firstPlayer == .ai && turns[secondIndex]?.player == .computer) || (firstPlayer == .computer && turns[secondIndex]?.player == .ai)),
               (turns[thirdIndex]?.player == firstPlayer || (firstPlayer == .ai && turns[thirdIndex]?.player == .computer) || (firstPlayer == .computer && turns[thirdIndex]?.player == .ai)) {
                winningPlayer = firstPlayer
                isGameOver = true
                return
            }
        }

        if turns.allSatisfy({ $0 != nil }) {
            isGameOver = true // Draw
        }
    }
    
    private func getTurnIndices() -> (humanIndices: [Int], aiIndices: [Int]) {
        var humanIndices = [Int]()
        var aiIndices = [Int]()
        for (index, turn) in turns.enumerated() {
            if let turn = turn {
                if turn.player == .human {
                    humanIndices.append(index)
                } else if turn.player == .ai || turn.player == .computer {
                    aiIndices.append(index)
                }
            }
        }
        return (humanIndices, aiIndices)
    }

    private func resetGame() {
        currentPlayer = .human
        winningPlayer = nil
        turns = [Turn?](repeating: nil, count: 9)
        isGameOver = false
        updateVacantPositions()
    }
}

#Preview {
    ContentView()
}
