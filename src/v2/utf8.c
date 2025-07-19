#include "moonbit.h"
#include <stdbool.h>
#include <stdint.h>

struct moonbit_int32_array {
  int32_t size;
  int32_t *data;
};

struct moonbit_bytes_view {
  int32_t offset;
  int32_t length;
  moonbit_bytes_t bytes;
};

MOONBIT_FFI_EXPORT int
tonyfettes_encoding_v2_decode_utf8_to_char_array(
  struct moonbit_bytes_view s,
  struct moonbit_int32_array *restrict t
) {
  const unsigned char *sptr = s.bytes + s.offset;
  int32_t slen = s.length;
  while (true) {
    unsigned char c0;
    unsigned char c1;
    unsigned char c2;
    unsigned char c3;
    if (slen == 0) {
      return -1;
    }
    c0 = sptr[0];
    if (c0 <= 0x7F) {
      if (slen >= 8) {
        unsigned char c1 = sptr[1];
        unsigned char c2 = sptr[2];
        unsigned char c3 = sptr[3];
        unsigned char c4 = sptr[4];
        unsigned char c5 = sptr[5];
        unsigned char c6 = sptr[6];
        unsigned char c7 = sptr[7];
        if (c1 <= 0x7F && c2 <= 0x7F && c3 <= 0x7F && c4 <= 0x7F &&
            c5 <= 0x7F && c6 <= 0x7F && c7 <= 0x7F) {
          t->data[t->size] = c0;
          t->data[t->size + 1] = c1;
          t->data[t->size + 2] = c2;
          t->data[t->size + 3] = c3;
          t->data[t->size + 4] = c4;
          t->data[t->size + 5] = c5;
          t->data[t->size + 6] = c6;
          t->data[t->size + 7] = c7;
          t->size += 8;
          sptr += 8;
          slen -= 8;
          continue;
        } else {
          goto utf8_1_byte;
        }
      } else {
        goto utf8_1_byte;
      }
    }
    if (c0 <= 0xC1) {
      goto malformed;
    }
    if (slen < 2) {
      goto malformed;
    }
    c1 = sptr[1];
    if (c0 <= 0xDF) {
      if (c1 >= 0x80 && c1 <= 0xBF) {
        if (slen >= 4) {
          c2 = sptr[2];
          c3 = sptr[3];
          if (c2 >= 0xC2 && c2 <= 0xDF && c3 >= 0x80 && c3 <= 0xBF) {
            t->data[t->size] = ((c0 & 0x1F) << 6) | (c1 & 0x3F);
            t->data[t->size + 1] = ((c2 & 0x1F) << 6) | (c3 & 0x3F);
            t->size += 2;
            sptr += 4;
            slen -= 4;
            continue;
          } else {
            goto utf8_2_bytes;
          }
        } else {
          goto utf8_2_bytes;
        }
      } else {
        goto malformed;
      }
    }
    if (slen < 3) {
      goto malformed;
    }
    c2 = sptr[2];
    if (c0 == 0xE0) {
      if ((c1 >= 0xA0 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF)) {
        goto utf8_3_bytes;
      } else {
        goto malformed;
      }
    }
    if (c0 == 0xED) {
      if ((c1 >= 0x80 && c1 <= 0x9F) && (c2 >= 0x80 && c2 <= 0xBF)) {
        goto utf8_3_bytes;
      } else {
        goto malformed;
      }
    }
    if (c0 <= 0xEF) {
      if ((c1 >= 0x80 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF)) {
        goto utf8_3_bytes;
      } else {
        goto malformed;
      }
    }
    if (slen < 4) {
      goto malformed;
    }
    c3 = sptr[3];
    if (c0 == 0xF0) {
      if ((c1 >= 0x90 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF) &&
          (c3 >= 0x80 && c3 <= 0xBF)) {
        goto utf8_4_bytes;
      } else {
        goto malformed;
      }
    }
    if (c0 <= 0xF3) {
      if ((c1 >= 0x80 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF) &&
          (c3 >= 0x80 && c3 <= 0xBF)) {
        goto utf8_4_bytes;
      } else {
        goto malformed;
      }
    }
    if (c0 == 0xF4) {
      if ((c1 >= 0x80 && c1 <= 0x8F) && (c2 >= 0x80 && c2 <= 0xBF) &&
          (c3 >= 0x80 && c3 <= 0xBF)) {
        goto utf8_4_bytes;
      } else {
        goto malformed;
      }
    }
    goto malformed;
  utf8_1_byte:
    t->data[t->size] = c0;
    t->size++;
    sptr += 1;
    slen -= 1;
    continue;
  utf8_2_bytes:
    t->data[t->size] = ((c0 & 0x1F) << 6) | (c1 & 0x3F);
    t->size++;
    sptr += 2;
    slen -= 2;
    continue;
  utf8_3_bytes:
    t->data[t->size] = ((c0 & 0x0F) << 12) | ((c1 & 0x3F) << 6) | (c2 & 0x3F);
    t->size++;
    sptr += 3;
    slen -= 3;
    continue;
  utf8_4_bytes:
    t->data[t->size] = ((c0 & 0x07) << 18) | ((c1 & 0x3F) << 12) |
                       ((c2 & 0x3F) << 6) | (c3 & 0x3F);
    t->size++;
    sptr += 4;
    slen -= 4;
    continue;
  malformed:
    return sptr - s.bytes + s.offset;
  }
}

MOONBIT_FFI_EXPORT int
tonyfettes_encoding_v2_validate_utf8_to_char_array(struct moonbit_bytes_view s
) {
  const unsigned char *sptr = s.bytes + s.offset;
  int32_t slen = s.length;
  int32_t tlen = 0;
  while (true) {
    unsigned char c0;
    unsigned char c1;
    unsigned char c2;
    unsigned char c3;
    if (slen == 0) {
      return tlen;
    }
    c0 = sptr[0];
    if (c0 <= 0x7F) {
      if (slen >= 8) {
        unsigned char c1 = sptr[1];
        unsigned char c2 = sptr[2];
        unsigned char c3 = sptr[3];
        unsigned char c4 = sptr[4];
        unsigned char c5 = sptr[5];
        unsigned char c6 = sptr[6];
        unsigned char c7 = sptr[7];
        if (c1 <= 0x7F && c2 <= 0x7F && c3 <= 0x7F && c4 <= 0x7F &&
            c5 <= 0x7F && c6 <= 0x7F && c7 <= 0x7F) {
          sptr += 8;
          slen -= 8;
          tlen += 8;
          continue;
        } else {
          goto utf8_1_byte;
        }
      } else {
        goto utf8_1_byte;
      }
    }
    if (c0 <= 0xC1) {
      goto malformed;
    }
    if (slen < 2) {
      goto malformed;
    }
    c1 = sptr[1];
    if (c0 <= 0xDF) {
      if (c1 >= 0x80 && c1 <= 0xBF) {
        if (slen >= 4) {
          c2 = sptr[2];
          c3 = sptr[3];
          if (c2 >= 0xC2 && c2 <= 0xDF && c3 >= 0x80 && c3 <= 0xBF) {
            sptr += 4;
            slen -= 4;
            tlen += 2;
            continue;
          } else {
            goto utf8_2_bytes;
          }
        } else {
          goto utf8_2_bytes;
        }
      } else {
        goto malformed;
      }
    }
    if (slen < 3) {
      goto malformed;
    }
    c2 = sptr[2];
    if (c0 == 0xE0) {
      if ((c1 >= 0xA0 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF)) {
        goto utf8_3_bytes;
      } else {
        goto malformed;
      }
    }
    if (c0 == 0xED) {
      if ((c1 >= 0x80 && c1 <= 0x9F) && (c2 >= 0x80 && c2 <= 0xBF)) {
        goto utf8_3_bytes;
      } else {
        goto malformed;
      }
    }
    if (c0 <= 0xEF) {
      if ((c1 >= 0x80 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF)) {
        goto utf8_3_bytes;
      } else {
        goto malformed;
      }
    }
    if (slen < 4) {
      goto malformed;
    }
    c3 = sptr[3];
    if (c0 == 0xF0) {
      if ((c1 >= 0x90 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF) &&
          (c3 >= 0x80 && c3 <= 0xBF)) {
        goto utf8_4_bytes;
      } else {
        goto malformed;
      }
    }
    if (c0 <= 0xF3) {
      if ((c1 >= 0x80 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF) &&
          (c3 >= 0x80 && c3 <= 0xBF)) {
        goto utf8_4_bytes;
      } else {
        goto malformed;
      }
    }
    if (c0 == 0xF4) {
      if ((c1 >= 0x80 && c1 <= 0x8F) && (c2 >= 0x80 && c2 <= 0xBF) &&
          (c3 >= 0x80 && c3 <= 0xBF)) {
        goto utf8_4_bytes;
      } else {
        goto malformed;
      }
    }
    goto malformed;
  utf8_1_byte:
    sptr += 1;
    slen -= 1;
    tlen += 1;
    continue;
  utf8_2_bytes:
    sptr += 2;
    slen -= 2;
    tlen += 1;
    continue;
  utf8_3_bytes:
    sptr += 3;
    slen -= 3;
    tlen += 1;
    continue;
  utf8_4_bytes:
    sptr += 4;
    slen -= 4;
    tlen += 1;
    continue;
  malformed:
    return -1;
  }
}

MOONBIT_FFI_EXPORT void
tonyfettes_encoding_v2_unsafe_decode_utf8_to_char_array(
  struct moonbit_bytes_view s,
  struct moonbit_int32_array *restrict t
) {
  const unsigned char *sptr = s.bytes + s.offset;
  int32_t slen = s.length;
  while (slen > 0) {
    unsigned char c0;
    unsigned char c1;
    unsigned char c2;
    unsigned char c3;
    c0 = sptr[0];
    if (c0 <= 0x7F) {
      if (slen >= 8) {
        unsigned char c1 = sptr[1];
        unsigned char c2 = sptr[2];
        unsigned char c3 = sptr[3];
        unsigned char c4 = sptr[4];
        unsigned char c5 = sptr[5];
        unsigned char c6 = sptr[6];
        unsigned char c7 = sptr[7];
        if (c1 <= 0x7F && c2 <= 0x7F && c3 <= 0x7F && c4 <= 0x7F &&
            c5 <= 0x7F && c6 <= 0x7F && c7 <= 0x7F) {
          t->data[t->size] = c0;
          t->data[t->size + 1] = c1;
          t->data[t->size + 2] = c2;
          t->data[t->size + 3] = c3;
          t->data[t->size + 4] = c4;
          t->data[t->size + 5] = c5;
          t->data[t->size + 6] = c6;
          t->data[t->size + 7] = c7;
          t->size += 8;
          sptr += 8;
          slen -= 8;
          continue;
        } else {
          goto utf8_1_byte;
        }
      } else {
        goto utf8_1_byte;
      }
    }
    c1 = sptr[1];
    if (c0 <= 0xDF) {
      if (slen >= 8) {
        unsigned char c2 = sptr[2];
        unsigned char c3 = sptr[3];
        unsigned char c4 = sptr[4];
        unsigned char c5 = sptr[5];
        unsigned char c6 = sptr[6];
        unsigned char c7 = sptr[7];
        if (c2 >= 0xC0 && c2 <= 0xDF && c4 >= 0xC0 && c4 <= 0xDF &&
            c6 >= 0xC0 && c6 <= 0xDF) {
          t->data[t->size] = ((c0 & 0x1F) << 6) | (c1 & 0x3F);
          t->data[t->size + 1] = ((c2 & 0x1F) << 6) | (c3 & 0x3F);
          t->data[t->size + 2] = ((c4 & 0x1F) << 6) | (c5 & 0x3F);
          t->data[t->size + 3] = ((c6 & 0x1F) << 6) | (c7 & 0x3F);
          t->size += 4;
          sptr += 8;
          slen -= 8;
          continue;
        } else {
          goto utf8_2_bytes;
        }
      } else {
        goto utf8_2_bytes;
      }
    }
    c2 = sptr[2];
    if (c0 <= 0xEF) {
      if (slen >= 6) {
        unsigned char c3 = sptr[3];
        unsigned char c4 = sptr[4];
        unsigned char c5 = sptr[5];
        if (c3 >= 0xE0 && c3 <= 0xEF) {
          t->data[t->size] =
            ((c0 & 0x0F) << 12) | ((c1 & 0x3F) << 6) | (c2 & 0x3F);
          t->data[t->size + 1] =
            ((c3 & 0x0F) << 12) | ((c4 & 0x3F) << 6) | (c5 & 0x3F);
          t->size += 2;
          sptr += 6;
          slen -= 6;
          continue;
        } else {
          goto utf8_3_bytes;
        }
      } else {
        goto utf8_3_bytes;
      }
    }
    c3 = sptr[3];
    t->data[t->size] = ((c0 & 0x07) << 18) | ((c1 & 0x3F) << 12) |
                       ((c2 & 0x3F) << 6) | (c3 & 0x3F);
    t->size++;
    sptr += 4;
    slen -= 4;
    continue;
  utf8_1_byte:
    t->data[t->size] = c0;
    t->size++;
    sptr += 1;
    slen -= 1;
    continue;
  utf8_2_bytes:
    t->data[t->size] = ((c0 & 0x1F) << 6) | (c1 & 0x3F);
    t->size++;
    sptr += 2;
    slen -= 2;
    continue;
  utf8_3_bytes:
    t->data[t->size] = ((c0 & 0x0F) << 12) | ((c1 & 0x3F) << 6) | (c2 & 0x3F);
    t->size++;
    sptr += 3;
    slen -= 3;
    continue;
  }
}
