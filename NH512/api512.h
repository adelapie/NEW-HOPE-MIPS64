#ifndef API512_H
#define API512_H

#include "params512.h"

#define CRYPTO_SECRETKEYBYTES  3680  /* 1792 for s, 1792 for b, 32 for z, 32 for H(pk) */
#define CRYPTO_PUBLICKEYBYTES  1824  /* 1792 for b, 32 for seed */
#define CRYPTO_CIPHERTEXTBYTES 2208  /* 1792 for v, 768 for compress(c), 32 for H(x) */
#define CRYPTO_BYTES           NEWHOPE_SYMBYTES    

#define CRYPTO_ALGNAME "NewHope512-CPAKEM"

int crypto_kem_keypair(unsigned char *pk, unsigned char *sk);

int crypto_kem_enc(unsigned char *ct, unsigned char *ss, const unsigned char *pk);

int crypto_kem_dec(unsigned char *ss, const unsigned char *ct, const unsigned char *sk);

#endif
