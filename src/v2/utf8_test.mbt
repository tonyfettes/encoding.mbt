///|
test {
  let bytes = @fs.read_file_to_bytes("src/v2/utf8-test.txt")
  let values_0 = []
  decode_utf8_to_char_array_0(bytes, values_0)
  let values_1 = []
  decode_utf8_to_char_array_1(bytes, values_1)
  assert_eq(values_0, values_1)
  let values_3 = []
  decode_utf8_to_char_array_3(bytes, values_3)
  assert_eq(values_0, values_3)
}

///|
test "chinese" (b : @bench.T) {
  let bytes = @fs.read_file_to_bytes(
    "unicode_lipsum/wikipedia_mars/chinese.utf8.txt",
  )
  let errors = []
  b.bench(name="moonbit", () => {
    let values_0 = []
    decode_utf8_to_char_array_0(bytes, values_0) catch {
      e => errors.push(e)
    }
  })
  for e in errors {
    raise e
  }
  b.bench(name="regex", () => {
    let values_1 = []
    decode_utf8_to_char_array_1(bytes, values_1) catch {
      e => errors.push(e)
    }
  })
  b.bench(name="c", () => try {
    let values_3 = []
    decode_utf8_to_char_array_3(bytes, values_3)
  } catch {
    e => errors.push(e)
  })
  for e in errors {
    raise e
  }
}

///|
test "english" (b : @bench.T) {
  let bytes = @fs.read_file_to_bytes(
    "unicode_lipsum/wikipedia_mars/english.utf8.txt",
  )
  let errors = []
  b.bench(name="moonbit", () => {
    let values_0 = []
    decode_utf8_to_char_array_0(bytes, values_0) catch {
      e => errors.push(e)
    }
  })
  for e in errors {
    raise e
  }
  b.bench(name="c", () => try {
    let values_3 = []
    decode_utf8_to_char_array_3(bytes, values_3)
  } catch {
    e => errors.push(e)
  })
  for e in errors {
    raise e
  }
}

test "arabic" (b : @bench.T) {
  let bytes = @fs.read_file_to_bytes(
    "unicode_lipsum/wikipedia_mars/arabic.utf8.txt",
  )
  let errors = []
  b.bench(name="moonbit", () => {
    let values_0 = []
    decode_utf8_to_char_array_0(bytes, values_0) catch {
      e => errors.push(e)
    }
  })
  for e in errors {
    raise e
  }
  b.bench(name="c", () => try {
    let values_3 = []
    decode_utf8_to_char_array_3(bytes, values_3)
  } catch {
    e => errors.push(e)
  })
  for e in errors {
    raise e
  }
}