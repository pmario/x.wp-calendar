#! /bin/bash

# This file is not used at the moment.
# It may be become the "put any text on a stiy-not"

ARG0=$(basename $0 .sh)
ARG0DIR=$(dirname $0)
[ $ARG0DIR == "." ] && ARG0DIR=$PWD 

source "$ARG0DIR/global"

help() {
	usage
	echo
	echo Options:
	echo $'\t'-v .. Version
	echo $'\t'-H .. Calendar header default format eg: \"May - 2012\"
	echo $'\t'-t .. Input text file
	echo $'\t'-o .. Output file
	echo $'\t'-c .. Calendar Output file
	echo $'\t'-O .. Same as -o, but opens the result after creation
	echo $'\t'-S .. Print the calendar onto a stickyNote
	echo
	echo $'\t'-h .. Help

	exit 0;
}

RESULT="$DTMP/sticky-txt.png"
STICKYCAL=1
OPENRESULT=
while getopts vhSc:t:o:O:H: flag
do
    case "$flag" in
    (H) HEADER="$OPTARG";;
    (t) bodyFile="$OPTARG";;
    (o) OUTFILE="$OPTARG";;
    (c) CALMARK="$OPTARG";;
    (O) OUTFILE="$OPTARG"
		OPENRESULT="$OUTFILE"
		;;
    (S) STICKYCAL="1";;
    (h) help; exit 0;;
    (v) version; exit 0;;
    (*) echo
		help;;
    esac
done
shift $(expr $OPTIND - 1)


calcHeight() {
	local lines=$(cat $1 | wc -l )
	local y
	let "y= lines * 22 + 100"
	echo $y
}

y=$(calcHeight "$bodyFile")

AREA="500x$y"

echo "area: "$AREA

createCalText() {
	cBodyTxt=`cat $bodyFile`

	# the output file will be set in "global" or from command line.
	outfile=${OUTFILE:-$RESULT}

	# header may be set from command line -H parameter. Mainly for testing
	# header format eg: May - 2012
	cHeaderTxt=${HEADER:-"Note: "`date "+%F %X - %a"`}

	# create the calendar text
	convert -size ${AREA} xc:transparent -font $TXT_FONT \
		-pointsize 22 -fill "$TXT_COLOR" -gravity NorthWest -draw "text 20,20 '${cHeaderTxt}'" \
		-pointsize 18 -fill "$TXT_COLOR" -draw "text 20,70 '${cBodyTxt}'" $CALTXT
}

createCalText

if [ $STICKYCAL ] 
then
	"$ARG0DIR/wpc-note.sh" -t $CALTXT -o $CALMARK
fi

if [ ${#OPENRESULT} -ne 0 ]
then
	open $OPENRESULT
fi
