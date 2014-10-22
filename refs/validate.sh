#!/bin/sh

OUT=$1.tmp

cat > $OUT <<EOF
<rpc xmlns='urn:ietf:params:xml:ns:netconf:base:1.0'
     message-id='101'>
  <edit-config>
    <target>
      <running/>
    </target>
    <config>
EOF
cat $1 >> $OUT
cat >> $OUT <<EOF
    </config>
  </edit-config>
</rpc>
EOF

yang2dsdl -t edit-config -v $OUT $2 $3

rm $OUT

