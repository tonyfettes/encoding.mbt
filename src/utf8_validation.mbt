// Copyright 2024 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
/// Validate UTF-8 bytes using naive pattern matching approach.
/// This is the reference implementation with comprehensive UTF-8 validation.
///
/// # Parameters
///
/// - `bytes` : The bytes to validate as UTF-8
///
/// # Returns
///
/// `true` if the bytes represent valid UTF-8, `false` otherwise
pub fn validate_utf8_naive(bytes : @bytes.View) -> Bool {
  loop bytes {
    [0x00..=0x7F, .. bytes]
    | [0xC2..=0xDF, 0x80..=0xBF, .. bytes]
    | [0xE0, 0xA0..=0xBF, 0x80..=0xBF, .. bytes]
    | [0xE1..=0xEC, 0x80..=0xBF, 0x80..=0xBF, .. bytes]
    | [0xED, 0x80..=0x9F, 0x80..=0xBF, .. bytes]
    | [0xEE..=0xEF, 0x80..=0xBF, 0x80..=0xBF, .. bytes]
    | [0xF0, 0x90..=0xBF, 0x80..=0xBF, 0x80..=0xBF, .. bytes]
    | [0xF1..=0xF3, 0x80..=0xBF, 0x80..=0xBF, 0x80..=0xBF, .. bytes]
    | [0xF4, 0x80..=0x8F, 0x80..=0xBF, 0x80..=0xBF, .. bytes] => continue bytes
    [] => true
    [..] => false
  }
}

///|
/// Default UTF-8 validation function that uses the naive implementation.
///
/// # Parameters
///
/// - `bytes` : The bytes to validate as UTF-8
///
/// # Returns
///
/// `true` if the bytes represent valid UTF-8, `false` otherwise
pub fn validate_utf8(bytes : @bytes.View) -> Bool {
  validate_utf8_naive(bytes)
}
