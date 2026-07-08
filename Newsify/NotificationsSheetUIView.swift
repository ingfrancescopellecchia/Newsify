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
            Text("Notifications")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.navy)
                .padding(.top, 12)

            Spacer()

            NavigationStack {
                emptyStateView
            }
        }
        .presentationDetents([.medium])
    }

    private var emptyStateView: some View {
        VStack(spacing: 18) {
            Image(systemName: "bell.slash.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 72)
                .foregroundStyle(.navy)

            VStack(spacing: 8) {
                Text("No notifications")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.navy)
                    .multilineTextAlignment(.center)

                Text("Notifications about your favorite news will appear here.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.navy)
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
