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

///|
test "encoding String to UTF8" {
  let src = "你好👀"
  let bytes = @encoding.encode(encoding=UTF8, src)
  @json.inspect(bytes.to_array(), content=[
    228, 189, 160, 229, 165, 189, 240, 159, 145, 128,
  ])
}

///|
test "encode_to/UTF8" {
  let src = "你好👀"
  let buf = @buffer.new(size_hint=10)
  @encoding.encode_to(src, buf, encoding=UTF8)
  @json.inspect(buf.to_bytes().to_array(), content=[
    228, 189, 160, 229, 165, 189, 240, 159, 145, 128,
  ])
}

///|
test "encoding String to UTF16 (alias of UTF16LE)" {
  let src = "LISP programmers know the value of everything"
  let bytes = @encoding.encode(encoding=UTF16LE, src)
  @json.inspect(bytes.to_array(), content=[
    76, 0, 73, 0, 83, 0, 80, 0, 32, 0, 112, 0, 114, 0, 111, 0, 103, 0, 114, 0, 97,
    0, 109, 0, 109, 0, 101, 0, 114, 0, 115, 0, 32, 0, 107, 0, 110, 0, 111, 0, 119,
    0, 32, 0, 116, 0, 104, 0, 101, 0, 32, 0, 118, 0, 97, 0, 108, 0, 117, 0, 101,
    0, 32, 0, 111, 0, 102, 0, 32, 0, 101, 0, 118, 0, 101, 0, 114, 0, 121, 0, 116,
    0, 104, 0, 105, 0, 110, 0, 103, 0,
  ])
}

///|
test "encode_to/UTF16" {
  let src = "LISP programmers know the value of everything"
  let buf = @buffer.new(size_hint=10)
  @encoding.encode_to(src, buf, encoding=UTF16LE)
  @json.inspect(buf.to_bytes().to_array(), content=[
    76, 0, 73, 0, 83, 0, 80, 0, 32, 0, 112, 0, 114, 0, 111, 0, 103, 0, 114, 0, 97,
    0, 109, 0, 109, 0, 101, 0, 114, 0, 115, 0, 32, 0, 107, 0, 110, 0, 111, 0, 119,
    0, 32, 0, 116, 0, 104, 0, 101, 0, 32, 0, 118, 0, 97, 0, 108, 0, 117, 0, 101,
    0, 32, 0, 111, 0, 102, 0, 32, 0, 101, 0, 118, 0, 101, 0, 114, 0, 121, 0, 116,
    0, 104, 0, 105, 0, 110, 0, 103, 0,
  ])
}

///|
test "encoding String to UTF16LE" {
  let src = "and the cost of nothing"
  let bytes = @encoding.encode(encoding=UTF16LE, src)
  @json.inspect(bytes.to_array(), content=[
    97, 0, 110, 0, 100, 0, 32, 0, 116, 0, 104, 0, 101, 0, 32, 0, 99, 0, 111, 0, 115,
    0, 116, 0, 32, 0, 111, 0, 102, 0, 32, 0, 110, 0, 111, 0, 116, 0, 104, 0, 105,
    0, 110, 0, 103, 0,
  ])
}

///|
test "encode_to/UTF16LE" {
  let src = "and the cost of nothing"
  let buf = @buffer.new(size_hint=10)
  @encoding.encode_to(src, buf, encoding=UTF16LE)
  @json.inspect(buf.to_bytes().to_array(), content=[
    97, 0, 110, 0, 100, 0, 32, 0, 116, 0, 104, 0, 101, 0, 32, 0, 99, 0, 111, 0, 115,
    0, 116, 0, 32, 0, 111, 0, 102, 0, 32, 0, 110, 0, 111, 0, 116, 0, 104, 0, 105,
    0, 110, 0, 103, 0,
  ])
}

///|
test "encoding String to UTF16BE" {
  let src = "λf.(λx.f(x x))(λx.f(x x))"
  let bytes = @encoding.encode(encoding=UTF16BE, src)
  @json.inspect(bytes.to_array(), content=[
    3, 187, 0, 102, 0, 46, 0, 40, 3, 187, 0, 120, 0, 46, 0, 102, 0, 40, 0, 120, 0,
    32, 0, 120, 0, 41, 0, 41, 0, 40, 3, 187, 0, 120, 0, 46, 0, 102, 0, 40, 0, 120,
    0, 32, 0, 120, 0, 41, 0, 41,
  ])
}

///|
test "encode_to/UTF16BE" {
  let src = "λf.(λx.f(x x))(λx.f(x x))"
  let buf = @buffer.new(size_hint=10)
  @encoding.encode_to(src, buf, encoding=UTF16BE)
  @json.inspect(buf.to_bytes().to_array(), content=[
    3, 187, 0, 102, 0, 46, 0, 40, 3, 187, 0, 120, 0, 46, 0, 102, 0, 40, 0, 120, 0,
    32, 0, 120, 0, 41, 0, 41, 0, 40, 3, 187, 0, 120, 0, 46, 0, 102, 0, 40, 0, 120,
    0, 32, 0, 120, 0, 41, 0, 41,
  ])
}
