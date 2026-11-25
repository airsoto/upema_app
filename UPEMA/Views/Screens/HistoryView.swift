import SwiftUI

struct HistoryView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28).fill(LinearGradient(colors: [.upemaOrange, .black], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Image(systemName: "person.2.wave.2.fill").font(.system(size: 85)).foregroundStyle(.white.opacity(0.9))
                }.frame(height: 210)
                Text("Desde Madrid, 1985").font(.largeTitle.bold())
                Text("Un Pingüino en mi Ascensor (UPEMA) es un grupo español de pop electrónico e irreverente formado en Madrid en 1985 por José Luis Moro, al que pronto se unió Mario Gil como productor y segundo integrante del dúo.")
                    .font(.title3).lineSpacing(7)
                Divider()
                Link(destination: URL(string: "https://en.wikipedia.org/wiki/Un_Ping%C3%BCino_en_mi_Ascensor")!) {
                    Label("Leer más en Wikipedia", systemImage: "arrow.up.right.square")
                }
                Text("Las carátulas, letras y enlaces de audio proceden del catálogo facilitado con este proyecto. Los audios siguen alojados en sus fuentes originales.")
                    .font(.footnote).foregroundStyle(.secondary)
            }.padding()
        }
        .background(Color.black)
        .navigationTitle("Historia")
    }
}

