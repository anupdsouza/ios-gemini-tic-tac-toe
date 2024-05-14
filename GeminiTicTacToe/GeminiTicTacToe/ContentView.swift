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
    private let spacing: CGFloat = 30

    var body: some View {
        GeometryReader(content: { geometry in
            LazyVGrid(columns: columns, spacing: spacing, content: {
                ForEach(0..<9) { index in
                    MarkerItemView()
                        .frame(width: geometry.size.width/3 - spacing,
                               height: geometry.size.width/3 - spacing)
                }
            })
            .padding()
        })
    }
}

#Preview {
    ContentView()
}
