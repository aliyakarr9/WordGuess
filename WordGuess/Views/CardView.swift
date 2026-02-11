import SwiftUI

struct CardView: View {
    let card: WordCard

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - ANA KELİME BÖLÜMÜ (Spotlight Efektli)
            VStack(spacing: 12) {
                Text("ANA KELİME")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.white.opacity(0.5)) // Başlık daha soft
                    .tracking(4)
                
                Text(card.word.uppercased())
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    // MARK: ÇÖZÜM - Uzun kelimeler için otomatik küçültme
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    // Okunabilirliği artıran derinlik gölgesi
                    .shadow(color: .black.opacity(0.6), radius: 1, x: 1, y: 1)
                    .shadow(color: Color.purple.opacity(0.6), radius: 15)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 45)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.black.opacity(0.25)) // Metin arkasını karartarak kontrast sağladık
                    .padding(10)
            )

            // MARK: - MODERN AYIRICI (Neon Çizgi)
            ZStack {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
                Capsule()
                    .fill(LinearGradient(colors: [.clear, .purple.opacity(0.8), .clear], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 220, height: 4)
                    .blur(radius: 1)
            }
            .padding(.vertical, 10)

            // MARK: - YASAKLI KELİMELER BÖLÜMÜ (Devasa ve Net)
            VStack(spacing: 20) {
                Text("YASAKLI KELİMELER")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.red.opacity(0.9))
                    .tracking(3)
                
                VStack(spacing: 14) {
                    ForEach(card.forbiddenWords, id: \.self) { word in
                        Text(word.uppercased())
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            // MARK: ÇÖZÜM - Sığmama sorununa karşı koruma
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                            // Arka plandan ayıran keskin gölge
                            .shadow(color: .black.opacity(0.8), radius: 2)
                    }
                }
            }
            .padding(.vertical, 30)
        }
        .frame(width: 340, height: 540) // Telefon ekranına daha iyi oturan boyut
        .background(
            ZStack {
                // Katmanlı arka plan (Okunabilirlik için Material karartıldı)
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color.black.opacity(0.55))
                
                RoundedRectangle(cornerRadius: 40)
                    .fill(.ultraThinMaterial)
                
                // Kenar parlaması
                RoundedRectangle(cornerRadius: 40)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .clear, .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
        )
        .shadow(color: Color.black.opacity(0.5), radius: 30, x: 0, y: 20)
    }
}
