///|
test "write_utf8_char" {
  let buf = @buffer.new(size_hint=10)
  write_utf8_char(buf, 'A')
  write_utf8_char(buf, 'α')
  write_utf8_char(buf, '啊')
  write_utf8_char(buf, '😦')
  @json.inspect(buf.to_bytes().to_array(), content=[
    65, 206, 177, 229, 149, 138, 240, 159, 152, 166,
  ])
}

///|
test "write_utf16le_char" {
  let buf = @buffer.new(size_hint=10)
  write_utf16le_char(buf, 'A')
  write_utf16le_char(buf, 'α')
  write_utf16le_char(buf, '啊')
  write_utf16le_char(buf, '😦')
  @json.inspect(buf.to_bytes().to_array(), content=[
    65, 0, 177, 3, 74, 85, 61, 216, 38, 222,
  ])
}

///|
test "write_utf16be_char" {
  let buf = @buffer.new(size_hint=10)
  write_utf16be_char(buf, 'A')
  write_utf16be_char(buf, 'α')
  write_utf16be_char(buf, '啊')
  write_utf16be_char(buf, '😦')
  @json.inspect(buf.to_bytes().to_array(), content=[
    0, 65, 3, 177, 85, 74, 216, 61, 222, 38,
  ])
}
