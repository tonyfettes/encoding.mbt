use std::fs;
use std::time::Instant;

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
                if bytes[byte_idx + i] > 0x7F {
                    all_ascii = false;
                    break;
                }
            }

            if all_ascii {
                for i in 0..8 {
                    unsafe {
                        *chars.get_unchecked_mut(char_idx + i) = bytes[byte_idx + i] as char;
                    }
                }
                byte_idx += 8;
                char_idx += 8;
                continue;
            }
        }

        // Single byte ASCII (0x00..=0x7F)
        if bytes[byte_idx] <= 0x7F {
            unsafe {
                *chars.get_unchecked_mut(char_idx) = bytes[byte_idx] as char;
            }
            byte_idx += 1;
            char_idx += 1;
        }
        // Two-byte sequence (0xC2..=0xDF, 0x80..=0xBF)
        else if byte_idx + 1 < bytes_len
            && bytes[byte_idx] >= 0xC2
            && bytes[byte_idx] <= 0xDF
            && bytes[byte_idx + 1] >= 0x80
            && bytes[byte_idx + 1] <= 0xBF
        {
            let b0 = bytes[byte_idx] as u32;
            let b1 = bytes[byte_idx + 1] as u32;
            let code_point = ((b0 & 0x1F) << 6) + (b1 & 0x3F);

            let ch = unsafe { char::from_u32_unchecked(code_point) };
            unsafe {
                *chars.get_unchecked_mut(char_idx) = ch;
            }
            byte_idx += 2;
            char_idx += 1;
        }
        // Three-byte sequences
        else if byte_idx + 2 < bytes_len {
            let b0 = bytes[byte_idx];
            let b1 = bytes[byte_idx + 1];
            let b2 = bytes[byte_idx + 2];

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
                let b3 = bytes[byte_idx + 3];

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
                    chars[char_idx] = ch;
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

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let bytes = fs::read("english.utf8.txt")?;
    let mut naive_unicode = vec!['\0'; bytes.len()];
    let naive_length = decode_utf8_to_char_array_naive(&bytes, &mut naive_unicode);
    if naive_length < 0 {
        eprintln!(
            "Error: Invalid UTF-8 sequence at byte {}",
            -naive_length - 1
        );
        return Ok(());
    }
    for _ in 0..5 {
        decode_utf8_to_char_array_naive(&bytes, &mut naive_unicode);
    }
    let start = Instant::now();
    for _ in 0..1000 {
        decode_utf8_to_char_array_naive(&bytes, &mut naive_unicode);
    }
    let duration = start.elapsed();
    println!("{}", duration.as_nanos() as f64 / 1_000_000.0);
    Ok(())
}
