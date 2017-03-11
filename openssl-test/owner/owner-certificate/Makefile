
owner_cert_request:
	$(OPENSSL) ecparam -out private_key.pem -genkey -name prime256v1 >> /dev/null 2>&1
	$(OPENSSL) req -new -key private_key.pem -nodes -config openssl.cnf -out cert_request.pem -outform PEM >> /dev/null 2>&1


clean:
	@rm -f private_key.pem cert_request.pem owner_certificate.pem
	@rm -f owner_certificate.pem owner_certificate.pk7



