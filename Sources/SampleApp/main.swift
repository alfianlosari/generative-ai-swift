import Foundation
import GoogleGenerativeAI

class SampleApp {

    static let apiKey = "AIzaSyBKzqB_o0QMliDyevxz4qhBc07AcS0Xk-E"

    static func main() async throws {
        print("Welcome to Google Gemini Swift SDK on Windows")
        let model = GenerativeModel(name: "gemini-pro", apiKey: apiKey)
        while true {
            print("Prompt:")
            guard let prompt = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines), !prompt.isEmpty else { break }
            
            let contentStream = model.generateContentStream(prompt)
            print("\n")
            print("Gemini Pro:")
            for try await chunk in contentStream {
                if let text = chunk.text {
                    print(text)
                }
            }
            print("\n")
        }
        exit(0)
    }

}

Task {
    do {
        try await SampleApp.main()
    } catch {
        print(error.localizedDescription)
    }
}

_ = RunLoop.current.run(mode: .default, before: .distantFuture)