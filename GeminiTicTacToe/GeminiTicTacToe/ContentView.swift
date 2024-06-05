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
    private let columns = Array(repeating: GridItem(.flexible()), count: 3)
    private let spacing: CGFloat = 20
    private let fontName = "Chalkboard SE Bold"
    @State private var turns = [Turn?](repeating: nil, count: 9)
    @State private var vacantPositions = [Int]()
    @State private var currentPlayer: Player = .human
    @State private var winningPlayer: Player?
    @State private var isGameOver = false
    @State private var opacities = Array(repeating: 1.0, count: 9)
    @State private var timers = [Timer?](repeating: nil, count: 9)
    @State private var gameService = GameService()

    var body: some View {
        VStack {
            titleView

            turnOrResultView

            gameGridView

            if isGameOver {
                playAgainView
            }
        }
        .font(.custom(fontName, fixedSize: 20))
        .foregroundStyle(.white)
        .background(Color.black.ignoresSafeArea())
        .onChange(of: gameService.loadingAiTurn) { _, _ in
            gameService.loadingAiTurn ? startFlashing() : stopFlashing()
        }
        .onChange(of: gameService.turnPosition) { _, _ in
            guard let turnPosition = gameService.turnPosition else { return }
            currentPlayer = gameService.receivedAiTurn ? currentPlayer : .computer
            updateTurn(position: turnPosition)
            checkForResult()
            if !isGameOver { changePlayer() }
        }
        .onAppear { updateVacantPositions() }
    }

    private var titleView: some View {
        Text("Tic Tac Toe")
            .font(.custom(fontName, fixedSize: 50))
            .padding(.bottom, 20)
    }

    private var turnOrResultView: some View {
        Group {
            if isGameOver {
                if let winner = winningPlayer {
                    if winner == .ai {
                        HStack {
                            Image(.gemini)
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("Wins!").foregroundStyle(.yellow)
                        }
                    } else {
                        Text("\(winner.icon) Wins!").foregroundStyle(.yellow)
                    }
                } else {
                    Text("It's a Draw!")
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

    private var gameGridView: some View {
        GeometryReader { geometry in
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(0..<9) { index in
                    MarkerItemView(turn: turns[index])
                        .frame(width: geometry.size.width / 3 - spacing,
                               height: geometry.size.width / 3 - spacing)
                        .opacity(turns[index] == nil ? opacities[index] : 1)
                        .onTapGesture {
                            Task { await handleTap(at: index) }
                        }
                }
            }
            .disabled(currentPlayer == .ai || isGameOver)
            .padding()
        }
    }

    private var playAgainView: some View {
        Button {
            resetGame()
        } label: {
            Text("Play again")
                .font(.custom(fontName, fixedSize: 20))
                .foregroundStyle(.black)
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
        .padding(.top, 20)
    }

    @MainActor
    private func handleTap(at index: Int) {
        guard isValidTurn(position: index) else { return }
        updateTurn(position: index)
        checkForResult()
        if isGameOver { return }
        changePlayer()

        gameService.vacantPositions = vacantPositions
        let (humanIndices, aiIndices) = getTurnIndices()
        gameService.xPositions = humanIndices
        gameService.oPositions = aiIndices
        gameService.loadAiTurn()
    }

    private func isValidTurn(position: Int) -> Bool {
        turns[position] == nil && !isGameOver
    }

    private func updateTurn(position: Int) {
        turns[position] = .init(player: currentPlayer, position: position)
        updateVacantPositions()
    }

    private func changePlayer() {
        currentPlayer = currentPlayer == .human ? .ai : .human
    }

    private func updateVacantPositions() {
        vacantPositions = turns.enumerated().compactMap { $0.element == nil ? $0.offset : nil }
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
        for timer in timers { timer?.invalidate() }
        timers = [Timer?](repeating: nil, count: 9)
        opacities = [Double](repeating: 1.0, count: 9)
    }

    private func checkForResult() {
        let winPatterns: [[Int]] = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],
            [0, 3, 6], [1, 4, 7], [2, 5, 8],
            [0, 4, 8], [2, 4, 6]
        ]

        for pattern in winPatterns {
            let (a, b, c) = (pattern[0], pattern[1], pattern[2])
            if let player = turns[a]?.player,
               turns[b]?.player == player && turns[c]?.player == player {
                winningPlayer = player
                isGameOver = true
                return
            }
        }

        if turns.allSatisfy({ $0 != nil }) { isGameOver = true }
    }

    private func getTurnIndices() -> (humanIndices: [Int], aiIndices: [Int]) {
        turns.enumerated().reduce(into: ([Int](), [Int]())) { result, item in
            if let turn = item.element {
                if turn.player == .human {
                    result.0.append(item.offset)
                } else {
                    result.1.append(item.offset)
                }
            }
        }
    }

    private func resetGame() {
        currentPlayer = .human
        winningPlayer = nil
        turns = [Turn?](repeating: nil, count: 9)
        isGameOver = false
        updateVacantPositions()
        gameService.reset()
    }
}

#Preview {
    ContentView()
}
