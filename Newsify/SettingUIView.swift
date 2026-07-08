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
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(Color("navy"))
                        
                        VStack(alignment: .leading) {
                            Text(nickname)
                                .font(.headline)
                                .foregroundStyle(Color("navy"))
                            
                            Text("Free")
                                .font(.caption)
                                .foregroundStyle(Color("navy"))
                        }
                    }
                }
                
                Section("General") {
                    TextField("Nickname", text: $nickname)
                        .foregroundStyle(Color("navy"))
                    
                    Label("Milan, Italy", systemImage: "location.fill")
                }
                
                Section("Notifications") {
                    Toggle("Breaking News", isOn: $breakingNews)
                        .foregroundStyle(Color("navy"))
                    
                    Toggle("Morning Digest", isOn: $morningDigest)
                        .foregroundStyle(Color("navy"))
                    
                    Toggle("Sports Updates", isOn: $sportsUpdates)
                        .foregroundStyle(Color("navy"))
                }
                
                Section {
                    Button("Log out", role: .destructive) {
                        
                    }
                    
                    Button("Delete account", role: .destructive) {
                        
                    }
                }
            }
           
                .navigationTitle("Profile")// Gestione corretta del titolo nella barra di navigazione
                .scrollContentBackground(.hidden) // 1. Nasconde lo sfondo di default della Form (iOS 16+)
                .background(Color("cream")) // 2. Applica il tuo colore personalizzato
            }
        }
    }

#Preview {
    SettingUIView()
}
