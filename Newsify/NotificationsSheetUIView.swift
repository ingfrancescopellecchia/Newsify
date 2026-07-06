//
//  NotificationsSheetUIView.swift
//  Newsify
//
//  Created by san-7 on 03/07/2026.
//

import SwiftUI

struct NotificationsSheetUIView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Notifiche")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.primary)
                .padding(.top, 12)

            Spacer()

            NavigationStack {
                emptyStateView
            }
        }
        .presentationDetents([.medium]) // Apre lo sheet a metà schermo
    }

    // MARK: Stato vuoto

    private var emptyStateView: some View {
        VStack(spacing: 18) {
            Image(systemName: "bell")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 72)
                .foregroundStyle(.primary)

            VStack(spacing: 8) {
                Text("Nessuna notifica")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)

                Text("Le notifiche relative alle tue notizie preferite appariranno qui.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    NotificationsSheetUIView()
}
