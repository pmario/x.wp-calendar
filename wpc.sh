#! /bin/bash
ARG0=$(basename $0 .sh)
ARG0DIR=$(dirname $0)
[ $ARG0DIR == "." ] && ARG0DIR=$PWD 

source "$ARG0DIR/global"

help() {
	usage
	echo
	echo Options:
	echo $'\t'-v .. Version
	echo $'\t'-y .. Year eg: 2012
	echo $'\t'-m .. Month eg: 02
	echo $'\t'-d .. Day eg: 01
	echo $'\t'-H .. Calendar header default format eg: \"May - 2012\"
	echo $'\t'-o .. Output file
	echo $'\t'-c .. Calendar Output file
	echo $'\t'-O .. Same as -o, but opens the result after creation
	echo $'\t'-S .. Print the calendar directly on to the background
	echo
	echo $'\t'-h .. Help

	exit 0;
}

# the calendar is printed on the sticky note. 
# If set to "0" it will be printed directly to the background
STICKYCAL="1"

# This variable has to be set to a file, that will be opened. for debugging only
OPENRESULT=

while getopts vhSc:o:O:H:y:m:d: flag
do
    case "$flag" in
    (y) YEAR="$OPTARG";;
    (m) MONTH="$OPTARG";;
    (d) DAY="$OPTARG";;
    (H) HEADER="$OPTARG";;
    (o) OUTFILE="$OPTARG";;
    (c) CALMARK="$OPTARG";;
    (O) OUTFILE="$OPTARG"
		OPENRESULT="$OUTFILE"
		;;
    (S) STICKYCAL="0";;
    (h) help; exit 0;;
    (v) version; exit 0;;
    (*) echo
		help;;
    esac
done
shift $(expr $OPTIND - 1)

createCalText() {
	# the output file will be set in "global" or from command line.
	outfile=${OUTFILE:-$RESULT}

	# date can be set with command line
	# see help for more info

	year=${YEAR:-`date "+%Y"`}
	month=${MONTH:-`date "+%m"`}
	day=${DAY:-`date "+%d"`}

	# get calendar data file. fileName format: YYYY-MM.txt
	# MM must have leading 0's eg: 01 
	cBodyTxt=`cat $DTXT/$year-$month.txt`

	#echo "cal-file: "$DTXT$year"-"$month".txt"

	# header may be set from command line -H parameter. Mainly for testing
	# header format eg: May - 2012
	cHeaderTxt=${HEADER:-`date "+%b - %Y" --date=$year"/"$month"/"$day`}

	# dow: day of week .. 1 is Monday
	# week: calendar week .. 1..53
	# needs to be created with --date because of command line
	dow=`date  "+%u" --date=$year"/"$month"/"$day`
	week=`date "+%V" --date=$year"/"$month"/"$day`

	# first week of the actual month. needed for day marker line calculation.
	fw=`date "+%V" --date=$year"/"$month"/01"`

	#echo "fw: "$fw

	# due to the format of the calendar there has to be some corrections 
	# to calclulate the right row/line for the actual day indicator
	if [ $fw -ge "52" ] && [ $week -ge "52" ]
	then
		week="0"
	elif [ $fw -ge "52" ]
	then
		local a=a
		# no correction needed
	else
		week=$((week - fw))
	fi

	# echo "week: "$week

	# create the calendar text
	convert -size ${AREA} xc:transparent -font $TXT_FONT \
		-pointsize 22 -fill "$TXT_COLOR" -gravity NorthWest -draw "text 45,70 '${cHeaderTxt}'" \
		-pointsize 18 -fill "$TXT_COLOR" -draw "text 45,120 '${cBodyTxt}'" $CALTXT
}

createDayMarker() {
	# positions are relative to the stiky note AREA
	iposx="34"
	iposy="158"
	dx="55"
	dy="22"

	xx=$(( iposx + dx * dow))
	yy=$(( iposy + week * dy))

	#echo $xx, $yy

	# TODO find better day markers
	# actual day marker (??). Replace the ? with spaces.
	#dm="»  «"
	dm="(  )"

	#convert -size ${AREA} xc:transparent -font $MARKER_FONT \
	convert $CALTXT -font $MARKER_FONT \
		-pointsize 18 -fill "$MARKER_COLOR" -draw "text $xx,$yy '$dm'" $CALMARK
}

createCalText
createDayMarker

if [ $STICKYCAL ] 
then
	"$ARG0DIR/wpc-note.sh" -o $CALMARK
fi

# draw the calendar top right to the background
convert $WPBG -gravity NorthEast -draw "image over 0,0 0,0 '$CALMARK'" "$outfile"
#convert $WPBG -gravity NorthEast -draw "image over 0,0 0,0 test/stickyNote.png" ${outfile}

# gsettings is done by the calling script now
# gsettings set org.gnome.desktop.background picture-uri "file:///media/Daten/Git/x.calendar/"$RESULT

if [ ${#OPENRESULT} -ne 0 ]
then
	open $OPENRESULT
fi
