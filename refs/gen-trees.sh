echo "Generating tree diagrams..."

pyang -f tree --tree-print-yang-data ../ietf-sztp-conveyed-info\@*.yang > ietf-sztp-conveyed-info-tree.txt 
#
# HACK around `pyang --tree-print-yang-data` not yet supporting ietf-yang-data-ext
#name=`ls -1 ../ietf-sztp-conveyed-info\@*.yang | sed 's/\.\.\///'`
#sed 's/ietf-yang-data-ext/ietf-restconf/' ../$name > $name
#pyang -f tree --tree-print-yang-data $name > ietf-sztp-conveyed-info-tree.txt 2> /dev/null
#rm $name

cat ietf-sztp-conveyed-info-tree.txt | sed -n '/:(redirect-information)/,/:(onboarding-information)/p' | sed '$d' | sed 's/^       |/        /' | sed 's/^       //' > redirect-information-tree.txt 

cat ietf-sztp-conveyed-info-tree.txt | sed -n '/:(onboarding-information)/,$p' | sed 's/^       //'  > onboarding-information-tree.txt

pyang -f tree ../ietf-sztp-bootstrap-server\@*.yang > ietf-sztp-bootstrap-server-tree.txt 
sed 's/reporting-level?        /reporting-level?    /' ietf-sztp-bootstrap-server-tree.txt > tmp;
mv tmp ietf-sztp-bootstrap-server-tree.txt

pyang -p ../ -f tree --tree-line-length=69 ../example-device-data-model\@*.yang > example-device-data-model-tree.txt 

