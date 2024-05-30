//
//  GameService.swift
//  GeminiTicTacToe
//
//  Created by Anup D'Souza on 29/05/24.
//  🕸️ https://www.anupdsouza.com
//  🔗 https://twitter.com/swift_odyssey
//  👨🏻‍💻 https://github.com/anupdsouza
//  ☕️ https://www.buymeacoffee.com/anupdsouza
//

import Foundation
import SwiftUI
import GoogleGenerativeAI

@Observable class GameService {
    private let model: GenerativeModel
    private var chat: Chat?
    private(set) var turnPosition: Int?
    private(set) var loadingAiTurn = false
    private(set) var receivedAiTurn = false
    private var aiTimer: Timer?
    var vacantPositions: [Int] = []
    var xPositions: [Int] = []
    var oPositions: [Int] = []
    private var startPrompt = """
                               ## Introduction:
                               We are playing a game of tic-tac-toe in a 3x3 grid numbered with positions 0 to 8.
                               Position 0 is the top-left square, 4 is the center, and 8 is the bottom-right square.
                               I will place X & you will place O.
                               You win either by getting three Xs or Os in a row, column, or diagonally.
                               We will continue taking turns until there is a winner or the board is filled (a tie).
                               You will indicate your move by telling me the number (between 0 and 8) of the square you want to place your O.
                               Before each turn, you will be provided with the positions of X's & O's in the grid as an array of integers.
                               Always recall the winning patterns for the grid and compare against the positions of X's & O's before making a choice.
                                                              
                               ## Rules you must follow:
                               Rule #1. Inspect the grid for the position of X's and O's before deciding on a square.
                               Rule #2. If you are in a position to win, you MUST choose to win.
                               Rule #3. If I am in a position to win on my next turn, you must try and block my move.
                               Rule #4. If you can either WIN OR BLOCK me during your turn, you should choose to win.

                               Reply ONLY with a number of the square you choose to place an O. Do not provide any reasoning behind your choice.
                               """

    init() {
        model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.gemini)
        chat = model.startChat()
    }

    @MainActor
    func loadAiTurn() {
        loadingAiTurn = true
        receivedAiTurn = false
        turnPosition = nil

        let task = Task {
            do {
                
                var aiPrompt = ""
                if !startPrompt.isEmpty {
                    aiPrompt = startPrompt
                    startPrompt = ""
                }
                
                // Add 'X' positions in the prompt
                aiPrompt += "\nRemember the rules of tic tac toe."
                
                if !xPositions.isEmpty {
                    if xPositions.count == 1 {
                        aiPrompt += "\nThis is a new game."
                    }
                    
                    aiPrompt += "\nX position(s) in the grid: [\(xPositions.map{ String($0) }.joined(separator: ","))]."
                }
                
                // Add 'O' positions in the prompt
                if !oPositions.isEmpty {
                    aiPrompt += "\nO position(s) in the grid: [\(oPositions.map{ String($0) }.joined(separator: ","))]."
                }
                
                print("##################################################")
                print("PROMPT :\n\(aiPrompt)")
                print("##################################################")
                
                let response = try await chat?.sendMessage(aiPrompt)
                print("AI response \(response?.text ?? "empty")")
                guard let text = response?.text?.trimmingCharacters(in: .whitespacesAndNewlines), let position = Int(text) else {
                    throw NSError(domain: "Invalid response", code: -1, userInfo: nil)
                }
                
                withAnimation {
                    aiTimer?.invalidate()
                    loadingAiTurn = false
                    receivedAiTurn = true
                    turnPosition = position
                }
            } catch {
                
                print(error.localizedDescription)
                aiTimer?.invalidate()
                loadingAiTurn = false
                generateRandomAiTurn()
            }
        }

        aiTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { _ in
            task.cancel()
            self.generateRandomAiTurn()
        }
    }

    private func generateRandomAiTurn() {
        guard let randomPosition = vacantPositions.randomElement() else { return }
        turnPosition = randomPosition
    }
    
    func reset() {
        turnPosition = nil
        vacantPositions.removeAll()
    }
}

