CC=mipsisa64-octeon-elf-gcc
CFLAGS_LOCAL =-march=octeon3 -W -Wall -Wno-unused-parameter -I$(OCTEON_ROOT)/target/include

TARGET_POLY = poly.o
TARGET_POLY_ASM = poly_asm.o
TARGET_REDUCE = ../common/reduce.o
TARGET_FIPS = ../common/fips202.o
TARGET_CCAKEM = ccakem.o
TARGET_CPAKEM = cpakem.o
TARGET_VERIFY = ../common/verify.o
TARGET_CPAPKE = cpapke.o
TARGET_NTT_ASM = ntt_asm.o
TARGET_NTT512 = ntt512.o
TARGET_FIPS_ASM = f1600.o

all: obj_files
	$(CC) $(CFLAGS_LOCAL) $(CFLAGS_GLOBAL) $(TARGET_POLY) $(TARGET_POLY_ASM) $(TARGET_FIPS) $(TARGET_FIPS_ASM) $(TARGET_REDUCE) $(TARGET_NTT_ASM) $(TARGET_NTT512) $(TARGET_CPAPKE) $(TARGET_CCAKEM) $(TARGET_VERIFY) test_newhope.c ../common/randombytes.c -o ../test/test_ccakem512 
	$(CC) $(CFLAGS_LOCAL) $(CFLAGS_GLOBAL) $(TARGET_POLY) $(TARGET_POLY_ASM) $(TARGET_FIPS) $(TARGET_FIPS_ASM) $(TARGET_REDUCE) $(TARGET_NTT_ASM) $(TARGET_NTT512) $(TARGET_CPAPKE) $(TARGET_CPAKEM) $(TARGET_VERIFY) test_newhope.c ../common/randombytes.c -o ../test/test_cpakem512 

obj_files: $(TARGET_POLY1024) \
     $(TARGET_POLY) \
     $(TARGET_POLY_ASM) \
     $(TARGET_REDUCE) \
     $(TARGET_FIPS) \
     $(TARGET_CCAKEM) \
     $(TARGET_CPAKEM) \
     $(TARGET_VERIFY) \
     $(TARGET_NTT_ASM) \
     $(TARGET_CPAPKE) \
     $(TARGET_NTT512) \
     $(TARGET_FIPS_ASM)


$(TARGET_POLY): poly.c
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c -DNEWHOPE512 poly.c -o $@

$(TARGET_POLY_ASM): poly.s
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c poly.s -o $@

$(TARGET_REDUCE): ../common/reduce.s
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c ../common/reduce.s -o $@

$(TARGET_FIPS): ../common/fips202.c
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c ../common/fips202.c -o $@

$(TARGET_CCAKEM): ccakem.c 
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c ccakem.c -o $@

$(TARGET_CPAKEM): cpakem.c 
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c cpakem.c -o $@

$(TARGET_VERIFY): ../common/verify.c 
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c ../common/verify.c -o $@

$(TARGET_CPAPKE): cpapke.c 
	$(CC) -O3 $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c cpapke.c -o $@

$(TARGET_NTT512): ntt512.c 
	$(CC)  $(CFLAGS_LOCAL) $(CFLAGS_GLOBAL) -c  ntt512.c -o $@

$(TARGET_NTT_ASM): ntt_asm.s
	$(CC) $(CFLAGS_LOCAL) $(CFLAGS_GLOBAL) -c ntt_asm.s -o $@

$(TARGET_FIPS_ASM): ../common/f1600.s
	$(CC) $(CFLAGS_LOCAL)  $(CFLAGS_GLOBAL) -c ../common/f1600.s -o $@

clean:
	rm -f $(TARGET_POLY) = poly.o
	rm -f $(TARGET_POLY_ASM)
	rm -f $(TARGET_REDUCE) = ../common/reduce.o
	rm -f $(TARGET_FIPS =) ../common/fips202.o
	rm -f $(TARGET_CCAKEM) = ccakem.o
	rm -f $(TARGET_CPAKEM) = cpakem.o
	rm -f $(TARGET_VERIFY) = ../common/verify.o
	rm -f $(TARGET_CPAPKE) = cpapke.o
	rm -f $(TARGET_NTT_ASM) = ntt_asm.o
	rm -f $(TARGET_NTT512) = ntt512.o
	rm -f ../test/test_ccakem512
	rm -f ../test/test_cpakem512
	rm -f *~ *.o 
