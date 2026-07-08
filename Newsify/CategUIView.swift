//  CategUIView.swift
//  Newsify
//
//  Created by san-7 on 03/07/2026.
//

import SwiftUI

struct CategUIView: View {
    let title: String
    let count: Int
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(.navy)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.bold)
                    .foregroundColor(.navy)
                
                Text("\(count) ARTICLES")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 110)
        .background(Color(.biancosporco))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}
#Preview {
    CategUIView(title: "MONDO", count: 248, iconName: "globe")
}
