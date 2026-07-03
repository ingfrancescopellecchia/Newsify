//
//  CategoryPlaceholderUIView.swift
//  Newsify
//
//  Created by san-7 on 02/07/2026.
//

import SwiftUI

struct CategoryPlaceholderUIView: View {
    let categoryName: String
    var body: some View {
        ZStack {
//            .ignoresSafeArea()
            VStack {
                Text("Sezione \(categoryName)")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.primary)
                        
                Text("Qui vedrai solo le notizie della categoria \(categoryName.lowercased()).")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CategoryPlaceholderUIView(categoryName: "sport")
}
