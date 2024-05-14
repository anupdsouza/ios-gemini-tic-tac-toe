//
//  MarkerItemView.swift
//  GeminiTicTacToe
//
//  Created by Anup D'Souza on 14/05/24.
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
