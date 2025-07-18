#include "moonbit.h"
#include <stdbool.h>
#include <stdint.h>

MOONBIT_FFI_EXPORT
int
moonbit_encoding_v2_utf8_decode_0(
  const unsigned char *restrict s,
  size_t soff,
  size_t slen,
  uint32_t *restrict t
) {
  const unsigned char *sptr = s + soff;
  uint32_t *tptr = t;
  while (true) {
    unsigned char c0;
    unsigned char c1;
    unsigned char c2;
    unsigned char c3;
    if (slen == 0) {
      return 0;
    }
    c0 = sptr[0];
    if (c0 <= 0x7F) {
      *tptr++ = c0;
      sptr += 1;
      slen -= 1;
      continue;
    }
    if (slen < 2) {
      return -1;
    }
    c1 = sptr[1];
    if (c0 >= 0xC2 && c0 <= 0xDF) {
      if (c1 >= 0x80 && c1 <= 0xBF) {
        *tptr++ = ((c0 & 0x1F) << 6) | (c1 & 0x3F);
        sptr += 2;
        slen -= 2;
        continue;
      } else {
        return -1;
      }
    }
    if (slen < 3) {
      return -1;
    }
    c2 = sptr[2];
    if (c0 == 0xE0) {
      if ((c1 >= 0xA0 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF)) {
        goto utf8_3_bytes;
      } else {
        return -1;
      }
    }
    if (c0 >= 0xE1 && c0 <= 0xEC) {
      if ((c1 >= 0x80 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF)) {
        goto utf8_3_bytes;
      } else {
        return -1;
      }
    }
    if (c0 == 0xED) {
      if ((c1 >= 0x80 && c1 <= 0x9F) && (c2 >= 0x80 && c2 <= 0xBF)) {
        goto utf8_3_bytes;
      } else {
        return -1;
      }
    }
    if (c0 >= 0xEE && c0 <= 0xEF) {
      if ((c1 >= 0x80 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF)) {
        goto utf8_3_bytes;
      } else {
        return -1;
      }
    }
    if (slen < 4) {
      return -1;
    }
    c3 = sptr[3];
    if (c0 == 0xF0) {
      if ((c1 >= 0x90 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF) &&
          (c3 >= 0x80 && c3 <= 0xBF)) {
        goto utf8_4_bytes;
      } else {
        return -1;
      }
    }
    if (c0 >= 0xF1 && c0 <= 0xF3) {
      if ((c1 >= 0x80 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF) &&
          (c3 >= 0x80 && c3 <= 0xBF)) {
        goto utf8_4_bytes;
      } else {
        return -1;
      }
    }
    if (c0 == 0xF4) {
      if ((c1 >= 0x80 && c1 <= 0x8F) && (c2 >= 0x80 && c2 <= 0xBF) &&
          (c3 >= 0x80 && c3 <= 0xBF)) {
        goto utf8_4_bytes;
      } else {
        return -1;
      }
    }
    return -1;
  utf8_3_bytes:
    sptr += 3;
    slen -= 3;
    *tptr++ = ((c0 & 0x0F) << 12) | ((c1 & 0x3F) << 6) | (c2 & 0x3F);
    continue;
  utf8_4_bytes:
    sptr += 4;
    slen -= 4;
    *tptr++ = ((c0 & 0x07) << 18) | ((c1 & 0x3F) << 12) | ((c2 & 0x3F) << 6) |
              (c3 & 0x3F);
    continue;
  }
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

static inline uint32_t
moonbit_encoding_v2_utf8_transition(
  uint32_t *state,
  uint32_t *codep,
  uint32_t byte
) {
  uint32_t type = utf8d[byte];

  *codep = (*state != UTF8_ACCEPT) ? (byte & 0x3fu) | (*codep << 6)
                                   : (0xff >> type) & (byte);

  *state = utf8d[256 + *state * 16 + type];
  return *state;
}

MOONBIT_FFI_EXPORT
int
moonbit_encoding_v2_utf8_decode_1(
  const unsigned char *restrict s,
  size_t soff,
  size_t slen,
  int32_t *restrict t
) {
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
