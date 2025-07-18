///|
test {
  for
    path in [
      "src/v2/utf8-test.txt", "unicode_lipsum/wikipedia_mars/chinese.utf8.txt", "unicode_lipsum/wikipedia_mars/english.utf8.txt",
      "unicode_lipsum/wikipedia_mars/arabic.utf8.txt",
    ] {
    let bytes = @fs.read_file_to_bytes(path)
    let values_naive = []
    decode_utf8_to_char_array_naive(bytes, values_naive)
    let values_regex = []
    decode_utf8_to_char_array_regex(bytes, values_regex)
    assert_eq(values_naive, values_regex)
    let values_vector = []
    decode_utf8_to_char_array_vector(bytes, values_vector)
    assert_eq(values_naive, values_vector)
    let values_c = []
    decode_utf8_to_char_array_c(bytes, values_c)
    assert_eq(values_naive, values_c)
  }
}

///|
test "decode/english" (b : @bench.T) {
  let bytes = @fs.read_file_to_bytes(
    "unicode_lipsum/wikipedia_mars/english.utf8.txt",
  )
  let errors = []
  b.bench(name="regex", () => decode_utf8_to_char_array_regex(bytes, []) catch {
    e => errors.push(e)
  })
  b.bench(name="naive", () => {
    let values = []
    decode_utf8_to_char_array_naive(bytes, values) catch {
      e => errors.push(e)
    }
  })
  b.bench(name="vector", () => decode_utf8_to_char_array_vector(bytes, []) catch {
    e => errors.push(e)
  })
  b.bench(name="c", () => decode_utf8_to_char_array_c(bytes, []) catch {
    e => errors.push(e)
  })
}

///|
test "decode/chinese" (b : @bench.T) {
  let bytes = @fs.read_file_to_bytes("src/v2/chinese.utf8.txt")
  let errors = []
  b.bench(name="regex", () => decode_utf8_to_char_array_regex(bytes, []) catch {
    e => errors.push(e)
  })
  b.bench(name="naive", () => {
    let values = []
    decode_utf8_to_char_array_naive(bytes, values) catch {
      e => errors.push(e)
    }
  })
  b.bench(name="vector", () => decode_utf8_to_char_array_vector(bytes, []) catch {
    e => errors.push(e)
  })
  b.bench(name="c", () => decode_utf8_to_char_array_c(bytes, []) catch {
    e => errors.push(e)
  })
}

///|
test "decode/arabic" (b : @bench.T) {
  let bytes = @fs.read_file_to_bytes("src/v2/arabic.utf8.txt")
  let errors = []
  b.bench(name="regex", () => decode_utf8_to_char_array_regex(bytes, []) catch {
    e => errors.push(e)
  })
  b.bench(name="naive", () => {
    let values = []
    decode_utf8_to_char_array_naive(bytes, values) catch {
      e => errors.push(e)
    }
  })
  b.bench(name="vector", () => decode_utf8_to_char_array_vector(bytes, []) catch {
    e => errors.push(e)
  })
  b.bench(name="c", () => decode_utf8_to_char_array_c(bytes, []) catch {
    e => errors.push(e)
  })
}

///|
test "validate/english" (b : @bench.T) {
  let bytes = @fs.read_file_to_bytes(
    "unicode_lipsum/wikipedia_mars/english.utf8.txt",
  )
  b.bench(name="naive/validate", () => validate_utf8_naive(bytes) |> ignore())
  b.bench(name="naive/decode", () => decode_utf8_to_char_array_naive(bytes, []) catch {
    _ => ()
  })
  b.bench(name="naive/unsafe_decode", () => unsafe_decode_utf8_to_char_array_naive(
    bytes,
    [],
  ) catch {
    _ => ()
  })
  b.bench(name="c/validate", () => validate_utf8_c(bytes) |> ignore())
  b.bench(name="c/decode", () => decode_utf8_to_char_array_c(bytes, []) catch {
    _ => ()
  })
  b.bench(name="c/unsafe_decode", () => unsafe_decode_utf8_to_char_array_c(
    bytes,
    [],
  ))
}

///|
test "validate/chinese" (b : @bench.T) {
  let bytes = @fs.read_file_to_bytes("src/v2/chinese.utf8.txt")
  b.bench(name="naive/validate", () => validate_utf8_naive(bytes) |> ignore())
  b.bench(name="naive/decode", () => decode_utf8_to_char_array_naive(bytes, []) catch {
    _ => ()
  })
  b.bench(name="naive/unsafe_decode", () => unsafe_decode_utf8_to_char_array_naive(
    bytes,
    [],
  ) catch {
    _ => ()
  })
  b.bench(name="c/validate", () => validate_utf8_c(bytes) |> ignore())
  b.bench(name="c/decode", () => decode_utf8_to_char_array_c(bytes, []) catch {
    _ => ()
  })
  b.bench(name="c/unsafe_decode", () => unsafe_decode_utf8_to_char_array_c(
    bytes,
    [],
  ))
}

///|
test "validate/arabic" (b : @bench.T) {
  let bytes = @fs.read_file_to_bytes("src/v2/arabic.utf8.txt")
  b.bench(name="naive/validate", () => validate_utf8_naive(bytes) |> ignore())
  b.bench(name="naive/decode", () => decode_utf8_to_char_array_naive(bytes, []) catch {
    _ => ()
  })
  b.bench(name="naive/unsafe_decode", () => unsafe_decode_utf8_to_char_array_naive(
    bytes,
    [],
  ) catch {
    _ => ()
  })
  b.bench(name="c/validate", () => validate_utf8_c(bytes) |> ignore())
  b.bench(name="c/decode", () => decode_utf8_to_char_array_c(bytes, []) catch {
    _ => ()
  })
  b.bench(name="c/unsafe_decode", () => unsafe_decode_utf8_to_char_array_c(
    bytes,
    [],
  ))
}
