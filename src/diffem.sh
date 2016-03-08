OUTFILE=diffout.txt
OUTFILEGOLD=diffout\ -\ gold.txt
GOLDDIR=../Gold\ Files/
GOLDNC=\ -\ gold.nc
declare -a sarr
shopt -s nullglob
sarr=(*.nc)

echo "" > $OUTFILE


for n in "${sarr[@]}"
do
    # create temp files form the two files being compared that
    # have all the content except the first 10 lines, which will always
    # have differences
    cat "$n".nc | tail -n+10 > tmp.nc
    cat "$GOLDDIR""$n""$GOLDNC" | tail -n+10 > tmp1.nc
    echo "diffing .. ""$n".nc "$GOLDDIR""$n""$GOLDNC" >> $OUTFILE
    echo "" >> $OUTFILE
    diff tmp.nc tmp1.nc >> $OUTFILE
done

rm -f tmp.nc
rm -f tmp1.nc

diff $OUTFILE "$GOLDDIR""$OUTFILEGOLD" > tmp

#echo $(stat -f%z tmp)
TMPSIZE=$(stat -f%z tmp)
ZERO='0'
red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
blue='\e[1;34m%s\e[0m\n'

if [ $TMPSIZE -eq 0 ]; then
    printf $green "..GOOD!"
else 
    printf $red "BAD __ BAD __ BAD!"
    echo ""
    echo $TMPSIZE
    echo ""
    cat $OUTFILE
    echo "Copy up all files to gold y/n?"
    read rply
    if [ $rply == y ]; then
        for n in "${sarr[@]}"
        do
            printf $blue "upload to gold" "$n".nc
            cp -f "$n".nc "$GOLDDIR""$n""$GOLDNC"
        done
        printf $blue "upload to gold" $OUTFILE
        cp -f $OUTFILE "$GOLDDIR""$OUTFILEGOLD"
    else
        printf $blue "upload cancelled"
    fi
fi
rm -f tmp
