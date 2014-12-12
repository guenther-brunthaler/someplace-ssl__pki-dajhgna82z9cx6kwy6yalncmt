#! /bin/sh
SUFFIX=.pem
sf=last_serial.txt

set -e
trap 'echo "Failure!" >& 2' 0

kind=${0##*/}; kind=${kind%.sh}; kind=${kind#generate_}; test -n "$kind"
SUBTYPE=$1
PRVKEY_PREFIX=$kind-${SUBTYPE}${SUBTYPE:+-}private-key
PUBCERT_PREFIX=$kind-${SUBTYPE}${SUBTYPE:+-}public-cert

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
set -- -E -I../shared -DSERIAL_NUMBER=$sn
if test -n "$SUBTYPE"
then
	set -- "$@" -DSUBTYPE="$SUBTYPE"
else
	set -- "$@" -USUBTYPE
fi
cpp "$@" "$infile" | grep -v "^#line" > "$tpl"

pk=$PRVKEY_PREFIX-$sn$SUFFIX
certtool --generate-privkey > "$pk"
chmod 600 "$pk"
pc=$PUBCERT_PREFIX-$sn$SUFFIX
case $kind in
	ca)
		set -- --generate-self-signed
		;;
	*)
		set -- \
			--generate-certificate \
			--load-ca-certificate ../ca/ca-public-cert.pem \
			--load-ca-privkey ../ca/ca-private-key.pem
esac
certtool "$@" \
	--load-privkey "$pk" \
	--template "$tpl" \
	--outfile "$pc" \
2>& 1 | tee "$pc"_info.txt

echo "$sn" > "$sf"
rm -- "$tpl"

ln -sf "$pk" "$PRVKEY_PREFIX$SUFFIX"
ln -sf "$pc" "$PUBCERT_PREFIX$SUFFIX"
ln -sf "$pc"_info.txt "$PUBCERT_PREFIX$SUFFIX"_info.txt

trap - 0
