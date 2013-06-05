#! /bin/sh
PRVKEY=ca-private-key.pem
PUBCERT=ca-public-cert.pem
certtool --generate-privkey > "$PRVKEY"
chmod 600 "$PRVKEY"
certtool --generate-self-signed \
	--load-privkey "$PRVKEY" \
	--template ca.info \
	--outfile "$PUBCERT" \
2>& 1 | tee "$PUBCERT"_info.txt
