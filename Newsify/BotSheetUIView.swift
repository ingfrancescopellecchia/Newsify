//
//  BotSheetUIView.swift
//  Newsify
//
//  Created by san-7 on 03/07/2026.
//

import SwiftUI

struct BotSheetUIView: View {
    @Environment(\.dismiss) var dismiss // Permette di chiudere lo sheet trascinando
    var body: some View {
        VStack {
            HStack {
                Text("Assistente AI")
                    .foregroundColor(Color(hex: "003D6C"))
                    .font(.title2)
                    .bold()
                Spacer()
        }
            .padding()
            
            Spacer()
        }
        .padding()
        // presentationDetents imposta l'altezza dello sheet (es. metà schermo o intero)
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    BotSheetUIView()
}
