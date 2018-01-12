CC=mipsisa64-octeon-elf-gcc
CFLAGS_LOCAL = -march=octeon3 -W -Wall -Wno-unused-parameter -I$(OCTEON_ROOT)/target/include

TARGET_POLY = poly.o
TARGET_POLY_ASM = poly_asm.o
TARGET_PRECOMP = precomp.o
TARGET_REDUCE = ../common/reduce.o
TARGET_FIPS = ../common/fips202.o
TARGET_NTT_ASM = ntt_asm.o
TARGET_FIPS_ASM = f1600_bare_metal.o
TARGET_NTT = ntt.o
TARGET_CPAPKE = cpapke.o
TARGET_CCAKEM = ccakem.o
TARGET_CPAKEM = cpakem.o
TARGET_VERIFY = ../common/verify.o

all: obj_files
	$(CC) $(CFLAGS_LOCAL) $(CFLAGS_GLOBAL) $(TARGET_POLY) $(TARGET_POLY_ASM) $(TARGET_PRECOMP) $(TARGET_FIPS) $(TARGET_FIPS_ASM) $(TARGET_REDUCE) $(TARGET_NTT_ASM) $(TARGET_NTT) $(TARGET_CPAPKE) $(TARGET_CCAKEM) $(TARGET_VERIFY) test_newhope.c ../common/randombytes.c -o ../test/test_ccakem1024
	$(CC) $(CFLAGS_LOCAL) $(CFLAGS_GLOBAL) $(TARGET_POLY) $(TARGET_POLY_ASM) $(TARGET_PRECOMP) $(TARGET_FIPS) $(TARGET_FIPS_ASM) $(TARGET_REDUCE) $(TARGET_NTT_ASM) $(TARGET_NTT) $(TARGET_CPAPKE) $(TARGET_CPAKEM) $(TARGET_VERIFY) test_newhope.c ../common/randombytes.c -o ../test/test_cpakem1024

obj_files: $(TARGET_REDUCE) \
     $(TARGET_POLY) \
     $(TARGET_PRECOMP) \
     $(TARGET_FIPS) \
     $(TARGET_POLY_ASM) \
     $(TARGET_NTT_ASM) \
     $(TARGET_NTT) \
     $(TARGET_CPAPKE) \
     $(TARGET_CCAKEM) \
     $(TARGET_CPAKEM) \
     $(TARGET_VERIFY) \
     $(TARGET_FIPS_ASM)

$(TARGET_VERIFY): ../common/verify.c 
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c ../common/verify.c -o $@

$(TARGET_CCAKEM): ccakem.c 
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c ccakem.c -o $@

$(TARGET_CPAKEM): cpakem.c 
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c cpakem.c -o $@

$(TARGET_CPAPKE): cpapke.c 
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c cpapke.c -o $@

$(TARGET_NTT): ntt.c 
	$(CC) $(CFLAGS_LOCAL) $(CFLAGS_GLOBAL) -c ntt.c -o $@

$(TARGET_NTT_ASM): ntt_asm.s
	$(CC) $(CFLAGS_LOCAL) $(CFLAGS_GLOBAL) -c ntt_asm.s -o $@

$(TARGET_POLY): poly.c
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c poly.c -o $@

$(TARGET_POLY_ASM): poly.s
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c poly.s -o $@

$(TARGET_PRECOMP): precomp.c
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c precomp.c -o $@

$(TARGET_REDUCE): ../common/reduce.o
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c ../common/reduce.s -o $@

$(TARGET_FIPS): ../common/fips202.c
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c ../common/fips202.c -o $@

$(TARGET_FIPS_ASM): ../common/f1600_bare_metal.s
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c ../common/f1600_bare_metal.s -o $@
clean:
	rm -f $(TARGET_POLY)
	rm -f $(TARGET_POLY_ASM)
	rm -f $(TARGET_PRECOMP)
	rm -f $(TARGET_REDUCE)
	rm -f $(TARGET_FIPS)
	rm -f $(TARGET_NTT_ASM)
	rm -f $(TARGET_NTT)
	rm -f $(TARGET_CPAPKE)
	rm -f $(TARGET_CCAKEM)
	rm -f $(TARGET_CPAKEM)
	rm -f $(TARGET_VERIFY)
	rm -f ../test/test_ccakem1024
	rm -f ../test/test_cpakem1024
	rm -f *~ *.o

