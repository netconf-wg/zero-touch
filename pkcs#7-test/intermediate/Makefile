
# gen both private-key and csr
cert_request.pem:
	@$(OPENSSL) req -new -config openssl.cnf -nodes -out cert_request.pem -outform PEM >> /dev/null 2>&1
	@echo "created private_key.pem and cert_request.pem"


ca_stuff:
	@touch index
	@echo "01" > serial
	@echo "01" > crlnumber
	@mkdir signed_keys


sign_owner_cert_request: ca_stuff ca_cert.pem
	@$(OPENSSL) ca -config openssl.cnf -gencrl -out crl.pem
	@$(OPENSSL) ca -batch -config openssl.cnf -in ../rightful_owner/cert_request.pem -out ../rightful_owner/owner_cert.pem -enddate 99991231235959Z -notext;
	@echo "saved ../rightful_owner/owner_cert.pem"
	#@rm ../chip1/cert_request.pem


clean:
	@rm -f private_key.pem cert_request.pem ca_cert.pem
	@rm -f  serial* index*
	@rm -rf signed_keys

