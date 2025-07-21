///|
suberror DecodingError {
  Malformed(@bytes.View)
} derive(Show)

///|
pub fn decode_utf8_to_char_array_naive(
  bytes : @bytes.View,
  chars : Array[Char]
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
  chars : Array[Char]
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
      0x00..=0x7F as b8,
      0x00..=0x7F as b9,
      0x00..=0x7F as b10,
      0x00..=0x7F as b11,
      0x00..=0x7F as b12,
      0x00..=0x7F as b13,
      0x00..=0x7F as b14,
      0x00..=0x7F as b15,
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
      chars.push(b8.to_char())
      chars.push(b9.to_char())
      chars.push(b10.to_char())
      chars.push(b11.to_char())
      chars.push(b12.to_char())
      chars.push(b13.to_char())
      chars.push(b14.to_char())
      chars.push(b15.to_char())
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
    [0x00..=0x7F as b0, .. bytes] => {
      chars.push(b0.to_char())
      continue bytes
    }
    [
      0xC2..=0xDF as b0,
      0x80..=0xBF as b1,
      0xC2..=0xDF as b2,
      0x80..=0xBF as b3,
      0xC2..=0xDF as b4,
      0x80..=0xBF as b5,
      0xC2..=0xDF as b6,
      0x80..=0xBF as b7,
      .. bytes,
    ] => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let b2 = b2.to_int()
      let b3 = b3.to_int()
      let b4 = b4.to_int()
      let b5 = b5.to_int()
      let b6 = b6.to_int()
      let b7 = b7.to_int()
      let c0 = ((b0 & 0x1F) << 6) + (b1 & 0x3F)
      let c1 = ((b2 & 0x1F) << 6) + (b3 & 0x3F)
      let c2 = ((b4 & 0x1F) << 6) + (b5 & 0x3F)
      let c3 = ((b6 & 0x1F) << 6) + (b7 & 0x3F)
      chars.push(c0.unsafe_to_char())
      chars.push(c1.unsafe_to_char())
      chars.push(c2.unsafe_to_char())
      chars.push(c3.unsafe_to_char())
      continue bytes
    }
    [0xC2..=0xDF as b0, 0x80..=0xBF as b1, .. bytes] => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let char = ((b0 & 0x1F) << 6) + (b1 & 0x3F)
      chars.push(char.unsafe_to_char())
      continue bytes
    }
    [
      0xE1..=0xEC as b0,
      0x80..=0xBF as b1,
      0x80..=0xBF as b2,
      0xE1..=0xEC as b3,
      0x80..=0xBF as b4,
      0x80..=0xBF as b5,
      0xE1..=0xEC as b6,
      0x80..=0xBF as b7,
      0x80..=0xBF as b8,
      0xE1..=0xEC as b9,
      0x80..=0xBF as b10,
      0x80..=0xBF as b11,
      .. bytes,
    ] => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let b2 = b2.to_int()
      let b3 = b3.to_int()
      let b4 = b4.to_int()
      let b5 = b5.to_int()
      let b6 = b6.to_int()
      let b7 = b7.to_int()
      let b8 = b8.to_int()
      let b9 = b9.to_int()
      let b10 = b10.to_int()
      let b11 = b11.to_int()
      let c0 = ((b0 & 0x0F) << 12) + ((b1 & 0x3F) << 6) + (b2 & 0x3F)
      let c1 = ((b3 & 0x0F) << 12) + ((b4 & 0x3F) << 6) + (b5 & 0x3F)
      let c2 = ((b6 & 0x0F) << 12) + ((b7 & 0x3F) << 6) + (b8 & 0x3F)
      let c3 = ((b9 & 0x0F) << 12) + ((b10 & 0x3F) << 6) + (b11 & 0x3F)
      chars.push(c0.unsafe_to_char())
      chars.push(c1.unsafe_to_char())
      chars.push(c2.unsafe_to_char())
      chars.push(c3.unsafe_to_char())
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
  chars : Array[Char]
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
  bytes : Bytes,
  bytes_offset : Int,
  bytes_length : Int,
  chars : Array[Char]
) -> Int = "tonyfettes_encoding_v2_decode_utf8_to_char_array"

///|
pub fn decode_utf8_to_char_array_c(
  bytes : @bytes.View,
  chars : Array[Char]
) -> Unit raise DecodingError {
  // chars.reserve_capacity(chars.length() + bytes.length())
  let result = tonyfettes_encoding_v2_decode_utf8_to_char_array(
    bytes.data(),
    bytes.start_offset(),
    bytes.length(),
    chars,
  )
  if result >= 0 {
    raise DecodingError::Malformed(bytes[result:])
  }
}

///|
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
pub fn unsafe_decode_utf8_to_char_array_naive(
  bytes : @bytes.View,
  chars : Array[Char]
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
extern "c" fn tonyfettes_encoding_v2_validate_utf8(
  bytes : Bytes,
  offset : Int,
  length : Int
) -> Bool = "tonyfettes_encoding_v2_validate_utf8"

pub fn validate_utf8_c(bytes : @bytes.View) -> Bool {
  tonyfettes_encoding_v2_validate_utf8(
    bytes.data(),
    bytes.start_offset(),
    bytes.length(),
  )
}

///|
#borrow(bytes, chars)
pub extern "c" fn tonyfettes_encoding_v2_unsafe_decode_utf8_to_char_array(
  bytes : Bytes,
  bytes_offset : Int,
  bytes_length : Int,
  chars : Array[Char]
) = "tonyfettes_encoding_v2_unsafe_decode_utf8_to_char_array"

///|
pub fn unsafe_decode_utf8_to_char_array_c(
  bytes : @bytes.View,
  chars : Array[Char]
) -> Unit {
  tonyfettes_encoding_v2_unsafe_decode_utf8_to_char_array(
    bytes.data(),
    bytes.start_offset(),
    bytes.length(),
    chars,
  )
}
