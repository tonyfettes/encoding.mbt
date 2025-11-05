///|
fn String::to_utf16le_bytes(self : String) -> Bytes {
  let array = FixedArray::make(self.length() * 2, Byte::default())
  array.blit_from_string(0, self, 0, self.length())
  array.unsafe_reinterpret_as_bytes()
}

///|
test "streaming decoding UTF8 rabbit" {
  let inputs = [b"abc", b"\xf0", b"\x9f\x90\xb0"] // UTF8(🐰) == <F09F 90B0>
  let decoder = decoder(UTF8)
  inspect(decoder.consume(inputs[0]), content="abc")
  inspect(decoder.consume(inputs[1]), content="")
  inspect(decoder.consume(inputs[2]), content="🐰")
  assert_true(decoder.finish().is_empty())
}

///|
test "decode_to/UTF8/stream" {
  let inputs = [b"abc", b"\xf0", b"\x9f\x90\xb0"] // UTF8(🐰) == <F09F 90B0>
  let decoder = decoder(UTF8)
  let acc = StringBuilder::new()
  decoder.decode_to(inputs[0], acc, stream=true)
  inspect(acc, content="abc")
  decoder.decode_to(inputs[1], acc, stream=true)
  inspect(acc, content="abc")
  decoder.decode_to(inputs[2], acc, stream=true)
  inspect(acc, content="abc🐰")
}

///|
test "streaming decoding UTF16LE rabbit" {
  // UTF16LE(🐰) == <3DD8 30DC>
  let inputs = [
    b"\x3D", b"\xD8\x30\xDC", b"\x3D\xD8", b"\x30\xDC", b"\x3D\xD8\x30", b"\xDC",
  ]
  let decoder = decoder(UTF16LE)
  inspect(decoder.consume(inputs[0]), content="")
  inspect(decoder.consume(inputs[1]), content="🐰")
  inspect(decoder.consume(inputs[2]), content="")
  inspect(decoder.consume(inputs[3]), content="🐰")
  inspect(decoder.consume(inputs[4]), content="")
  inspect(decoder.consume(inputs[5]), content="🐰")
  assert_true(decoder.finish().is_empty())
}

///|
test "decode_to/UTF16LE/stream" {
  // UTF16LE(🐰) == <3DD8 30DC>
  let inputs = [
    b"\x3D", b"\xD8\x30\xDC", b"\x3D\xD8", b"\x30\xDC", b"\x3D\xD8\x30", b"\xDC",
  ]
  let decoder = decoder(UTF16LE)
  let acc = StringBuilder::new()
  decoder.decode_to(inputs[0], acc, stream=true)
  inspect(acc, content="")
  decoder.decode_to(inputs[1], acc, stream=true)
  inspect(acc, content="🐰")
  decoder.decode_to(inputs[2], acc, stream=true)
  inspect(acc, content="🐰")
  decoder.decode_to(inputs[3], acc, stream=true)
  inspect(acc, content="🐰🐰")
  decoder.decode_to(inputs[4], acc, stream=true)
  inspect(acc, content="🐰🐰")
  decoder.decode_to(inputs[5], acc, stream=true)
  inspect(acc, content="🐰🐰🐰")
}

///|
test "streaming decoding UTF16LE ASCII" {
  let ascii = "How do we grasp all the apples at once?"
  let from_array = Bytes::from_array
  {
    let decoder = decoder(UTF16LE)

    // NOTE: `to_bytes` means `to_utf16le_bytes` to MoonBit String
    let chunks = ascii.to_utf16le_bytes().to_array().chunks(17)
    assert_eq(chunks.length(), 5)

    // chunk by chunk
    assert_eq(
      from_array(chunks[0]),
      b"\x48\x00\x6f\x00\x77\x00\x20\x00\x64\x00\x6f\x00\x20\x00\x77\x00\x65",
    )
    inspect(decoder.consume(from_array(chunks[0])), content="How do w")
    assert_eq(
      from_array(chunks[1]),
      b"\x00\x20\x00\x67\x00\x72\x00\x61\x00\x73\x00\x70\x00\x20\x00\x61\x00",
    )
    inspect(decoder.consume(from_array(chunks[1])), content="e grasp a")
    assert_eq(
      from_array(chunks[2]),
      b"\x6c\x00\x6c\x00\x20\x00\x74\x00\x68\x00\x65\x00\x20\x00\x61\x00\x70",
    )
    inspect(decoder.consume(from_array(chunks[2])), content="ll the a")
    assert_eq(
      from_array(chunks[3]),
      b"\x00\x70\x00\x6c\x00\x65\x00\x73\x00\x20\x00\x61\x00\x74\x00\x20\x00",
    )
    inspect(decoder.consume(from_array(chunks[3])), content="pples at ")
    assert_eq(
      from_array(chunks[4]),
      b"\x6f\x00\x6e\x00\x63\x00\x65\x00\x3f\x00",
    )
    inspect(decoder.consume(from_array(chunks[4])), content="once?")
    // `decode_finish!()` is an alias for `decode!(b"", stream=false)`
    assert_true(decoder.finish().is_empty())
  }

  // check accumulator
  let decoder = decoder(UTF16LE)
  let acc = StringBuilder::new()
  for chunk in ascii.to_utf16le_bytes().to_array().chunks(7) {
    acc.write_string(decoder.consume(from_array(chunk)).to_string())
  }
  assert_true(decoder.finish().is_empty())
  assert_eq(acc.to_string(), ascii)
}

///|
test "streaming decoding UTF8 Emoji" {
  let art =
    #|   🎩
    #|   👶
    #| ✋👕🌂
    #|   ‼️
    #|   👞👞
  let art_bytes = encode(encoding=UTF8, art)
  let from_array = Bytes::from_array
  {
    let decoder = decoder(UTF8)
    let buf = @buffer.new(size_hint=art_bytes.length())
    buf.write_bytes(art_bytes)
    let chunks = buf.contents().to_array().chunks(13)
    assert_eq(chunks.length(), 4)

    // chunk by chunk
    assert_eq(
      from_array(chunks[0]),
      b"\x20\x20\x20\xf0\x9f\x8e\xa9\x0a\x20\x20\x20\xf0\x9f",
    )
    inspect(decoder.consume(from_array(chunks[0])), content="   🎩\n   ")
    assert_eq(
      from_array(chunks[1]),
      b"\x91\xb6\x0a\x20\xe2\x9c\x8b\xf0\x9f\x91\x95\xf0\x9f",
    )
    inspect(decoder.consume(from_array(chunks[1])), content="👶\n ✋👕")
    assert_eq(
      from_array(chunks[2]),
      b"\x8c\x82\x0a\x20\x20\x20\xe2\x80\xbc\xef\xb8\x8f\x0a",
    )
    inspect(decoder.consume(from_array(chunks[2])), content="🌂\n   ‼️\n")
    assert_eq(
      from_array(chunks[3]),
      b"\x20\x20\x20\xf0\x9f\x91\x9e\xf0\x9f\x91\x9e",
    )
    // stream default to false
    inspect(decoder.decode(from_array(chunks[3])), content="   👞👞")
  }

  // check accumulator
  let decoder = decoder(UTF8)
  let acc = StringBuilder::new()
  for chunk in art_bytes.to_array().chunks(7) {
    acc.write_string(decoder.consume(from_array(chunk)).to_string())
  }
  assert_true(decoder.finish().is_empty())
  assert_eq(acc.to_string(), art)
}

///|
test "streaming decoding UTF16BE Tao71" {
  let tao71 = "知不知，尚矣；不知知，病也。圣人不病，以其病病，夫惟病病，是以不病。"
  let tao71_bytes = encode(encoding=UTF16BE, tao71)
  let from_array = Bytes::from_array
  {
    let decoder = decoder(UTF16BE)
    let buf = @buffer.new(size_hint=tao71_bytes.length())
    buf.write_bytes(tao71_bytes)
    let chunks = buf.contents().to_array().chunks(17)
    assert_eq(chunks.length(), 4)

    // chunk by chunk
    assert_eq(
      from_array(chunks[0]),
      b"\x77\xe5\x4e\x0d\x77\xe5\xff\x0c\x5c\x1a\x77\xe3\xff\x1b\x4e\x0d\x77",
    )
    inspect(
      decoder.consume(from_array(chunks[0])),
      content="知不知，尚矣；不",
    )
    assert_eq(
      from_array(chunks[1]),
      b"\xe5\x77\xe5\xff\x0c\x75\xc5\x4e\x5f\x30\x02\x57\x23\x4e\xba\x4e\x0d",
    )
    inspect(
      decoder.consume(from_array(chunks[1])),
      content="知知，病也。圣人不",
    )
    assert_eq(
      from_array(chunks[2]),
      b"\x75\xc5\xff\x0c\x4e\xe5\x51\x76\x75\xc5\x75\xc5\xff\x0c\x59\x2b\x60",
    )
    inspect(
      decoder.consume(from_array(chunks[2])),
      content="病，以其病病，夫",
    )
    assert_eq(
      from_array(chunks[3]),
      b"\xdf\x75\xc5\x75\xc5\xff\x0c\x66\x2f\x4e\xe5\x4e\x0d\x75\xc5\x30\x02",
    )
    // decoder.decode!(input, stream~ = false)
    inspect(
      decoder.decode(from_array(chunks[3])),
      content="惟病病，是以不病。",
    )
  }

  // check accumulator
  let decoder = decoder(UTF16BE)
  let acc = StringBuilder::new()
  for chunk in tao71_bytes.to_array().chunks(7) {
    acc.write_string(decoder.consume(from_array(chunk)).to_string())
  }
  assert_true(decoder.finish().is_empty())
  assert_eq(acc.to_string(), tao71)
}

// In one go

///|
test "decoding String (UTF16LE encoded) to String (buffer.write_bytes)" {
  let src = "你好👀"
  let buf = @buffer.new(size_hint=src.to_utf16le_bytes().length())
  buf.write_bytes(src.to_utf16le_bytes())
  assert_eq(buf.to_bytes(), b"\x60\x4f\x7d\x59\x3d\xd8\x40\xdc")
  let decoder = decoder(UTF16LE)
  let chars = decoder.decode(buf.to_bytes())
  assert_eq(chars, src)
}

///|
test "decode_to/UTF16LE" {
  let src = "你好👀"
  let buf = @buffer.new(size_hint=src.to_utf16le_bytes().length())
  buf.write_bytes(src.to_utf16le_bytes())
  let decoder = decoder(UTF16LE)
  let acc = StringBuilder::new()
  decoder.decode_to(buf.to_bytes(), acc)
  inspect(acc.to_string(), content="你好👀")
}

///|
test "decoding String (UTF16LE encoded) to String (buffer.write_char)" {
  let src = "👋再见"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    buf.write_char(s)
  }
  assert_eq(buf.to_bytes(), b"\x3d\xd8\x4b\xdc\x8d\x51\xc1\x89")
  let decoder = decoder(UTF16LE)
  let chars = decoder.decode(buf.to_bytes())
  assert_eq(chars, src)
}

///|
test "decoding UTF16LE encoded data to String" {
  let buf = @buffer.new(size_hint=10)
  buf.write_bytes(b"\x60\x4f") // 你
  buf.write_bytes(b"\x7d\x59") // 好
  buf.write_bytes(b"\x3d\xd8\x40\xdc") // 👀
  assert_eq(buf.to_bytes(), b"\x60\x4f\x7d\x59\x3d\xd8\x40\xdc")
  let decoder = decoder(UTF16LE)
  let chars = decoder.decode(buf.to_bytes())
  inspect(chars, content="你好👀")
}

///|
test "decoding UTF16 (alias for UTF16LE) encoded data to String" {
  let buf = @buffer.new(size_hint=20)
  buf.write_bytes(b"\x65\x18")
  buf.write_bytes(b"\x20\x18")
  buf.write_bytes(b"\x73\x18")
  buf.write_bytes(b"\x64\x18")
  buf.write_bytes(b"\x73\x18")
  buf.write_bytes(b"\x36\x18")
  buf.write_bytes(b"\x20\x18")
  assert_eq(
    buf.to_bytes(),
    b"\x65\x18\x20\x18\x73\x18\x64\x18\x73\x18\x36\x18\x20\x18",
  )
  let decoder = decoder(UTF16LE)
  let chars = decoder.decode(buf.to_bytes())
  inspect(chars, content="ᡥᠠᡳᡤᡳᠶᠠ")
}

///|
test "decode_to/UTF16" {
  let buf = @buffer.new(size_hint=20)
  buf.write_bytes(b"\x65\x18")
  buf.write_bytes(b"\x20\x18")
  buf.write_bytes(b"\x73\x18")
  buf.write_bytes(b"\x64\x18")
  buf.write_bytes(b"\x73\x18")
  buf.write_bytes(b"\x36\x18")
  buf.write_bytes(b"\x20\x18")
  let decoder = decoder(UTF16LE)
  let acc = StringBuilder::new()
  decoder.decode_to(buf.to_bytes(), acc)
  inspect(acc.to_string(), content="ᡥᠠᡳᡤᡳᠶᠠ")
}

///|
test "decoding UTF16BE encoded data to String" {
  let buf = @buffer.new(size_hint=10)
  buf.write_bytes(b"\xd8\x3d\xdc\x08")
  buf.write_bytes(b"\xd8\x3d\xdc\x31")
  buf.write_bytes(b"\xd8\x3d\xdc\x07")
  buf.write_bytes(b"\xd8\x3d\xdc\x30")
  assert_eq(
    buf.to_bytes(),
    b"\xd8\x3d\xdc\x08\xd8\x3d\xdc\x31\xd8\x3d\xdc\x07\xd8\x3d\xdc\x30",
  )
  let decoder = decoder(UTF16BE)
  let chars = decoder.decode(buf.to_bytes())
  inspect(chars, content="🐈🐱🐇🐰")
}

///|
test "decode_to/UTF16BE" {
  let buf = @buffer.new(size_hint=10)
  buf.write_bytes(b"\xd8\x3d\xdc\x08")
  buf.write_bytes(b"\xd8\x3d\xdc\x31")
  buf.write_bytes(b"\xd8\x3d\xdc\x07")
  buf.write_bytes(b"\xd8\x3d\xdc\x30")
  let decoder = decoder(UTF16BE)
  let acc = StringBuilder::new()
  decoder.decode_to(buf.to_bytes(), acc)
  inspect(acc.to_string(), content="🐈🐱🐇🐰")
}

///|
test "decoding UTF8 encoded data to String" {
  let buf = @buffer.new(size_hint=10)
  buf.write_bytes(b"\xe4\xbd\xa0") // 你
  buf.write_bytes(b"\xe5\xa5\xbd") // 好
  buf.write_bytes(b"\xf0\x9f\x91\x80") // 👀
  assert_eq(buf.to_bytes(), b"\xe4\xbd\xa0\xe5\xa5\xbd\xf0\x9f\x91\x80")
  let decoder = decoder(UTF8)
  let chars = decoder.decode(buf.to_bytes())
  inspect(chars, content="你好👀")
}

///|
test "decode_to/UTF8" {
  let buf = @buffer.new(size_hint=10)
  buf.write_bytes(b"\xe4\xbd\xa0") // 你
  buf.write_bytes(b"\xe5\xa5\xbd") // 好
  buf.write_bytes(b"\xf0\x9f\x91\x80") // 👀
  let decoder = decoder(UTF8)
  let acc = StringBuilder::new()
  decoder.decode_to(buf.to_bytes(), acc)
  inspect(acc.to_string(), content="你好👀")
}

///|
test "decoding UTF8 encoded bytes to String" {
  let src = "👋再见"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf8_char(buf, s)
  }
  assert_eq(buf.to_bytes(), b"\xf0\x9f\x91\x8b\xe5\x86\x8d\xe8\xa7\x81")
  let decoder = decoder(UTF8)
  let chars = decoder.decode(buf.to_bytes())
  assert_eq(chars, src)
}

///|
test "decoding UTF8 encoded data" {
  let src = "👋再见"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf8_char(buf, s)
  }
  assert_eq(buf.to_bytes(), b"\xf0\x9f\x91\x8b\xe5\x86\x8d\xe8\xa7\x81")
  let decoder = decoder(UTF8)
  let chars = decoder.decode(buf.to_bytes())
  inspect(chars.iter().collect(), content="['👋', '再', '见']")
}

///|
test "decoding UTF16LE encoded data with UTF8" {
  let src = "跑步🏃游泳🏊"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf16le_char(buf, s)
  }
  assert_eq(
    buf.to_bytes(),
    b"\xd1\x8d\x65\x6b\x3c\xd8\xc3\xdf\x38\x6e\xf3\x6c\x3c\xd8\xca\xdf",
  )
  let decoder = decoder(UTF8)
  // NOTE: Expected to be malformed here
  let chars = try? decoder.decode(buf.to_bytes())
  assert_true(chars is Err(_))
  inspect(
    chars,
    content=(
      #|Err(Malformed(b"\xd8\xc3"))
    ),
  )
}

///|
test "decode_to/UTF16LE-UTF8/MalformedError" {
  let src = "跑步🏃游泳🏊"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf16le_char(buf, s)
  }
  let decoder = decoder(UTF8)
  let acc = StringBuilder::new()
  inspect(
    try? decoder.decode_to(buf.to_bytes(), acc),
    content=(
      #|Err(Malformed(b"\xd8\xc3"))
    ),
  )
}

///|
test "decode_to/UTF16LE-UTF8/TruncatedError" {
  let src = "跑步🏃游泳🏊"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf16le_char(buf, s)
  }
  let bytes = buf.to_bytes()
  let bytes_view : Bytes = [..bytes[:bytes.length() - 1]]
  let decoder = decoder(UTF16LE)
  let acc = StringBuilder::new()
  let result = try? decoder.decode_to(bytes_view, acc)
  inspect(
    result,
    content=(
      #|Err(Truncated(b"\xca\x00\x00\x00"))
    ),
  )
}

///|
test "decode_to/UTF16LE-UTF8/stream" {
  let src = "跑步🏃游泳🏊"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf16le_char(buf, s)
  }
  let bytes = buf.to_bytes()
  let bytes_view : Bytes = [..bytes[:bytes.length() - 1]]
  let decoder = decoder(UTF16LE)
  let acc = StringBuilder::new()
  let result = try? decoder.decode_to(bytes_view, acc, stream=true)
  inspect(result, content="Ok(())")
  inspect(acc.to_string(), content="跑步🏃游泳")
  let result = try? decoder.decode_to(
      [bytes[bytes.length() - 1]],
      acc,
      stream=true,
    )
  inspect(result, content="Ok(())")
  inspect(acc.to_string(), content="跑步🏃游泳🏊")
}

///|
test "decode_to/empty" {
  let acc = StringBuilder::new()
  let decoder = decoder(UTF8)
  decoder.decode_to("", acc)
  inspect(acc.to_string(), content="")
  decode_to("", acc, encoding=UTF8)
  inspect(acc.to_string(), content="")
}

///|
test "decoding UTF8 encoded data with UTF16LE" {
  let src = "跑步🏃游泳🏊"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf8_char(buf, s)
  }
  assert_eq(
    buf.to_bytes(),
    b"\xe8\xb7\x91\xe6\xad\xa5\xf0\x9f\x8f\x83\xe6\xb8\xb8\xe6\xb3\xb3\xf0\x9f\x8f\x8a",
  )
  let decoder = decoder(UTF16LE)
  let chars = decoder.decode(buf.to_bytes())
  // NOTE: Happens to be legal UTF16LE
  inspect(
    chars.iter().collect(),
    content="['럨', '\\u{e691}', 'ꖭ', '鿰', '莏', '룦', '\\u{e6b8}', '뎳', '鿰', '誏']",
  )
}

///|
test "decode_to/UTF8-UTF16LE" {
  let src = "跑步🏃游泳🏊"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf8_char(buf, s)
  }
  let decoder = decoder(UTF16LE)
  let acc = StringBuilder::new()
  decoder.decode_to(buf.to_bytes(), acc)
  // NOTE: Happens to be legal UTF16LE
  inspect(acc.to_string(), content="럨ꖭ鿰莏룦뎳鿰誏")
}

///|
test "decoding UTF16BE encoded data with UTF8" {
  let src = "跑步🏃游泳🏊"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf16be_char(buf, s)
  }
  assert_eq(
    buf.to_bytes(),
    b"\x8d\xd1\x6b\x65\xd8\x3c\xdf\xc3\x6e\x38\x6c\xf3\xd8\x3c\xdf\xca",
  )
  let decoder = decoder(UTF8)
  // NOTE: Expected to be malformed here
  let chars = try? decoder.decode(buf.to_bytes())
  assert_true(chars is Err(_))
  inspect(
    chars,
    content=(
      #|Err(Malformed(b"\x8d"))
    ),
  )
}

///|
test "decode_to/UTF16BE-UTF8" {
  let src = "跑步🏃游泳🏊"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf16be_char(buf, s)
  }
  let decoder = decoder(UTF8)
  let acc = StringBuilder::new()
  @json.inspect(try? decoder.decode_to(buf.to_bytes(), acc), content={
    "Err": { "malformed": [141] },
  })
}

///|
test "decoding UTF8 encoded data with UTF16BE" {
  let src = "跑步🏃游泳🏊"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf8_char(buf, s)
  }
  assert_eq(
    buf.to_bytes(),
    b"\xe8\xb7\x91\xe6\xad\xa5\xf0\x9f\x8f\x83\xe6\xb8\xb8\xe6\xb3\xb3\xf0\x9f\x8f\x8a",
  )
  let decoder = decoder(UTF16BE)
  let chars = decoder.decode(buf.to_bytes())
  // NOTE: Happens to be legal UTF16BE
  inspect(
    chars.iter().collect(),
    content="['\\u{e8b7}', '釦', '궥', '\\u{f09f}', '较', '\\u{e6b8}', '룦', '뎳', '\\u{f09f}', '辊']",
  )
}

///|
test "decode_to/UTF8-UTF16BE" {
  let src = "跑步🏃游泳🏊"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf8_char(buf, s)
  }
  let decoder = decoder(UTF16BE)
  let acc = StringBuilder::new()
  decoder.decode_to(buf.to_bytes(), acc)
  // NOTE: Happens to be legal UTF16BE
  inspect(acc.to_string(), content="釦궥较룦뎳辊")
}

///|
test "decoding UTF16LE encoded data with UTF16BE" {
  let src = "跑步🏃游泳🏊"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf16le_char(buf, s)
  }
  assert_eq(
    buf.to_bytes(),
    b"\xd1\x8d\x65\x6b\x3c\xd8\xc3\xdf\x38\x6e\xf3\x6c\x3c\xd8\xca\xdf",
  )
  let decoder = decoder(UTF16BE)
  let chars = decoder.decode(buf.to_bytes())
  // NOTE: Happens to be legal UTF16BE
  inspect(
    chars.iter().collect(),
    content="['톍', '敫', '㳘', '쏟', '㡮', '\\u{f36c}', '㳘', '쫟']",
  )
}

///|
test "decode_to/UTF16LE-UTF16BE" {
  let src = "跑步🏃游泳🏊"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf16le_char(buf, s)
  }
  let decoder = decoder(UTF16BE)
  let acc = StringBuilder::new()
  decoder.decode_to(buf.to_bytes(), acc)
  // NOTE: Happens to be legal UTF16BE
  inspect(acc.to_string(), content="톍敫㳘쏟㡮㳘쫟")
}

///|
test "decoding UTF16BE encoded data with UTF16LE" {
  let src = "跑步🏃游泳🏊"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf16be_char(buf, s)
  }
  assert_eq(
    buf.to_bytes(),
    b"\x8d\xd1\x6b\x65\xd8\x3c\xdf\xc3\x6e\x38\x6c\xf3\xd8\x3c\xdf\xca",
  )
  let decoder = decoder(UTF16LE)
  let chars = decoder.decode(buf.to_bytes())
  // NOTE: Happens to be legal UTF16LE
  inspect(
    chars.iter().collect(),
    content="['톍', '敫', '㳘', '쏟', '㡮', '\\u{f36c}', '㳘', '쫟']",
  )
}

///|
test "decode_to/UTF16BE-UTF16LE" {
  let src = "跑步🏃游泳🏊"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf16be_char(buf, s)
  }
  let decoder = decoder(UTF16LE)
  let acc = StringBuilder::new()
  decoder.decode_to(buf.to_bytes(), acc)
  // NOTE: Happens to be legal UTF16LE
  inspect(acc.to_string(), content="톍敫㳘쏟㡮㳘쫟")
}

///|
test "lossy decoding UTF16LE encoded data with UTF8" {
  let src = "跑步🏃游泳🏊"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf16le_char(buf, s)
  }
  assert_eq(
    buf.to_bytes(),
    b"\xd1\x8d\x65\x6b\x3c\xd8\xc3\xdf\x38\x6e\xf3\x6c\x3c\xd8\xca\xdf",
  )
  let decoder = decoder(UTF8)
  let chars = decoder.decode_lossy(buf.to_bytes())
  inspect(
    chars.iter().collect(),
    content="['э', 'e', 'k', '<', '�', '�', 'n', '�', '�']",
  )
}

///|
test "decode_lossy_to/UTF16LE-UTF8" {
  let src = "跑步🏃游泳🏊"
  let buf = @buffer.new(size_hint=10)
  for s in src {
    write_utf16le_char(buf, s)
  }
  let decoder = decoder(UTF8)
  let acc = StringBuilder::new()
  decoder.decode_lossy_to(buf.to_bytes(), acc)
  inspect(acc.to_string(), content="эek<��n��")
}

///|
test "lossy decoding UTF16LE incorrectly encoded data to String" {
  let src = b"\x00\xD8"
  assert_eq(src, b"\x00\xd8")
  let decoder = decoder(UTF16LE)
  let chars = decoder.decode_lossy(src, stream=false)
  inspect(chars, content="�")
  assert_eq(chars.length(), 1)
  assert_eq(chars.iter().nth(0).unwrap(), U_REP)
}

///|
test "decode_lossy_to/UTF16LE" {
  let src = b"\x00\xD8"
  assert_eq(src, b"\x00\xd8")
  let decoder = decoder(UTF16LE)
  let acc = StringBuilder::new()
  decoder.decode_lossy_to(src, acc)
  inspect(acc.to_string(), content="�")
}

///|
test "lossy decoding UTF16 (alias for UTF16LE) incorrectly encoded data to String" {
  let src = b"\x00\xD8"
  assert_eq(src, b"\x00\xd8")
  let decoder = decoder(UTF16LE)
  let chars = decoder.decode_lossy(src, stream=false)
  inspect(chars, content="�")
  assert_eq(chars.length(), 1)
  assert_eq(chars.iter().nth(0).unwrap(), U_REP)
}

///|
test "decode_lossy_to/UTF16" {
  let src = b"\x00\xD8"
  assert_eq(src, b"\x00\xd8")
  let decoder = decoder(UTF16LE)
  let acc = StringBuilder::new()
  decoder.decode_lossy_to(src, acc)
  inspect(acc.to_string(), content="�")
}

///|
test "lossy decoding UTF16BE incorrectly encoded data to String" {
  let src = b"\xD8\x00"
  assert_eq(src, b"\xd8\x00")
  let decoder = decoder(UTF16BE)
  let chars = decoder.decode_lossy(src, stream=false)
  inspect(chars, content="�")
  assert_eq(chars.length(), 1)
  assert_eq(chars.iter().nth(0).unwrap(), U_REP)
}

///|
test "decode_lossy_to/UTF16BE" {
  let src = b"\xD8\x00"
  assert_eq(src, b"\xd8\x00")
  let decoder = decoder(UTF16BE)
  let acc = StringBuilder::new()
  decoder.decode_lossy_to(src, acc)
  inspect(acc.to_string(), content="�")
}

///|
test "lossy decoding UTF16BE which is `HI+!LO`" {
  let src = b"\xD8\x00\x00\x48"
  assert_eq(src, b"\xd8\x00\x00\x48")
  let decoder = decoder(UTF16BE)
  let chars = decoder.decode_lossy(src, stream=false)

  // NOTE(jinser): should decode as many characters as possible
  inspect(chars, content="�H") // ✅
  assert_eq(chars.length(), 2)
  assert_eq(chars.iter().nth(0).unwrap(), U_REP)
  assert_eq(chars.iter().nth(1).unwrap(), 'H')
}

///|
test "decode_lossy_to/UTF16BE/as-many-as-possible" {
  let src = b"\xD8\x00\x00\x48"
  assert_eq(src, b"\xd8\x00\x00\x48")
  let decoder = decoder(UTF16BE)
  let acc = StringBuilder::new()
  decoder.decode_lossy_to(src, acc)

  // NOTE(jinser): should decode as many characters as possible
  inspect(acc.to_string(), content="�H") // ✅
}

///|
/// Well-Formed UTF-8 Byte Sequences
/// https://www.unicode.org/versions/Unicode16.0.0/core-spec/chapter-3/#G27506
test "lossy decoding UTF8 incorrectly encoded data to String" {
  let buf = @buffer.new(size_hint=10)
  buf.write_bytes(b"\xE0\x9F\x80")
  assert_eq(buf.to_bytes(), b"\xe0\x9f\x80")
  let decoder = decoder(UTF8)
  let chars = decoder.decode_lossy(buf.to_bytes())
  inspect(chars, content="�")
  assert_eq(chars.iter().nth(0).unwrap(), U_REP)
}

///|
test "decode_lossy_to/UTF8" {
  let buf = @buffer.new(size_hint=10)
  buf.write_bytes(b"\xE0\x9F\x80")
  assert_eq(buf.to_bytes(), b"\xe0\x9f\x80")
  let decoder = decoder(UTF8)
  let acc = StringBuilder::new()
  decoder.decode_lossy_to(buf.to_bytes(), acc)
  inspect(acc.to_string(), content="�")
}

///|
test "decode_lossy_to/empty" {
  let acc = StringBuilder::new()
  let decoder = decoder(UTF8)
  decoder.decode_lossy_to("", acc)
  inspect(acc.to_string(), content="")
}

///|
/// https://learn.microsoft.com/en-us/windows/win32/intl/surrogates-and-supplementary-characters
/// > The first (high) surrogate is a 16-bit code value in the range U+D800 to U+DBFF.
/// > The second (low) surrogate is a 16-bit code value in the range U+DC00 to U+DFFF.
test "Not all UTF16LE is format-legal UTF16BE and vice versa" {
  let bytes_le = b"\xD8\x00\xD9\x00"

  // valid in UTF16LE
  let decoder_utf16le = decoder(UTF16LE)
  let chars_utf16le = decoder_utf16le.decode(bytes_le)
  inspect(chars_utf16le, content="ØÙ")

  // invalid in UTF16BE
  let decoder_utf16be = decoder(UTF16BE)
  let malformedError = try? decoder_utf16be.decode(bytes_le)
  assert_true(malformedError is Err(_))

  // vice versa
  let bytes_be = b"\x00\xD8\x00\xD9"

  // valid in UTF16BE
  let decoder_utf16be = decoder(UTF16BE)
  let chars_utf16be = decoder_utf16be.decode(bytes_be)
  inspect(chars_utf16be, content="ØÙ")

  // invalid in UTF16LE
  let decoder_utf16le = decoder(UTF16LE)
  let malformedError = try? decoder_utf16le.decode(bytes_be)
  assert_true(malformedError is Err(_))
}
