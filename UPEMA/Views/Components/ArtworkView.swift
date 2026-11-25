import SwiftUI

struct ArtworkView: View {
    let urlString: String?
    var size: CGFloat? = nil
    var cornerRadius: CGFloat = 14

    var body: some View {
        AsyncImage(url: urlString.flatMap(URL.init(string:))) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            default:
                ZStack {
                    LinearGradient(colors: [.upemaOrange.opacity(0.9), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Image(systemName: "music.note")
                        .font(.system(size: (size ?? 100) * 0.28, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .frame(width: size, height: size)
        .aspectRatio(1, contentMode: .fill)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

extension Color {
    static let upemaOrange = Color(red: 1, green: 0.52, blue: 0.08)
    static let upemaPanel = Color(red: 0.08, green: 0.09, blue: 0.11)
}

