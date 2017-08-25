
generate_offline_data:
	@#Everything needed:
	@#+--ro (information-type)        anydata
	@#+--ro signature?                binary
	@#+--ro ownership-voucher?        binary
	@#+--ro owner-certificate?        binary


	@echo "\n[6.1] constructing information-type..."
	@$(eval B64 = $(shell $(OPENSSL) x509 -in ../../3rd-party-ca/tls-server-certificate-pki/trust-anchor-ca/ca_cert.pem -outform der | $(OPENSSL) enc -base64 -A))
	@sed 's#BOOSTRAP_SERVER_TRUST_ANCHOR#$(B64)#' .redirect-information-template.xml > information-type.xml

	@echo "\n[6.2] generating signature..."
	#$(OPENSSL) smime -sign -signer ../owner-certificate/owner_certificate.pem -binary -in information-type.xml -inkey ../owner-certificate/private_key.pem -nocerts -noattr -nodetach -out signature.smime
	$(OPENSSL) smime -sign -signer ../owner-certificate/owner_certificate.pem -binary -in information-type.xml -inkey ../owner-certificate/private_key.pem -noattr -nodetach -out signature.smime
	$(OPENSSL) smime -pk7out -in signature.smime | $(OPENSSL) pkcs7 -out signature.pk7 -outform DER
	@#$(OPENSSL) asn1parse -inform DER -in signature.pk7 -i
	@rm -f signature.smime

	@echo "\n[6.3] collecting ownership-voucher..."
	cp ../../device/ownership-voucher/ownership-voucher.pk7 .

	@echo "\n[6.4] collecting owner-certificate..."
	cp ../owner-certificate/owner_certificate.pk7 .

	@# NOTE: this code no longer assembles a voucher-revocation object due
	@#       to the new irrevocable-voucher strategy (see voucher draft)

	@echo "\n[6.6] assembling owner-certificate-revocation bundle..."
	@echo "FIXME *** THE CRLS ARE SUPPOSED TO BE INSIDE THE OWNER_CERT.PK7 NOW !!! FIXME"
	cat ../../3rd-party-ca/owner-certificate-pki/intermediate-ca/crl.pem ../../3rd-party-ca/owner-certificate-pki/trust-anchor-ca/crl.pem > tmp_crls.pem
	../../tools/pack-crls -i tmp_crls.pem -o owner-certificate-revocation.pk7
	@rm tmp_crls.pem
	#$(OPENSSL) asn1parse -inform DER -in owner-certificate-revocation.pk7 -i


clean:
	@rm -f private_key.pem cert_request.pem owner_cert.pem
	@rm -f owner_cert.pem owner_cert.pk7
	@rm -f information-type.xml
	@rm -f signature.pk7 signature.smime
	@rm -f ownership-voucher.pk7
	@rm -f owner_certificate.pk7
	@rm -f owner-certificate-revocation.pk7


