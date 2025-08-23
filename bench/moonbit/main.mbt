///|
fn main {
  try {
    let bytes = @fs.read_file_to_bytes("english.utf8.txt")[:]
    let naive_unicode : FixedArray[Char] = FixedArray::make(
      bytes.length(),
      '\u{0}',
    )
    let c_unicode : FixedArray[Char] = FixedArray::make(bytes.length(), '\u{0}')
    let bitstring_unicode : FixedArray[Char] = FixedArray::make(
      bytes.length(),
      '\u{0}',
    )
    let naive_length = decode_utf8_to_char_array_naive(bytes, naive_unicode)
    let c_length = decode_utf8_to_char_array_c(bytes, c_unicode)
    let bitstring_length = decode_utf8_to_char_array_bitstring(
      bytes, bitstring_unicode,
    )
    assert_eq(naive_length, c_length)
    assert_eq(naive_length, bitstring_length)
    assert_eq(naive_unicode, c_unicode)
    assert_eq(naive_unicode, bitstring_unicode)
    // Naive
    for _ in 0..<5 {
      ignore(decode_utf8_to_char_array_naive(bytes, naive_unicode))
    }
    let clock = @bench.monotonic_clock_start()
    for _ in 0..<1000 {
      ignore(decode_utf8_to_char_array_naive(bytes, naive_unicode))
    }
    println("moonbit: \{@bench.monotonic_clock_end(clock) / 1000}")
    // C
    for _ in 0..<5 {
      ignore(decode_utf8_to_char_array_c(bytes, c_unicode))
    }
    let clock = @bench.monotonic_clock_start()
    for _ in 0..<1000 {
      ignore(decode_utf8_to_char_array_c(bytes, c_unicode))
    }
    println("c: \{@bench.monotonic_clock_end(clock) / 1000}")
    // Bitstring
    for _ in 0..<5 {
      ignore(decode_utf8_to_char_array_bitstring(bytes, c_unicode))
    }
    let clock = @bench.monotonic_clock_start()
    for _ in 0..<1000 {
      ignore(decode_utf8_to_char_array_bitstring(bytes, c_unicode))
    }
    println("bitstring: \{@bench.monotonic_clock_end(clock) / 1000}")
  } catch {
    error => println("Error: \{error}")
  }
}
