# warning, this must point to at least openssl version 1.0.1e (CRL extensions)
#export OPENSSL = /usr/local/openssl-1.0.1f/bin/openssl
export OPENSSL = /Users/kwatsen/Downloads/openssl-1.0.2d/apps/openssl

all: clean
	@echo "\nMaking Juniper Trust CA..."
	cd root_ca && make ca_cert.pem

	@echo "\nMaking Intermediate CA..."
	cd intermediate && make cert_request.pem
	cd root_ca && make sign_intermediate_request

	@echo "\nMaking Owner Cert..."
	cd rightful_owner && make cert_request.pem
	cd intermediate && make sign_owner_cert_request

	@echo "\nOwner Signing Redirect Information (PKCS#7)"
	cd rightful_owner && make sign_redirect_information

	#@echo "\nOwner Signing Bootstrapping Data..."
	#cd rightful_owner && make gen_unsigned_bootstrapping_data && make gen_signed_bootstrapping_data

	#@echo "\nGenerating cert bundles..."
	#cat rightful_owner/owner_cert.pem intermediate/ca_cert.pem root_ca/ca_cert.pem >> owner_bundle.pem

	@echo "\nGenerating PKCS#7 based Owner Certificate (including cert chain and crls)..."
	cat rightful_owner/owner_cert.pem intermediate/ca_cert.pem root_ca/ca_cert.pem > cert_bundle.pem
	cat intermediate/crl.pem root_ca/crl.pem > crl_bundle.pem
	#$(OPENSSL) crl2pkcs7 -nocrl -certfile owner_bundle.pem -out owner_bundle.p7b
	$(OPENSSL) crl2pkcs7 -in crl_bundle.pem -certfile cert_bundle.pem -out owner_cert_chain_and_crls.p7b

	@echo "\nTEST COMPLETE."


clean:
	cd root_ca && make clean
	cd intermediate && make clean
	cd rightful_owner && make clean

