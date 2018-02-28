
# pyang -f tree --tree-print-yang-data ../ietf-zerotouch-information\@*.yang > ietf-zerotouch-information-tree.txt 
#
# HACK around `pyang --tree-print-yang-data` not yet supporting ietf-yang-data-ext
name=`ls -1 ../ietf-zerotouch-information\@*.yang | sed 's/\.\.\///'`
sed 's/ietf-yang-data-ext/ietf-restconf/' ../$name > $name
pyang -f tree --tree-print-yang-data $name > ietf-zerotouch-information-tree.txt
rm $name

cat ietf-zerotouch-information-tree.txt | sed -n '/:(redirect-information)/,/:(onboarding-information)/p' | sed '$d' | sed 's/^         |/          /' | sed 's/         //' > redirect-information-tree.txt 

cat ietf-zerotouch-information-tree.txt | sed -n '/:(onboarding-information)/,$p' | sed 's/         //'  > onboarding-information-tree.txt

pyang -f tree ../ietf-zerotouch-bootstrap-server\@*.yang > ietf-zerotouch-bootstrap-server-tree.txt 

pyang -p ../ -f tree --tree-line-length=70 ../example-zerotouch-device\@*.yang > example-zerotouch-device-tree.txt 
