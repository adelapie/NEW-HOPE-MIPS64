#ifndef POLY_H
#define POLY_H

#include <stdint.h>
#include "params1024.h"

typedef struct {
  uint16_t coeffs[NEWHOPE_N*3];
} poly __attribute__ ((aligned (32)));


void poly_add_asm(uint16_t *r, const uint16_t *a, const uint16_t *b);
void poly_mul_pointwise_asm(uint16_t *r, const uint16_t *a, const uint16_t *b);
void pointwise_1_64_asm(uint16_t *r, const uint64_t *a, const uint16_t *b);
void poly_add_vector_asm(uint64_t *r, const uint64_t *a, const uint64_t *b);
void poly_sub_asm(uint16_t *r, const uint16_t *a, const uint16_t *b);
void poly_frombytes_asm(uint16_t *r, const unsigned char *a);

void poly_uniform(poly *a, const unsigned char *seed);
void poly_sample(poly *r, const unsigned char *seed, unsigned char nonce);

void poly_tobytes(unsigned char *r, const poly *p);

void poly_compress(unsigned char *r, const poly *p);
void poly_decompress(poly *r, const unsigned char *a);

void poly_frommsg(poly *r, const unsigned char *msg);
void poly_tomsg(unsigned char *msg, const poly *x);



#endif
