#! /bin/sh
sf=last_serial.txt
ns=next_serial.tmp

set -e
trap 'echo "Failure!" >& 2' 0
expanded=${2:?Name of expanded file}
case $1 in
	start)
		infile=${3:?Input file to be expanded?}
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
		cpp -P -I../shared -DSERIAL_NUMBER=$sn "$infile" > "$expanded"
		echo $sn > "$ns"
		;;
	stop)
		test -f "$ns"
		cat "$ns" > "$sf"
		rm -- "$expanded" "$ns"
esac
trap - 0
