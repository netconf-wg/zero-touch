voucher_pki:
	@echo "\n[1.2.1] Trust Anchor generating a self-signed cert..."
	cd trust-anchor-ca && make gen_ca

	@echo "\n[1.2.2] Intermediate1 generating its CSR..."
	cd intermediate1-ca && make cert_request

	@echo "\n[1.2.3] Trust anchor signing intermediate1's CSR..."
	cd trust-anchor-ca && make sign_intermediate1_request

	@echo "\n[1.2.4] Intermediate2 generating its CSR..."
	cd intermediate2-ca && make cert_request

	@echo "\n[1.2.5] Intermediate1 signing intermediate2's CSR..."
	cd intermediate1-ca && make sign_intermediate2_request

	@echo "\n[1.2.6] Intermediate3 generating its CSR..."
	cd intermediate3-ca && make cert_request

	@echo "\n[1.2.7] Intermediate2 signing intermediate2's CSR..."
	cd intermediate2-ca && make sign_intermediate3_request

clean:
	cd trust-anchor-ca && make clean
	cd intermediate1-ca && make clean
	cd intermediate2-ca && make clean
	cd intermediate3-ca && make clean

