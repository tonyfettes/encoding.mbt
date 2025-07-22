#include "moonbit.h"
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

struct moonbit_int32_array {
  int32_t size;
  int32_t *data;
};

static inline void *
moonbit_malloc_array(
  enum moonbit_block_kind kind,
  int elem_size_shift,
  int32_t len
) {
  struct moonbit_object *obj = (struct moonbit_object *)malloc(
    (len << elem_size_shift) + sizeof(struct moonbit_object)
  );
  obj->rc = 1;
  obj->meta = Moonbit_make_array_header(kind, elem_size_shift, len);
  return obj + 1;
}

static inline int32_t *
moonbit_make_int32_array_unsafe(int32_t len) {
  return moonbit_malloc_array(moonbit_BLOCK_KIND_VAL_ARRAY, 2, len);
}

static inline void
moonbit_int32_array_reserve(
  struct moonbit_int32_array *restrict array,
  int32_t by
) {
  int32_t required = array->size + by;
  int32_t capacity;
  if (array->data == moonbit_empty_int32_array) {
    capacity = 8;
    do {
      capacity *= 2;
    } while (capacity < required);
    array->data = moonbit_make_int32_array_unsafe(capacity);
    return;
  }
  capacity = Moonbit_array_length(array->data);
  if (required <= capacity) {
    return;
  }
  do {
    capacity *= 2;
  } while (capacity < required);
  struct moonbit_object *header = Moonbit_object_header(array->data);
  header = realloc(header, sizeof(struct moonbit_object) + (capacity << 2));
  array->data = (int32_t *)(header + 1);
}

struct moonbit_bytes_view {
  int32_t offset;
  int32_t length;
  moonbit_bytes_t bytes;
};

MOONBIT_FFI_EXPORT int
tonyfettes_encoding_v2_decode_utf8_to_char_array(
  const uint8_t *restrict s,
  int32_t soff,
  int32_t slen,
  struct moonbit_int32_array *restrict t
) {
  moonbit_int32_array_reserve(t, slen);
  const uint8_t *restrict sptr = s + soff;
  int32_t *restrict tptr = t->data + t->size;
  while (true) {
    uint8_t c0;
    uint8_t c1;
    uint8_t c2;
    uint8_t c3;
    if (slen == 0) {
      t->size += tptr - t->data;
      return -1;
    }
    c0 = sptr[0];
    if (c0 <= 0x7F) {
      union {
        uint64_t b;
        uint8_t c[8];
      } data;
      if (slen >= 8) {
        data.b = *(const uint64_t *)sptr;
        if ((data.b & 0x8080808080808080ULL) == 0) {
          goto utf8_1x8;
        } else {
          goto utf8_1_byte;
        }
      } else {
        goto utf8_1_byte;
      }
    utf8_1x8:
      tptr[0] = data.c[0];
      tptr[1] = data.c[1];
      tptr[2] = data.c[2];
      tptr[3] = data.c[3];
      tptr[4] = data.c[4];
      tptr[5] = data.c[5];
      tptr[6] = data.c[6];
      tptr[7] = data.c[7];
      tptr += 8;
      sptr += 8;
      slen -= 8;
      continue;
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
            tptr[0] = ((c0 & 0x1F) << 6) | (c1 & 0x3F);
            tptr[1] = ((c2 & 0x1F) << 6) | (c3 & 0x3F);
            tptr += 2;
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
    tptr[0] = c0;
    tptr++;
    sptr += 1;
    slen -= 1;
    continue;
  utf8_2_bytes:
    tptr[0] = ((c0 & 0x1F) << 6) | (c1 & 0x3F);
    tptr++;
    sptr += 2;
    slen -= 2;
    continue;
  utf8_3_bytes:
    tptr[0] = ((c0 & 0x0F) << 12) | ((c1 & 0x3F) << 6) | (c2 & 0x3F);
    tptr++;
    sptr += 3;
    slen -= 3;
    continue;
  utf8_4_bytes:
    tptr[0] = ((c0 & 0x07) << 18) | ((c1 & 0x3F) << 12) | ((c2 & 0x3F) << 6) |
              (c3 & 0x3F);
    tptr++;
    sptr += 4;
    slen -= 4;
    continue;
  malformed:
    t->size += tptr - t->data;
    return sptr - s + soff;
  }
}

MOONBIT_FFI_EXPORT bool
tonyfettes_encoding_v2_validate_utf8(
  moonbit_bytes_t s,
  int32_t soff,
  int32_t slen
) {
  const unsigned char *sptr = s + soff;
  while (true) {
    unsigned char c0;
    unsigned char c1;
    unsigned char c2;
    unsigned char c3;
    if (slen == 0) {
      return true;
    }
    c0 = sptr[0];
    if (c0 <= 0x7F) {
      size_t i = 1;
      if (slen >= 8) {
        uint64_t data = *(const uint64_t *)sptr;
        if ((data & 0x8080808080808080ULL) == 0) {
          i = 8;
        } else if ((data & 0x80808080ULL) == 0) {
          i = 4;
        } else if ((data & 0x8080ULL) == 0) {
          i = 2;
        }
      }
      sptr += i;
      slen -= i;
      continue;
    }
    if (c0 <= 0xC1 || slen < 2) {
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
            continue;
          }
        }
        goto utf8_2_bytes;
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
    if (c0 <= 0xEC) {
      if ((c1 >= 0x80 && c1 <= 0xBF) && (c2 >= 0x80 && c2 <= 0xBF)) {
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
    continue;
  utf8_2_bytes:
    sptr += 2;
    slen -= 2;
    continue;
  utf8_3_bytes:
    sptr += 3;
    slen -= 3;
    continue;
  utf8_4_bytes:
    sptr += 4;
    slen -= 4;
    continue;
  malformed:
    return false;
  }
}

MOONBIT_FFI_EXPORT void
tonyfettes_encoding_v2_unsafe_decode_utf8_to_char_array(
  moonbit_bytes_t s,
  int32_t soff,
  int32_t slen,
  struct moonbit_int32_array *restrict t
) {
  unsigned char *sptr = s + soff;
  moonbit_int32_array_reserve(t, slen);
  int32_t *restrict tptr = t->data + t->size;
  while (true) {
    unsigned char c0;
    unsigned char c1;
    unsigned char c2;
    unsigned char c3;
    if (slen == 0) {
      t->size += tptr - t->data;
      return;
    }
    c0 = sptr[0];
    if (c0 <= 0x7F) {
      if (slen >= 8) {
        uint64_t data = *(const uint64_t *)sptr;
        if ((data & 0x8080808080808080ULL) == 0) {
          goto utf8_1x8;
        } else {
          goto utf8_1_byte;
        }
      } else {
        goto utf8_1_byte;
      }
    utf8_1x8:
      tptr[0] = sptr[0];
      tptr[1] = sptr[1];
      tptr[2] = sptr[2];
      tptr[3] = sptr[3];
      tptr[4] = sptr[4];
      tptr[5] = sptr[5];
      tptr[6] = sptr[6];
      tptr[7] = sptr[7];
      tptr += 8;
      sptr += 8;
      slen -= 8;
      continue;
    }
    c1 = sptr[1];
    if (c0 <= 0xDF) {
      if (slen >= 4) {
        c2 = sptr[2];
        c3 = sptr[3];
        if (c2 >= 0xC2 && c2 <= 0xDF) {
          tptr[0] = ((c0 & 0x1F) << 6) | (c1 & 0x3F);
          tptr[1] = ((c2 & 0x1F) << 6) | (c3 & 0x3F);
          tptr += 2;
          sptr += 4;
          slen -= 4;
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
      goto utf8_3_bytes;
    }
    c3 = sptr[3];
    goto utf8_4_bytes;
  utf8_1_byte:
    tptr[0] = c0;
    tptr++;
    sptr += 1;
    slen -= 1;
    continue;
  utf8_2_bytes:
    tptr[0] = ((c0 & 0x1F) << 6) | (c1 & 0x3F);
    tptr++;
    sptr += 2;
    slen -= 2;
    continue;
  utf8_3_bytes:
    tptr[0] = ((c0 & 0x0F) << 12) | ((c1 & 0x3F) << 6) | (c2 & 0x3F);
    tptr++;
    sptr += 3;
    slen -= 3;
    continue;
  utf8_4_bytes:
    tptr[0] = ((c0 & 0x07) << 18) | ((c1 & 0x3F) << 12) | ((c2 & 0x3F) << 6) |
              (c3 & 0x3F);
    tptr++;
    sptr += 4;
    slen -= 4;
    continue;
  }
}
