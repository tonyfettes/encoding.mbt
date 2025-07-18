#include "moonbit.h"
#include <stdint.h>

MOONBIT_FFI_EXPORT
int moonbit_encoding_v2_utf8_decode_0(const unsigned char *restrict s,
                                      size_t soff, size_t slen,
                                      int32_t *restrict t) {
  size_t tlen = Moonbit_array_length(t);
  size_t si = soff;
  size_t ti = 0;
  while (si < slen && ti < tlen) {
    unsigned char c0 = s[si];
    if (c0 <= 0x7F) { // 0x00..=0x7F
      t[ti] = c0;
      si++;
      ti++;
    } else if (c0 < 0xC2) { // 0x80..=0xC1
      return -1;
    } else if (c0 <= 0xDF) { // 0xC2..=0xDF
      if (si + 1 >= slen) {
        return -1;
      }
      unsigned char c1 = s[si + 1]; // 0x80..=0xBF
      if (c1 < 0x80 || c1 > 0xBF) {
        return -1; // Invalid UTF-8
      }
      t[ti] = ((c0 & 0x1F) << 6) | (s[si + 1] & 0x3F);
      si += 2;
      ti++;
    } else if (c0 == 0xE0) {
      if (si + 2 >= slen) {
        return -1;
      }
      unsigned char c1 = s[si + 1]; // 0xA0..=0xBF
      unsigned char c2 = s[si + 2]; // 0x80..=0xBF
      if (c1 < 0xA0 || c1 > 0xBF || (c2 & 0xC0) != 0x80) {
        return -1; // Invalid UTF-8
      }
      t[ti] = ((c0 & 0x0F) << 12) | ((c1 & 0x3F) << 6) | (c2 & 0x3F);
      si += 3;
      ti++;
    } else if (c0 <= 0xEC) { // 0xE1..=0xEC
      if (si + 2 >= slen) {
        return -1;
      }
      unsigned char c1 = s[si + 1]; // 0x80..=0xBF
      unsigned char c2 = s[si + 2]; // 0x80..=0xBF
      if ((c1 & 0xC0) != 0x80 || (c2 & 0xC0) != 0x80) {
        return -1; // Invalid UTF-8
      }
      t[ti] = ((c0 & 0x0F) << 12) | ((c1 & 0x3F) << 6) | (c2 & 0x3F);
      si += 3;
      ti++;
    } else if (c0 == 0xED) {
      if (si + 2 >= slen) {
        return -1;
      }
      unsigned char c1 = s[si + 1]; // 0x80..=0x9F
      unsigned char c2 = s[si + 2]; // 0x80..=0xBF
      if (c1 < 0x80 || c1 > 0x9F || (c2 & 0xC0) != 0x80) {
        return -1; // Invalid UTF-8
      }
      t[ti] = ((c0 & 0x0F) << 12) | ((c1 & 0x3F) << 6) | (c2 & 0x3F);
      si += 3;
      ti++;
    } else if (c0 <= 0xEF) { // 0xEE..=0xEF
      if (si + 3 >= slen) {
        return -1;
      }
      unsigned char c1 = s[si + 1]; // 0x80..=0xBF
      unsigned char c2 = s[si + 2]; // 0x80..=0xBF
      if ((c1 & 0xC0) != 0x80 || (c2 & 0xC0) != 0x80) {
        return -1; // Invalid UTF-8
      }
      t[ti] = ((c0 & 0x0F) << 12) | ((c1 & 0x3F) << 6) | (c2 & 0x3F);
      si += 3;
      ti++;
    } else if (c0 == 0xF0) { // 0xF0
      if (si + 3 >= slen) {
        return -1;
      }
      unsigned char c1 = s[si + 1]; // 0x90..=0xBF
      unsigned char c2 = s[si + 2]; // 0x80..=0xBF
      unsigned char c3 = s[si + 3]; // 0x80..=0xBF
      if (c1 < 0x90 || c1 > 0xBF || (c2 & 0xC0) != 0x80 ||
          (c3 & 0xC0) != 0x80) {
        return -1; // Invalid UTF-8
      }
      t[ti] = ((c0 & 0x0F) << 18) | ((c1 & 0x3F) << 12) | ((c2 & 0x3F) << 6) |
              (c3 & 0x3F);
      si += 4;
      ti++;
    } else if (c0 <= 0xF3) { // 0xF1..=0xF3
      if (si + 3 >= slen) {
        return -1;
      }
      unsigned char c1 = s[si + 1]; // 0x80..=0xBF
      unsigned char c2 = s[si + 2]; // 0x80..=0xBF
      unsigned char c3 = s[si + 3]; // 0x80..=0xBF
      if ((c1 & 0xC0) != 0x80 || (c2 & 0xC0) != 0x80 || (c3 & 0xC0) != 0x80) {
        return -1; // Invalid UTF-8
      }
      t[ti] = ((c0 & 0x0F) << 18) | ((c1 & 0x3F) << 12) | ((c2 & 0x3F) << 6) |
              (c3 & 0x3F);
      si += 4;
      ti++;
    } else if (c0 == 0xF4) { // 0xF4
      if (si + 3 >= slen) {
        return -1;
      }
      unsigned char c1 = s[si + 1]; // 0x80..=0x8F
      unsigned char c2 = s[si + 2]; // 0x80..=0xBF
      unsigned char c3 = s[si + 3]; // 0x80..=0xBF
      if (c1 < 0x80 || c1 > 0x8F || (c2 & 0xC0) != 0x80 ||
          (c3 & 0xC0) != 0x80) {
        return -1; // Invalid UTF-8
      }
      t[ti] = ((c0 & 0x07) << 18) | ((c1 & 0x3F) << 12) | ((c2 & 0x3F) << 6) |
              (c3 & 0x3F);
      si += 4;
      ti++;
    } else {
      return -1; // Invalid UTF-8
    }
  }
  return ti;
}

#define UTF8_ACCEPT 0
#define UTF8_REJECT 1

static const uint8_t utf8d[] = {
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0, // 00..1f
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0, // 20..3f
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0, // 40..5f
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0, // 60..7f
    1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
    1,   1,   1,   1,   1,   9,   9,   9,   9,   9,   9,
    9,   9,   9,   9,   9,   9,   9,   9,   9,   9, // 80..9f
    7,   7,   7,   7,   7,   7,   7,   7,   7,   7,   7,
    7,   7,   7,   7,   7,   7,   7,   7,   7,   7,   7,
    7,   7,   7,   7,   7,   7,   7,   7,   7,   7, // a0..bf
    8,   8,   2,   2,   2,   2,   2,   2,   2,   2,   2,
    2,   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,
    2,   2,   2,   2,   2,   2,   2,   2,   2,   2, // c0..df
    0xa, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3,
    0x3, 0x3, 0x4, 0x3, 0x3, // e0..ef
    0xb, 0x6, 0x6, 0x6, 0x5, 0x8, 0x8, 0x8, 0x8, 0x8, 0x8,
    0x8, 0x8, 0x8, 0x8, 0x8, // f0..ff
    0x0, 0x1, 0x2, 0x3, 0x5, 0x8, 0x7, 0x1, 0x1, 0x1, 0x4,
    0x6, 0x1, 0x1, 0x1, 0x1, // s0..s0
    1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
    1,   1,   1,   1,   1,   1,   0,   1,   1,   1,   1,
    1,   0,   1,   0,   1,   1,   1,   1,   1,   1, // s1..s2
    1,   2,   1,   1,   1,   1,   1,   2,   1,   2,   1,
    1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
    1,   2,   1,   1,   1,   1,   1,   1,   1,   1, // s3..s4
    1,   2,   1,   1,   1,   1,   1,   1,   1,   2,   1,
    1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,
    1,   3,   1,   3,   1,   1,   1,   1,   1,   1, // s5..s6
    1,   3,   1,   1,   1,   1,   1,   3,   1,   3,   1,
    1,   1,   1,   1,   1,   1,   3,   1,   1,   1,   1,
    1,   1,   1,   1,   1,   1,   1,   1,   1,   1, // s7..s8
};

static inline uint32_t moonbit_encoding_v2_utf8_transition(uint32_t *state,
                                                           uint32_t *codep,
                                                           uint32_t byte) {
  uint32_t type = utf8d[byte];

  *codep = (*state != UTF8_ACCEPT) ? (byte & 0x3fu) | (*codep << 6)
                                   : (0xff >> type) & (byte);

  *state = utf8d[256 + *state * 16 + type];
  return *state;
}

MOONBIT_FFI_EXPORT
int moonbit_encoding_v2_utf8_decode_1(const unsigned char *restrict s,
                                      size_t soff, size_t slen,
                                      int32_t *restrict t) {
  size_t tlen = Moonbit_array_length(t);
  size_t si = soff;
  size_t ti = 0;
  uint32_t state = UTF8_ACCEPT;
  uint32_t codep = 0;
  while (si < slen && ti < tlen) {
    unsigned char byte = s[si];
    if (moonbit_encoding_v2_utf8_transition(&state, &codep, byte) ==
        UTF8_ACCEPT) {
      t[ti] = codep;
      si++;
      ti++;
    } else if (state == UTF8_REJECT) {
      return -1; // Invalid UTF-8
    } else {
      si++;
    }
  }
  return ti;
}
