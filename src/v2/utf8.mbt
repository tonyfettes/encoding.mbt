///|
suberror DecodingError {
  Malformed(@bytes.View)
} derive(Show)

///|
pub fn decode_utf8_to_char_array_0(
  bytes : @bytes.View,
  unicode : Array[Char],
) -> Unit raise DecodingError {
  loop bytes {
    [] => return
    [0x00..=0x7F as b0, .. bytes] => {
      unicode.push(b0.to_char())
      continue bytes
    }
    [0xC2..=0xDF as b0, 0x80..=0xBF as b1, .. bytes] => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let char = ((b0 & 0x1F) << 6) + (b1 & 0x3F)
      unicode.push(char.unsafe_to_char())
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
      unicode.push(char.unsafe_to_char())
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
      unicode.push(char.unsafe_to_char())
      continue bytes
    }
    [..] as input => raise DecodingError::Malformed(input)
  }
}

///|
pub fn decode_utf8_to_char_array_1(
  bytes : @bytes.View,
  unicode : Array[Char],
) -> Unit raise DecodingError {
  for curr = bytes {
    match curr using regex {
      [] => return
      ["(?utf8:.)" as c, .. rest] => {
        unicode.push(c)
        continue rest
      }
      bytes => raise DecodingError::Malformed(bytes)
    }
  }
}

///|
let decode_utf8_to_char_array_2_automata : Array[Int] = [
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, // 00..1f
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, // 20..3f
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, // 40..5f
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, // 60..7f
   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
  9, 9, 9, 9, 9, 9, // 80..9f
   7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
  7, 7, 7, 7, 7, 7, // a0..bf
   8, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
  2, 2, 2, 2, 2, 2, // c0..df
   0xa, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x4, 0x3, 0x3, // e0..ef
   0xb, 0x6, 0x6, 0x6, 0x5, 0x8, 0x8, 0x8, 0x8, 0x8, 0x8, 0x8, 0x8, 0x8, 0x8, 0x8, // f0..ff
   0x0, 0x1, 0x2, 0x3, 0x5, 0x8, 0x7, 0x1, 0x1, 0x1, 0x4, 0x6, 0x1, 0x1, 0x1, 0x1, // s0..s0
   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0,
  1, 1, 1, 1, 1, 1, // s1..s2
   1, 2, 1, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1,
  1, 1, 1, 1, 1, 1, // s3..s4
   1, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 3,
  1, 1, 1, 1, 1, 1, // s5..s6
   1, 3, 1, 1, 1, 1, 1, 3, 1, 3, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, // s7..s8
]

///|
pub fn decode_utf8_to_char_array_2(
  bytes : @bytes.View,
  unicode : Array[Char],
) -> Unit raise DecodingError {
  let mut code = 0
  let mut state = 0
  for byte in bytes {
    let byte = byte.to_int()
    let ty = decode_utf8_to_char_array_2_automata[byte]
    code = if state != 0 {
      (byte & 0x3f) | (code << 6)
    } else {
      (0xff >> ty) & byte
    }
    state = decode_utf8_to_char_array_2_automata[256 + state * 16 + ty]
    if state == 0 {
      unicode.push(code.unsafe_to_char())
    }
  }
  if state != 0 {
    raise DecodingError::Malformed(bytes)
  }
}

///|
extern "c" fn moonbit_encoding_v2_utf8_decode_0(
  bytes : Bytes,
  bytes_offset : Int,
  bytes_length : Int,
  unicode : FixedArray[Int],
) -> Int = "moonbit_encoding_v2_utf8_decode_0"

///|
extern "c" fn moonbit_encoding_v2_utf8_decode_1(
  bytes : Bytes,
  bytes_offset : Int,
  bytes_length : Int,
  unicode : FixedArray[Int],
) -> Int = "moonbit_encoding_v2_utf8_decode_1"

///|
pub fn decode_utf8_to_char_array_3(
  bytes : @bytes.View,
  unicode : Array[Char],
) -> Unit raise DecodingError {
  let fixed_array : FixedArray[Int] = FixedArray::make(bytes.length(), '\u{00}')
  let result = moonbit_encoding_v2_utf8_decode_0(
    bytes.data(),
    bytes.start_offset(),
    bytes.length(),
    fixed_array,
  )
  if result < 0 {
    raise DecodingError::Malformed(bytes)
  }
  for i in 0..<result {
    unicode.push(fixed_array[i].unsafe_to_char())
  }
}

///|
pub fn decode_utf8_to_char_array_4(
  bytes : @bytes.View,
  unicode : Array[Char],
) -> Unit raise DecodingError {
  let fixed_array : FixedArray[Int] = FixedArray::make(bytes.length(), '\u{00}')
  let result = moonbit_encoding_v2_utf8_decode_1(
    bytes.data(),
    bytes.start_offset(),
    bytes.length(),
    fixed_array,
  )
  if result < 0 {
    raise DecodingError::Malformed(bytes)
  }
  for i in 0..<result {
    unicode.push(fixed_array[i].unsafe_to_char())
  }
}
