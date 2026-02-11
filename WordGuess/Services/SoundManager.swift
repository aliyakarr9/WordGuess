import AVFoundation

class SoundManager {
    static let shared = SoundManager()

    private var audioPlayer: AVAudioPlayer?

    private init() {}

    func playSound(named soundName: String) {
        // Assuming sound files are mp3. Adjust extension if needed.
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Sound file \(soundName) not found.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }

    func playCorrectSound() {
        playSound(named: "correct")
    }

    func playWrongSound() {
        playSound(named: "wrong")
    }

    func playTimeUpSound() {
        playSound(named: "timeup")
    }
}
