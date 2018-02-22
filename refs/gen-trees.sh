pyang -f tree --tree-print-yang-data ../ietf-zerotouch-information\@*.yang > ietf-zerotouch-information-tree.txt 

cat ietf-zerotouch-information-tree.txt | sed -n '/:(redirect-information)/,/:(onboarding-information)/p' | sed '$d' | sed 's/^         |/          /' | sed 's/         //' > redirect-information-tree.txt 

cat ietf-zerotouch-information-tree.txt | sed -n '/:(onboarding-information)/,$p' | sed 's/         //'  > onboarding-information-tree.txt

pyang -f tree ../ietf-zerotouch-bootstrap-server\@*.yang > ietf-zerotouch-bootstrap-server-tree.txt 

pyang -p ../ -f tree --tree-line-length=70 ../example-zerotouch-device\@*.yang > example-zerotouch-device-tree.txt 
