gen_ca_env:
	@touch index
	@echo "01" > serial
	@echo "01" > crlnumber
	@mkdir signed_keys


cert_request: gen_ca_env
	#$(OPENSSL) ecparam -out private_key.pem -genkey -name prime256v1 >> /dev/null 2>&1
	$(OPENSSL) genrsa -out private_key.pem 2048 >> /dev/null 2>&1 # RSA 2048 per TPM 1.2 & 802.1AR-2018
	$(OPENSSL) req -new -key private_key.pem -nodes -config openssl.cnf -out cert_request.pem -outform PEM >> /dev/null 2>&1


sign_idevid_request:
	$(OPENSSL) ca -batch -config openssl.cnf -in ../../../device/idevid-certificate/cert_request.pem -out ../../../device/idevid-certificate/idevid_cert.pem -enddate 99991231235959Z -notext >> /dev/null 2>&1


generate_crl:
	$(OPENSSL) ca -config openssl.cnf -gencrl -crlexts crl_extensions -out crl.pem >> /dev/null 2>&1



clean:
	@rm -f private_key.pem cert_request.pem ca_cert.pem
	@rm -f  serial* index* crl*
	@rm -rf signed_keys

