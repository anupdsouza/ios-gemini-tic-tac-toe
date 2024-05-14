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
    private var columns: [GridItem] = [GridItem].init(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        GeometryReader(content: { geometry in
            LazyVGrid(columns: columns, spacing: 30, content: {
                ForEach(0..<9) { index in
                    Circle()
                        .fill(Color.blue)
                }
            })
            .padding()
        })
    }
}

#Preview {
    ContentView()
}
