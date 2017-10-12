pyang -f tree --tree-print-yang-data ../ietf-zerotouch-information\@*.yang > ietf-zerotouch-information-tree.txt 

pyang -f tree ../ietf-zerotouch-bootstrap-server\@*.yang > ietf-zerotouch-bootstrap-server-tree.txt 

pyang -p ../ -f tree --tree-line-length=70 ../ietf-zerotouch-device\@*.yang > ietf-zerotouch-device-tree.txt 
