#! /bin/sh
exec sh ../shared/generation_helper.sh client "$1" \
	--generate-certificate \
	--load-ca-certificate ../ca/ca-public-cert.pem \
	--load-ca-privkey ../ca/ca-private-key.pem
