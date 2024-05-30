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

/*
 
 Play a game of tic-tac-toe with me in a 3x3 grid numbered 0-8.
 
 I will place X's & you will place O's. The first player to get three X's or O's either vertically, horizontally or diagonally in the 3x3 grid wins the game.
 
 */
@Observable class GameService {
    private let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.gemini)
    private(set) var turnPosition: Int?
    private(set) var loadingAiTurn = false
    private(set) var receivedAiTurn = false
    private var aiTimer: Timer?
    var vacantPositions: [Int] = []
    var xPositions: [Int] = []
    var oPositions: [Int] = []

    func loadAiTurn() {
        loadingAiTurn = true
        receivedAiTurn = false
        turnPosition = nil

        let task = Task {
            do {
                var aiPrompt = ""
                if oPositions.isEmpty {
                    // Starting the game, elaborate the rules.
                    aiPrompt = """
                    
                    We will play a game of Tic-Tac-Toe on a 3x3 grid numbered from 0 to 8.

                    I will play as "X" and U will play as "O".
                    I will go first.
                    0 is the top-left square, 4 is the center, and 8 is the bottom-right square.
                    After each turn, I will update the board and tell you where I placed my X's and where you have placed your O's.
                    We will continue taking turns until there is a winner (either by getting three Xs or Os in a row, column, or diagonally) or the board is filled (a tie).
                    You will indicate your move by telling me the number (between 0 and 8) of the square you want to place your O.
                    
                    
                    X's occupy position(s): [\(xPositions.map{ String($0) }.joined(separator: ","))] in the grid.
                    
                    Now, choose a position on the grid to place an O, reply ONLY with a number.
                    
                    """
                } else {
                    aiPrompt = """
                    
                    I have X's in position(s): [\(xPositions.map{ String($0) }.joined(separator: ","))] on the grid.
                    
                    You have O's in position(s): [\(oPositions.map{ String($0) }.joined(separator: ","))] on the grid."
                    
                    Now, choose a position on the grid to place an O, reply ONLY with a number.
                    
                    """
                }
                

                let response = try await model.generateContent(aiPrompt)
                guard let text = response.text?.trimmingCharacters(in: .whitespacesAndNewlines), let position = Int(text) else {
                    throw NSError(domain: "Invalid response", code: -1, userInfo: nil)
                }
                
                await MainActor.run {
                    withAnimation {
                        aiTimer?.invalidate()
                        loadingAiTurn = false
                        receivedAiTurn = true
                        turnPosition = position
                    }
                }
            } catch {
                
                print(error.localizedDescription)
                await MainActor.run {
                    aiTimer?.invalidate()
                    loadingAiTurn = false
                    generateRandomAiTurn()
                }
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

