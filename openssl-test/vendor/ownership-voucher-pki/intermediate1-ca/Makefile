gen_ca_env:
	@touch index
	@echo "01" > serial
	@echo "01" > crlnumber
	@mkdir signed_keys


cert_request: gen_ca_env
	$(OPENSSL) ecparam -out private_key.pem -genkey -name prime256v1 >> /dev/null 2>&1
	$(OPENSSL) req -new -key private_key.pem -nodes -config openssl.cnf -out cert_request.pem -outform PEM >> /dev/null 2>&1


sign_intermediate2_request:
	$(OPENSSL) ca -batch -config openssl.cnf -in ../intermediate2-ca/cert_request.pem -enddate 99991231235959Z -out ../intermediate2-ca/ca_cert.pem -notext >> /dev/null 2>&1


generate_crl:
	$(OPENSSL) ca -config openssl.cnf -gencrl -crlexts crl_extensions -out crl.pem >> /dev/null 2>&1


clean:
	@rm -f private_key.pem cert_request.pem ca_cert.pem
	@rm -f  private_key.pem ca_cert.pem ca_cert.csr
	@rm -f  serial* index* crl*
	@rm -rf signed_keys



