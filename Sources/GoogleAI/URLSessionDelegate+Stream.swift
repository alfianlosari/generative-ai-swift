import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class URLSessionDelegateStream<T: Decodable>: NSObject, URLSessionDataDelegate {
    var receivedData = Data()
    var continuation: AsyncThrowingStream<T, any Error>.Continuation?

    init(continuation: AsyncThrowingStream<T, any Error>.Continuation?) {
        self.continuation = continuation
        super.init()
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let continuation else { return }
        receivedData.append(data)
        if let receivedString = String(data: receivedData, encoding: .utf8) {
            if receivedString.hasPrefix("data:") {
                let jsonText = String(receivedString.dropFirst(5))
                let data: Data
                do {
                    data = try jsonData(jsonText: jsonText)
                } catch {
                    Logging.default.error("Failed to convert string to json data \(error)")
                    return
                }

                do {
                    let content = try JSONDecoder().decode(T.self, from: data)
                    continuation.yield(content)
                    receivedData = Data()
                } catch {
                    Logging.default.error("Failed to convert jsonDta to response \(error)")
                    return
                }
            } 
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            continuation?.finish(throwing: error)
        } else {
            continuation?.finish(throwing: nil)
        }
    }

    private func jsonData(jsonText: String) throws -> Data {
        guard let data = jsonText.data(using: .utf8) else {
        let error = NSError(
            domain: "com.google.generative-ai",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Could not parse response as UTF8."]
        )
        throw error
        }

        return data
    }

}

