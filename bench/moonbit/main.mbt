///|
fn main {
  try {
    let bytes = @fs.read_file_to_bytes("english.utf8.txt")
    let naive_unicode : FixedArray[Char] = FixedArray::make(
      bytes.length(),
      '\u{0}',
    )
    let c_unicode : FixedArray[Char] = FixedArray::make(bytes.length(), '\u{0}')
    let naive_length = decode_utf8_to_char_array_naive(bytes, naive_unicode)
    let c_length = decode_utf8_to_char_array_c(bytes, c_unicode)
    assert_eq(naive_length, c_length)
    assert_eq(naive_unicode, c_unicode)
    for i in 0..<5 {
      ignore(decode_utf8_to_char_array_naive(bytes, naive_unicode))
    }
    let start = @uv.hrtime()
    for i in 0..<1000 {
      ignore(decode_utf8_to_char_array_naive(bytes, naive_unicode))
    }
    let end = @uv.hrtime()
    println((end - start).to_double() / 1_000_000)
  } catch {
    error => println("Error: \{error}")
  }
}
