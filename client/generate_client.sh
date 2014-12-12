#! /bin/sh
helper_script=../shared/generation_helper.sh
CAPRVKEY=../ca/ca-private-key.pem
CAPUBCERT=../ca/ca-public-cert.pem
kind=client
PRVKEY_PREFIX=$kind-${1}${1:+-}private-key
PUBCERT_PREFIX=$kind-${1}${1:+-}public-cert
SUFFIX=.pem
infile=$kind.info
tpl=$infile.tmp

set -e
trap 'echo "Failure!" >& 2' 0
sh "$helper_script" start "$tpl" "$infile"
read sn < next_serial.tmp
test -n "$sn"
pk=$PRVKEY_PREFIX-$sn$SUFFIX
certtool --generate-privkey > "$pk"
chmod 600 "$pk"
pc=$PUBCERT_PREFIX-$sn$SUFFIX
certtool --generate-certificate \
	--load-ca-certificate "$CAPUBCERT" \
	--load-ca-privkey "$CAPRVKEY" \
	--load-privkey "$pk" \
	--template "$tpl" \
	--outfile "$pc" \
2>& 1 | tee "$pc"_info.txt
sh "$helper_script" stop "$tpl"
trap - 0
