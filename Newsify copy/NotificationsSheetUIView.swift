//
//  NotificationsSheetUIView.swift
//  Newsify
//
//  Created by san-7 on 03/07/2026.
//

import SwiftUI

struct NotificationsSheetUIView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        
        VStack {
            HStack {
                Text("Notifiche")
                    .foregroundColor(.primary)
                    .font(.title2)
                    .bold()
                Spacer()
            }
            .padding()
            
            NavigationStack{
                List {
                    NavigationLink(destination: EmptyView()) {
                        Text("🔴 Terremoto in Venezuela - 10m fa")
                            .foregroundColor(.primary)
                    }
                    NavigationLink(destination: EmptyView()) {
                        Text("☀️ Caldo record a Roma - 1h fa")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .presentationDetents([.large]) // Apre lo sheet a schermo intero
            }
        }

#Preview {
    NotificationsSheetUIView()
}
