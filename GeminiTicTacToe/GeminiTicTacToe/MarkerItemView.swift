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
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue)
            Image(systemName: "xmark")
                .resizable()
                .bold()
                .frame(width: 30, height: 30)
        }
    }
}

#Preview {
    MarkerItemView()
}
