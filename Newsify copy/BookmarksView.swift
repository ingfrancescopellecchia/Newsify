import SwiftUI
import SwiftData


// MARK: - Palette colori

extension Color {
    static let notesNavy       = Color(red: 0x00 / 255, green: 0x3D / 255, blue: 0x6C / 255) // #003D6C
    static let notesAccent     = Color(red: 0x00 / 255, green: 0x88 / 255, blue: 0xFF / 255) // #0088FF
    static let notesBackground = Color(red: 0xF4 / 255, green: 0xF4 / 255, blue: 0xF4 / 255) // #F4F4F4
    static let notesSelectedBG = Color(red: 0xED / 255, green: 0xED / 255, blue: 0xED / 255) // #EDEDED
}

// MARK: - Schermata principale

struct BookmarksView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {

            
        VStack {
            Text("Bookmarks")
                .font(.largeTitle)
                .foregroundStyle(Color.primary)
                .bold()
            Spacer()
        
            NavigationStack {
                emptyStateView
            }
        }
        }
    

    // MARK: Header

    private var header: some View {
        HStack(spacing: 16) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.notesNavy)
                    .frame(width: 48, height: 48)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(Color.black.opacity(0.03), lineWidth: 1))
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
            }
        }
        
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // MARK: Stato vuoto

    private var emptyStateView: some View {
        VStack(spacing: 18) {
            Image(systemName: "bookmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 72)
                .foregroundStyle(.primary)

            VStack(spacing: 8) {
                Text("Nessuna notizia nei Bookmarks")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)

                Text("Tocca il pulsante segnalibro nella barra degli strumenti di una notizia per aggiungerla qui.")
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
    BookmarksView()
}
