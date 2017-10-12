echo "Testing ietf-zerotouch-bootstrap-server.yang..."
pyang --ietf --strict --max-line-length=70 ../ietf-zerotouch-bootstrap-server\@*.yang
pyang --canonical ../ietf-zerotouch-bootstrap-server\@*.yang
yanglint ../ietf-zerotouch-bootstrap-server\@*.yang

echo "Testing ietf-zerotouch-information.yang..."
pyang --ietf --strict --max-line-length=70 ../ietf-zerotouch-information\@*.yang
pyang --canonical ../ietf-zerotouch-information\@*.yang
yanglint ../ietf-zerotouch-information\@*.yang

echo "Testing ietf-zerotouch-device.yang..."
pyang -p ../ --ietf --strict --max-line-length=70 ../ietf-zerotouch-device\@*.yang
pyang -p ../ --canonical ../ietf-zerotouch-device\@*.yang
yanglint -p ../ ../ietf-zerotouch-device\@*.yang

echo "Testing ex-api-redirect-information-unsigned.xml..."
yanglint -s ../ietf-zerotouch-bootstrap-server\@*.yang ex-api-redirect-information-unsigned.xml

echo "Testing ex-api-redirect-information-signed.xml..."
yanglint -s ../ietf-zerotouch-bootstrap-server\@*.yang ex-api-redirect-information-signed.xml

echo "Testing ex-api-bootstrap-complete-update.xml..."
yanglint -s -t auto ../ietf-zerotouch-bootstrap-server\@*.yang ex-api-bootstrap-complete-update.xml

echo "Testing ex-file-redirect-information.xml..."
yanglint -s ../ietf-zerotouch-information\@*.yang ex-file-redirect-information.xml

echo "Testing ex-file-onboarding-information.xml..."
yanglint -s ../ietf-zerotouch-information\@*.yang ex-file-onboarding-information.xml

echo "Testing ex-api-device-model.xml..."
yanglint -m -p ../ -s ../ietf-zerotouch-device\@*.yang ex-api-device-model.xml ../../keystore/refs/ex-keystore.xml

