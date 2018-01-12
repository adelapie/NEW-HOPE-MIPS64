#ifndef CPAKEM_H
#define CPAKEM_H

int crypto_kem_keygenerate(
    unsigned char *pk,
    unsigned char *sk);

int crypto_kem_encapsulate(
    unsigned char *ct,
    unsigned char *ss,
    const unsigned char *pk);

int crypto_kem_decapsulate(
    unsigned char *ss,
    const unsigned char *ct,
    const unsigned char *sk);
  
int crypto_kem_keygenerate_KAT(
    unsigned char *pk,
    unsigned char *sk,
    const unsigned char *randomness);

int crypto_kem_encapsulate_KAT(
    unsigned char *ct,
    unsigned char *ss,
    const unsigned char *pk,
    const unsigned char *randomness);


#endif
