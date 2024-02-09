import Foundation
import GoogleGenerativeAI

class SampleApp {

    let apiKey = "AIzaSyBKzqB_o0QMliDyevxz4qhBc07AcS0Xk-E"

    static func main() async throws {
        print("Welcome to Google Gemini Swift SDK on Windows")
        let model = GenerativeModel(name: "gemini-pro", apiKey: "AIzaSyBKzqB_o0QMliDyevxz4qhBc07AcS0Xk-E")
        let prompt = "Tell me the silicon capabilities and process that PlayStation 5 is using"
        print("PROMPT: \(prompt)")
        let response = try await model.generateContent(prompt)
        if let text = response.text {
            print("GEMINI:")
            print(text)
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