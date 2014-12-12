#! /bin/sh
SUFFIX=.pem
sf=last_serial.txt

set -e
trap 'echo "Failure!" >& 2' 0

kind=$1
test -n "$kind"
PRVKEY_PREFIX=$kind-${2}${2:+-}private-key
PUBCERT_PREFIX=$kind-${2}${2:+-}public-cert
shift 2

infile=$kind.info
test -f "$infile"
tpl=$infile.tmp

if test -e "$sf"
then
	read sn < "$sf"
	digits=`printf %s "$sn" | wc -c`
	sn=${sn##0}
else
	sn=0
	digits=5
fi
sn=`expr "$sn" + 1`
sn=`printf '%0*u' "$digits" "$sn"`
cpp -P -I../shared -DSERIAL_NUMBER=$sn "$infile" > "$tpl"

pk=$PRVKEY_PREFIX-$sn$SUFFIX
certtool --generate-privkey > "$pk"
chmod 600 "$pk"
pc=$PUBCERT_PREFIX-$sn$SUFFIX
certtool "$@" \
	--load-privkey "$pk" \
	--template "$tpl" \
	--outfile "$pc" \
2>& 1 | tee "$pc"_info.txt

echo "$sn" > "$sf"
rm -- "$tpl"

ln -sf "$pk" "$PRVKEY_PREFIX$SUFFIX"
ln -sf "$pc" "$PUBCERT_PREFIX$SUFFIX"

trap - 0
