///|
suberror DecodingError {
  Malformed(@bytes.View)
} derive(Show)

///|
pub fn decode_utf8_to_char_array_naive(
  bytes : @bytes.View,
  chars : Array[Char],
) -> Unit raise DecodingError {
  chars.reserve_capacity(chars.length() + bytes.length())
  loop bytes {
    [] => return
    [0x00..=0x7F as b0, .. bytes] => {
      chars.push(b0.to_char())
      continue bytes
    }
    [0xC2..=0xDF as b0, 0x80..=0xBF as b1, .. bytes] => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let char = ((b0 & 0x1F) << 6) + (b1 & 0x3F)
      chars.push(char.unsafe_to_char())
      continue bytes
    }
    [0xE0 as b0, 0xA0..=0xBF as b1, 0x80..=0xBF as b2, .. bytes]
    | [0xE1..=0xEC as b0, 0x80..=0xBF as b1, 0x80..=0xBF as b2, .. bytes]
    | [0xED as b0, 0x80..=0x9F as b1, 0x80..=0xBF as b2, .. bytes]
    | [0xEE..=0xEF as b0, 0x80..=0xBF as b1, 0x80..=0xBF as b2, .. bytes] => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let b2 = b2.to_int()
      let char = ((b0 & 0x0F) << 12) + ((b1 & 0x3F) << 6) + (b2 & 0x3F)
      chars.push(char.unsafe_to_char())
      continue bytes
    }
    [
      0xF0 as b0,
      0x90..=0xBF as b1,
      0x80..=0xBF as b2,
      0x80..=0xBF as b3,
      .. bytes,
    ]
    | [
      0xF1..=0xF3 as b0,
      0x80..=0xBF as b1,
      0x80..=0xBF as b2,
      0x80..=0xBF as b3,
      .. bytes,
    ]
    | [
      0xF4 as b0,
      0x80..=0x8F as b1,
      0x80..=0xBF as b2,
      0x80..=0xBF as b3,
      .. bytes,
    ] => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let b2 = b2.to_int()
      let b3 = b3.to_int()
      let char = ((b0 & 0x07) << 18) +
        ((b1 & 0x3F) << 12) +
        ((b2 & 0x3F) << 6) +
        (b3 & 0x3F)
      chars.push(char.unsafe_to_char())
      continue bytes
    }
    [..] as input => raise DecodingError::Malformed(input)
  }
}

///|
pub fn decode_utf8_to_char_array_vector(
  bytes : @bytes.View,
  chars : Array[Char],
) -> Unit raise DecodingError {
  chars.reserve_capacity(chars.length() + bytes.length())
  loop bytes {
    [] => return
    [
      0x00..=0x7F as b0,
      0x00..=0x7F as b1,
      0x00..=0x7F as b2,
      0x00..=0x7F as b3,
      0x00..=0x7F as b4,
      0x00..=0x7F as b5,
      0x00..=0x7F as b6,
      0x00..=0x7F as b7,
      .. bytes,
    ] => {
      chars.push(b0.to_char())
      chars.push(b1.to_char())
      chars.push(b2.to_char())
      chars.push(b3.to_char())
      chars.push(b4.to_char())
      chars.push(b5.to_char())
      chars.push(b6.to_char())
      chars.push(b7.to_char())
      continue bytes
    }
    [
      0x00..=0x7F as b0,
      0x00..=0x7F as b1,
      0x00..=0x7F as b2,
      0x00..=0x7F as b3,
      .. bytes,
    ] => {
      chars.push(b0.to_char())
      chars.push(b1.to_char())
      chars.push(b2.to_char())
      chars.push(b3.to_char())
      continue bytes
    }
    [0x00..=0x7F as b0, 0x00..=0x7F as b1, .. bytes] => {
      chars.push(b0.to_char())
      chars.push(b1.to_char())
      continue bytes
    }
    [0x00..=0x7F as b0, .. bytes] => {
      chars.push(b0.to_char())
      continue bytes
    }
    [
      0xC2..=0xDF as b0,
      0x80..=0xBF as b1,
      0xC2..=0xDF as b2,
      0x80..=0xBF as b3,
      .. bytes,
    ] => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let b2 = b2.to_int()
      let b3 = b3.to_int()
      let char = ((b0 & 0x1F) << 6) + (b1 & 0x3F)
      chars.push(char.unsafe_to_char())
      let char = ((b2 & 0x1F) << 6) + (b3 & 0x3F)
      chars.push(char.unsafe_to_char())
      continue bytes
    }
    [0xC2..=0xDF as b0, 0x80..=0xBF as b1, .. bytes] => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let char = ((b0 & 0x1F) << 6) + (b1 & 0x3F)
      chars.push(char.unsafe_to_char())
      continue bytes
    }
    [0xE0 as b0, 0xA0..=0xBF as b1, 0x80..=0xBF as b2, .. bytes]
    | [0xED as b0, 0x80..=0x9F as b1, 0x80..=0xBF as b2, .. bytes]
    | [0xE1..=0xEF as b0, 0x80..=0xBF as b1, 0x80..=0xBF as b2, .. bytes] => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let b2 = b2.to_int()
      let char = ((b0 & 0x0F) << 12) + ((b1 & 0x3F) << 6) + (b2 & 0x3F)
      chars.push(char.unsafe_to_char())
      continue bytes
    }
    [
      0xF0 as b0,
      0x90..=0xBF as b1,
      0x80..=0xBF as b2,
      0x80..=0xBF as b3,
      .. bytes,
    ]
    | [
      0xF1..=0xF3 as b0,
      0x80..=0xBF as b1,
      0x80..=0xBF as b2,
      0x80..=0xBF as b3,
      .. bytes,
    ]
    | [
      0xF4 as b0,
      0x80..=0x8F as b1,
      0x80..=0xBF as b2,
      0x80..=0xBF as b3,
      .. bytes,
    ] => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let b2 = b2.to_int()
      let b3 = b3.to_int()
      let char = ((b0 & 0x07) << 18) +
        ((b1 & 0x3F) << 12) +
        ((b2 & 0x3F) << 6) +
        (b3 & 0x3F)
      chars.push(char.unsafe_to_char())
      continue bytes
    }
    [..] as input => raise DecodingError::Malformed(input)
  }
}

///|
pub fn decode_utf8_to_char_array_regex(
  bytes : @bytes.View,
  chars : Array[Char],
) -> Unit raise DecodingError {
  chars.reserve_capacity(chars.length() + bytes.length())
  for curr = bytes {
    match curr using regex {
      [] => return
      ["(?utf8:.)" as c, .. rest] => {
        chars.push(c)
        continue rest
      }
      bytes => raise DecodingError::Malformed(bytes)
    }
  }
}

///|
#borrow(bytes, chars)
extern "c" fn tonyfettes_encoding_v2_decode_utf8_to_char_array(
  bytes : @bytes.View,
  chars : Array[Char],
) -> Int = "tonyfettes_encoding_v2_decode_utf8_to_char_array"

///|
pub fn decode_utf8_to_char_array_c(
  bytes : @bytes.View,
  chars : Array[Char],
) -> Unit raise DecodingError {
  chars.reserve_capacity(chars.length() + bytes.length())
  let result = tonyfettes_encoding_v2_decode_utf8_to_char_array(bytes, chars)
  if result >= 0 {
    raise DecodingError::Malformed(bytes[result:])
  }
}

///|
pub fn validate_utf8_naive(bytes : @bytes.View) -> Int {
  for length = 0, bytes = bytes {
    match bytes {
      [] => return length
      [0x00..=0x7F, .. bytes]
      | [0xC2..=0xDF, 0x80..=0xBF, .. bytes]
      | [0xE0, 0xA0..=0xBF, 0x80..=0xBF, .. bytes]
      | [0xE1..=0xEC, 0x80..=0xBF, 0x80..=0xBF, .. bytes]
      | [0xED, 0x80..=0x9F, 0x80..=0xBF, .. bytes]
      | [0xEE..=0xEF, 0x80..=0xBF, 0x80..=0xBF, .. bytes]
      | [0xF0, 0x90..=0xBF, 0x80..=0xBF, 0x80..=0xBF, .. bytes]
      | [0xF1..=0xF3, 0x80..=0xBF, 0x80..=0xBF, 0x80..=0xBF, .. bytes]
      | [0xF4, 0x80..=0x8F, 0x80..=0xBF, 0x80..=0xBF, .. bytes] =>
        continue length + 1, bytes
      [..] => return -1
    }
  }
}

///|
pub fn unsafe_decode_utf8_to_char_array_naive(
  bytes : @bytes.View,
  chars : Array[Char],
) -> Unit raise DecodingError {
  chars.reserve_capacity(chars.length() + bytes.length())
  loop bytes {
    [] => return
    [
      0x00..=0x7F as b0,
      0x00..=0x7F as b1,
      0x00..=0x7F as b2,
      0x00..=0x7F as b3,
      .. bytes,
    ] => {
      chars.push(b0.to_char())
      chars.push(b1.to_char())
      chars.push(b2.to_char())
      chars.push(b3.to_char())
      continue bytes
    }
    [0x00..=0x7F as b0, .. bytes] => {
      chars.push(b0.to_char())
      continue bytes
    }
    [0x80..=0xDF as b0, b1, 0x80..=0xDF as b2, b3, .. bytes] => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let char = ((b0 & 0x1F) << 6) + (b1 & 0x3F)
      chars.push(char.unsafe_to_char())
      let b2 = b2.to_int()
      let b3 = b3.to_int()
      let char = ((b2 & 0x1F) << 6) + (b3 & 0x3F)
      chars.push(char.unsafe_to_char())
      continue bytes
    }
    [0x80..=0xDF as b0, b1, .. bytes] => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let char = ((b0 & 0x1F) << 6) + (b1 & 0x3F)
      chars.push(char.unsafe_to_char())
      continue bytes
    }
    [0xE0..=0xEF as b0, b1, b2, .. bytes] => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let b2 = b2.to_int()
      let char = ((b0 & 0x0F) << 12) + ((b1 & 0x3F) << 6) + (b2 & 0x3F)
      chars.push(char.unsafe_to_char())
      continue bytes
    }
    [b0, b1, b2, b3, .. bytes] => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let b2 = b2.to_int()
      let b3 = b3.to_int()
      let char = ((b0 & 0x07) << 18) +
        ((b1 & 0x3F) << 12) +
        ((b2 & 0x3F) << 6) +
        (b3 & 0x3F)
      chars.push(char.unsafe_to_char())
      continue bytes
    }
    [..] as input => raise DecodingError::Malformed(input)
  }
}

///|
#borrow(bytes)
pub extern "c" fn validate_utf8_c(bytes : @bytes.View) -> Int = "tonyfettes_encoding_v2_validate_utf8_to_char_array"

///|
#borrow(bytes, chars)
pub extern "c" fn tonyfettes_encoding_v2_unsafe_decode_utf8_to_char_array(
  bytes : @bytes.View,
  chars : Array[Char],
) = "tonyfettes_encoding_v2_unsafe_decode_utf8_to_char_array"

///|
pub fn unsafe_decode_utf8_to_char_array_c(
  bytes : @bytes.View,
  chars : Array[Char],
) -> Unit {
  chars.reserve_capacity(chars.length() + bytes.length())
  tonyfettes_encoding_v2_unsafe_decode_utf8_to_char_array(bytes, chars)
}
