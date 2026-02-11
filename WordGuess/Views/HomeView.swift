import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            // MARK: - Arka Plan (Oyunla Uyumlu Koyu Tema)
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 30) {
                    // MARK: - Başlık Bölümü (Okunabilirlik Artırıldı)
                    VStack(spacing: 12) {
                        Text("Kelime Tahmini")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Arkadaşlarınla eğlenceye hazır mısın?")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.top, 60) // Dynamic Island payı

                    // MARK: - Takımlar Kartı (Dark Glassmorphism)
                    VStack(alignment: .leading, spacing: 20) {
                        Label("Takımlar", systemImage: "person.2.fill")
                            .font(.headline)
                            .foregroundColor(.purple)

                        VStack(spacing: 15) {
                            TeamInputRow(color: viewModel.teams[0].color, placeholder: "1. Takım Adı", text: $viewModel.teams[0].name)
                            
                            TeamInputRow(color: viewModel.teams[1].color, placeholder: "2. Takım Adı", text: $viewModel.teams[1].name)
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(25)
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.white.opacity(0.1), lineWidth: 1))

                    // MARK: - Ayarlar Kartı (Okunaklı Sliderlar)
                    VStack(alignment: .leading, spacing: 25) {
                        Label("Oyun Ayarları", systemImage: "gearshape.fill")
                            .font(.headline)
                            .foregroundColor(.blue)

                        VStack(spacing: 25) {
                            SettingsSliderRow(
                                title: "Tur Süresi",
                                valueText: "\(viewModel.settings.roundTime) sn",
                                color: .purple,
                                value: Binding(
                                    get: { Double(viewModel.settings.roundTime) },
                                    set: { viewModel.settings.roundTime = Int($0) }
                                ),
                                range: 30...120,
                                step: 10
                            )

                            SettingsSliderRow(
                                title: "Hedef Skor",
                                valueText: "\(viewModel.settings.targetScore) puan",
                                color: .blue,
                                value: Binding(
                                    get: { Double(viewModel.settings.targetScore) },
                                    set: { viewModel.settings.targetScore = Int($0) }
                                ),
                                range: 10...100,
                                step: 10
                            )

                            // Maksimum Pas (HUD Stilinde)
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Maksimum Pas")
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(viewModel.settings.maxPassCount == -1 ? "Sınırsız" : "\(viewModel.settings.maxPassCount)")
                                        .fontWeight(.bold)
                                        .foregroundColor(.purple)
                                }
                                
                                Slider(value: Binding(
                                    get: { viewModel.settings.maxPassCount == -1 ? 0 : Double(viewModel.settings.maxPassCount + 1) },
                                    set: { newValue in
                                        if newValue == 0 { viewModel.settings.maxPassCount = -1 }
                                        else { viewModel.settings.maxPassCount = Int(newValue - 1) }
                                    }
                                ), in: 0...11, step: 1)
                                .accentColor(.purple)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(25)
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.white.opacity(0.1), lineWidth: 1))

                    // MARK: - Başlat Butonu
                    Button(action: {
                        withAnimation { viewModel.startGame() }
                    }) {
                        HStack {
                            Text("OYUNU BAŞLAT")
                            Image(systemName: "play.fill")
                        }
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(22)
                        .shadow(color: .purple.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Güncellenmiş Okunaklı Alt Bileşenler
struct TeamInputRow: View {
    let color: Color
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.3)))
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium, design: .rounded))
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(15)
    }
}

struct SettingsSliderRow: View {
    let title: String
    let valueText: String
    let color: Color
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title).foregroundColor(.white).fontWeight(.medium)
                Spacer()
                Text(valueText).foregroundColor(color).fontWeight(.bold)
            }
            Slider(value: $value, in: range, step: step)
                .accentColor(color)
        }
    }
}
