
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

	@# The voucher is a payload, a signature, and a stapled certificate chain.  First
	@# verify the payload is signed by a chain of certs leading to the hardcoded trust
	@# anchor (and output the unsigned payload).  Note: this step does NOT verify the
	@# revocation status of the stapled certificates, or if the voucher contains the
	@# device's unique-id
	#@$(OPENSSL) smime -verify -inform DER -in ownership-voucher.pk7 -CAfile ../../vendor/ownership-voucher-pki/trust-anchor-ca/ca_cert.pem -out unsigned-ownership-voucher.xml >> /dev/null 2>&1
	$(OPENSSL) smime -verify -inform DER -in ownership-voucher.pk7 -CAfile ../../vendor/ownership-voucher-pki/trust-anchor-ca/ca_cert.pem -out unsigned-ownership-voucher.xml 

	@# Extract the cert-chain from the voucher
	$(OPENSSL) pkcs7 -inform DER -in ownership-voucher.pk7 -print_certs -out voucher-certs.pem

	@# The VRL here is actually a bundle containing the VRL itself plus the CRL for the
	@# vendor's voucher-pki cert chain.  To be symmetric with the sequence of operations
	@# in creating the bundle, we first unbundle the bundled-VRL into its parts...
	../../tools/pack-ovr-bundle -r -b ownership-voucher-revocation.pk7 -c voucher-pki-crls.pem -v voucher-revocation-itself.pk7

	@# The VRL itself is a payload and a signature and, like a CRL, there is no stapled
	@# cert chain.  However, verifying the VRL itself requires the cert chain (same as
	@# the voucher verification above), so use the cert-chain from the voucher.  This
	@# step also outputs the unsigned voucher revocation payload.
	$(OPENSSL) smime -verify -inform DER -in voucher-revocation-itself.pk7 -CAfile ../../vendor/ownership-voucher-pki/trust-anchor-ca/ca_cert.pem -certfile voucher-certs.pem -out unsigned-ownership-voucher-revocation.xml >> /dev/null 2>&1

	@# Now we need to ensure none of the certificates have been revoked.
	@# note: we need to extract leaf cert first
	@split -p "BEGIN" voucher-certs.pem  frag
	@LEAF_CERT=`ls frag* | sort -r | head -1`; \
	$(OPENSSL) verify -CAfile ../../vendor/ownership-voucher-pki/trust-anchor-ca/ca_cert.pem -untrusted voucher-certs.pem -crl_check_all -CRLfile voucher-pki-crls.pem $$LEAF_CERT >> /dev/null 2>&1
	@rm frag*

	@# Now we need to check if the voucher itself has been revoked
	@DGST=`$(OPENSSL) dgst -sha256 unsigned-ownership-voucher.xml | sed 's/.*= //'`; \
	GREP_OUTPUT=`grep $$DGST unsigned-ownership-voucher-revocation.xml`; \
	if [ -n "$$GREP_OUTPUT" ]; then \
	  "The voucher has been revoked, another voucher is needed..."; \
	  exit -1; \
	fi

	@# Ensure the voucher-revocation hasn't expired 
	@EXPIRES_ON_LINE=`grep expires-on unsigned-ownership-voucher-revocation.xml`; \
	if [ -n $$EXPIRES_ON_LINE ]; then \
	  CURR_TS=`date +'%s'`; \
	  EXPIRES_ON=`echo $$EXPIRES_ON_LINE | sed 's/.*>\(.*\)<.*/\1/'`; \
	  EXPIRES_ON_TS=`date -j -f '%Y%m%dT%H%M%SZ' $$EXPIRES_ON +"%s"`; \
	  if [ $$CURR_TS -gt $$EXPIRES_ON_TS ]; then \
	    echo "The voucher-revocation expired, a more recent revocation file is needed..."; \
	    exit -1; \
	  fi; \
	fi  

	@# Ensure the voucher hasn't expired 
	@EXPIRES_ON_LINE=`grep expires-on unsigned-ownership-voucher.xml`; \
	if [ -n "$$EXPIRES_ON_LINE" ]; then \
	  CURR_TS=`date +'%s'`; \
	  EXPIRES_ON=`echo $$EXPIRES_ON_LINE | sed 's/.*>\(.*\)<.*/\1/'`; \
	  EXPIRES_ON_TS=`date -j -f '%Y%m%dT%H%M%SZ' $$EXPIRES_ON +"%s"`; \
	  if [ $$CURR_TS -gt $$EXPIRES_ON_TS ]; then \
	    echo "The voucher expired, a more recent voucher is needed..."; \
	    exit -1; \
	  fi; \
	fi

	@# Lastly, make sure the voucher contains this device's unique-id
	MY_SERIAL_NUMBER=`$(OPENSSL) x509 -in ../../device/idevid-certificate/idevid_cert.pem -noout -subject | sed -e 's/.*serialNumber = //' | tr -d '\n'`; \
	GREP_OUTPUT=`grep unique-id unsigned-ownership-voucher.xml | grep $$MY_SERIAL_NUMBER`; \
	if [ -z "$$GREP_OUTPUT" ]; then \
	  "The voucher does not apply to this device ($$MY_SERIAL_NUMBER), another voucher is needed..."; \
	  exit -1; \
	fi

	@rm unsigned-ownership-voucher-revocation.xml # don't need this anymore
	@echo "The voucher is valid"


	@echo "\n[7.2] extracting trust-anchor and owner-cert-subject from voucher..."
	@grep '<trusted-ca-certificate>' unsigned-ownership-voucher.xml | sed 's/.*>\(.*\)<.*/\1/'` > owner_cert_trust_anchor.pem
	OWNER_CERT_SUBJ=`grep '<subject>' unsigned-ownership-voucher.xml | sed 's/.*>\(.*\)<.*/\1/'`; \
	echo "OWNER_CERT_SUBJ = $$OWNER_CERT_SUBJ"; \

	#@rm unsigned-ownership-voucher.xml # don't need this anymore



	@echo "\n[7.3] verifying owner-certificate..."

        # need to extract owner-cert-certs.pem...
	$(OPENSSL) pkcs7 -inform DER -in owner_certificate.pk7 -print_certs -out owner-cert-certs.pem

        # need to extract owner-cert-pki-crls.pem...
	../../tools/pack-crls -r -i owner-certificate-revocation.pk7 -o .pem

	# need to isolate the owner certificate itself (LEAF_CERT)...

	$(OPENSSL) verify -CAfile owner_cert_trust_anchor.pem -untrusted owner-cert-certs.pem -crl_check_all -CRLfile owner-cert-pki-crls.pem $$LEAF_CERT >> /dev/null 2>&1



	@echo "\n[7.4] extracting pubkey from owner-certificate..."

	@echo "\n[7.5] verifying signature..."
	#@$(OPENSSL) smime -verify -inform DER -in signature.pk7 -content information-type.xml -CAfile owner-certificate.pk7 -content information-type.xml



	@echo "\n[7.6] processing information-type..."


clean:
	@rm -f *.*





