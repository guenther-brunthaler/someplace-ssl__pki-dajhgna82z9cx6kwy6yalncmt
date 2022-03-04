#! /bin/sh
# v2022.62
SUFFIX=.pem
sf=last_serial.txt

set -e
trap 'echo "Failure!" >& 2' 0

command -v certtool > /dev/null || {
	cat <<- '----' >& 2; false || exit
		Please install 'certtool'!
		One some platforms, package "gnutls-bin" provides this tool.
----
}

kind=${0##*/}; kind=${kind%.sh}; kind=${kind#generate_}; test "$kind"
SUBTYPE=$1
CLNSUBTYPE=`
	printf '%s\n' "$SUBTYPE" | sed '
		s/[^[:alnum:]]\{1,\}/_/g; s/^_//; s/_$//
	'
`
PRVKEY_PREFIX=$kind-${CLNSUBTYPE}${CLNSUBTYPE:+-}private-key
PUBCERT_PREFIX=$kind-${CLNSUBTYPE}${CLNSUBTYPE:+-}public-cert

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
if test "$SUBTYPE"
then
	set -- ${1+"$@"} -DSUBTYPE="$SUBTYPE"
else
	set -- ${1+"$@"} -USUBTYPE
fi
cpp "$@" "$infile" | grep -v "^#line" > "$tpl"

pk=$PRVKEY_PREFIX-$sn$SUFFIX
certtool \
	--generate-privkey \
	--bits=4096 \
	--key-type=rsa \
	> "$pk"
# (The --seed option is insecure and has therefore been omitted for now.)
chmod 600 "$pk"
pc=$PUBCERT_PREFIX-$sn$SUFFIX
case $kind in
	ca)
		test -z "$SUBTYPE" # CA creation does not use an argument!
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
