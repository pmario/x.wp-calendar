#! /bin/bash
ARG0=$(basename $0 .sh)
ARG0DIR=$(dirname $0)
[ $ARG0DIR == "." ] && ARG0DIR=$PWD 

source "$ARG0DIR/global"

AREA="500x300"

OUTFILE="$DWP/wpc-calendar.png"
TEXT=$CALMARK

background="$DTMP/sticky-cal.png"
noteTemplate="$DTMP/sticky-template.png"
motion1="$DTMP/motion1.png"
motion2="$DTMP/motion2.png"
random="$DTMP/random-trans.png"

help() {
	usage
	echo
	echo Options:
	echo $'\t'"-t .. Input png file contains the text for the StickyNote"
	echo $'\t'"-o .. Output file"
	echo $'\t'"-O .. Same as -o, but opens the result after creation"
	echo
	echo $'\t'"-h .. Help"
	
	exit 0;
}

# file to be opend, after creation
OPENRESULT=

while getopts vho:O:t: flag
do
    case "$flag" in
    (t) TEXT="$OPTARG";;
    (o) OUTFILE="$OPTARG";;
    (O) OUTFILE="$OPTARG"
		OPENRESULT="$OUTFILE"
		;;
    (h) help; exit 0;;
    (v) version; exit 0;;
    (*) echo
		help;;
    esac
done
shift $(expr $OPTIND - 1)

text=$TEXT
output=$OUTFILE

# creating the template is quite slow, so do it just once
# TODO create a command line option too
if [ ! -e $noteTemplate ] 
then
	# create a random dot matrix that will be used for the paper structure
	convert -size $AREA gradient: -separate \
		-virtual-pixel tile   -spread 200   -combine \
		-channel G -threshold 2% -negate \
	          -channel RG -separate +channel \
	          -compose CopyOpacity -composite   $random

	# create the yellow sticky-note background color.
	convert -size $AREA xc:khaki $noteTemplate

	# merry the sticky-not with the random background dots
	composite $random $noteTemplate $noteTemplate 

	# motion blure the dots in 2 axis
	convert $noteTemplate -motion-blur 0x12+10  $motion1
	convert $noteTemplate -motion-blur 0x12+165 $motion2

	# marry the motion backgrounds 
	composite $motion1 $motion2 -dissolve 50 $noteTemplate
fi

# remove the old sticky calendar.
# TODO use better var names
cp $noteTemplate $background

# apply the text to the paper like note
convert $background -gravity North -draw "image over 0,0 0,0 '$text'" $background

# rotate the finished note by a random angle. 
convert $background \
	-background  none   -rotate `convert null: -format '%[fx:rand()*4]' info:` +repage \
	-background  black  \( +clone -shadow 60x6+4+4 \) +swap \
	-background  none   -flatten \
	"$output"

if [ ${#OPENRESULT} -ne 0 ]
then
	open $output
fi
