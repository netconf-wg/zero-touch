
# KENT: DELETE THIS LINE
OPENSSL_DIR = /usr/local/openssl-1.1.0c
# KENT: DELETE THIS LINE

CFLAGS = -I $(OPENSSL_DIR)/include/
LDFLAGS = -L $(OPENSSL_DIR)/lib/ -lcrypto

all:
	cc $(CFLAGS) -o pack-crls $(LDFLAGS) pack-crls.c
	cc $(CFLAGS) -o pack-ovr-bundle $(LDFLAGS) pack-ovr-bundle.c
	cc $(CFLAGS) -o file-to-unsigned-pk7 $(LDFLAGS) file-to-unsigned-pk7.c

clean:
	rm -f pack-crls
	rm -f pack-ovr-bundle
	rm -f file-to-unsigned-pk7

