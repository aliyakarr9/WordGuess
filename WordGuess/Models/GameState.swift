import Foundation

enum GameState {
    case idle
    case playing
    case paused
    case roundOver
    case betweenRounds // Jules'un raoundlar arası skor tablosu için eklediği durum
    case gameOver
}
