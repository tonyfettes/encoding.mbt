///|
test "write_utf8_char" {
  let buf = @buffer.new(size_hint=10)
  write_utf8_char(buf, 'A')
  write_utf8_char(buf, 'α')
  write_utf8_char(buf, '啊')
  write_utf8_char(buf, '😦')
  inspect(
    buf.to_bytes(),
    content=
      #|b"\x41\xce\xb1\xe5\x95\x8a\xf0\x9f\x98\xa6"
    ,
  )
}

///|
test "write_utf16le_char" {
  let buf = @buffer.new(size_hint=10)
  write_utf16le_char(buf, 'A')
  write_utf16le_char(buf, 'α')
  write_utf16le_char(buf, '啊')
  write_utf16le_char(buf, '😦')
  inspect(
    buf.to_bytes(),
    content=
      #|b"\x41\x00\xb1\x03\x4a\x55\x3d\xd8\x26\xde"
    ,
  )
}

///|
test "write_utf16be_char" {
  let buf = @buffer.new(size_hint=10)
  write_utf16be_char(buf, 'A')
  write_utf16be_char(buf, 'α')
  write_utf16be_char(buf, '啊')
  write_utf16be_char(buf, '😦')
  inspect(
    buf.to_bytes(),
    content=
      #|b"\x00\x41\x03\xb1\x55\x4a\xd8\x3d\xde\x26"
    ,
  )
}
