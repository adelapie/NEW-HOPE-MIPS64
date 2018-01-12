#ifndef NTT_H
#define NTT_H

#include "inttypes.h"

extern uint16_t omegas_montgomery[];
extern uint16_t omegas_inv_montgomery[];

extern uint16_t psis_bitrev_montgomery[];
extern uint16_t psis_inv_montgomery[];

void bitrev_vector(uint16_t* poly);
void mul_coefficients(uint16_t* poly, const uint16_t* factors);
void ntt(uint16_t* poly, const uint16_t* omegas);
uint64_t *ntt_pre(uint16_t * a, const uint16_t* omega);

void ntt_layer_0(uint16_t *a, const uint16_t *omega);
void ntt_layers_1_9(uint64_t *a, const uint16_t *omega);

#endif
