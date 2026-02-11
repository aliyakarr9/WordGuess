import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel

    @State private var offset: CGSize = .zero
    @State private var showQuitAlert: Bool = false
    
    private var isTimeCritical: Bool { viewModel.timeRemaining <= 10 }
    private var progress: Double {
        Double(viewModel.timeRemaining) / Double(viewModel.settings.roundTime)
    }

    var body: some View {
        ZStack {
            // MARK: - Arka Plan
            LinearGradient(
                gradient: Gradient(colors: [
                    viewModel.currentTeam.color.opacity(0.4),
                    Color.black.opacity(0.9),
                    Color.black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // MARK: - 1. Yeni Minimal Üst Panel (Dynamic Island Dostu)
                HStack(spacing: 20) {
                    // Çıkış Butonu
                    Button(action: { showQuitAlert = true }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .alert(isPresented: $showQuitAlert) {
                        Alert(
                            title: Text("Oyundan Çık?"),
                            message: Text("Mevcut oyun ilerlemesi kaybolacak."),
                            primaryButton: .destructive(Text("Çık")) { viewModel.quitGame() },
                            secondaryButton: .cancel(Text("Devam Et"))
                        )
                    }

                    Spacer()

                    // Dinamik Sayaç (Daha aşağıda ve minimal)
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 5)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(progress))
                            .stroke(
                                isTimeCritical ? Color.red : viewModel.currentTeam.color,
                                style: StrokeStyle(lineWidth: 5, lineCap: .round)
                            )
                            .rotationEffect(Angle(degrees: 270.0))

                        Text("\(viewModel.timeRemaining)")
                            .font(.system(size: 24, weight: .black, design: .monospaced))
                            .foregroundColor(isTimeCritical ? .red : .white)
                    }
                    .frame(width: 60, height: 60)

                    Spacer()

                    // Takım Bilgisi ve Skor
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(viewModel.currentTeam.name.uppercased())
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.white.opacity(0.5))
                            .lineLimit(1)
                        
                        Text("\(viewModel.roundScore)")
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(width: 80, alignment: .trailing)
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.black.opacity(0.4))
                        .background(.ultraThinMaterial)
                        .cornerRadius(30)
                )
                // MARK: DYNAMIC ISLAND KAÇIŞI
                // Dynamic Island'ın (çentiğin) altına düşmesi için padding artırıldı
                .padding(.top, 70)
                .padding(.horizontal)

                Spacer(minLength: 20)

                // MARK: - 2. Kart Alanı
                if let card = viewModel.currentCard {
                    ModernCardView(card: card)
                        .offset(offset)
                        .rotationEffect(.degrees(Double(offset.width / 12)))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    if viewModel.isPassLimitReached && gesture.translation.width < 0 {
                                        offset = CGSize(width: max(gesture.translation.width, -30), height: gesture.translation.height)
                                    } else {
                                        offset = gesture.translation
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                        handleSwipe(width: offset.width, height: offset.height)
                                    }
                                }
                        )
                        .overlay(swipeIndicators)
                        .zIndex(1)
                } else {
                    ProgressView().tint(.white).scaleEffect(1.5)
                }

                // MARK: - 3. Pas Hakkı (Minimal HUD)
                if viewModel.settings.maxPassCount >= 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 10))
                        Text("KALAN PAS: \(viewModel.settings.maxPassCount - viewModel.passesUsed)")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(viewModel.isPassLimitReached ? Color.red.opacity(0.4) : Color.white.opacity(0.12))
                    .foregroundColor(viewModel.isPassLimitReached ? .red : .white)
                    .clipShape(Capsule())
                    .padding(.top, 15)
                }

                Spacer(minLength: 20)

                // MARK: - 4. Kontrol Butonları
                HStack(spacing: 30) {
                    ControlButton(icon: "arrow.right.arrow.left", label: "PAS", color: .yellow, isDisabled: viewModel.isPassLimitReached) { viewModel.markPass() }
                    ControlButton(icon: "hand.raised.fill", label: "TABU", color: .red, isLarge: true) { viewModel.markTaboo() }
                    ControlButton(icon: "checkmark", label: "DOĞRU", color: .green) { viewModel.markCorrect() }
                }
                .padding(.bottom, 60)
            }
        }
    }

    private var swipeIndicators: some View {
        ZStack {
            if offset.width > 60 { SwipeIndicatorIcon(icon: "checkmark.circle.fill", color: .green) }
            else if offset.width < -60 && !viewModel.isPassLimitReached { SwipeIndicatorIcon(icon: "arrow.right.circle.fill", color: .yellow) }
            else if offset.height > 60 { SwipeIndicatorIcon(icon: "xmark.circle.fill", color: .red) }
        }
    }

    func handleSwipe(width: CGFloat, height: CGFloat) {
        let threshold: CGFloat = 100
        if abs(width) > abs(height) {
            if width > threshold { viewModel.markCorrect() }
            else if width < -threshold && !viewModel.isPassLimitReached { viewModel.markPass() }
        } else if height > threshold { viewModel.markTaboo() }
        offset = .zero
    }
}

// MARK: - MODERN CARD VIEW
struct ModernCardView: View {
    let card: WordCard

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Text("ANA KELİME")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(4)
                
                Text(card.word.uppercased())
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .shadow(color: .black.opacity(0.6), radius: 1, x: 1, y: 1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.black.opacity(0.4))
                    .padding(10)
            )

            ZStack {
                Capsule().fill(Color.white.opacity(0.1)).frame(height: 1)
                Capsule().fill(LinearGradient(colors: [.clear, .purple.opacity(0.8), .clear], startPoint: .leading, endPoint: .trailing)).frame(width: 240, height: 4)
            }
            .padding(.vertical, 10)

            VStack(spacing: 18) {
                Text("YASAKLI KELİMELER")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.red.opacity(0.9))
                    .tracking(3)
                
                VStack(spacing: 12) {
                    ForEach(card.forbiddenWords, id: \.self) { word in
                        Text(word.uppercased())
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                            .shadow(color: .black, radius: 2)
                    }
                }
            }
            .padding(.vertical, 25)
        }
        .frame(width: 340, height: 530) // Kart boyutu hafif daraltıldı orantı için
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color.black.opacity(0.65))
                    .background(.ultraThinMaterial)
                    .cornerRadius(40)
                
                RoundedRectangle(cornerRadius: 40)
                    .stroke(LinearGradient(colors: [.white.opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
            }
        )
        .shadow(color: Color.black.opacity(0.5), radius: 30, x: 0, y: 20)
    }
}
