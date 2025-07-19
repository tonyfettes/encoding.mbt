#include "moonbit.h"
#include <stdbool.h>
#include <stdint.h>

struct moonbit_int32_array {
  int32_t size;
  int32_t *data;
};

MOONBIT_FFI_EXPORT
int32_t
moonbit_encoding_v2_utf8_decode_0(
  const unsigned char *restrict s,
  int32_t soff,
  int32_t slen,
  struct moonbit_int32_array *restrict t
) {
  const unsigned char *sptr = s + soff;
  while (slen > 8) {
    uint64_t b = ((uint64_t *)sptr)[0];
    if ((b & 0x8080808080808080) == 0) {
      t->data[t->size] = sptr[0];
      t->data[t->size + 1] = sptr[1];
      t->data[t->size + 2] = sptr[2];
      t->data[t->size + 3] = sptr[3];
      t->data[t->size + 4] = sptr[4];
      t->data[t->size + 5] = sptr[5];
      t->data[t->size + 6] = sptr[6];
      t->data[t->size + 7] = sptr[7];
      t->size += 8;
      sptr += 8;
      slen -= 8;
      continue;
    } else {
      break;
    }
  }
  while (slen > 4) {
    uint32_t b;
    unsigned char c0;
    unsigned char c1;
    unsigned char c2;
    unsigned char c3;
    b = ((uint32_t *)sptr)[0];
    c0 = sptr[0];
    c1 = sptr[1];
    c2 = sptr[2];
    c3 = sptr[3];
    if ((b & 0x80808080) == 0) {
      t->data[t->size] = c0;
      t->data[t->size + 1] = c1;
      t->data[t->size + 2] = c2;
      t->data[t->size + 3] = c3;
      t->size += 4;
      sptr += 4;
      slen -= 4;
      continue;
    }
    if (c0 <= 0x7F) {
      goto vec_utf8_1_byte;
    }
    if (c0 >= 0xC2 && c0 <= 0xDF) {
      if (c1 >= 0x80 && c1 <= 0xBF) {
        if (c2 >= 0xC2 && c2 <= 0xDF && c3 >= 0x80 && c3 <= 0xBF) {
          t->data[t->size] = ((c0 & 0x1F) << 6) | (c1 & 0x3F);
          t->data[t->size + 1] = ((c2 & 0x1F) << 6) | (c3 & 0x3F);
          t->size += 2;
          sptr += 4;
          slen -= 4;
          continue;
        } else {
          goto vec_utf8_2_bytes;
        }
      } else {
        return -1;
      }
    }
    if (c0 == 0xE0) {
      if ((c1 >= 0xA0 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF)) {
        goto vec_utf8_3_bytes;
      } else {
        return -1;
      }
    }
    if (c0 == 0xED) {
      if ((c1 >= 0x80 && c1 <= 0x9F) && (c2 >= 0x80 && c2 <= 0xBF)) {
        goto vec_utf8_3_bytes;
      } else {
        return -1;
      }
    }
    if (c0 >= 0xE1 && c0 <= 0xEF) {
      if ((c1 >= 0x80 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF)) {
        goto vec_utf8_3_bytes;
      } else {
        return -1;
      }
    }
    if (c0 == 0xF0) {
      if ((c1 >= 0x90 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF) &&
          (c3 >= 0x80 && c3 <= 0xBF)) {
        goto vec_utf8_4_bytes;
      } else {
        return -1;
      }
    }
    if (c0 >= 0xF1 && c0 <= 0xF3) {
      if ((c1 >= 0x80 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF) &&
          (c3 >= 0x80 && c3 <= 0xBF)) {
        goto vec_utf8_4_bytes;
      } else {
        return -1;
      }
    }
    if (c0 == 0xF4) {
      if ((c1 >= 0x80 && c1 <= 0x8F) && (c2 >= 0x80 && c2 <= 0xBF) &&
          (c3 >= 0x80 && c3 <= 0xBF)) {
        goto vec_utf8_4_bytes;
      } else {
        return -1;
      }
    }
    return -1;
  vec_utf8_1_byte:
    t->data[t->size] = c0;
    t->size++;
    sptr += 1;
    slen -= 1;
    continue;
  vec_utf8_2_bytes:
    t->data[t->size] = ((c0 & 0x1F) << 6) | (c1 & 0x3F);
    t->size++;
    sptr += 2;
    slen -= 2;
    continue;
  vec_utf8_3_bytes:
    t->data[t->size] = ((c0 & 0x0F) << 12) | ((c1 & 0x3F) << 6) | (c2 & 0x3F);
    t->size++;
    sptr += 3;
    slen -= 3;
    continue;
  vec_utf8_4_bytes:
    t->data[t->size] = ((c0 & 0x07) << 18) | ((c1 & 0x3F) << 12) |
                       ((c2 & 0x3F) << 6) | (c3 & 0x3F);
    t->size++;
    sptr += 4;
    slen -= 4;
    continue;
  }
  while (slen > 0) {
    unsigned char c0;
    unsigned char c1;
    unsigned char c2;
    unsigned char c3;
    c0 = sptr[0];
    if (c0 <= 0x7F) {
      goto utf8_1_byte;
    }
    if (slen < 2) {
      return -1;
    }
    c1 = sptr[1];
    if (c0 >= 0xC2 && c0 <= 0xDF) {
      if (c1 >= 0x80 && c1 <= 0xBF) {
        goto utf8_2_bytes;
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
    if (c0 == 0xED) {
      if ((c1 >= 0x80 && c1 <= 0x9F) && (c2 >= 0x80 && c2 <= 0xBF)) {
        goto utf8_3_bytes;
      } else {
        return -1;
      }
    }
    if (c0 >= 0xE1 && c0 <= 0xEF) {
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
  }
  return 0;
}
