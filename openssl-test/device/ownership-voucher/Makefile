
gen_unsigned_ownership_voucher:
	@echo "[5.1.1] Generating Ownership Voucher request..."
	@echo '<voucher xmlns="urn:ietf:params:xml:ns:yang:ietf-voucher">' >> unsigned-ownership-voucher.xml
	@echo '  <assertion>verified</assertion>' >> unsigned-ownership-voucher.xml
	@/bin/echo -n '  <trusted-ca-certificate>' >> unsigned-ownership-voucher.xml
	@$(OPENSSL) x509 -in ../../3rd-party-ca/owner-certificate-pki/trust-anchor-ca/ca_cert.pem -outform der | $(OPENSSL) base64 | tr -d '\n' >> unsigned-ownership-voucher.xml
	@echo '</trusted-ca-certificate>' >> unsigned-ownership-voucher.xml
	@echo '  <certificate-id>' >> unsigned-ownership-voucher.xml
	@/bin/echo -n '    <subject>'  >> unsigned-ownership-voucher.xml
	@$(OPENSSL) x509 -in ../../owner/owner-certificate/owner_certificate.pem -noout -subject | sed -e 's/subject= //' | tr -d '\n' >> unsigned-ownership-voucher.xml
	@echo '</subject>' >> unsigned-ownership-voucher.xml
	@echo '  </certificate-id>' >> unsigned-ownership-voucher.xml
	@/bin/echo -n '  <unique-id>' >> unsigned-ownership-voucher.xml
	@$(OPENSSL) x509 -in ../../device/idevid-certificate/idevid_cert.pem -noout -subject | sed -e 's/.*serialNumber = //' | tr -d '\n' >> unsigned-ownership-voucher.xml
	@echo '</unique-id>' >> unsigned-ownership-voucher.xml
	@/bin/echo -n '  <created-on>' >> unsigned-ownership-voucher.xml
	@date +'%Y%m%dT%H%M%SZ' | tr -d '\n' >> unsigned-ownership-voucher.xml
	@echo '</created-on>' >> unsigned-ownership-voucher.xml
	@echo '</voucher>' >> unsigned-ownership-voucher.xml


clean:
	@rm -f unsigned-ownership-voucher.xml
	@rm -f ownership-voucher.pk7

