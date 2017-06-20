
# gen both private-key and csr
cert_request:
	$(OPENSSL) ecparam -out private_key.pem -genkey -name prime256v1 >> /dev/null 2>&1
	$(OPENSSL) req -new -key private_key.pem -nodes -config openssl.cnf -out cert_request.pem -outform PEM >> /dev/null 2>&1


sign_ownership_voucher:
	@echo "[5.1] Signing Ownership Voucher..."
	@make sign_file INPUT=../../../device/ownership-voucher/unsigned-ownership-voucher.json OUTPUT=../../../device/ownership-voucher/ownership-voucher.pk7 NOCERTS=""


generate_vrl:
	$(eval CURR_DATE = $(shell date +'%Y%m%dT%H%M%SZ' | tr -d '\n'))
	$(eval EXP_DATE = $(shell date -v +30d +'%Y%m%dT%H%M%SZ' | tr -d '\n'))
	@sed -e 's/CURRENT_DATE/$(CURR_DATE)/' -e 's/EXPIRATION_DATE/$(EXP_DATE)/' -e 's/LIST_OF_REVOKED_VOUCHER_IDS//' .voucher-revocation-template.xml > unsigned-voucher-revocation.xml
	@make sign_file INPUT=unsigned-voucher-revocation.xml OUTPUT=ownership-voucher-revocation.pk7 NOCERTS="-nocerts"
	@rm unsigned-voucher-revocation.xml


sign_file:
	@cat ../intermediate2-ca/ca_cert.pem ../intermediate1-ca/ca_cert.pem > tmp_certfile
	$(OPENSSL) smime -sign -signer ca_cert.pem -inkey private_key.pem -certfile tmp_certfile -binary -in $(INPUT) $(NOCERTS) -noattr -nodetach -out _temp_.smime >> /dev/null 2>&1
	@rm tmp_certfile
	$(OPENSSL) smime -pk7out -in _temp_.smime | $(OPENSSL) pkcs7 -out $(OUTPUT) -outform DER >> /dev/null 2>&1
	@rm _temp_.smime 


clean:
	@rm -f private_key.pem cert_request.pem ca_cert.pem
	@rm -f ownership-voucher-revocation.pk7

