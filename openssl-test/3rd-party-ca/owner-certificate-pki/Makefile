owner_cert_pki:
	@echo "\n[2.1.1] Trust Anchor generating a self-signed cert..."
	cd trust-anchor-ca && make gen_ca

	@echo "\n[2.1.2] Intermediate generating its CSR..."
	cd intermediate-ca && make cert_request

	@echo "\n[2.1.3] Trust anchor signing intermediate's CSR..."
	cd trust-anchor-ca && make sign_intermediate_request


clean:
	cd trust-anchor-ca && make clean
	cd intermediate-ca && make clean

