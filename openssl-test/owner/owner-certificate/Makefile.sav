
# gen both private-key and csr
cert_request.pem:
	#@$(OPENSSL) req -new -config openssl.cnf -nodes -out cert_request.pem -outform PEM >> /dev/null 2>&1
	@$(OPENSSL) req -new -config openssl.cnf -nodes -out cert_request.pem -outform PEM 
	@echo "created private_key.pem and cert_request.pem"


gen_unsigned_bootstrapping_data:
	@echo "WARNING!!! gen_unsigned_bootstrapping_data disabled!"
	# disabled due to the follow line not working without the "-sign" parameter
	#   - can't create an unsigned smime...
	#$(OPENSSL) smime -binary -in bootstrapping-data.xml -signer owner_cert.pem  -inkey private_key.pem -nocerts -noattr -nodetach -out signature.smime
	#$(OPENSSL) smime -pk7out -in signature.smime | $(OPENSSL) pkcs7 -out unsigned-bootstrapping-data.pk7 -outform DER
	#(OPENSSL) asn1parse -inform DER -in unsigned-bootstrapping-data.pk7 -i
	#@rm signature.smime


gen_signed_bootstrapping_data:
	$(OPENSSL) smime -sign -binary -in bootstrapping-data.xml -signer owner_cert.pem -inkey private_key.pem -nocerts -noattr -nodetach -out signature.smime
	$(OPENSSL) smime -pk7out -in signature.smime | $(OPENSSL) pkcs7 -out signed-bootstrapping-data.pk7 -outform DER
	$(OPENSSL) asn1parse -inform DER -in signed-bootstrapping-data.pk7 -i
	@rm signature.smime


sign_redirect_information:
	$(OPENSSL) smime -sign -signer owner_cert.pem -binary -in redirect-information.xml -inkey private_key.pem -nocerts -noattr -nodetach -out signature.smime
	$(OPENSSL) smime -pk7out -in signature.smime | $(OPENSSL) pkcs7 -out signature.pk7 -outform DER
	$(OPENSSL) asn1parse -inform DER -in signature.pk7 -i
	@rm signature.smime


clean:
	@rm -f private_key.pem cert_request.pem ek_cert.pem

