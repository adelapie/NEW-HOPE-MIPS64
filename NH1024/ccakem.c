#include <string.h>
#include "ccakem.h"
#include "cpapke.h"
#include "api1024.h"
#include "params1024.h"
#include "../common/randombytes.h"
#include "../common/fips202.h"
#include "../common/verify.h"


int crypto_kem_keypair(
    unsigned char *pk,
    unsigned char *sk)
{
  size_t i;

  cpapke_keypair(pk, sk);
  sk += NEWHOPE_CPAPKE_SECRETKEYBYTES;

  for(i=0;i<NEWHOPE_CPAPKE_PUBLICKEYBYTES;i++)                              /* Append the public key for re-encryption */
    sk[i] = pk[i];
  sk += NEWHOPE_CPAPKE_PUBLICKEYBYTES;

  shake256(sk, NEWHOPE_SYMBYTES, pk, NEWHOPE_CPAPKE_PUBLICKEYBYTES); /* Append the hash of the public key */
  sk += NEWHOPE_SYMBYTES;

  randombytes(sk, NEWHOPE_SYMBYTES); 

  return 0;
}


int crypto_kem_enc(
    unsigned char *ct,
    unsigned char *ss,
    const unsigned char *pk)
{
  unsigned char k_coins_d[NEWHOPE_SYMBYTES*3];                             /* Will contain key, coins, qrom-hash */
  unsigned char buf[NEWHOPE_SYMBYTES*2];                          
  int i;
  
  randombytes(buf,NEWHOPE_SYMBYTES);
  
  shake256(buf,NEWHOPE_SYMBYTES,buf,NEWHOPE_SYMBYTES);                    /* Don't release system RNG output */
  shake256(buf+NEWHOPE_SYMBYTES, NEWHOPE_SYMBYTES, pk, NEWHOPE_PUBLICKEYBYTES);  /* Multitarget countermeasure for coins + contributory KEM */
  shake256(k_coins_d, NEWHOPE_SYMBYTES*3, buf, NEWHOPE_SYMBYTES*2);

  cpapke_enc(ct, buf, pk, k_coins_d+NEWHOPE_SYMBYTES);                    /* coins are in k_coins_d+NEWHOPE_SYMBYTES */

  for(i=0;i<NEWHOPE_SYMBYTES;i++)
    ct[i+NEWHOPE_CPAPKE_CIPHERTEXTBYTES] = k_coins_d[i+NEWHOPE_SYMBYTES*2];

  shake256(k_coins_d+NEWHOPE_SYMBYTES, NEWHOPE_SYMBYTES, ct, NEWHOPE_CIPHERTEXTBYTES);  /* overwrite coins in k_coins_d with h(c) */
  shake256(ss, NEWHOPE_SYMBYTES, k_coins_d, NEWHOPE_SYMBYTES*2);                          /* hash concatenation of pre-k and h(c) to k */
  return 0;
}


int crypto_kem_dec(
    unsigned char *ss,
    const unsigned char *ct,
    const unsigned char *sk)
{
  int i, fail;
  unsigned char cmp[NEWHOPE_CIPHERTEXTBYTES];
  unsigned char buf[NEWHOPE_SYMBYTES*2];
  unsigned char k_coins_d[NEWHOPE_SYMBYTES*3];                             /* Will contain key, coins, qrom-hash */
  const unsigned char *pk = sk+NEWHOPE_CPAPKE_SECRETKEYBYTES;

  cpapke_dec(buf, ct, sk);

  for(i=0;i<NEWHOPE_SYMBYTES;i++)                                  /* Save hash by storing h(pk) in sk */
    buf[NEWHOPE_SYMBYTES+i] = sk[NEWHOPE_SECRETKEYBYTES-NEWHOPE_SYMBYTES*2+i];
  shake256(k_coins_d, NEWHOPE_SYMBYTES*3, buf, NEWHOPE_SYMBYTES*2);

  cpapke_enc(cmp, buf, pk, k_coins_d+NEWHOPE_SYMBYTES);                  /* coins are in k_coins_d+NEWHOPE_SYMBYTES */

  for(i=0;i<NEWHOPE_SYMBYTES;i++)
    cmp[i+NEWHOPE_CPAPKE_CIPHERTEXTBYTES] = k_coins_d[i+NEWHOPE_SYMBYTES*2];

  fail = verify(ct, cmp, NEWHOPE_CIPHERTEXTBYTES);

  shake256(k_coins_d+NEWHOPE_SYMBYTES, NEWHOPE_SYMBYTES, ct, NEWHOPE_CIPHERTEXTBYTES); /* overwrite coins in k_coins_d with h(c)  */
  cmov(k_coins_d, sk+NEWHOPE_SECRETKEYBYTES-NEWHOPE_SYMBYTES, NEWHOPE_SYMBYTES, fail); /* Overwrite pre-k with z on re-encryption failure */
  shake256(ss, NEWHOPE_SYMBYTES, k_coins_d, NEWHOPE_SYMBYTES*2);                          /* hash concatenation of pre-k and h(c) to k */

  return -fail;
}
