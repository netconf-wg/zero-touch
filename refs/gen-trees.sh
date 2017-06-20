pyang -f tree --tree-print-yang-data ../ietf-zerotouch-information\@*.yang | sed -e '2,3 d' -e 's/^    //' > ietf-zerotouch-information-tree.txt 

pyang -f tree ../ietf-zerotouch-bootstrap-server\@*.yang > ietf-zerotouch-bootstrap-server-tree.txt 
