
# gen both private-key and csr
cert_request:
	$(OPENSSL) ecparam -out private_key.pem -genkey -name prime256v1 >> /dev/null 2>&1
	$(OPENSSL) req -new -key private_key.pem -nodes -config openssl.cnf -out cert_request.pem -outform PEM >> /dev/null 2>&1



sign_ownership_voucher:
	@echo "[5.1] Signing Ownership Voucher..."
	@cat ../intermediate2-ca/ca_cert.pem ../intermediate1-ca/ca_cert.pem > tmp_certfile
	$(OPENSSL) smime -sign -signer ca_cert.pem -inkey private_key.pem -certfile tmp_certfile -binary -in ../../../device/ownership-voucher/unsigned-ownership-voucher.json -noattr -nodetach -out _temp_.smime >> /dev/null 2>&1
	@rm tmp_certfile
	$(OPENSSL) smime -pk7out -in _temp_.smime | $(OPENSSL) pkcs7 -out ../../../device/ownership-voucher/ownership-voucher.pk7 -outform DER >> /dev/null 2>&1
	@rm _temp_.smime 


clean:
	@rm -f private_key.pem cert_request.pem ca_cert.pem

