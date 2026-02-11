import SwiftUI

struct ScoreBoardView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            // MARK: - Arka Plan (Tam Siyah & Yüksek Kontrast)
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // 1. Başlık Alanı (Dynamic Island Payı ile)
                VStack(spacing: 8) {
                    Text("Skor Tablosu")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Rectangle()
                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 80, height: 4)
                        .cornerRadius(2)
                }
                .padding(.top, 65) // Üst barın kameraya çarpmaması için

                Spacer() // İçeriği merkeze itmek için üst boşluk

                // 2. Skor Kartları (Dengeli ve Okunaklı)
                HStack(spacing: 16) {
                    TeamScoreCard(
                        name: viewModel.teams[0].name,
                        score: viewModel.teams[0].score,
                        color: viewModel.teams[0].color
                    )

                    TeamScoreCard(
                        name: viewModel.teams[1].name,
                        score: viewModel.teams[1].score,
                        color: viewModel.teams[1].color
                    )
                }
                .padding(.horizontal, 20)

                // 3. Sıradaki Takım Vurgusu (Yeni HUD Tasarımı)
                VStack(spacing: 15) {
                    Text("SIRADAKİ TAKIM")
                        .font(.system(size: 13, weight: .bold))
                        .tracking(3)
                        .foregroundColor(.white.opacity(0.5))

                    HStack(spacing: 15) {
                        Image(systemName: "person.3.sequence.fill")
                            .font(.title2)
                        
                        Text(viewModel.currentTeam.name.uppercased())
                            .font(.system(size: 26, weight: .black, design: .rounded))
                    }
                    .foregroundColor(viewModel.currentTeam.color)
                    .padding(.vertical, 25)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.07))
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(viewModel.currentTeam.color.opacity(0.4), lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, 30)
                .padding(.top, 40)

                Spacer() // Alt boşluk

                // 4. Başlat Butonu (Sabit ve Dikkat Çekici)
                Button(action: {
                    withAnimation(.spring()) { viewModel.startRound() }
                }) {
                    HStack(spacing: 12) {
                        Text("TURU BAŞLAT")
                        Image(systemName: "play.fill")
                    }
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(
                            colors: [viewModel.currentTeam.color, viewModel.currentTeam.color.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(22)
                    .shadow(color: viewModel.currentTeam.color.opacity(0.4), radius: 15, x: 0, y: 10)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Modern Skor Kartı Bileşeni
struct TeamScoreCard: View {
    let name: String
    let score: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Text(name.uppercased())
                .font(.system(size: 11, weight: .black))
                .foregroundColor(.white.opacity(0.6))
                .tracking(1.5)
                .lineLimit(1)
            
            Text("\(score)")
                .font(.system(size: 65, weight: .heavy, design: .rounded))
                .foregroundColor(color)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 35)
        .background(Color.white.opacity(0.08)) // Siyah temaya uygun modern koyu kart
        .cornerRadius(30)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(color.opacity(0.3), lineWidth: 1.5)
        )
    }
}
