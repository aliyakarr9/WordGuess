import SwiftUI

@main
struct WordGuessApp: App {
    // ViewModel instance'ı burada tek bir yerde oluşturulur
    @StateObject private var viewModel = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ZStack {
                switch viewModel.gameState {
                case .idle:
                    HomeView(viewModel: viewModel)
                        .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
                    
                case .playing, .paused:
                    GameView(viewModel: viewModel)
                        .transition(.move(edge: .bottom))
                    
                case .betweenRounds, .roundOver:
                    ScoreBoardView(viewModel: viewModel)
                        .transition(.opacity.combined(with: .scale))
                    
                case .gameOver:
                    // Kazanan ekranı
                    if let winner = viewModel.teams.max(by: { $0.score < $1.score }) {
                        WinnerView(viewModel: viewModel, winner: winner)
                            .transition(.opacity.combined(with: .scale))
                    } else {
                        WinnerView(viewModel: viewModel, winner: viewModel.teams[0])
                    }
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.gameState)
        }
    }
}

// MARK: - Modern Konfeti Parçacık Sistemi (GeometryReader ile güncellendi)
struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let speed: Double
    let delay: Double
}

struct ConfettiCannon: View {
    @State private var animate = false
    let pieces: [ConfettiPiece] = (0...60).map { _ in
        ConfettiPiece(
            color: [.blue, .red, .green, .yellow, .pink, .purple, .orange].randomElement()!,
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: -0.2...0.8),
            size: CGFloat.random(in: 6...14),
            speed: Double.random(in: 2.5...5),
            delay: Double.random(in: 0...0.8)
        )
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(pieces) { piece in
                    Rectangle()
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size)
                        .rotationEffect(Angle(degrees: animate ? 720 : 0))
                        .position(
                            x: piece.x * geometry.size.width,
                            y: animate ? geometry.size.height + 150 : -150
                        )
                        .animation(
                            Animation.linear(duration: piece.speed)
                                .repeatForever(autoreverses: false)
                                .delay(piece.delay),
                            value: animate
                        )
                }
            }
        }
        .onAppear { animate = true }
    }
}

// MARK: - Kazanan Ekranı (WinnerView)
struct WinnerView: View {
    @ObservedObject var viewModel: GameViewModel
    let winner: Team

    var body: some View {
        ZStack {
            winner.color.opacity(0.15).edgesIgnoringSafeArea(.all)
            Color.black.opacity(0.85).edgesIgnoringSafeArea(.all)
            
            ConfettiCannon()

            VStack(spacing: 40) {
                ZStack {
                    Circle()
                        .fill(winner.color.opacity(0.2))
                        .frame(width: 180, height: 180)
                        .blur(radius: 30)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 90))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.6), radius: 20)
                }
                .padding(.top, 60)

                VStack(spacing: 12) {
                    Text("ŞAMPİYON")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(8)

                    Text(winner.name.uppercased())
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(winner.color)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 15) {
                    Text("TOPLAM SKOR")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 255/255, green: 215/255, blue: 0/255))
                        .tracking(3)
                        .shadow(color: .yellow.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    Text("\(winner.score)")
                        .font(.system(size: 85, weight: .black, design: .rounded))
                        .foregroundColor(winner.color)
                }
                .padding(.horizontal, 50)
                .padding(.vertical, 30)
                .background(Color.white.opacity(0.06))
                .cornerRadius(35)
                .overlay(RoundedRectangle(cornerRadius: 35).stroke(winner.color.opacity(0.4), lineWidth: 2))

                Spacer()

                Button(action: {
                    withAnimation { viewModel.quitGame() }
                }) {
                    HStack(spacing: 15) {
                        Image(systemName: "house.fill")
                        Text("ANA MENÜYE DÖN")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(winner.color)
                    .cornerRadius(22)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
            .padding()
        }
    }
}
