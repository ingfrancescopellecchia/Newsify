//
// ExploreView.swift
// Newsify
//
// Created by san-9 on 01/07/2026.
//

import SwiftUI

struct ExploreView: View {
    @State var catSelected = 0
    // Variabile di stato per attivare la navigazione automatica
    @State private var navigateToCategory = false
    @State private var showBotSheet = false
    @State private var showNotificationsSheet = false
var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F4F4F4")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // BARRA SUPERIORE: Bot AI, Titolo e Notifiche
                    HStack {
                        // Tasto Bot AI (Sinistra) che apre lo sheet
                        Button(action: {
                            showBotSheet = true
                        }) {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundColor(Color(hex: "003D6C"))
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.05), radius: 3)
                        }
                        
                        Spacer()
                        
                        Text("Explore")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color(hex: "003D6C"))
                        
                        Spacer()
                        
                        // Tasto Notifiche (Destra)- apre lo sheet
                        Button(action: {
                            showNotificationsSheet = true
                        }) {
                            Image(systemName: "bell.fill")
                                .font(.title2)
                                .foregroundColor(Color(hex: "003D6C"))
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.05), radius: 3)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // SELETTORE CATEGORIE
                    HStack {
                        Picker("choose a cat", selection: $catSelected) {
                            Text("Per te").tag(0)
                            Text("Mondo").tag(1)
                            Text("Teach").tag(2)
                            Text("Sport").tag(3)
                        }
                        .pickerStyle(.segmented)
                        .onAppear{
                            let myCustomColor = UIColor(hex: "003D6C")
                            let myCustomColor1 = UIColor(hex: "003D6C")
                            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: myCustomColor], for: .normal)
                            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: myCustomColor1], for: .selected)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // SCRITTA IN PRIMO PIANO
                    HStack {
                        Text("IN PRIMO PIANO OGGI")
                            .foregroundColor(Color(hex: "003D6C"))
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                            .font(.system(size: 12, weight: .bold))
                        Spacer()
                    }
                    
                    // FEED SCORREVOLE DELLE NOTIZIE
                    ScrollView {
                        VStack(spacing: 14) {
                            
                            // Card Grande Cliccabile
                            NavigationLink(destination: EmptyView()) {
                                BigNewsCardUIView()
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Card Piccola Cliccabile
                            NavigationLink(destination: EmptyView()) {
                                SmallNewsCardUIView(
                                    title: "Caldo record in Italia, continua l'ondata di afa: 16 città da bollino rosso",
                                    source: "Cronaca"
                               )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Card Piccola Cliccabile
                            NavigationLink(destination: EmptyView()) {
                                SmallNewsCardUIView(
                                    title: "Genova, lite familiare: due persone gettate dalla finestra",
                                    source: "Notizie"
                               )
                            }
                           .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 20)
                    }
                
                    // Intercettiamo il cambio di categoria e attiviamo la navigazione
                    .onChange(of: catSelected) { oldValue, newValue in
                        // Evitiamo di navigare se si riclicca su "Per te" (tag 0), che è la home attuale
                        if newValue != 0 {
                            navigateToCategory = true
                        }
                    }
                } //fine vstack
            } //fine zstack
            
            //push della pagina corretta
                        .navigationDestination(isPresented: $navigateToCategory) {
                            destinationView(for: catSelected)
                        }
            // Modificatori degli sheet in fondo al navigatorStack
                        .sheet(isPresented: $showBotSheet) {
                            BotSheetUIView()
                        }
                        .sheet(isPresented: $showNotificationsSheet) {
                            NotificationsSheetUIView()
                        }
        } //fine navstack
    } // fine body
    
    
    // Funzione di supporto che restituisce la vista corretta in base al tag selezionato
    @ViewBuilder
    private func destinationView(for category: Int) -> some View {
        switch category {
        case 1:
            CategoryPlaceholderUIView(categoryName: "Mondo")
        case 2:
            CategoryPlaceholderUIView(categoryName: "Tech")
        case 3:
            CategoryPlaceholderUIView(categoryName: "Sport")
        default:
            EmptyView()
        }
    }
} //fine struct

#Preview {
    ExploreView()
}

// Estensione per i colori HEX
extension Color {
    init(hex: String){
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = ((int >> 16) & 0xff, (int >> 8) & 0xff, int & 0xff)
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}
//extension for picker color
extension UIColor {
    convenience init(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleanHex.hasPrefix("#") { cleanHex.remove(at: cleanHex.startIndex) }
        
        var rgb: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
