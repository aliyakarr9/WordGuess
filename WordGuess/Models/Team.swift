import Foundation
import SwiftUI

struct Team: Identifiable {
    let id: UUID = UUID()
    var name: String
    var score: Int = 0
    var color: Color
}
