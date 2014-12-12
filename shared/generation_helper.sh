#! /bin/sh
kind=$1
PRVKEY_PREFIX=$kind-${2}${2:+-}private-key
PUBCERT_PREFIX=$kind-${2}${2:+-}public-cert
shift 2
SUFFIX=.pem
infile=$kind.info
tpl=$infile.tmp
sf=last_serial.txt
ns=next_serial.tmp

test -f "$infile"
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
echo $sn > "$ns"

read sn < next_serial.tmp
test -n "$sn"
pk=$PRVKEY_PREFIX-$sn$SUFFIX
certtool --generate-privkey > "$pk"
chmod 600 "$pk"
pc=$PUBCERT_PREFIX-$sn$SUFFIX
certtool "$@" \
	--load-privkey "$pk" \
	--template "$tpl" \
	--outfile "$pc" \
2>& 1 | tee "$pc"_info.txt

test -f "$ns"
cat "$ns" > "$sf"
rm -- "$tpl" "$ns"

trap - 0
