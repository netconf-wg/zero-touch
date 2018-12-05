
idevid_cert_request:
	$(OPENSSL) genrsa -out private_key.pem 2048 >> /dev/null 2>&1 # RSA 2048 per TPM 1.2 & 802.1AR-2018
	$(OPENSSL) req -new -key private_key.pem -nodes -config openssl.cnf -out cert_request.pem -outform PEM >> /dev/null 2>&1


clean:
	@rm -f private_key.pem cert_request.pem idevid_cert.pem

