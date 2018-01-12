#include "api1024.h"
#include "poly.h"
#include "../common/randombytes.h"
#include <math.h>
#include <stdio.h>
#include <string.h>

#define NTESTS 1


int test_keys()
{
  unsigned char key_a[NEWHOPE_SYMBYTES], key_b[NEWHOPE_SYMBYTES];
  unsigned char pk[CRYPTO_PUBLICKEYBYTES];
  unsigned char sendb[CRYPTO_CIPHERTEXTBYTES];
  unsigned char sk_a[CRYPTO_SECRETKEYBYTES];
  int i;

  for(i=0; i<NTESTS; i++)
  {
    //Alice generates a public key
    crypto_kem_keypair(pk, sk_a);

    //Bob derives a secret key and creates a response
    crypto_kem_enc(sendb, key_b, pk);
  
    //Alice uses Bobs response to get her secre key
    crypto_kem_dec(key_a, sendb, sk_a);

    if(memcmp(key_a, key_b, 32))
    {
      int j;
      for(j=0;j<32;j++)
        printf("%02x ", key_a[j]);
      printf("\n");
      for(j=0;j<32;j++)
        printf("%02x ", key_b[j]);
      printf("\n");
      printf("ERROR keys\n");
    }
  }

  return 0;
}


int test_invalid_sk_a()
{
  unsigned char sk_a[CRYPTO_SECRETKEYBYTES];
  unsigned char key_a[32], key_b[32];
  unsigned char pk[CRYPTO_PUBLICKEYBYTES];
  unsigned char sendb[CRYPTO_CIPHERTEXTBYTES];
  int i;

  FILE *urandom = fopen("/dev/urandom", "r");
  
  for(i=0; i<NTESTS; i++)
  {
    //Alice generates a public key
    crypto_kem_keypair(pk, sk_a);

    //Bob derives a secret key and creates a response
    crypto_kem_enc(sendb, key_b, pk);

    //Replace secret key with random values
    fread(sk_a, CRYPTO_SECRETKEYBYTES, 1, urandom); 
  
    //Alice uses Bobs response to get her secre key
    crypto_kem_dec(key_a, sendb, sk_a);

    if(!memcmp(key_a, key_b, 32))
      printf("ERROR invalid sk_a\n");
  }

  fclose(urandom);

  return 0;
}


int test_invalid_ciphertext()
{
  unsigned char sk_a[CRYPTO_SECRETKEYBYTES];
  unsigned char key_a[32], key_b[32];
  unsigned char pk[CRYPTO_PUBLICKEYBYTES];
  unsigned char sendb[CRYPTO_CIPHERTEXTBYTES];
  int i;

  FILE *urandom = fopen("/dev/urandom", "r");
  
  for(i=0; i<NTESTS; i++)
  {
    //Alice generates a public key
    crypto_kem_keypair(pk, sk_a);

    //Bob derives a secret key and creates a response
    crypto_kem_enc(sendb, key_b, pk);

    //Change some byte in the ciphertext (i.e., encd key)
    sendb[42] ^= 23;
  
    //Alice uses Bobs response to get her secre key
    crypto_kem_dec(key_a, sendb, sk_a);

    if(!memcmp(key_a, key_b, 32))
      printf("ERROR invalid sk_a\n");
  }

  fclose(urandom);

  return 0;
}

int main(){

  unsigned char sk_a[CRYPTO_SECRETKEYBYTES];
  unsigned char key_a[32], key_b[32];
  unsigned char pk[CRYPTO_PUBLICKEYBYTES];
  unsigned char sendb[CRYPTO_CIPHERTEXTBYTES];

  int start=0, end=0, total_cycles = 0;

  asm volatile("rdhwr %0, $2" : "=r" (start));
  test_keys();
  asm volatile("rdhwr %0, $2" : "=r" (end));

  total_cycles = (end - start);

  printf("Cycles during operation (whole algorithm): %d\n\n", total_cycles);

  asm volatile("rdhwr %0, $2" : "=r" (start));
  crypto_kem_keypair(pk, sk_a);
  asm volatile("rdhwr %0, $2" : "=r" (end));

  total_cycles = (end - start);

  printf("Cycles during operation (key generate): %d\n\n", total_cycles);

  asm volatile("rdhwr %0, $2" : "=r" (start));
  crypto_kem_enc(sendb, key_b, pk);

  asm volatile("rdhwr %0, $2" : "=r" (end));

  total_cycles = (end - start);

  printf("Cycles during operation (key enc): %d\n\n", total_cycles);

  sendb[42] ^= 23;

  asm volatile("rdhwr %0, $2" : "=r" (start));
  
  //Alice uses Bobs response to get her secre key
  crypto_kem_dec(key_a, sendb, sk_a);
  asm volatile("rdhwr %0, $2" : "=r" (end));

  total_cycles = (end - start);

  printf("Cycles during operation (key dec): %d\n\n", total_cycles);


  /*
  test_invalid_sk_a();
  test_invalid_ciphertext();
  */
  
  printf("CRYPTO_SECRETKEYBYTES: %d\n",CRYPTO_SECRETKEYBYTES);
  printf("CRYPTO_PUBLICKEYBYTES: %d\n",CRYPTO_PUBLICKEYBYTES);
  printf("NEWHOPE_BYTES:          %d\n",CRYPTO_CIPHERTEXTBYTES);

  return 0;
}
