gen_ca_env:
	@touch index
	@echo "01" > serial
	@echo "01" > crlnumber
	@mkdir signed_keys


cert_request: gen_ca_env
	$(OPENSSL) ecparam -out private_key.pem -genkey -name prime256v1 >> /dev/null 2>&1
	$(OPENSSL) req -new -key private_key.pem -nodes -config openssl.cnf -out cert_request.pem -outform PEM >> /dev/null 2>&1


sign_tls_server_cert_request:
	$(OPENSSL) ca -batch -config openssl.cnf -in ../../../owner/tls-server-certificate/cert_request.pem -out ../../../owner/tls-server-certificate/tls_server_cert.pem -enddate 99991231235959Z -notext >> /dev/null 2>&1
	cat ca_cert.pem >> ../../../owner/tls-server-certificate/tls_server_cert.pem
	$(OPENSSL) crl2pkcs7 -nocrl -certfile ../../../owner/tls-server-certificate/tls_server_cert.pem -out ../../../owner/tls-server-certificate/tls_server_cert.pk7 >> /dev/null 2>&1

# openssl pkcs7 -print_certs -in owner_bundle.p7b -out owner_bundle.pem.2
# diff owner_bundle.pem*  // there’s a small difference (comments only)


generate_crl:
	$(OPENSSL) ca -config openssl.cnf -gencrl -crlexts crl_extensions -out crl.pem >> /dev/null 2>&1


clean:
	@rm -f private_key.pem cert_request.pem ca_cert.pem 
	@rm -f  serial* index* crl*
	@rm -rf signed_keys

