#include "moonbit.h"
#include <immintrin.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

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
  int32_t capacity = Moonbit_array_length(array->data);
  if (required <= capacity) {
    return;
  }
  if (capacity < 8) {
    capacity = 8;
  }
  do {
    capacity *= 2;
  } while (capacity < required);
  struct moonbit_object *header = Moonbit_object_header(array->data);
  if (array->data == moonbit_empty_int32_array) {
    array->data = moonbit_make_int32_array_unsafe(capacity);
  } else {
    header = realloc(header, sizeof(struct moonbit_object) + (capacity << 2));
    array->data = (int32_t *)(header + 1);
  }
}

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
  unsigned char *sptr = s.bytes + s.offset;
  int32_t slen = s.length;
  moonbit_int32_array_reserve(t, slen);
  int32_t *restrict tptr = t->data + t->size;
  int32_t tlen = 0;
  while (true) {
    unsigned char c0;
    unsigned char c1;
    unsigned char c2;
    unsigned char c3;
    if (slen == 0) {
      t->size += tlen;
      return -1;
    }
    c0 = sptr[0];
    if (c0 <= 0x7F) {
      if (slen >= 64) {
        __m512i data = _mm512_loadu_si512((const __m512i *)sptr);
        __mmask64 mask = _mm512_test_epi8_mask(data, _mm512_set1_epi8(0x80));
        if (mask == 0) {
          __m128i b0 = _mm512_extracti32x4_epi32(data, 0);
          __m128i b1 = _mm512_extracti32x4_epi32(data, 1);
          __m128i b2 = _mm512_extracti32x4_epi32(data, 2);
          __m128i b3 = _mm512_extracti32x4_epi32(data, 3);
          __m512i q0 = _mm512_cvtepu8_epi32(b0);
          __m512i q1 = _mm512_cvtepu8_epi32(b1);
          __m512i q2 = _mm512_cvtepu8_epi32(b2);
          __m512i q3 = _mm512_cvtepu8_epi32(b3);
          _mm512_storeu_si512((__m512i *)&tptr[tlen], q0);
          _mm512_storeu_si512((__m512i *)&tptr[tlen + 16], q1);
          _mm512_storeu_si512((__m512i *)&tptr[tlen + 32], q2);
          _mm512_storeu_si512((__m512i *)&tptr[tlen + 48], q3);
          tlen += 64;
          sptr += 64;
          slen -= 64;
          continue;
        } else if ((mask & 0xFFFFFFFF) == 0) {
          __m128i b0 = _mm512_extracti32x4_epi32(data, 0);
          __m128i b1 = _mm512_extracti32x4_epi32(data, 1);
          __m512i q0 = _mm512_cvtepu8_epi32(b0);
          __m512i q1 = _mm512_cvtepu8_epi32(b1);
          _mm512_storeu_si512((__m512i *)&tptr[tlen], q0);
          _mm512_storeu_si512((__m512i *)&tptr[tlen + 16], q1);
          tlen += 32;
          sptr += 32;
          slen -= 32;
          continue;
        } else if ((mask & 0xFFFF) == 0) {
          __m128i b0 = _mm512_extracti32x4_epi32(data, 0);
          __m512i q0 = _mm512_cvtepu8_epi32(b0);
          _mm512_storeu_si512((__m512i *)&tptr[tlen], q0);
          tlen += 16;
          sptr += 16;
          slen -= 16;
          continue;
        } else if ((mask & 0xFF) == 0) {
          goto utf8_1x8;
        } else if ((mask & 0xF) == 0) {
          goto utf8_1x4;
        } else if ((mask & 0x3) == 0) {
          goto utf8_1x2;
        } else {
          goto utf8_1_byte;
        }
      } else if (slen >= 32) {
        __m256i data = _mm256_loadu_si256((const __m256i *)sptr);
        __mmask32 mask = _mm256_test_epi8_mask(data, _mm256_set1_epi8(0x80));
        if (mask == 0) {
          __m128i b0 = _mm256_extracti128_si256(data, 0);
          __m128i b1 = _mm256_extracti128_si256(data, 1);
          __m512i q0 = _mm512_cvtepu8_epi32(b0);
          __m512i q1 = _mm512_cvtepu8_epi32(b1);
          _mm512_storeu_si512((__m512i *)&tptr[tlen], q0);
          _mm512_storeu_si512((__m512i *)&tptr[tlen + 16], q1);
          tlen += 32;
          sptr += 32;
          slen -= 32;
          continue;
        } else if ((mask & 0xFFFF) == 0) {
          __m128i b0 = _mm256_extracti128_si256(data, 0);
          __m512i q0 = _mm512_cvtepu8_epi32(b0);
          _mm512_storeu_si512((__m512i *)&tptr[tlen], q0);
          tlen += 16;
          sptr += 16;
          slen -= 16;
          continue;
        } else if ((mask & 0xFF) == 0) {
          goto utf8_1x8;
        } else if ((mask & 0xF) == 0) {
          goto utf8_1x4;
        } else if ((mask & 0x3) == 0) {
          goto utf8_1x2;
        } else {
          goto utf8_1_byte;
        }
      } else if (slen >= 16) {
        __m128i data = _mm_loadu_si128((const __m128i *)sptr);
        __mmask16 mask = _mm_test_epi8_mask(data, _mm_set1_epi8(0x80));
        if (mask == 0) {
          __m512i q0 = _mm512_cvtepu8_epi32(data);
          _mm512_storeu_si512((__m512i *)&tptr[tlen], q0);
          tlen += 16;
          sptr += 16;
          slen -= 16;
          continue;
        } else if ((mask & 0xFF) == 0) {
          goto utf8_1x8;
        } else if ((mask & 0xF) == 0) {
          goto utf8_1x4;
        } else if ((mask & 0x3) == 0) {
          goto utf8_1x2;
        } else {
          goto utf8_1_byte;
        }
      } else if (slen >= 8) {
        uint64_t data = *(const uint64_t *)sptr;
        if ((data & 0x8080808080808080ULL) == 0) {
          goto utf8_1x8;
        } else if ((data & 0x80808080ULL) == 0) {
          goto utf8_1x4;
        } else if ((data & 0x8080ULL) == 0) {
          goto utf8_1x2;
        } else {
          goto utf8_1_byte;
        }
      } else if (slen >= 4) {
        uint32_t data = *(const uint32_t *)sptr;
        if ((data & 0x80808080U) == 0) {
          goto utf8_1x4;
        } else if ((data & 0x8080U) == 0) {
          goto utf8_1x2;
        } else {
          goto utf8_1_byte;
        }
      } else if (slen >= 2) {
        unsigned char c1 = sptr[1];
        if (c1 <= 0x7F) {
          tptr[tlen] = c0;
          tptr[tlen + 1] = c1;
          tlen += 2;
          sptr += 2;
          slen -= 2;
          continue;
        } else {
          goto utf8_1_byte;
        }
      } else {
        goto utf8_1_byte;
      }
    utf8_1x8:
      tptr[tlen] = c0;
      tptr[tlen + 1] = sptr[1];
      tptr[tlen + 2] = sptr[2];
      tptr[tlen + 3] = sptr[3];
      tptr[tlen + 4] = sptr[4];
      tptr[tlen + 5] = sptr[5];
      tptr[tlen + 6] = sptr[6];
      tptr[tlen + 7] = sptr[7];
      tlen += 8;
      sptr += 8;
      slen -= 8;
      continue;
    utf8_1x4:
      tptr[tlen] = c0;
      tptr[tlen + 1] = sptr[1];
      tptr[tlen + 2] = sptr[2];
      tptr[tlen + 3] = sptr[3];
      tlen += 4;
      sptr += 4;
      slen -= 4;
      continue;
    utf8_1x2:
      tptr[tlen] = c0;
      tptr[tlen + 1] = sptr[1];
      tlen += 2;
      sptr += 2;
      slen -= 2;
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
            tptr[tlen] = ((c0 & 0x1F) << 6) | (c1 & 0x3F);
            tptr[tlen + 1] = ((c2 & 0x1F) << 6) | (c3 & 0x3F);
            tlen += 2;
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
    tptr[tlen] = c0;
    tlen++;
    sptr += 1;
    slen -= 1;
    continue;
  utf8_2_bytes:
    tptr[tlen] = ((c0 & 0x1F) << 6) | (c1 & 0x3F);
    tlen++;
    sptr += 2;
    slen -= 2;
    continue;
  utf8_3_bytes:
    tptr[tlen] = ((c0 & 0x0F) << 12) | ((c1 & 0x3F) << 6) | (c2 & 0x3F);
    tlen++;
    sptr += 3;
    slen -= 3;
    continue;
  utf8_4_bytes:
    tptr[tlen] = ((c0 & 0x07) << 18) | ((c1 & 0x3F) << 12) |
                 ((c2 & 0x3F) << 6) | (c3 & 0x3F);
    tlen++;
    sptr += 4;
    slen -= 4;
    continue;
  malformed:
    t->size += tlen;
    return sptr - s.bytes + s.offset;
  }
}

MOONBIT_FFI_EXPORT bool
tonyfettes_encoding_v2_validate_utf8_to_char_array(struct moonbit_bytes_view s
) {
  const unsigned char *sptr = s.bytes + s.offset;
  int32_t slen = s.length;
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
      goto utf8_1_byte;
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
      if (slen >= 64) {
        __m512i data = _mm512_loadu_si512((const __m512i *)sptr);
        __mmask64 mask = _mm512_test_epi8_mask(data, _mm512_set1_epi8(0x80));
        if (mask == 0) {
          __m128i b0 = _mm512_extracti32x4_epi32(data, 0);
          __m128i b1 = _mm512_extracti32x4_epi32(data, 1);
          __m128i b2 = _mm512_extracti32x4_epi32(data, 2);
          __m128i b3 = _mm512_extracti32x4_epi32(data, 3);
          __m512i q0 = _mm512_cvtepu8_epi32(b0);
          __m512i q1 = _mm512_cvtepu8_epi32(b1);
          __m512i q2 = _mm512_cvtepu8_epi32(b2);
          __m512i q3 = _mm512_cvtepu8_epi32(b3);
          _mm512_storeu_si512((__m512i *)&t->data[t->size], q0);
          _mm512_storeu_si512((__m512i *)&t->data[t->size + 16], q1);
          _mm512_storeu_si512((__m512i *)&t->data[t->size + 32], q2);
          _mm512_storeu_si512((__m512i *)&t->data[t->size + 48], q3);
          t->size += 64;
          sptr += 64;
          slen -= 64;
          continue;
        } else if ((mask & 0xFFFFFFFF) == 0) {
          __m128i b0 = _mm512_extracti32x4_epi32(data, 0);
          __m128i b1 = _mm512_extracti32x4_epi32(data, 1);
          __m512i q0 = _mm512_cvtepu8_epi32(b0);
          __m512i q1 = _mm512_cvtepu8_epi32(b1);
          _mm512_storeu_si512((__m512i *)&t->data[t->size], q0);
          _mm512_storeu_si512((__m512i *)&t->data[t->size + 16], q1);
          t->size += 32;
          sptr += 32;
          slen -= 32;
          continue;
        } else if ((mask & 0xFFFF) == 0) {
          __m128i b0 = _mm512_extracti32x4_epi32(data, 0);
          __m512i q0 = _mm512_cvtepu8_epi32(b0);
          _mm512_storeu_si512((__m512i *)&t->data[t->size], q0);
          t->size += 16;
          sptr += 16;
          slen -= 16;
          continue;
        } else if ((mask & 0xFF) == 0) {
          goto utf8_1x8;
        } else if ((mask & 0xF) == 0) {
          goto utf8_1x4;
        } else if ((mask & 0x3) == 0) {
          goto utf8_1x2;
        } else {
          goto utf8_1_byte;
        }
      } else if (slen >= 32) {
        __m256i data = _mm256_loadu_si256((const __m256i *)sptr);
        __mmask32 mask = _mm256_test_epi8_mask(data, _mm256_set1_epi8(0x80));
        if (mask == 0) {
          __m128i b0 = _mm256_extracti128_si256(data, 0);
          __m128i b1 = _mm256_extracti128_si256(data, 1);
          __m512i q0 = _mm512_cvtepu8_epi32(b0);
          __m512i q1 = _mm512_cvtepu8_epi32(b1);
          _mm512_storeu_si512((__m512i *)&t->data[t->size], q0);
          _mm512_storeu_si512((__m512i *)&t->data[t->size + 16], q1);
          t->size += 32;
          sptr += 32;
          slen -= 32;
          continue;
        } else if ((mask & 0xFFFF) == 0) {
          __m128i b0 = _mm256_extracti128_si256(data, 0);
          __m512i q0 = _mm512_cvtepu8_epi32(b0);
          _mm512_storeu_si512((__m512i *)&t->data[t->size], q0);
          t->size += 16;
          sptr += 16;
          slen -= 16;
          continue;
        } else if ((mask & 0xFF) == 0) {
          goto utf8_1x8;
        } else if ((mask & 0xF) == 0) {
          goto utf8_1x4;
        } else if ((mask & 0x3) == 0) {
          goto utf8_1x2;
        } else {
          goto utf8_1_byte;
        }
      } else if (slen >= 16) {
        __m128i data = _mm_loadu_si128((const __m128i *)sptr);
        __mmask16 mask = _mm_test_epi8_mask(data, _mm_set1_epi8(0x80));
        if (mask == 0) {
          __m512i q0 = _mm512_cvtepu8_epi32(data);
          _mm512_storeu_si512((__m512i *)&t->data[t->size], q0);
          t->size += 16;
          sptr += 16;
          slen -= 16;
          continue;
        } else if ((mask & 0xFF) == 0) {
          goto utf8_1x8;
        } else if ((mask & 0xF) == 0) {
          goto utf8_1x4;
        } else if ((mask & 0x3) == 0) {
          goto utf8_1x2;
        } else {
          goto utf8_1_byte;
        }
      } else if (slen >= 8) {
        uint64_t data = *(const uint64_t *)sptr;
        if ((data & 0x8080808080808080ULL) == 0) {
          goto utf8_1x8;
        } else if ((data & 0x80808080ULL) == 0) {
          goto utf8_1x4;
        } else if ((data & 0x8080ULL) == 0) {
          goto utf8_1x2;
        } else {
          goto utf8_1_byte;
        }
      } else if (slen >= 4) {
        uint32_t data = *(const uint32_t *)sptr;
        if ((data & 0x80808080U) == 0) {
          goto utf8_1x4;
        } else if ((data & 0x8080U) == 0) {
          goto utf8_1x2;
        } else {
          goto utf8_1_byte;
        }
      } else if (slen >= 2) {
        unsigned char c1 = sptr[1];
        if (c1 <= 0x7F) {
          t->data[t->size] = c0;
          t->data[t->size + 1] = c1;
          t->size += 2;
          sptr += 2;
          slen -= 2;
          continue;
        } else {
          goto utf8_1_byte;
        }
      } else {
        goto utf8_1_byte;
      }
    utf8_1x8:
      t->data[t->size] = c0;
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
    utf8_1x4:
      t->data[t->size] = c0;
      t->data[t->size + 1] = sptr[1];
      t->data[t->size + 2] = sptr[2];
      t->data[t->size + 3] = sptr[3];
      t->size += 4;
      sptr += 4;
      slen -= 4;
      continue;
    utf8_1x2:
      t->data[t->size] = c0;
      t->data[t->size + 1] = sptr[1];
      t->size += 2;
      sptr += 2;
      slen -= 2;
      continue;
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
