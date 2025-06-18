// Copyright 2024 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Streaming

///|
test "decode_to/UTF8" {
  let buf = @buffer.new(size_hint=10)
  buf.write_bytes(b"\xe4\xbd\xa0") // 你
  buf.write_bytes(b"\xe5\xa5\xbd") // 好
  buf.write_bytes(b"\xf0\x9f\x91\x80") // 👀
  let acc = StringBuilder::new()
  decode_to(buf.to_bytes(), acc, encoding=UTF8)
  inspect(acc.to_string(), content="你好👀")
}

///|
test "decode_to/UTF16LE" {
  let src = "你好👀"
  let buf = @buffer.new(size_hint=src.to_bytes().length())
  buf.write_bytes(src.to_bytes())
  let acc = StringBuilder::new()
  decode_to(buf.to_bytes(), acc, encoding=UTF16LE)
  inspect(acc.to_string(), content="你好👀")
}

///|
test "decode_to/UTF16BE" {
  let buf = @buffer.new(size_hint=10)
  buf.write_bytes(b"\xd8\x3d\xdc\x08")
  buf.write_bytes(b"\xd8\x3d\xdc\x31")
  buf.write_bytes(b"\xd8\x3d\xdc\x07")
  buf.write_bytes(b"\xd8\x3d\xdc\x30")
  let acc = StringBuilder::new()
  decode_to(buf.to_bytes(), acc, encoding=UTF16BE)
  inspect(acc.to_string(), content="🐈🐱🐇🐰")
}
