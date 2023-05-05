// Generated by Create API
// https://github.com/CreateAPI/CreateAPI
//
// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

/// The base unit of structured text. A `Message` includes an `author` and the `content` of the `Message`. The `author` is used to tag messages when they are fed to the model as text.
public struct Message: Codable {
  /// Required. The text content of the structured `Message`.
  public var content: String?
  /// A collection of source attributions for a piece of content.
  public var citationMetadata: CitationMetadata?
  /// Optional. The author of this Message. This serves as a key for tagging the content of this Message when it is fed to the model as text. The author can be any alphanumeric string.
  public var author: String?

  public init(content: String? = nil, citationMetadata: CitationMetadata? = nil, author: String? = nil) {
    self.content = content
    self.citationMetadata = citationMetadata
    self.author = author
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: StringCodingKey.self)
    self.content = try values.decodeIfPresent(String.self, forKey: "content")
    self.citationMetadata = try values.decodeIfPresent(CitationMetadata.self, forKey: "citationMetadata")
    self.author = try values.decodeIfPresent(String.self, forKey: "author")
  }

  public func encode(to encoder: Encoder) throws {
    var values = encoder.container(keyedBy: StringCodingKey.self)
    try values.encodeIfPresent(content, forKey: "content")
    try values.encodeIfPresent(citationMetadata, forKey: "citationMetadata")
    try values.encodeIfPresent(author, forKey: "author")
  }
}
