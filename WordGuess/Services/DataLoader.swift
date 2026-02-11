import Foundation

class DataLoader {
    static let shared = DataLoader()

    private init() {}

    func load<T: Decodable>(_ filename: String) -> T {
        let data: Data

        guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            print("Warning: Could not find \(filename) in main bundle. Returning empty instance if possible or crashing.")
            // Ideally we shouldn't crash in production, but for this assignment allowing a crash on missing critical data is often acceptable dev practice.
            // However, let's try to be safer if we can, but the return type T enforces a value.
            fatalError("Couldn't find \(filename) in main bundle.")
        }

        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
}
