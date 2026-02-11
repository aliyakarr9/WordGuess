import Foundation
import Combine
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var teams: [Team] = [
        Team(name: "Team A", color: .purple),
        Team(name: "Team B", color: .orange)
    ]
    @Published var currentTeamIndex: Int = 0
    @Published var gameState: GameState = .idle
    @Published var currentCard: WordCard?
    @Published var timeRemaining: Int = 60
    @Published var roundScore: Int = 0 
    @Published var passesUsed: Int = 0 
    @Published var settings: GameSettings = GameSettings()

    private var deck: [WordCard] = []
    private var usedCards: [WordCard] = []
    private var timerCancellable: AnyCancellable?

    var currentTeam: Team {
        teams[currentTeamIndex]
    }

    init() {
        loadDeck()
    }

    func loadDeck() {
        deck = DataLoader.shared.load("words.json")
        deck.shuffle()
    }

    // MARK: - Game Flow

    func startGame() {
        teams[0].score = 0
        teams[1].score = 0
        currentTeamIndex = 0
        // Oyun başladığında ilk olarak Skor Tablosu (Between Rounds) görünür, 
        // böylece takımlar hazır olduklarında "Başlat" diyebilir.
        gameState = .betweenRounds
    }

    func startRound() {
        roundScore = 0
        passesUsed = 0
        timeRemaining = settings.roundTime
        gameState = .playing
        nextCard()
        startTimer()
    }

    func pauseGame() {
        gameState = .paused
        timerCancellable?.cancel()
    }

    func resumeGame() {
        gameState = .playing
        startTimer()
    }

    func endRound() {
        timerCancellable?.cancel()
        teams[currentTeamIndex].score += roundScore

        // Raund bittiğinde win condition kontrolü yap
        if checkWinCondition() { return }

        gameState = .betweenRounds
        SoundManager.shared.playTimeUpSound()
        HapticManager.shared.notification(type: .warning)

        // Sırayı diğer takıma geçir
        currentTeamIndex = (currentTeamIndex + 1) % teams.count
    }

    func quitGame() {
        timerCancellable?.cancel()
        resetGame()
    }

    func resetGame() {
        gameState = .idle
        teams[0].score = 0
        teams[1].score = 0
        currentTeamIndex = 0
        loadDeck()
    }

    // MARK: - Game Logic

    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.endRound()
                }
            }
    }

    func nextCard() {
        if deck.isEmpty {
            if usedCards.isEmpty { return }
            deck = usedCards
            usedCards.removeAll()
            deck.shuffle()
        }
        guard !deck.isEmpty else { return }
        currentCard = deck.removeFirst()
    }

    func markCorrect() {
        roundScore += 1
        if let card = currentCard {
            usedCards.append(card)
        }
        SoundManager.shared.playCorrectSound()
        HapticManager.shared.notification(type: .success)

        // ANLIK KAZANMA KONTROLÜ (Instant Win Check)
        let currentTotalScore = teams[currentTeamIndex].score + roundScore
        if currentTotalScore >= settings.targetScore {
            teams[currentTeamIndex].score = currentTotalScore
            gameState = .gameOver
            timerCancellable?.cancel()
            return
        }

        nextCard()
    }

    func markTaboo() {
        roundScore -= 1
        if let card = currentCard {
            usedCards.append(card)
        }
        SoundManager.shared.playWrongSound()
        HapticManager.shared.notification(type: .error)
        nextCard()
    }

    func markPass() {
        // PAS LİMİTİ KONTROLÜ
        if settings.maxPassCount >= 0 && passesUsed >= settings.maxPassCount {
            HapticManager.shared.notification(type: .error)
            return
        }

        passesUsed += 1
        if let card = currentCard {
            usedCards.append(card)
        }
        HapticManager.shared.impact(style: .light)
        nextCard()
    }

    private func checkWinCondition() -> Bool {
        if teams.contains(where: { $0.score >= settings.targetScore }) {
             gameState = .gameOver
             return true
        }
        return false
    }

    // UI için yardımcı değişken
    var isPassLimitReached: Bool {
        guard settings.maxPassCount >= 0 else { return false }
        return passesUsed >= settings.maxPassCount
    }
}
