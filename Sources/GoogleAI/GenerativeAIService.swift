// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct GenerativeAIService {
  /// Gives permission to talk to the backend.
  private let apiKey: String

  private let urlSession: URLSession

  init(apiKey: String, urlSession: URLSession) {
    self.apiKey = apiKey
    self.urlSession = urlSession
  }

  func loadRequest<T: GenerativeAIRequest>(request: T) async throws -> T.Response {
    let urlRequest = try urlRequest(request: request)

    let data: Data
    let rawResponse: URLResponse
    (data, rawResponse) = try await urlSession.data(for: urlRequest)

    let response = try httpResponse(urlResponse: rawResponse)

    // Verify the status code is 200
    guard response.statusCode == 200 else {
      Logging.default.error("[GoogleGenerativeAI] The server responded with an error: \(response)")
      if let responseString = String(data: data, encoding: .utf8) {
        Logging.network.error("[GoogleGenerativeAI] Response payload: \(responseString)")
      }

      throw parseError(responseData: data)
    }

    return try parseResponse(T.Response.self, from: data)
  }

  func loadRequestStream<T: GenerativeAIRequest>(request: T)
    -> AsyncThrowingStream<T.Response, Error> {
    return AsyncThrowingStream { continuation in
      Task {
        let urlRequest: URLRequest
        do {
          urlRequest = try self.urlRequest(request: request)
        } catch {
          continuation.finish(throwing: error)
          return
        }
        
        let session = URLSession(configuration: .default, delegate: URLSessionDelegateStream(continuation: continuation), delegateQueue: nil)
        let dataTask = session.dataTask(with: urlRequest)
        dataTask.resume()
      }
    }
  }

  // MARK: - Private Helpers

  private func urlRequest<T: GenerativeAIRequest>(request: T) throws -> URLRequest {
    var urlRequest = URLRequest(url: request.url)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
    urlRequest.setValue("genai-swift/\(GenerativeAISwift.version)",
                        forHTTPHeaderField: "x-goog-api-client")
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    urlRequest.httpBody = try encoder.encode(request)

    if let timeoutInterval = request.options.timeout {
      urlRequest.timeoutInterval = timeoutInterval
    }

    return urlRequest
  }

  private func httpResponse(urlResponse: URLResponse) throws -> HTTPURLResponse {
    // Verify the status code is 200
    guard let response = urlResponse as? HTTPURLResponse else {
      Logging.default
        .error(
          "[GoogleGenerativeAI] Response wasn't an HTTP response, internal error \(urlResponse)"
        )
      throw NSError(
        domain: "com.google.generative-ai",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Response was not an HTTP response."]
      )
    }

    return response
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

  private func parseError(responseBody: String) -> Error {
    do {
      let data = try jsonData(jsonText: responseBody)
      return parseError(responseData: data)
    } catch {
      return error
    }
  }

  private func parseError(responseData: Data) -> Error {
    do {
      return try JSONDecoder().decode(RPCError.self, from: responseData)
    } catch {
      // TODO: Return an error about an unrecognized error payload with the response body
      return error
    }
  }

  private func parseResponse<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    do {
      return try JSONDecoder().decode(type, from: data)
    } catch {
      if let json = String(data: data, encoding: .utf8) {
        Logging.network.error("[GoogleGenerativeAI] JSON response: \(json)")
      }
      Logging.default.error("[GoogleGenerativeAI] Error decoding server JSON: \(error)")
      throw error
    }
  }
}
