# warning, this must point to at least openssl
# version 1.0.1e (CRL extensions)
export OPENSSL_DIR = /usr/local/openssl-1.1.0c
export OPENSSL = $(OPENSSL_DIR)/bin/openssl

all:
	@# compile some tools
	@echo "\n[0] Making some CLI tools..."
	cd tools && make

	@# This would occur before any device is manufactured
	@echo "\n[1] Making Vendor's PKIs..."
	cd vendor/idevid-certificate-pki && make idevid_pki
	cd vendor/ownership-voucher-pki && make voucher_pki

	@# This would occur before any owner comes along
	@echo "\n[2] Making 3rd-Party CA's PKIs..."
	cd 3rd-party-ca/owner-certificate-pki && make owner_cert_pki
	cd 3rd-party-ca/tls-server-certificate-pki && make tls_server_cert_pki

	@# now that all the PKIs are setup...
	make generate_crls

	@# This would occur when a device is manufactured
	@# Note: IDevID isn't really needed for this test,
	@#       other than to extract/compare subject field
	@echo "\n[3] Making Device's IDevID certificate..."
	cd device/idevid-certificate && make idevid_cert_request
	cd vendor/idevid-certificate-pki/intermediate-ca && make sign_idevid_request

	@# This would occur when an owner comes along
	@echo "\n[4] Making owner's owner certificate..."
	cd owner/owner-certificate && make owner_cert_request
	cd 3rd-party-ca/owner-certificate-pki/intermediate-ca && make sign_owner_cert_request
	cd owner/tls-server-certificate && make tls_server_cert_request
	cd 3rd-party-ca/tls-server-certificate-pki/intermediate-ca && make sign_tls_server_cert_request

	@# This would occur when an owner buys a device
	@echo "\n[5] Making Device's Ownership Voucher..."
	cd device/ownership-voucher && make gen_unsigned_ownership_voucher
	cd vendor/ownership-voucher-pki/intermediate3-ca && make sign_ownership_voucher

	@# This would occur when an owner is staging offline data
	@echo "\n[6] Owner staging offline data..."
	cd owner/removable-storage-device && make generate_offline_data

	@# Now, let's see if the device can process the signed data
	@echo "\n[7] Device processing signed bootstrapping data..."
	cp owner/removable-storage-device/*.* device/removable-storage-device/
	cd device/removable-storage-device && make process_offline_data


	@echo "\nTo Do:"
	@echo "  - replace PKCS#7 with CMS..."
	@echo "  - add hardwareModule to DevID..."
	@echo "  - replace voucher PKCS#7 with CWS?..."
	@echo "  - add subject or subject-hash to Owner Cert?..."
	@echo "  - replace CRL with OCSP Response?"
	@echo "  - let owner generate signing certs below owner cert? - what is an owner/identity cert from a CA perspective?"



generate_crls:
	cd vendor/idevid-certificate-pki/trust-anchor-ca && make generate_crl
	cd vendor/idevid-certificate-pki/intermediate-ca && make generate_crl
	# COMMENTED OUT WITH NEW IRREVOCABLE VOUCHER STRATEGY
	#cd vendor/ownership-voucher-pki/trust-anchor-ca && make generate_crl
	#cd vendor/ownership-voucher-pki/intermediate1-ca && make generate_crl
	#cd vendor/ownership-voucher-pki/intermediate2-ca && make generate_crl
	#cd vendor/ownership-voucher-pki/intermediate3-ca && make generate_vrl
	cd 3rd-party-ca/owner-certificate-pki/trust-anchor-ca && make generate_crl
	cd 3rd-party-ca/owner-certificate-pki/intermediate-ca && make generate_crl
	cd 3rd-party-ca/tls-server-certificate-pki/trust-anchor-ca && make generate_crl
	cd 3rd-party-ca/tls-server-certificate-pki/intermediate-ca && make generate_crl


print:
	make print_idevid
	make print_owner

print_idevid:
	@echo; echo; echo "TRUST ANCHOR:"; $(OPENSSL) x509 -text -noout -in vendor/idevid-certificate-pki/trust-anchor-ca/ca_cert.pem; echo; echo; echo "INTERMEDIATE:"; $(OPENSSL) x509 -text -noout -in vendor/idevid-certificate-pki/intermediate-ca/ca_cert.pem; echo; echo; echo "IDEVID:"; $(OPENSSL) x509 -text -noout -in device/idevid-certificate/idevid_cert.pem

print_owner:
	@echo; echo; echo "TRUST ANCHOR:"; $(OPENSSL) x509 -text -noout -in 3rd-party-ca/owner-certificate-pki/trust-anchor-ca/ca_cert.pem; echo; echo; echo "INTERMEDIATE:"; $(OPENSSL) x509 -text -noout -in 3rd-party-ca/owner-certificate-pki/intermediate-ca/ca_cert.pem; echo; echo; echo "OWNER CERTIFICATE:"; $(OPENSSL) x509 -text -noout -in owner/owner-certificate/owner_cert.pem


clean:
	cd tools && make clean
	cd device/idevid-certificate && make clean
	cd device/ownership-voucher && make clean
	cd device/removable-storage-device && make clean
	cd owner/tls-server-certificate && make clean
	cd owner/owner-certificate && make clean
	cd owner/removable-storage-device && make clean
	cd vendor/idevid-certificate-pki && make clean
	cd vendor/ownership-voucher-pki && make clean
	cd 3rd-party-ca/owner-certificate-pki && make clean
	cd 3rd-party-ca/tls-server-certificate-pki && make clean
