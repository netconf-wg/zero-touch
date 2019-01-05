#/bin/bash

echo
echo "Testing YANG modules first..."
echo

echo "validating ietf-sztp-bootstrap-server.yang..."
printf "  ^ with pyang..."
response=`pyang --ietf --strict --canonical --max-line-length=69 ../ietf-sztp-bootstrap-server\@*.yang 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n"
printf "  ^ with yanglint..."
response=`yanglint ../ietf-sztp-bootstrap-server\@*.yang 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n\n"


echo "validating ietf-sztp-conveyed-info.yang..."
# COMMENTING OUT DUE TO IMPROPER YANG_DATA VALIDATION ERROR
#printf "  ^ with pyang..."
#response=`pyang --ietf --strict --canonical --max-line-length=69 ../ietf-sztp-conveyed-info\@*.yang 2>&1`
#if [ $? -ne 0 ]; then
#  printf "failed (error code: $?)\n"
#  printf "$response\n\n"
#  echo
#  exit 1
#fi
#printf "okay.\n"
printf "  ^ with yanglint..."
response=`yanglint ../ietf-sztp-conveyed-info\@*.yang 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n\n"


echo "validating example-device-data-model.yang..."
printf "  ^ with pyang..."
response=`pyang --lint --strict --canonical --max-line-length=69 ../example-device-data-model\@*.yang 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n"
printf "  ^ with yanglint..."
response=`yanglint ../example-device-data-model\@*.yang 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n\n"



echo
echo "Tranisitioning to testing ietf-sztp-bootstrap-server.yang examples"
echo

printf "validating ex-api-get-bootstrap-data-rpc-trusted.xml..."
cat ex-api-get-bootstrap-data-rpc-trusted.xml | sed '1,4d' | sed 's/input/get-bootstrapping-data/' > ex-api-get-bootstrap-data-rpc-trusted-4nc.xml
response=`yanglint -s -t rpc ../ietf-sztp-bootstrap-server\@*.yang ex-api-get-bootstrap-data-rpc-trusted-4nc.xml 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  rm ex-api-get-bootstrap-data-rpc-trusted-4nc.xml
  exit 1
fi
printf "okay.\n"

printf "validating ex-api-get-bootstrap-data-rpc-reply-trusted.xml..."
cat ex-api-get-bootstrap-data-rpc-reply-trusted.xml | sed '1,5d' | grep -v "output" | grep -v "xmlns=" | sed -e 's/<reporting-level>/<reporting-level xmlns="urn:ietf:params:xml:ns:yang:ietf-sztp-bootstrap-server">/' -e 's/<conveyed-information>/<conveyed-information xmlns="urn:ietf:params:xml:ns:yang:ietf-sztp-bootstrap-server">/' > ex-api-get-bootstrap-data-rpc-reply-trusted-4nc.xml
response=`yanglint -s -t rpcreply ../ietf-sztp-bootstrap-server\@*.yang ex-api-get-bootstrap-data-rpc-reply-trusted-4nc.xml ex-api-get-bootstrap-data-rpc-trusted-4nc.xml 2>&1`
rm ex-api-get-bootstrap-data-rpc-trusted-4nc.xml
rm ex-api-get-bootstrap-data-rpc-reply-trusted-4nc.xml
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n"

printf "validating ex-api-get-bootstrap-data-rpc-untrusted.xml..."
cat ex-api-get-bootstrap-data-rpc-untrusted.xml | sed '1,4d' | sed 's/input/get-bootstrapping-data/' > ex-api-get-bootstrap-data-rpc-untrusted-4nc.xml
response=`yanglint -s -t rpc ../ietf-sztp-bootstrap-server\@*.yang ex-api-get-bootstrap-data-rpc-untrusted-4nc.xml 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  rm ex-api-get-bootstrap-data-rpc-untrusted-4nc.xml
  exit 1
fi
printf "okay.\n"

printf "validating ex-api-get-bootstrap-data-rpc-reply-untrusted.xml..."
cat ex-api-get-bootstrap-data-rpc-reply-untrusted.xml | sed '1,5d' | grep -v "output" | grep -v "xmlns=" | sed 's/<conveyed-information>/<conveyed-information xmlns="urn:ietf:params:xml:ns:yang:ietf-sztp-bootstrap-server">/' | sed 's/<owner-certificate>/<owner-certificate xmlns="urn:ietf:params:xml:ns:yang:ietf-sztp-bootstrap-server">/' | sed 's/<ownership-voucher>/<ownership-voucher xmlns="urn:ietf:params:xml:ns:yang:ietf-sztp-bootstrap-server">/' > ex-api-get-bootstrap-data-rpc-reply-untrusted-4nc.xml
response=`yanglint -s -t rpcreply ../ietf-sztp-bootstrap-server\@*.yang ex-api-get-bootstrap-data-rpc-reply-untrusted-4nc.xml ex-api-get-bootstrap-data-rpc-untrusted-4nc.xml 2>&1`
rm ex-api-get-bootstrap-data-rpc-untrusted-4nc.xml
rm ex-api-get-bootstrap-data-rpc-reply-untrusted-4nc.xml
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n"



printf "validating ex-api-report-progress-rpc.xml..."
cat ex-api-report-progress-rpc.xml | sed '1,4d' | sed 's/input/report-progress/' > ex-api-report-progress-rpc-4nc.xml
response=`yanglint -s -t rpc ../ietf-sztp-bootstrap-server\@*.yang ex-api-report-progress-rpc-4nc.xml 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
rm ex-api-report-progress-rpc-4nc.xml
printf "okay.\n"



echo
echo "Transitioning to testing ietf-sztp-conveyed-info.yang examples"
echo

# first, we need to create a version of the YANG module without the "yang-data"
# extension (e.g., make it look like it defines protocol-accessible nodes)
name=`ls -1 ../ietf-sztp-conveyed-info\@*.yang | sed 's/\.\.\///'`
linenum=`grep -n "typedef script {" ../$name | sed 's/:.*//'`
delline=`expr $linenum - 2`  # hope it doesn't move!
awk "NR%$delline" ../$name > $name.2
sed -e '/rc:yang-data/d' $name.2 > $name
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
echo "Tranisitioning to testing example-device-data-model.yang examples"
echo

printf "validating ex-api-device-model.xml..."
response=`yanglint -m -s -p ../ ../example-device-data-model\@*.yang ./ietf-origin.yang ex-api-device-model.xml ../../trust-anchors/refs/ex-trust-anchors.xml 2>&1`
if [ $? -ne 0 ]; then
  printf "failed (error code: $?)\n"
  printf "$response\n\n"
  echo
  exit 1
fi
printf "okay.\n"

echo
echo

