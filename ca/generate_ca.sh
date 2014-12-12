#! /bin/sh
helper_script=../shared/generation_helper.sh
kind=ca
PRVKEY_PREFIX=$kind-private-key
PUBCERT_PREFIX=$kind-public-cert
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
certtool --generate-self-signed \
	--load-privkey "$pk" \
	--template "$tpl" \
	--outfile "$pc" \
2>& 1 | tee "$pc"_info.txt
sh "$helper_script" stop "$tpl"
ln -sf "$pk" "$PRVKEY_PREFIX$SUFFIX"
ln -sf "$pc" "$PUBCERT_PREFIX$SUFFIX"
trap - 0
