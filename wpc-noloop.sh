#! /bin/bash
#
# This file uses 1920x1080 background file and adds 3 pictures and a calendar to it. 
# Pictures have to be inside a ./pics directory. 

# This is exactly the same file as wpc-loop.sh except it's only executed once. 
# This is super ugly but I'm fed up with bash scripting. 
# A Rewrite in a different language is needed !!

ARG0=$(basename $0 .sh)
ARG0DIR=$(dirname $0)
[ $ARG0DIR == "." ] && ARG0DIR=$PWD 

source $ARG0DIR/global

#Time in seconds to wait between background switches
wait=3600

#for testing just use 10 seconds
#wait=10

help() {
	usage
	echo
	echo Options: are passed through to the sub-scripts
	echo
	echo $'\t'-v .. Version
	echo $'\t'-h .. Help
	echo
	echo $'\t' use: ./wpc.sh -h $'\t' .. to get help about \"calendar\" creation 	
	echo $'\t' use: ./wpc-note.sh -h $'\t' .. to get help about \"sticky note\" creation 	
	echo $'\t' use: ./wpc-pic.sh -h $'\t' .. to get help about \"picture stack\" creation 	
	echo $'\t' use: ./wpc-caltext.sh -h $'\t' .. to get help about \"calendar text to png\" creation 	
	
	exit 0;
}

# TODO It should be possible to use ./wpc-loop.sh with parameters
# At the moment this interferes with the other scripts. 

#list of files
pics="$DPICS/pics.list"

#reload picture list
touch $pics
rm $pics
find $DPICS -iregex '.*\(.jpg\|.png\|.jpeg\)' > $pics

getPic() {
	local pfile=$1
	local max=$(cat $pfile | wc -l )

    #get a random line number
    local lineNum=$RANDOM
    let "lineNum %= max"

    #get a random picture from the list
    local pic=`sed $lineNum'q;d' $pfile`
	echo $pic
}

result=$RESULT

#while [ true ]
#do
	# create a text calendar .png file
	# if parameter -S is active, the calendar will be printed on a sitcky note
	#./wpc.sh -S
    "$ARG0DIR/wpc.sh" $*

	# TODO have different picture directories with unique pics
	# atm 2 or 3 pics can be the same. It's better the more pics are there.
    pic1=$(getPic $pics)
    pic2=$(getPic $pics)
    pic3=$(getPic $pics)

    echo $pic1 $pic2 $pic3
    "$ARG0DIR/wpc-pic.sh" $pic1 $pic2 $pic3

    gsettings set org.gnome.desktop.background picture-uri "file://"$RESULT

#    sleep $wait
#done
