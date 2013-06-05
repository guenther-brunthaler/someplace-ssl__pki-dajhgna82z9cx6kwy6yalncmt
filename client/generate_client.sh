#! /bin/sh
CAPRVKEY=../ca/ca-private-key.pem
CAPUBCERT=../ca/ca-public-cert.pem
PRVKEY=client-${1}${1:+-}private-key.pem
PUBCERT=client-${1}${1:+-}public-cert.pem
certtool --generate-privkey > "$PRVKEY"
chmod 600 "$PRVKEY"
certtool --generate-certificate \
	--load-ca-certificate "$CAPUBCERT" \
	--load-ca-privkey "$CAPRVKEY" \
	--load-privkey "$PRVKEY" \
	--template client.info \
	--outfile "$PUBCERT" \
2>& 1 | tee "$PUBCERT"_info.txt
