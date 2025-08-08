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
/// Encode character array to UTF-8 bytes using naive approach.
/// This is the reference implementation for UTF-8 encoding.
///
/// # Parameters
///
/// - `chars` : The characters to encode
/// - `bytes` : The output buffer where encoded bytes will be written
///
/// # Raises
///
/// - `EncodingError::InvalidCharacter` : If a character is outside the valid Unicode range
pub fn encode_char_array_to_utf8(
  chars : @array.View[Char],
  bytes : @buffer.T,
) -> Unit raise EncodingError {
  for char in chars {
    let char = char.to_int()
    match char {
      0..<0x80 => bytes.write_byte(char.to_byte())
      0x80..<0x800 => {
        bytes.write_byte((0xC0 | (char >> 6)).to_byte())
        bytes.write_byte((0x80 | (char & 0x3F)).to_byte())
      }
      0x800..<0x10000 => {
        bytes.write_byte((0xE0 | (char >> 12)).to_byte())
        bytes.write_byte((0x80 | ((char >> 6) & 0x3F)).to_byte())
        bytes.write_byte((0x80 | (char & 0x3F)).to_byte())
      }
      0x10000..=0x10FFFF =>
        bytes.write_bytes([
          (0xF0 | (char >> 18)).to_byte(),
          (0x80 | ((char >> 12) & 0x3F)).to_byte(),
          (0x80 | ((char >> 6) & 0x3F)).to_byte(),
          (0x80 | (char & 0x3F)).to_byte(),
        ])
      _ => raise EncodingError::InvalidCharacter(char)
    }
  }
}

///|
/// Default UTF-8 encoding function that uses the naive implementation.
///
/// # Parameters
///
/// - `chars` : The characters to encode
/// - `bytes` : The output buffer where encoded bytes will be written
///
/// # Raises
///
/// - `EncodingError::InvalidCharacter` : If a character is outside the valid Unicode range
pub fn encode_utf8(chars : @array.View[Char], bytes : @buffer.T) -> Unit {
  for char in chars {
    let char = char.to_int()
    match char {
      0..<0x80 => bytes.write_byte(char.to_byte())
      0x80..<0x800 => {
        bytes.write_byte((0xC0 | (char >> 6)).to_byte())
        bytes.write_byte((0x80 | (char & 0x3F)).to_byte())
      }
      0x800..<0x10000 => {
        bytes.write_byte((0xE0 | (char >> 12)).to_byte())
        bytes.write_byte((0x80 | ((char >> 6) & 0x3F)).to_byte())
        bytes.write_byte((0x80 | (char & 0x3F)).to_byte())
      }
      0x10000..=0x10FFFF =>
        bytes.write_bytes([
          (0xF0 | (char >> 18)).to_byte(),
          (0x80 | ((char >> 12) & 0x3F)).to_byte(),
          (0x80 | ((char >> 6) & 0x3F)).to_byte(),
          (0x80 | (char & 0x3F)).to_byte(),
        ])
      _ => abort("Invalid character: \{char}")
    }
  }
}
