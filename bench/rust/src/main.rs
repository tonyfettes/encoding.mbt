use std::fs;
use std::time::Instant;

fn decode_utf8_to_char_array_std(bytes: &[u8], chars: &mut [char]) -> i32 {
    // Use standard library to convert bytes to string
    match std::str::from_utf8(bytes) {
        Ok(utf8_str) => {
            // Collect characters from the string
            let mut char_count = 0;
            for (idx, ch) in utf8_str.chars().enumerate() {
                unsafe { *chars.get_unchecked_mut(idx) = ch }
                char_count += 1;
            }
            char_count as i32
        }
        Err(error) => {
            // Return negative value indicating error position (1-based)
            -(error.valid_up_to() as i32 + 1)
        }
    }
}

/// Decode UTF-8 bytes to characters using a naive approach
/// Returns the number of characters decoded, or a negative value on error
fn decode_utf8_to_char_array_naive(bytes: &[u8], chars: &mut [char]) -> i32 {
    let mut byte_idx = 0;
    let mut char_idx = 0;
    let bytes_len = bytes.len();

    while byte_idx < bytes_len {
        // Try to process 8 ASCII characters at once (optimization from MoonBit version)
        if byte_idx + 8 <= bytes_len {
            let mut all_ascii = true;
            for i in 0..8 {
                unsafe {
                    if *bytes.get_unchecked(byte_idx + i) > 0x7F {
                        all_ascii = false;
                        break;
                    }
                }
            }

            if all_ascii {
                for i in 0..8 {
                    unsafe {
                        *chars.get_unchecked_mut(char_idx + i) =
                            *bytes.get_unchecked(byte_idx + i) as char;
                    }
                }
                byte_idx += 8;
                char_idx += 8;
                continue;
            }
        }

        // Single byte ASCII (0x00..=0x7F)
        let b0 = unsafe { *bytes.get_unchecked(byte_idx) };
        if b0 <= 0x7F {
            unsafe {
                *chars.get_unchecked_mut(char_idx) = b0 as char;
            }
            byte_idx += 1;
            char_idx += 1;
        }
        // Two-byte sequence (0xC2..=0xDF, 0x80..=0xBF)
        else if byte_idx + 1 < bytes_len && b0 >= 0xC2 && b0 <= 0xDF {
            let second_byte = unsafe { *bytes.get_unchecked(byte_idx + 1) };
            if second_byte >= 0x80 && second_byte <= 0xBF {
                let b0 = b0 as u32;
                let b1 = second_byte as u32;
                let code_point = ((b0 & 0x1F) << 6) + (b1 & 0x3F);

                let ch = unsafe { char::from_u32_unchecked(code_point) };
                unsafe {
                    *chars.get_unchecked_mut(char_idx) = ch;
                }
                byte_idx += 2;
                char_idx += 1;
            } else {
                return -(byte_idx as i32 + 1);
            }
        }
        // Three-byte sequences
        else if byte_idx + 2 < bytes_len {
            let b0 = b0;
            let b1 = unsafe { *bytes.get_unchecked(byte_idx + 1) };
            let b2 = unsafe { *bytes.get_unchecked(byte_idx + 2) };

            let valid_three_byte =
                // 0xE0, 0xA0..=0xBF, 0x80..=0xBF
                (b0 == 0xE0 && b1 >= 0xA0 && b1 <= 0xBF && b2 >= 0x80 && b2 <= 0xBF) ||
                // 0xE1..=0xEC, 0x80..=0xBF, 0x80..=0xBF
                (b0 >= 0xE1 && b0 <= 0xEC && b1 >= 0x80 && b1 <= 0xBF && b2 >= 0x80 && b2 <= 0xBF) ||
                // 0xED, 0x80..=0x9F, 0x80..=0xBF
                (b0 == 0xED && b1 >= 0x80 && b1 <= 0x9F && b2 >= 0x80 && b2 <= 0xBF) ||
                // 0xEE..=0xEF, 0x80..=0xBF, 0x80..=0xBF
                (b0 >= 0xEE && b0 <= 0xEF && b1 >= 0x80 && b1 <= 0xBF && b2 >= 0x80 && b2 <= 0xBF);

            if valid_three_byte {
                let b0 = b0 as u32;
                let b1 = b1 as u32;
                let b2 = b2 as u32;
                let code_point = ((b0 & 0x0F) << 12) + ((b1 & 0x3F) << 6) + (b2 & 0x3F);

                let ch = unsafe { char::from_u32_unchecked(code_point) };
                unsafe {
                    *chars.get_unchecked_mut(char_idx) = ch;
                }
                byte_idx += 3;
                char_idx += 1;
            }
            // Four-byte sequences
            else if byte_idx + 3 < bytes_len {
                let b3 = unsafe { *bytes.get_unchecked(byte_idx + 3) };

                let valid_four_byte =
                    // 0xF0, 0x90..=0xBF, 0x80..=0xBF, 0x80..=0xBF
                    (b0 == 0xF0 && b1 >= 0x90 && b1 <= 0xBF && b2 >= 0x80 && b2 <= 0xBF && b3 >= 0x80 && b3 <= 0xBF) ||
                    // 0xF1..=0xF3, 0x80..=0xBF, 0x80..=0xBF, 0x80..=0xBF
                    (b0 >= 0xF1 && b0 <= 0xF3 && b1 >= 0x80 && b1 <= 0xBF && b2 >= 0x80 && b2 <= 0xBF && b3 >= 0x80 && b3 <= 0xBF) ||
                    // 0xF4, 0x80..=0x8F, 0x80..=0xBF, 0x80..=0xBF
                    (b0 == 0xF4 && b1 >= 0x80 && b1 <= 0x8F && b2 >= 0x80 && b2 <= 0xBF && b3 >= 0x80 && b3 <= 0xBF);

                if valid_four_byte {
                    let b0 = b0 as u32;
                    let b1 = b1 as u32;
                    let b2 = b2 as u32;
                    let b3 = b3 as u32;
                    let code_point = ((b0 & 0x07) << 18)
                        + ((b1 & 0x3F) << 12)
                        + ((b2 & 0x3F) << 6)
                        + (b3 & 0x3F);

                    let ch = unsafe { char::from_u32_unchecked(code_point) };
                    unsafe {
                        *chars.get_unchecked_mut(char_idx) = ch;
                    }
                    byte_idx += 4;
                    char_idx += 1;
                } else {
                    return -(byte_idx as i32 + 1);
                }
            } else {
                return -(byte_idx as i32 + 1);
            }
        } else {
            return -(byte_idx as i32 + 1);
        }
    }

    char_idx as i32
}

fn decode_utf8_to_char_array_pattern_match(mut input: &[u8], chars: &mut [char]) -> i32 {
    let mut idx: usize = 0;

    loop {
        if input.len() >= 8 && input.as_ptr() as usize % 8 == 0 {
            let data = unsafe { *(input.as_ptr() as *const u64) };
            if data & 0x8080_8080_8080_8080u64 == 0 {
                unsafe {
                    *chars.get_unchecked_mut(idx + 0) = data as u8 as char;
                    *chars.get_unchecked_mut(idx + 1) = (data >> 8) as u8 as char;
                    *chars.get_unchecked_mut(idx + 2) = (data >> 16) as u8 as char;
                    *chars.get_unchecked_mut(idx + 3) = (data >> 24) as u8 as char;
                    *chars.get_unchecked_mut(idx + 4) = (data >> 32) as u8 as char;
                    *chars.get_unchecked_mut(idx + 5) = (data >> 40) as u8 as char;
                    *chars.get_unchecked_mut(idx + 6) = (data >> 48) as u8 as char;
                    *chars.get_unchecked_mut(idx + 7) = (data >> 56) as u8 as char;
                }
                idx += 8;
                input = unsafe { input.get_unchecked(8..) };
                continue;
            }
        }
        match input {
            [] => return idx as i32,

            // 1-byte (ASCII)
            [b0 @ 0x00..=0x7F, rest @ ..] => {
                unsafe {
                    *chars.get_unchecked_mut(idx) = *b0 as char;
                }
                idx += 1;
                input = rest;
            }

            // 2-byte
            [b0 @ 0xC2..=0xDF, b1 @ 0x80..=0xBF, rest @ ..] => {
                let c = ((u32::from(*b0) & 0x1F) << 6) | (u32::from(*b1) & 0x3F);
                unsafe {
                    *chars.get_unchecked_mut(idx) = char::from_u32_unchecked(c);
                }
                idx += 1;
                input = rest;
            }

            // 3-byte (with E0/ED edge constraints to avoid overlong + surrogates)
            [b0 @ 0xE0, b1 @ 0xA0..=0xBF, b2 @ 0x80..=0xBF, rest @ ..]
            | [
                b0 @ 0xE1..=0xEC,
                b1 @ 0x80..=0xBF,
                b2 @ 0x80..=0xBF,
                rest @ ..,
            ]
            | [b0 @ 0xED, b1 @ 0x80..=0x9F, b2 @ 0x80..=0xBF, rest @ ..]
            | [
                b0 @ 0xEE..=0xEF,
                b1 @ 0x80..=0xBF,
                b2 @ 0x80..=0xBF,
                rest @ ..,
            ] => {
                let c = ((u32::from(*b0) & 0x0F) << 12)
                    | ((u32::from(*b1) & 0x3F) << 6)
                    | (u32::from(*b2) & 0x3F);
                unsafe {
                    *chars.get_unchecked_mut(idx) = char::from_u32_unchecked(c);
                }
                idx += 1;
                input = rest;
            }

            // 4-byte (with F0/F4 edge constraints)
            [
                b0 @ 0xF0,
                b1 @ 0x90..=0xBF,
                b2 @ 0x80..=0xBF,
                b3 @ 0x80..=0xBF,
                rest @ ..,
            ]
            | [
                b0 @ 0xF1..=0xF3,
                b1 @ 0x80..=0xBF,
                b2 @ 0x80..=0xBF,
                b3 @ 0x80..=0xBF,
                rest @ ..,
            ]
            | [
                b0 @ 0xF4,
                b1 @ 0x80..=0x8F,
                b2 @ 0x80..=0xBF,
                b3 @ 0x80..=0xBF,
                rest @ ..,
            ] => {
                let c = ((u32::from(*b0) & 0x07) << 18)
                    | ((u32::from(*b1) & 0x3F) << 12)
                    | ((u32::from(*b2) & 0x3F) << 6)
                    | (u32::from(*b3) & 0x3F);
                unsafe {
                    *chars.get_unchecked_mut(idx) = char::from_u32_unchecked(c);
                }
                idx += 1;
                input = rest;
            }

            // Anything else is malformed at this point; return the remaining input
            _ => return -(idx as i32 + 1),
        }
    }
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let bytes = fs::read("english.utf8.txt")?;
    let mut naive_unicode = vec!['\0'; bytes.len()];
    let mut pattern_unicode = vec!['\0'; bytes.len()];
    let mut std_unicode = vec!['\0'; bytes.len()];

    assert_eq!(
        decode_utf8_to_char_array_naive(&bytes, &mut naive_unicode),
        decode_utf8_to_char_array_pattern_match(&bytes, &mut pattern_unicode)
    );
    assert_eq!(naive_unicode, pattern_unicode);

    // Warm up all implementations
    for _ in 0..5 {
        decode_utf8_to_char_array_naive(&bytes, &mut naive_unicode);
        decode_utf8_to_char_array_pattern_match(&bytes, &mut pattern_unicode);
        decode_utf8_to_char_array_std(&bytes, &mut std_unicode);
    }

    // Benchmark naive implementation
    let start = Instant::now();
    for _ in 0..1000 {
        decode_utf8_to_char_array_naive(&bytes, &mut naive_unicode);
    }
    let naive_duration = start.elapsed();
    println!(
        "naive: {:.3} ms",
        naive_duration.as_nanos() as f64 / 1_000_000.0
    );

    // Benchmark pattern matching implementation
    let start = Instant::now();
    for _ in 0..1000 {
        decode_utf8_to_char_array_pattern_match(&bytes, &mut pattern_unicode);
    }
    let pattern_duration = start.elapsed();
    println!(
        "pattern_match: {:.3} ms",
        pattern_duration.as_nanos() as f64 / 1_000_000.0
    );

    // Benchmark standard library implementation
    let start = Instant::now();
    for _ in 0..1000 {
        decode_utf8_to_char_array_std(&bytes, &mut std_unicode);
    }
    let std_duration = start.elapsed();
    println!(
        "standard: {:.3} ms",
        std_duration.as_nanos() as f64 / 1_000_000.0
    );

    Ok(())
}
