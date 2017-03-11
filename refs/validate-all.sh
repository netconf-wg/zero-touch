pyang --ietf --strict ../ietf-zerotouch\@*.yang

./validate.sh ietf-zerotouch\@*.yang ex-file-redirect-information.xml
./validate.sh ietf-zerotouch\@*.yang ex-file-bootstrap-information.xml
./validate.sh ietf-zerotouch\@*.yang ex-file-owner-certificate.xml
./validate.sh ietf-zerotouch\@*.yang ex-file-ownership-voucher.xml

./validate.sh ietf-zerotouch\@*.yang ex-api-redirect-information-signed.xml
./validate.sh ietf-zerotouch\@*.yang ex-api-bootstrap-information-signed.xml
./validate.sh ietf-zerotouch\@*.yang ex-api-redirect-information-unsigned.xml
./validate.sh ietf-zerotouch\@*.yang ex-api-bootstrap-information-unsigned.xml

