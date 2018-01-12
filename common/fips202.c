/* Based on the public domain implementation in
 * crypto_hash/keccakc512/simple/ from http://bench.cr.yp.to/supercop.html
 * by Ronny Van Keer 
 * and the public domain "TweetFips202" implementation
 * from https://twitter.com/tweetfips202
 * by Gilles Van Assche, Daniel J. Bernstein, and Peter Schwabe */

#include <stdint.h>
#include <assert.h>
#include "fips202.h"

#define NROUNDS 24
#define ROL(a, offset) ((a << offset) ^ (a >> (64-offset)))

static void store64(uint8_t *x, uint64_t u)
{
  unsigned int i;

  for(i=0; i<8; ++i) {
    x[i] = u;
    u >>= 8;
  }
}

#include <string.h>
#define MIN(a, b) ((a) < (b) ? (a) : (b))


static void keccak_absorb(uint64_t *s,
                          unsigned int r,
                          const unsigned char *m, unsigned long long int mlen,
                          unsigned char p)
{
  unsigned long long i;
  unsigned char t[200];

  for (i = 0; i < 25; ++i)
    s[i] = 0;
  
  while (mlen >= r) 
  {
    for (i = 0; i < r / 8; ++i) 
      s[i] ^= *(uint64_t *)(m + 8 *i);
    
    
    f1600(s);
    mlen -= r;
    m += r;
  }

  for (i = 0; i < r; ++i)
    t[i] = 0;
  for (i = 0; i < mlen; ++i)
    t[i] = m[i];
  t[i] = p;
  t[r - 1] |= 128;
  for (i = 0; i < r / 8; ++i)
    s[i] ^= *(uint64_t *)(t + 8 *i);
}


static void keccak_squeezeblocks(unsigned char *h, unsigned long long int nblocks,
                                 uint64_t *s, 
                                 unsigned int r)
{
  unsigned int i;
  while(nblocks > 0) 
  {
    f1600(s);
    for(i=0;i<(r>>3);i++)
    {
      store64(h+8*i, s[i]);
    }
    h += r;
    nblocks--;
  }
}

void shake128_absorb(uint64_t *s, const unsigned char *input, unsigned long long inputByteLen)
{
  keccak_absorb(s, SHAKE128_RATE, input, inputByteLen, 0x1F);
}


void shake128_squeezeblocks(unsigned char *output, unsigned long long nblocks, uint64_t *s)
{
  keccak_squeezeblocks(output, nblocks, s, SHAKE128_RATE);
}


void shake256(unsigned char *output, unsigned long long outlen, 
              const unsigned char *input,  unsigned long long inlen)
{
  uint64_t s[25];
  unsigned char t[SHAKE128_RATE];
  unsigned long long nblocks = outlen/SHAKE128_RATE;
  size_t i;

  for (i = 0; i < 25; ++i)
    s[i] = 0;
  
  /* Absorb input */
  keccak_absorb(s, SHAKE256_RATE, input, inlen, 0x1F);

  /* Squeeze output */
  keccak_squeezeblocks(output, nblocks, s, SHAKE256_RATE);

  output+=nblocks*SHAKE256_RATE;
  outlen-=nblocks*SHAKE256_RATE;

  if(outlen) 
  {
    keccak_squeezeblocks(t, 1, s, SHAKE256_RATE);
    for(i=0;i<outlen;i++)
      output[i] = t[i];
  }
}

