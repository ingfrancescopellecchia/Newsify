//
//  SettingUIView.swift
//  Newsify
//

import SwiftUI

struct SettingUIView: View {

    @AppStorage("nickname")
    var nickname = "Guest"

    @AppStorage("breakingNews")
    var breakingNews = true

    @AppStorage("morningDigest")
    var morningDigest = true

    @AppStorage("sportsUpdates")
    var sportsUpdates = true

    var body: some View {
        Text("Profile").bold(true)
        NavigationStack {
            Form {

                Section {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading) {
                            Text(nickname)
                                .font(.headline)

                            Text("Free")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("General") {

                    TextField("Nickname", text: $nickname)

                    Label("Milano, Italia", systemImage: "location.fill")
                }

                Section("Notifications") {

                    Toggle("Breaking News", isOn: $breakingNews)

                    Toggle("Morning Digest", isOn: $morningDigest)

                    Toggle("Sports Updates", isOn: $sportsUpdates)
                }

                Section {
                    Button("Log out", role: .destructive) {

                    }

                    Button("Delete account", role: .destructive) {

                    }
                }

            }
        }
    }
}

#Preview {
    SettingUIView()
}
