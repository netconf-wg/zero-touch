
process_offline_data:
	@#Steps:
	@# 1. verify voucher (signed by vendor's trust-anchor, not revoked, contains unique-id, etc.)
	@# 2. extract trust-anchor for owner's owner-certificate from voucher
	@# 3. verify owner-certificate (signed by extracted trust-anchor, not revoked, etc.)
	@# 4. extract owner's public key from owner-certificate
	@# 5. verify 'signature' over 'information-type' using owner's public key
	@# 6. done! - process information-type...


	@echo "\n[7.1] verifying voucher..."
	@# Note-1: the vendor's voucher TA cert would normally be hardcoded into the device

	@# The voucher is a PKCS#7 containing a payload, a signature, and a stapled certificate
	@# chain.  

	@# First verify the payload is signed by a chain of certs leading to the hardcoded
	@# trust anchor (and output the unsigned payload).  Note: this step does NOT verify the
	@# revocation status of the stapled certificates (due to the new irrevocable-voucher
	@# strategy), or if the voucher has expired, or if the voucher contains the device's
	@# unique-id.
	@#$(OPENSSL) smime -verify -inform DER -in ownership-voucher.pk7 -CAfile ../../vendor/ownership-voucher-pki/trust-anchor-ca/ca_cert.pem -out unsigned-ownership-voucher.json >> /dev/null 2>&1
	$(OPENSSL) smime -verify -inform DER -in ownership-voucher.pk7 -CAfile ../../vendor/ownership-voucher-pki/trust-anchor-ca/ca_cert.pem -out unsigned-ownership-voucher.json 

	@# Ensure the voucher hasn't expired 
	@EXPIRES_ON_LINE=`grep expires-on unsigned-ownership-voucher.json`; \
	if [ -n "$$EXPIRES_ON_LINE" ]; then \
	  CURR_TS=`date +'%s'`; \
	  EXPIRES_ON=`echo $$EXPIRES_ON_LINE | sed 's/.*"\(.*\)".*/\1/'`; \
	  EXPIRES_ON_TS=`date -j -f '%Y%m%dT%H%M%SZ' $$EXPIRES_ON +"%s"`; \
	  if [ $$CURR_TS -gt $$EXPIRES_ON_TS ]; then \
	    echo "The voucher expired, a more recent voucher is needed..."; \
	    exit -1; \
	  fi; \
	fi

	@# Lastly, ensure the voucher contains this device's unique-id
	@MY_SERIAL_NUMBER=`$(OPENSSL) x509 -in ../../device/idevid-certificate/idevid_cert.pem -noout -subject | sed -e 's/.*serialNumber = //' | tr -d '\n'`; \
	GREP_OUTPUT=`grep serial-number unsigned-ownership-voucher.json | grep $$MY_SERIAL_NUMBER`; \
	if [ -z "$$GREP_OUTPUT" ]; then \
	  echo "The voucher does not apply to this device ($$MY_SERIAL_NUMBER), another voucher is needed..."; \
          TMP=`grep serial-number unsigned-ownership-voucher.json`; \
	  echo " DEBUG: $$TMP"; \
	  exit -1; \
	fi

	@# DONE!
	@echo "The ownership voucher is valid"


	@echo "\n[7.2] extracting pinned-domain-cert from voucher..."
	@grep 'pinned-domain-cert' unsigned-ownership-voucher.json | sed 's/.*: "\(.*\)",/\1/' > owner_cert_trust_anchor.b64
	$(OPENSSL) base64 -d -in owner_cert_trust_anchor.b64 -out owner_cert_trust_anchor.der
	$(OPENSSL) x509 -in owner_cert_trust_anchor.der -inform DER -out owner_cert_trust_anchor.pem -outform PEM
	#$(OPENSSL) x509 -in owner_cert_trust_anchor.pem -text -noout

	@#rm unsigned-ownership-voucher.json # don't need this anymore



	@echo "\n[7.3] verifying owner-certificate..."

	@# extract owner-cert-certs.pem...
	$(OPENSSL) pkcs7 -inform DER -in owner_certificate.pk7 -print_certs -out owner-cert-certs.pem

	@# extract owner-cert-pki-crls.pem...   (FIXME: this is inside the owner_certificate.pk7 file now, right?)
	@echo "FIXME *** THE CRLS ARE SUPPOSED TO BE INSIDE THE OWNER_CERT.PK7 NOW !!! FIXME"
	../../tools/pack-crls -r -i owner-certificate-revocation.pk7 -o owner-cert-pki-crls.pem

	@# need to isolate the owner certificate itself (LEAF_CERT)...
	@split -p "BEGIN" owner-cert-certs.pem  frag
	@#LEAF_CERT=`ls frag* | sort -r | head -1`; cp $$LEAF_CERT owner-cert.pem
	cp fragab owner-cert.pem
	#$(OPENSSL) x509 -in owner-cert.pem -noout -text

	@# now do verification (including crls) 
	@# this assumes chain to root, but draft allows partial or no chain (use -partial-chain option?)
	$(OPENSSL) verify -CAfile owner_cert_trust_anchor.pem -untrusted owner-cert-certs.pem -crl_check_all -CRLfile owner-cert-pki-crls.pem owner-cert.pem >> /dev/null 2>&1

	@# cleanup
	@rm frag*

	@echo "The owner certificate is valid"


	@echo "\n[7.4] ensure that the owner certificate signed the zerotouch information..."
	# NOTE: this code takes the easy route of assuming that the signer cert is in the 
	# zerotouch-information pkcs file.  So, instead of extracting the public key from
	# the owner cert above the verify the signature, the code instead extracts the
	# signer cert from the pkcs file, and then compares it to the owner cert above.

	# extract the signer cert (and the information-type too)
        # note: this command verifies signature using the signer-cert (but it doesn't verify
	#       the signer cert itself via x509 path validation.  This is fine, since we just
	#	did that for the owner cert above...
	$(OPENSSL) smime -verify -inform DER -in signature.pk7 -noverify -signer signer-cert.pem -out information-type.json

	# finally, verify the signer cert matches the owner cert
	@$(OPENSSL) x509 -in signer-cert.pem -out signer-cert.der -outform DER
	@$(OPENSSL) x509 -in owner-cert.pem -out owner-cert.der -outform DER
	@DIFF_OUTPUT=`diff signer-cert.der owner-cert.der`; \
	if [ -n "$$DIFF_OUTPUT" ]; then \
	  echo "The owner certificate doesn't match the certificate that signed the zerotouch information!"; \
	  echo "\ndiff signer-cert.der owner-cert.der"; \
	  echo $$DIFF_OUTPUT; \
	  exit -1; \
	fi

	@echo "The zerotouch information is valid"



	@echo "\n[7.6] processing information-type..."
	cat information-type.json


clean:
	@rm -f *.*





