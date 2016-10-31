
# gen all of private key, ca cert, and an empty CRL
ca_cert.pem:
	#$(OPENSSL) req -x509 -new -config openssl.cnf -nodes -out ca_cert.pem -outform PEM 
	touch index
	echo "01" > serial
	echo "01" > crlnumber
	mkdir signed_keys
	$(OPENSSL) req -new -nodes -config openssl.cnf -nodes -out ca-cert.csr
	$(OPENSSL) ca -batch -config openssl.cnf -selfsign -in ca-cert.csr -out ca_cert.pem -enddate 99991231235959Z -notext;
	$(OPENSSL) ca -config openssl.cnf -gencrl -crlexts crl_extensions -out crl.pem
	@echo "created private_key.pem, ca_cert.pem, and crl.pem"


sign_intermediate_request: ca_cert.pem
	@$(OPENSSL) ca -batch -config openssl.cnf -in ../intermediate/cert_request.pem -out ../intermediate/ca_cert.pem -enddate 99991231235959Z -notext;
	@echo "saved ../intermediate/ca_cert.pem"
	#@rm ../intermediate/cert_request.pem
	#@echo "removed ../intermediate/cert_request.pem"


clean:
	@rm -f  private_key.pem ca_cert.pem ca-cert.csr
	@rm -f  serial* index* crl*
	@rm -rf signed_keys



