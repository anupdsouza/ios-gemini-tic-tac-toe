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
    let color: Color
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.2))
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.yellow, lineWidth: 2.0)
                }
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
                .foregroundStyle(color)
        }
    }
}

#Preview {
    MarkerItemView(mark: "xmark", color: .green)
}
