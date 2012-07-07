#! /bin/bash
#
# This script creates the final background. It takes the pics from tmp directory
# and mounts them to the background. x,y positions are random with some fixed offsets.

ARG0=$(basename $0 .sh)
ARG0DIR=$(dirname $0)
[ $ARG0DIR == "." ] && ARG0DIR=$PWD 

source "$ARG0DIR/global"

background=$RESULT
result=$RESULT

usage() {
	version
	echo Usage:$'\t'$ARG0 [Options] thumb1.png thumb2.png thumb3.png
}

help() {
	usage
	echo
	echo Options:
	echo $'\t'-v .. Version
	echo $'\t'-b .. Background input file
	echo $'\t'-o .. Output file
	echo $'\t'-O .. Same as -o, but opens the result after creation
	echo
	echo $'\t'-h .. Help
	
	exit 0;
}

OPENRESULT=
while getopts vhb:o:O: flag
do
    case "$flag" in
    (b) background="$OPTARG";;
    (o) result="$OPTARG";;
    (O) result="$OPTARG"
		OPENRESULT="$result"
		;;
    (h) help; exit 0;;
    (v) version; exit 0;;
    (*) echo
		help;;
    esac
done
shift $(expr $OPTIND - 1)

# create the thumbnail files
# TODO this could be optimiced, with the real pictur names. 
# if a file does exist allready, just use it, instead of creating it again.
# it would be faster, drawback would be the random rotation would be calculated only once.

createThumb() {
  convert $1  -thumbnail 400x250 \
	-bordercolor white  -border 6 \
	-bordercolor grey60 -border 1 \
	-background  none   -rotate `convert null: -format '%[fx:rand()*20-10]' info:` \
	-background  black  \( +clone -shadow 60x6+4+4 \) +swap \
	-background  none   -flatten $2
}

randx() {
	local max=$1
	local y=0
	local delta=$2

	while [ $y -le $max ]
	do
	  y=$RANDOM
	  let "y %= max+delta"  # Scales $x down within $RANGE.
	done
	echo $y
}

# get x,y coordinats for the 3 pics
# if the offsets would be totally random, tha pic overlap would be too high.
# it didn't look good. that's why the fixed offsets
for x in 50 150 300 
do
	cx+=($(randx $x 50))
done

for x in 30 250 30 
do
	cy+=($(randx $x 50))
done

echo "cx: "${cx[*]}
echo "cy: "${cy[*]}

if [ $# -eq 0 ] 
then
	help
	error "too less parameters"
fi

# create the thumbs files. get params from the calling script
cnt=1
while [ $# -ne 0 ]; do
  if [ -a $1  ]
  then
	thumb=$1
	createThumb "$thumb" "$DTMP/pic$cnt.png"
	let "cnt += 1"
  fi
  shift
done

# IMO more than 3 pics don't look good. 
convert $background \
	-draw "image over "${cx[0]}","${cy[0]}" 0,0 '$DTMP/pic1.png'" \
	-draw "image over "${cx[1]}","${cy[1]}" 0,0 '$DTMP/pic2.png'" \
	-draw "image over "${cx[2]}","${cy[2]}" 0,0 '$DTMP/pic3.png" $result

if [ ${#OPENRESULT} -ne 0 ]
then
	open $OPENRESULT
fi

