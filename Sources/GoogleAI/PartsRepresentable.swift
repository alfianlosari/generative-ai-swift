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

/// A protocol describing any data that could be interpreted as model input data.
public protocol PartsRepresentable {
  var partsValue: [ModelContent.Part] { get }
}

/// Enables a `String` to be passed in as ``PartsRepresentable``.
extension String: PartsRepresentable {
  public var partsValue: [ModelContent.Part] {
    return [.text(self)]
  }
}

/// Enables a ``ModelContent.Part`` to be passed in as ``PartsRepresentable``.
extension ModelContent.Part: PartsRepresentable {
  public var partsValue: [ModelContent.Part] {
    return [self]
  }
}

/// Enable an `Array` of ``PartsRepresentable`` values to be passed in as a single
/// ``PartsRepresentable``.
extension [any PartsRepresentable]: PartsRepresentable {
  public var partsValue: [ModelContent.Part] {
    return flatMap { $0.partsValue }
  }
}