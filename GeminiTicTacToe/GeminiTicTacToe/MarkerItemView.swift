//
//  MarkerItemView.swift
//  GeminiTicTacToe
//
//  Created by Anup D'Souza on 14/05/24.
//  🕸️ https://www.anupdsouza.com
//  🔗 https://twitter.com/swift_odyssey
//  👨🏻‍💻 https://github.com/anupdsouza
//  ☕️ https://www.buymeacoffee.com/anupdsouza
//

import SwiftUI

struct MarkerItemView: View {
    let mark: String
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue)
            Image(systemName: mark)
                .resizable()
                .bold()
                .frame(width: 40, height: 40)
                .foregroundStyle(.black)
                .offset(x: 2, y: 1)
                .opacity(0.5)
            Image(systemName: mark)
                .resizable()
                .bold()
                .frame(width: 40, height: 40)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    MarkerItemView(mark: "xmark")
}
