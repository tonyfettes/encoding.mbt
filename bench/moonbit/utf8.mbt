///|
pub fn decode_utf8_to_char_array_naive(
  bytes : @bytes.View,
  chars : FixedArray[Char],
) -> Int {
  let soff = bytes.start_offset()
  loop (0, bytes) {
    (tlen, []) => return tlen
    (
      tlen,
      [
        0x00..=0x7F as b0,
        0x00..=0x7F as b1,
        0x00..=0x7F as b2,
        0x00..=0x7F as b3,
        0x00..=0x7F as b4,
        0x00..=0x7F as b5,
        0x00..=0x7F as b6,
        0x00..=0x7F as b7,
        .. rest,
      ],
    ) => {
      chars.unsafe_set(tlen, b0.to_char())
      chars.unsafe_set(tlen + 1, b1.to_char())
      chars.unsafe_set(tlen + 2, b2.to_char())
      chars.unsafe_set(tlen + 3, b3.to_char())
      chars.unsafe_set(tlen + 4, b4.to_char())
      chars.unsafe_set(tlen + 5, b5.to_char())
      chars.unsafe_set(tlen + 6, b6.to_char())
      chars.unsafe_set(tlen + 7, b7.to_char())
      continue (tlen + 8, rest)
    }
    (tlen, [0x00..=0x7F as b0, .. rest]) => {
      chars.unsafe_set(tlen, b0.to_char())
      continue (tlen + 1, rest)
    }
    (tlen, [0xC2..=0xDF as b0, 0x80..=0xBF as b1, .. rest]) => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let char = ((b0 & 0x1F) << 6) + (b1 & 0x3F)
      chars.unsafe_set(tlen, char.unsafe_to_char())
      continue (tlen + 1, rest)
    }
    (
      tlen,
      [0xE0 as b0, 0xA0..=0xBF as b1, 0x80..=0xBF as b2, .. rest]
      | [0xE1..=0xEC as b0, 0x80..=0xBF as b1, 0x80..=0xBF as b2, .. rest]
      | [0xED as b0, 0x80..=0x9F as b1, 0x80..=0xBF as b2, .. rest]
      | [0xEE..=0xEF as b0, 0x80..=0xBF as b1, 0x80..=0xBF as b2, .. rest],
    ) => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let b2 = b2.to_int()
      let char = ((b0 & 0x0F) << 12) + ((b1 & 0x3F) << 6) + (b2 & 0x3F)
      chars.unsafe_set(tlen, char.unsafe_to_char())
      continue (tlen + 1, rest)
    }
    (
      tlen,
      [
        0xF0 as b0,
        0x90..=0xBF as b1,
        0x80..=0xBF as b2,
        0x80..=0xBF as b3,
        .. rest,
      ]
      | [
        0xF1..=0xF3 as b0,
        0x80..=0xBF as b1,
        0x80..=0xBF as b2,
        0x80..=0xBF as b3,
        .. rest,
      ]
      | [
        0xF4 as b0,
        0x80..=0x8F as b1,
        0x80..=0xBF as b2,
        0x80..=0xBF as b3,
        .. rest,
      ],
    ) => {
      let b0 = b0.to_int()
      let b1 = b1.to_int()
      let b2 = b2.to_int()
      let b3 = b3.to_int()
      let char = ((b0 & 0x07) << 18) +
        ((b1 & 0x3F) << 12) +
        ((b2 & 0x3F) << 6) +
        (b3 & 0x3F)
      chars.unsafe_set(tlen, char.unsafe_to_char())
      continue (tlen + 1, rest)
    }
    (_, [..] as input) => soff - input.start_offset() - 1
  }
}

///|
pub fn decode_utf8_to_char_array_bitstring(
  bytes : @bytes.View,
  chars : FixedArray[Char],
) -> Int {
  let soff = bytes.start_offset()
  for tlen = 0, bytes = bytes {
    if bytes.start_offset() % 8 == 0 &&
      bytes is [u64le(d0), .. rest] &&
      (d0 & 0x8080808080808080) == 0 {
      let b0 = (d0 >> 0).to_byte()
      let b1 = (d0 >> 8).to_byte()
      let b2 = (d0 >> 16).to_byte()
      let b3 = (d0 >> 24).to_byte()
      let b4 = (d0 >> 32).to_byte()
      let b5 = (d0 >> 40).to_byte()
      let b6 = (d0 >> 48).to_byte()
      let b7 = (d0 >> 56).to_byte()
      chars.unsafe_set(tlen, b0.to_char())
      chars.unsafe_set(tlen + 1, b1.to_char())
      chars.unsafe_set(tlen + 2, b2.to_char())
      chars.unsafe_set(tlen + 3, b3.to_char())
      chars.unsafe_set(tlen + 4, b4.to_char())
      chars.unsafe_set(tlen + 5, b5.to_char())
      chars.unsafe_set(tlen + 6, b6.to_char())
      chars.unsafe_set(tlen + 7, b7.to_char())
      continue tlen + 8, rest
    }
    match bytes {
      [] => break tlen
      [0x00..=0x7F as b0, .. rest] => {
        chars.unsafe_set(tlen, b0.to_char())
        continue tlen + 1, rest
      }
      [0xC2..=0xDF as b0, 0x80..=0xBF as b1, .. rest] => {
        let b0 = b0.to_int()
        let b1 = b1.to_int()
        let char = ((b0 & 0x1F) << 6) + (b1 & 0x3F)
        chars.unsafe_set(tlen, char.unsafe_to_char())
        continue tlen + 1, rest
      }
      [0xE0 as b0, 0xA0..=0xBF as b1, 0x80..=0xBF as b2, .. rest]
      | [0xE1..=0xEC as b0, 0x80..=0xBF as b1, 0x80..=0xBF as b2, .. rest]
      | [0xED as b0, 0x80..=0x9F as b1, 0x80..=0xBF as b2, .. rest]
      | [0xEE..=0xEF as b0, 0x80..=0xBF as b1, 0x80..=0xBF as b2, .. rest] => {
        let b0 = b0.to_int()
        let b1 = b1.to_int()
        let b2 = b2.to_int()
        let char = ((b0 & 0x0F) << 12) + ((b1 & 0x3F) << 6) + (b2 & 0x3F)
        chars.unsafe_set(tlen, char.unsafe_to_char())
        continue tlen + 1, rest
      }
      [
        0xF0 as b0,
        0x90..=0xBF as b1,
        0x80..=0xBF as b2,
        0x80..=0xBF as b3,
        .. rest,
      ]
      | [
        0xF1..=0xF3 as b0,
        0x80..=0xBF as b1,
        0x80..=0xBF as b2,
        0x80..=0xBF as b3,
        .. rest,
      ]
      | [
        0xF4 as b0,
        0x80..=0x8F as b1,
        0x80..=0xBF as b2,
        0x80..=0xBF as b3,
        .. rest,
      ] => {
        let b0 = b0.to_int()
        let b1 = b1.to_int()
        let b2 = b2.to_int()
        let b3 = b3.to_int()
        let char = ((b0 & 0x07) << 18) +
          ((b1 & 0x3F) << 12) +
          ((b2 & 0x3F) << 6) +
          (b3 & 0x3F)
        chars.unsafe_set(tlen, char.unsafe_to_char())
        continue tlen + 1, rest
      }
      [..] as input => break soff - input.start_offset() - 1
    }
  }
}

///|
#borrow(bytes, chars)
extern "c" fn tonyfettes_encoding_v2_decode_utf8_to_char_array(
  bytes : Bytes,
  bytes_offset : Int,
  bytes_length : Int,
  chars : FixedArray[Char],
) -> Int = "tonyfettes_encoding_v2_decode_utf8_to_char_array"

///|
pub fn decode_utf8_to_char_array_c(
  bytes : @bytes.View,
  chars : FixedArray[Char],
) -> Int {
  tonyfettes_encoding_v2_decode_utf8_to_char_array(
    bytes.data(),
    bytes.start_offset(),
    bytes.length(),
    chars,
  )
}
