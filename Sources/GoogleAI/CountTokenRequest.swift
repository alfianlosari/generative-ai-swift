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

struct CountTokensRequest {
  let model: String
  let contents: [ModelContent]
  let options: RequestOptions
}

extension CountTokensRequest: Encodable {
  enum CodingKeys: CodingKey {
    case contents
  }
}

extension CountTokensRequest: GenerativeAIRequest {
  typealias Response = CountTokensResponse

  var url: URL {
    URL(string: "\(GenerativeAISwift.baseURL)/\(model):countTokens")!
  }
}

/// The model's response to a count tokens request.
public struct CountTokensResponse: Decodable {
  /// The total number of tokens in the input given to the model as a prompt.
  public let totalTokens: Int
}
