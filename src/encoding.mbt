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
/// Encode a given string to the specified character encoding and returns the resulting bytes.
///
/// # Parameters
///
/// - `encoding` : The target encoding format.
/// - `src`: The input string to be encoded.
///
/// # Returns
///
/// A `bytes` representing the encoded string in the selected format.
///
/// # Examples
///
/// ```moonbit
/// let src = "Hello, World!"
/// @json.inspect(encode(encoding=UTF8, src).to_array(), content=
///   [72,101,108,108,111,44,32,87,111,114,108,100,33]
/// )
/// ```
pub fn[Encode : Encode] encode(string : Encode, encoding~ : Encoding) -> Bytes {
  Encode::encode(string, encoding~)
}

///|
/// Encodes a string into the specified character encoding and writes the result
/// directly into a buffer.
///
/// Parameters:
///
/// * `string` : The input string to be encoded.
/// * `buffer` : The buffer where the encoded bytes will be written to.
/// * `encoding` : The target encoding format. Defaults to UTF8 if not specified.
///
/// Example:
///
/// ```moonbit
/// let buf = @buffer.new()
/// let text = "Hello, world"
/// @encoding.encode_to(text, buf, encoding=UTF16LE)
/// inspect(buf.to_string(), content="Hello, world")
/// ```
pub fn[Encode : Encode] encode_to(
  src : Encode,
  buffer : @buffer.T,
  encoding~ : Encoding
) -> Unit {
  Encode::encode_to(src, buffer, encoding~)
}

///|
pub trait Encode {
  size_hint(Self, encoding~ : Encoding) -> Int
  encode(Self, encoding~ : Encoding) -> Bytes = _
  encode_to(Self, @buffer.T, encoding~ : Encoding) -> Unit
}

///|
impl Encode with encode(value : Self, encoding~ : Encoding) -> Bytes {
  let buffer = @buffer.new(size_hint=Encode::size_hint(value, encoding~))
  Encode::encode_to(value, buffer, encoding~)
  buffer.contents()
}

///|
pub impl Encode for Char with size_hint(value : Char, encoding~ : Encoding) -> Int {
  ignore(value)
  ignore(encoding)
  4
}

///|
pub impl Encode for Char with encode_to(
  value : Char,
  buffer : @buffer.T,
  encoding~ : Encoding
) -> Unit {
  match encoding {
    UTF8 => write_utf8_char(buffer, value)
    UTF16LE => write_utf16le_char(buffer, value)
    UTF16BE => write_utf16be_char(buffer, value)
  }
}

///|
pub impl Encode for String with size_hint(value : String, encoding~ : Encoding) -> Int {
  ignore(encoding)
  value.length() * 4
}

///|
pub impl Encode for String with encode_to(
  value : String,
  buffer : @buffer.T,
  encoding~ : Encoding
) -> Unit {
  match encoding {
    UTF8 =>
      for char in value {
        write_utf8_char(buffer, char)
      }
    UTF16BE =>
      for char in value {
        write_utf16be_char(buffer, char)
      }
    UTF16LE =>
      for char in value {
        write_utf16le_char(buffer, char)
      }
  }
}

///|
pub impl Encode for @string.View with size_hint(
  value : @string.View,
  encoding~ : Encoding
) -> Int {
  ignore(encoding)
  value.length() * 4
}

///|
pub impl Encode for @string.View with encode_to(
  value : @string.View,
  buffer : @buffer.T,
  encoding~ : Encoding
) -> Unit {
  match encoding {
    UTF8 =>
      for char in value {
        write_utf8_char(buffer, char)
      }
    UTF16BE =>
      for char in value {
        write_utf16be_char(buffer, char)
      }
    UTF16LE =>
      for char in value {
        write_utf16le_char(buffer, char)
      }
  }
}

///|
/// Write a char into buffer as UTF8.
fn write_utf8_char(buf : @buffer.T, value : Char) -> Unit {
  let code = value.to_uint()
  match code {
    _..<0x80 => {
      let b0 = ((code & 0x7F) | 0x00).to_byte()
      buf.write_byte(b0)
    }
    _..<0x0800 => {
      let b0 = (((code >> 6) & 0x1F) | 0xC0).to_byte()
      let b1 = ((code & 0x3F) | 0x80).to_byte()
      buf.write_byte(b0)
      buf.write_byte(b1)
    }
    _..<0x010000 => {
      let b0 = (((code >> 12) & 0x0F) | 0xE0).to_byte()
      let b1 = (((code >> 6) & 0x3F) | 0x80).to_byte()
      let b2 = ((code & 0x3F) | 0x80).to_byte()
      buf.write_byte(b0)
      buf.write_byte(b1)
      buf.write_byte(b2)
    }
    _..<0x110000 => {
      let b0 = (((code >> 18) & 0x07) | 0xF0).to_byte()
      let b1 = (((code >> 12) & 0x3F) | 0x80).to_byte()
      let b2 = (((code >> 6) & 0x3F) | 0x80).to_byte()
      let b3 = ((code & 0x3F) | 0x80).to_byte()
      buf.write_byte(b0)
      buf.write_byte(b1)
      buf.write_byte(b2)
      buf.write_byte(b3)
    }
    _ => abort("Char out of range")
  }
}

///|
/// Write a char into buffer as UTF16LE.
fn write_utf16le_char(buf : @buffer.T, value : Char) -> Unit {
  let code = value.to_uint()
  if code < 0x10000 {
    let b0 = (code & 0xFF).to_byte()
    let b1 = (code >> 8).to_byte()
    buf.write_byte(b0)
    buf.write_byte(b1)
  } else if code < 0x110000 {
    let hi = code - 0x10000
    let lo = (hi >> 10) | 0xD800
    let hi = (hi & 0x3FF) | 0xDC00
    let b0 = (lo & 0xFF).to_byte()
    let b1 = (lo >> 8).to_byte()
    let b2 = (hi & 0xFF).to_byte()
    let b3 = (hi >> 8).to_byte()
    buf.write_byte(b0)
    buf.write_byte(b1)
    buf.write_byte(b2)
    buf.write_byte(b3)
  } else {
    abort("Char out of range")
  }
}

///|
/// Write a char into buffer as UTF16BE.
fn write_utf16be_char(buf : @buffer.T, value : Char) -> Unit {
  let code = value.to_uint()
  if code < 0x10000 {
    let b0 = (code >> 8).to_byte()
    let b1 = (code & 0xFF).to_byte()
    buf.write_byte(b0)
    buf.write_byte(b1)
  } else if code < 0x110000 {
    let hi = code - 0x10000
    let lo = (hi >> 10) | 0xD800
    let hi = (hi & 0x3FF) | 0xDC00
    let b0 = (lo >> 8).to_byte()
    let b1 = (lo & 0xFF).to_byte()
    let b2 = (hi >> 8).to_byte()
    let b3 = (hi & 0xFF).to_byte()
    buf.write_byte(b0)
    buf.write_byte(b1)
    buf.write_byte(b2)
    buf.write_byte(b3)
  } else {
    abort("Char out of range")
  }
}
