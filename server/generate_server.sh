#! /bin/sh
CAPRVKEY=../ca/ca-private-key.pem
CAPUBCERT=../ca/ca-public-cert.pem
PRVKEY=server-private-key.pem
PUBCERT=server-public-cert.pem
certtool --generate-privkey > "$PRVKEY"
chmod 600 "$PRVKEY"
certtool --generate-certificate \
	--load-ca-certificate "$CAPUBCERT" \
	--load-ca-privkey "$CAPRVKEY" \
	--load-privkey "$PRVKEY" \
	--template server.info \
	--outfile "$PUBCERT" \
2>& 1 | tee "$PUBCERT"_info.txt
