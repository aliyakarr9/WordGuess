import Foundation

struct WordCard: Codable, Identifiable {
    let id: String
    let word: String
    let forbiddenWords: [String]
    let difficulty: String
}
