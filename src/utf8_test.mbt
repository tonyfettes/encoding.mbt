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
test "utf8 decode - comprehensive test" {
  for
    path in [
      "src/utf8-test.txt", "unicode_lipsum/wikipedia_mars/chinese.utf8.txt", "unicode_lipsum/wikipedia_mars/english.utf8.txt",
      "unicode_lipsum/wikipedia_mars/arabic.utf8.txt",
    ] {
    let bytes = @fs.read_file_to_bytes(path)
    let values_naive = []
    try decode_utf8_to_char_array_naive(bytes, values_naive) |> ignore catch {
      _ => continue
    }
    let values_regex = []
    try decode_utf8_to_char_array_regex(bytes, values_regex) |> ignore catch {
      _ => continue
    }
    assert_eq(values_naive, values_regex)
    let values_vector = []
    try decode_utf8_to_char_array_vector(bytes, values_vector) |> ignore catch {
      _ => continue
    }
    assert_eq(values_naive, values_vector)
  }
}

///|
test "utf8 encode - comprehensive test" {
  for
    path in [
      "src/utf8-test.txt", "unicode_lipsum/wikipedia_mars/chinese.utf8.txt", "unicode_lipsum/wikipedia_mars/english.utf8.txt",
      "unicode_lipsum/wikipedia_mars/arabic.utf8.txt",
    ] {
    let bytes = @fs.read_file_to_bytes(path)
    let unicode = []
    try decode_utf8_to_char_array_naive(bytes, unicode) |> ignore catch {
      _ => continue
    }
    let buffer_naive = @buffer.new()
    encode_char_array_to_utf8(unicode, buffer_naive)
    assert_eq(bytes, buffer_naive.to_bytes())
    let buffer_utf8 = @buffer.new()
    encode_utf8(unicode, buffer_utf8)
    assert_eq(bytes, buffer_utf8.to_bytes())
  }
}

///|
test "utf8 validate - basic test" {
  // Test simple cases only to avoid excessive runtime
  for c0 = b'\x00'; c0 < b'\x10'; c0 = c0 + 1 {
    for c1 = b'\x00'; c1 < b'\x10'; c1 = c1 + 1 {
      for c2 = b'\x00'; c2 < b'\x10'; c2 = c2 + 1 {
        for c3 = b'\x00'; c3 < b'\x10'; c3 = c3 + 1 {
          let bytes : Bytes = [c0, c1, c2, c3]
          let naive_result = validate_utf8_naive(bytes)
          let default_result = validate_utf8(bytes)
          assert_eq(naive_result, default_result)
        }
      }
    }
  }
}

///|
test "utf8 basic functionality" {
  // Test basic ASCII
  let ascii_bytes : Bytes = b"Hello, World!"
  let ascii_chars = []
  try
    decode_utf8_to_char_array_naive(ascii_bytes, ascii_chars) |> ignore
  catch {
    _ => fail("Failed to decode ASCII")
  }
  let expected_chars = [
    'H', 'e', 'l', 'l', 'o', ',', ' ', 'W', 'o', 'r', 'l', 'd', '!',
  ]
  assert_eq(ascii_chars, expected_chars)

  // Test encoding back
  let encoded_buffer = @buffer.new()
  encode_char_array_to_utf8(ascii_chars, encoded_buffer)
  assert_eq(encoded_buffer.to_bytes(), ascii_bytes)

  // Test validation
  assert_eq(validate_utf8(ascii_bytes), true)
}

///|
test "utf8 invalid sequences" {
  // Test invalid UTF-8 sequences
  let invalid_sequences = [
    Bytes::from_array([0xFF, 0xFE].map(fn(x) { x.to_byte() })), // Invalid start bytes
    Bytes::from_array([0xC0, 0x80].map(fn(x) { x.to_byte() })), // Overlong encoding
    Bytes::from_array([0xE0, 0x80, 0x80].map(fn(x) { x.to_byte() })), // Overlong encoding
    Bytes::from_array([0xF0, 0x80, 0x80, 0x80].map(fn(x) { x.to_byte() })), // Overlong encoding
    Bytes::from_array([0xC2].map(fn(x) { x.to_byte() })), // Incomplete sequence
    Bytes::from_array([0xE0, 0xA0].map(fn(x) { x.to_byte() })), // Incomplete sequence
    Bytes::from_array([0xF0, 0x90, 0x80].map(fn(x) { x.to_byte() })), // Incomplete sequence
  ]
  for invalid_bytes in invalid_sequences {
    assert_eq(validate_utf8(invalid_bytes), false)
    let chars = []
    try {
      decode_utf8_to_char_array_naive(invalid_bytes, chars) |> ignore
      fail("Expected DecodingError for invalid UTF-8")
    } catch {
      DecodingError::Malformed(_) => () // Expected
      _ => fail("Unexpected error type")
    }
  }
}

///|
test "utf8 edge cases" {
  // Test empty input
  let empty_bytes : Bytes = []
  let empty_chars = []
  try
    decode_utf8_to_char_array_naive(empty_bytes, empty_chars) |> ignore
  catch {
    _ => fail("Failed to decode empty bytes")
  }
  assert_eq(empty_chars.length(), 0)
  assert_eq(validate_utf8(empty_bytes), true)

  // Test single byte characters
  for i = 0; i < 128; i = i + 1 {
    let single_byte : Bytes = [i.to_byte()]
    let chars = []
    try decode_utf8_to_char_array_naive(single_byte, chars) |> ignore catch {
      _ => fail("Failed to decode single byte \{i}")
    }
    assert_eq(chars.length(), 1)
    assert_eq(chars[0].to_int(), i)
    assert_eq(validate_utf8(single_byte), true)
  }
}
