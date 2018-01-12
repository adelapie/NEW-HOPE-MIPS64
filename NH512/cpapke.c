#include <stdio.h>
#include "api512.h"
#include "poly.h"
#include "../common/randombytes.h"
#include "../common/fips202.h"
#include "ntt.h"

extern uint16_t omegas_montgomery[NEWHOPE_N/2];
extern uint16_t omegas_inv_montgomery[NEWHOPE_N/2];
extern uint16_t psis_bitrev_montgomery[NEWHOPE_N];
extern uint16_t psis_inv_montgomery[NEWHOPE_N];

static void encode_pk(unsigned char *r, const poly *pk, const unsigned char *seed)
{
  int i;
  poly_tobytes(r, pk);
  for(i=0;i<NEWHOPE_SYMBYTES;i++)
    r[NEWHOPE_POLYBYTES+i] = seed[i];
}

static void decode_pk(poly *pk, unsigned char *seed, const unsigned char *r)
{
  int i;
  poly_frombytes_asm(pk->coeffs, r);
  for(i=0;i<NEWHOPE_SYMBYTES;i++)
    seed[i] = r[NEWHOPE_POLYBYTES+i];
}

static void encode_c(unsigned char *r, const poly *b, const poly *v)
{
  poly_tobytes(r,b);
  poly_compress(r+NEWHOPE_POLYBYTES,v);
}

static void decode_c(poly *b, poly *v, const unsigned char *r)
{
  poly_frombytes_asm(b->coeffs, r);
  poly_decompress(v, r+NEWHOPE_POLYBYTES);
}

static void gen_a(poly *a, const unsigned char *seed)
{
  poly_uniform(a,seed);
}


// API FUNCTIONS 

void cpapke_keypair(unsigned char *pk, 
                    unsigned char *sk)
{

  uint64_t *p_64 = NULL, *p_64_ehat = NULL, *p_64_ahat_shat = NULL;
  uint64_t c_64[512];
  int i;

  poly ahat, ehat, ahat_shat, bhat, shat;

  unsigned char z[2*NEWHOPE_SYMBYTES];
  unsigned char *publicseed = z;
  unsigned char *noiseseed = z+NEWHOPE_SYMBYTES;

  randombytes(z, NEWHOPE_SYMBYTES);
  shake256(z, 2*NEWHOPE_SYMBYTES, z, NEWHOPE_SYMBYTES);

  /* generate shat , ntt(shat) */

  poly_sample(&shat,noiseseed,0);
  mul_coefficients(shat.coeffs, psis_bitrev_montgomery); 
  p_64 = ntt_pre((uint16_t *)&shat.coeffs, omegas_montgomery);

  /*generate ahat, ahat_shat = shat * ahat*/
  
  gen_a(&ahat, publicseed);
  
  pointwise_1_64_asm(ahat_shat.coeffs, p_64, ahat.coeffs);

  p_64_ahat_shat = (uint64_t*)ahat_shat.coeffs;
  
  /* generate ehat, ntt(ehat) */

  poly_sample(&ehat,noiseseed,1);
  mul_coefficients(ehat.coeffs, psis_bitrev_montgomery); 
  p_64_ehat = ntt_pre((uint16_t *)&ehat.coeffs, omegas_montgomery);

  /* bhat = ehat + ahat_shat */
  poly_add_vector_asm(c_64, p_64_ehat, p_64_ahat_shat);

  for(i=0;i<NEWHOPE_N/2;i++) {
   bhat.coeffs[2*i]   = c_64[i] >> 32;
   bhat.coeffs[2*i+1] = c_64[i] & 0xffffffff;
   shat.coeffs[2*i]   = p_64[i] >> 32;
   shat.coeffs[2*i+1] = p_64[i] & 0xffffffff;
  }

  poly_tobytes(sk,&shat);
  encode_pk(pk, &bhat, publicseed);
}

void cpapke_enc(unsigned char *c,
                const unsigned char *m,
                const unsigned char *pk,
                const unsigned char *coins)
{
  poly sprime, eprime, vprime, ahat, bhat, eprimeprime, uhat, v;
  unsigned char seed[NEWHOPE_SYMBYTES];
  
  uint64_t *p_64_sprime = NULL, *p_64_eprime = NULL, *p_64_uhat = NULL;
  uint64_t c_64[512];
  int i = 0;

  poly_frommsg(&v, m);

  decode_pk(&bhat, seed, pk);
  gen_a(&ahat, seed);
 
  poly_sample(&sprime,coins,0);
  poly_sample(&eprime,coins,1);
  poly_sample(&eprimeprime,coins,2);

  /* generate ntt(sprime) */
  mul_coefficients(sprime.coeffs, psis_bitrev_montgomery); 
  p_64_sprime = ntt_pre((uint16_t *)&sprime.coeffs, omegas_montgomery);

  for(i=0;i<NEWHOPE_N/2;i++) {
   sprime.coeffs[2*i]   = p_64_sprime[i] >> 32;
   sprime.coeffs[2*i+1] = p_64_sprime[i] & 0xffffffff;
  }
  /* generate ntt(sprime) */

  /* generate ntt(eprime) */
  mul_coefficients(eprime.coeffs, psis_bitrev_montgomery); 
  p_64_eprime = ntt_pre((uint16_t *)&eprime.coeffs, omegas_montgomery);
  /* generate ntt(eprime) */

  /* uhat = ahat * sprime */
  pointwise_1_64_asm(uhat.coeffs, p_64_sprime, ahat.coeffs);
  p_64_uhat = (uint64_t*)uhat.coeffs;

  /* uhat = uhat + eprime */
  poly_add_vector_asm(c_64, p_64_uhat, p_64_eprime);
 
  poly_mul_pointwise_asm(vprime.coeffs, bhat.coeffs, sprime.coeffs);
  /* invntt(vprime) */
  bitrev_vector(vprime.coeffs);
  ntt((uint16_t *)vprime.coeffs, omegas_inv_montgomery);
  mul_coefficients(vprime.coeffs, psis_inv_montgomery);
  /* invntt(vprime) */

  poly_add_asm(vprime.coeffs, vprime.coeffs, eprimeprime.coeffs);
  poly_add_asm(vprime.coeffs, vprime.coeffs, v.coeffs); // add message

  for(i=0;i<NEWHOPE_N/2;i++) {
   uhat.coeffs[2*i]   = c_64[i] >> 32;
   uhat.coeffs[2*i+1] = c_64[i] & 0xffffffff;
  }

  encode_c(c, &uhat, &vprime);
}

void cpapke_dec(unsigned char *m,
                const unsigned char *c,
                const unsigned char *sk)
{
  poly vprime,uhat,tmp,shat;

  poly_frombytes_asm(shat.coeffs, sk);

  decode_c(&uhat, &vprime, c);
  poly_mul_pointwise_asm(tmp.coeffs,shat.coeffs,uhat.coeffs);

  /* invntt(kp) */
  bitrev_vector(tmp.coeffs);
  ntt((uint16_t *)tmp.coeffs, omegas_inv_montgomery);
  mul_coefficients(tmp.coeffs, psis_inv_montgomery);
  /* invntt(kp) */

  poly_sub_asm(tmp.coeffs,tmp.coeffs,vprime.coeffs);

  poly_tomsg(m, &tmp);
}
