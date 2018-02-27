#/bin/bash

echo
echo "Testing YANG modules first..."
echo

echo "validating ietf-zerotouch-bootstrap-server.yang..."
printf "  ^ with pyang..."
response=`pyang --ietf --strict --canonical --max-line-length=70 ../ietf-zerotouch-bootstrap-server\@*.yang 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n"
printf "  ^ with yanglint..."
response=`yanglint ../ietf-zerotouch-bootstrap-server\@*.yang 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n\n"


echo "validating ietf-zerotouch-information.yang..."
printf "  ^ with pyang..."
response=`pyang --ietf --strict --canonical --max-line-length=70 ../ietf-zerotouch-information\@*.yang 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n"
printf "  ^ with yanglint..."
response=`yanglint ../ietf-zerotouch-information\@*.yang 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n\n"


echo "validating example-zerotouch-device.yang..."
printf "  ^ with pyang..."
response=`pyang --lint --strict --canonical --max-line-length=70 ../example-zerotouch-device\@*.yang 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n"
printf "  ^ with yanglint..."
response=`yanglint ../example-zerotouch-device\@*.yang 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n\n"



echo
echo "Tranisitioning to testing ietf-zerotouch-bootstrap-server.yang examples"
echo

printf "validating ex-api-get-bootstrap-data-rpc-trusted.xml..."
sed 's/input/get-bootstrapping-data/' ex-api-get-bootstrap-data-rpc-trusted.xml > ex-api-get-bootstrap-data-rpc-trusted-4nc.xml
response=`yanglint -s -t rpc ../ietf-zerotouch-bootstrap-server\@*.yang ex-api-get-bootstrap-data-rpc-trusted-4nc.xml 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n"

printf "validating ex-api-get-bootstrap-data-rpc-reply-trusted.xml..."
cat ex-api-get-bootstrap-data-rpc-reply-trusted.xml | grep -v "output" | sed 's/<zerotouch-information>/<zerotouch-information xmlns="urn:ietf:params:xml:ns:yang:ietf-zerotouch-bootstrap-server">/' >> ex-api-get-bootstrap-data-rpc-reply-trusted-4nc.xml
response=`yanglint -s -t rpcreply ../ietf-zerotouch-bootstrap-server\@*.yang ex-api-get-bootstrap-data-rpc-reply-trusted-4nc.xml ex-api-get-bootstrap-data-rpc-trusted-4nc.xml 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n"

printf "validating ex-api-get-bootstrap-data-rpc-untrusted.xml..."
sed 's/input/get-bootstrapping-data/' ex-api-get-bootstrap-data-rpc-untrusted.xml > ex-api-get-bootstrap-data-rpc-untrusted-4nc.xml
response=`yanglint -s -t rpc ../ietf-zerotouch-bootstrap-server\@*.yang ex-api-get-bootstrap-data-rpc-untrusted-4nc.xml 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n"

printf "validating ex-api-get-bootstrap-data-rpc-reply-untrusted.xml..."
cat ex-api-get-bootstrap-data-rpc-reply-untrusted.xml | grep -v "output" | sed 's/<zerotouch-information>/<zerotouch-information xmlns="urn:ietf:params:xml:ns:yang:ietf-zerotouch-bootstrap-server">/' | sed 's/<owner-certificate>/<owner-certificate xmlns="urn:ietf:params:xml:ns:yang:ietf-zerotouch-bootstrap-server">/' | sed 's/<ownership-voucher>/<ownership-voucher xmlns="urn:ietf:params:xml:ns:yang:ietf-zerotouch-bootstrap-server">/' >> ex-api-get-bootstrap-data-rpc-reply-untrusted-4nc.xml
response=`yanglint -s -t rpcreply ../ietf-zerotouch-bootstrap-server\@*.yang ex-api-get-bootstrap-data-rpc-reply-untrusted-4nc.xml ex-api-get-bootstrap-data-rpc-untrusted-4nc.xml 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n"

rm ex-api-get-bootstrap-data-rpc-trusted-4nc.xml
rm ex-api-get-bootstrap-data-rpc-reply-trusted-4nc.xml
rm ex-api-get-bootstrap-data-rpc-untrusted-4nc.xml
rm ex-api-get-bootstrap-data-rpc-reply-untrusted-4nc.xml


printf "validating ex-api-report-progress-rpc.xml..."
sed 's/input/report-progress/' ex-api-report-progress-rpc.xml > ex-api-report-progress-rpc-4nc.xml
response=`yanglint -s -t rpc ../ietf-zerotouch-bootstrap-server\@*.yang ex-api-report-progress-rpc-4nc.xml 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
rm ex-api-report-progress-rpc-4nc.xml
printf "okay.\n"



echo
echo "Tranisitioning to testing ietf-zerotouch-information.yang examples"
echo

# first, we need to create a version of the YANG module without the "yang-data"
# extension (e.g., make it look like it defines protocol-accessible nodes)
name=`ls -1 ../ietf-zerotouch-information\@*.yang | sed 's/\.\.\///'`
linenum=`grep -n "typedef script {" ../$name | sed 's/:.*//'`
delline=`expr $linenum - 2`  # hope it doesn't move!
awk "NR%$delline" ../$name > $name.2
sed -e '/yd:yang-data/d' $name.2 > $name
rm $name.2 


printf "validating ex-file-redirect-information.xml..."
response=`yanglint -s $name ex-file-redirect-information.xml 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  rm $name 
  echo
  exit 1
fi
printf "okay.\n"

printf "validating ex-file-redirect-information.json..."
response=`yanglint -s $name ex-file-redirect-information.json 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  rm $name 
  echo
  exit 1
fi
printf "okay.\n"

printf "validating ex-file-onboarding-information.xml..."
response=`yanglint -s $name ex-file-onboarding-information.xml 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  rm $name 
  echo
  exit 1
fi
printf "okay.\n"

printf "validating ex-file-onboarding-information.json..."
response=`yanglint -s $name ex-file-onboarding-information.json 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  rm $name 
  echo
  exit 1
fi
printf "okay.\n"

# now remove it
rm $name 




echo
echo "Tranisitioning to testing example-zerotouch-device.yang examples"
echo

printf "validating ex-api-device-model.xml..."
response=`yanglint -m -p ../ -s ../example-zerotouch-device\@*.yang ex-api-device-model.xml ../../keystore/refs/ex-keystore.xml 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n"

echo
echo

