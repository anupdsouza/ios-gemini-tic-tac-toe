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
    private var startPrompt = """
                               ## Introduction:
                               We are playing a game of tic-tac-toe in a 3x3 grid numbered with positions 0 to 8.
                               Position 0 is the top-left square, 4 is the center, and 8 is the bottom-right square.
                               I will place X & you will place O.
                               You win either by getting three Xs or Os in a row, column, or diagonally.
                               We will continue taking turns until there is a winner or the board is filled (a tie).
                               You will indicate your move by telling me the number (between 0 and 8) of the square you want to place your O.
                               Before each turn, you will be provided with the positions of X's & O's in the grid as an array of integers.
                               Check the existing positions of X's & O's in the 3x3 grid with the winning positions before making a choice.
                                                              
                               ## Rules you must follow:
                               Rule #1. Inspect the grid for the position of X's and O's before deciding on a square.
                               Rule #2. If you are in a position to win, you MUST choose to win.
                               Rule #3. If I am in a position to win on my next turn, you must try and block my move.
                               Rule #4. If you can either WIN OR BLOCK me during your turn, you should choose to win.
                               """
    var vacantPositions: [Int] = []
    var xPositions: [Int] = []
    var oPositions: [Int] = []

    private var aiPrompt: String {
        var prompt = ""
        if !startPrompt.isEmpty {
            prompt = startPrompt
            startPrompt = ""
        }
        prompt += "\nRecall the rules of tic tac toe and the winning positions for a 3x3 grid."
        
        if !xPositions.isEmpty {
            if xPositions.count == 1 {
                prompt += "\nThis is a new game."
            }
            prompt += "\nX position(s) in the grid are: [\(xPositions.map { String($0) }.joined(separator: ","))]."
        }

        if !oPositions.isEmpty {
            prompt += "\nO position(s) in the grid are: [\(oPositions.map { String($0) }.joined(separator: ","))]."
        }
        
        prompt += "\nReply ONLY with a number between 0 to 8 of the grid square you choose to place an O. Do not provide any explanation behind your choice."

        return prompt
    }

    init() {
        model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.gemini)
        chat = model.startChat()
    }

    @MainActor
    func loadAiTurn() {
        loadingAiTurn = true
        receivedAiTurn = false
        turnPosition = nil

        print("##################################################")
        print("PROMPT :\n\(aiPrompt)")
        print("##################################################")

        let task = Task {
            do {
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
                turnPosition = generateRandomAiTurn()
            }
        }

        aiTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            task.cancel()
            self?.turnPosition = self?.generateRandomAiTurn()
        }
    }

    private func generateRandomAiTurn() -> Int? {
        vacantPositions.randomElement()
    }
    
    func reset() {
        turnPosition = nil
        vacantPositions.removeAll()
    }
}
