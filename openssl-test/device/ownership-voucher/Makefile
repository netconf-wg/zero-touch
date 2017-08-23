gen_unsigned_ownership_voucher:
	@echo "[5.1.1] Generating Ownership Voucher request..."
	@CREATED_ON=`date +'%Y%m%dT%H%M%SZ' | tr -d '\n'`; \
	EXPIRES_ON=`date -v+2w +'%Y%m%dT%H%M%SZ' | tr -d '\n'`; \
	SERIAL_NUMBER=`$(OPENSSL) x509 -in ../../device/idevid-certificate/idevid_cert.pem -noout -subject | sed -e 's/.*serialNumber = //' | tr -d '\n'`;  \
	SERIAL_NUMBER_ISSUER=`$(OPENSSL) x509 -in ../../vendor/idevid-certificate-pki/intermediate-ca/ca_cert.pem -pubkey | $(OPENSSL) ec -pubin -pubout -outform DER | $(OPENSSL) dgst -sha256 | $(OPENSSL) base64 | tr -d '\n'`; \
	DOMAIN_CERT_TRUSTED_CA=`$(OPENSSL) x509 -in ../../3rd-party-ca/owner-certificate-pki/trust-anchor-ca/ca_cert.pem -outform der | $(OPENSSL) base64 | tr -d '\n'`; \
	LAST_RENEWAL_DATE=`date -v+1y +'%Y%m%dT%H%M%SZ' | tr -d '\n'`; \
	SERIAL_NUMBER=`echo "ex-serial-number"`; \
	IDEVID_ISSUER=`echo "36097E3DEA39316EA4CE5C695BE905E78AF2FB5A"`; \
	sed -e "s#CREATED-ON#$$CREATED_ON#" -e "s#EXPIRES-ON#$$EXPIRES_ON#" -e "s#IDEVID-ISSUER#$$IDEVID_ISSUER#" -e "s#SERIAL-NUMBER#$$SERIAL_NUMBER#" -e "s#DOMAIN-CERT-TRUSTED-CA#$$DOMAIN_CERT_TRUSTED_CA#" -e "s#LAST-RENEWAL-DATE#$$LAST_RENEWAL_DATE#" .ownership-voucher-template.json > unsigned-ownership-voucher.json


clean:
	@rm -f unsigned-ownership-voucher.json
	@rm -f ownership-voucher.pk7

