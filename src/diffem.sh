OUTFILE=diffout.txt
OUTFILEGOLD=diffout\ -\ gold.txt
GOLDDIR=../Gold\ Files/
GOLDNC=\ -\ gold.nc
declare -a sarr=("test Part 1" "Internal test part" "loopTest" "warnings Test" "PureGangToolingTest" "mill Turning Test" "millLathingError")

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
    else
        printf $blue "upload cancelled"
    fi
fi
rm -f tmp

# for n in "${sarr[@]}"
# do
#     cat "$n".nc | head + 10 > tmp.c
#     cat "$GOLDDIR""$n""$GOLDNC" | head + 10 > tmp1.c
#     echo "diffing .. ""$n".nc "$GOLDDIR""$n""$GOLDNC" >> $OUTFILE
#     echo "" >> $OUTFILE
#     diff "$n".nc "$GOLDDIR""$n""$GOLDNC" >> $OUTFILE
# done

# INFILE=test\ Part\ 1
# echo "diffing .. "$INFILE >> $OUTFILE
# echo "" >> $OUTFILE
# diff "$INFILE.nc" "$GOLDDIR$INFILE$GOLDNC" >> $OUTFILE
# 
# INFILE=Internal\ test\ part
# echo "" >> $OUTFILE
# echo "diffing .. Internal test part" >> $OUTFILE
# echo "" >> $OUTFILE
# diff "$INFILE.nc" "$GOLDDIR$INFILE$GOLDNC" >> $OUTFILE
# 
# INFILE=loopTest
# echo "" >> $OUTFILE
# echo "diffing .. loopTest" >> $OUTFILE
# echo "" >> $OUTFILE
# diff "$INFILE.nc" "$GOLDDIR$INFILE$GOLDNC" >> $OUTFILE
# 
# INFILE=warnings\ Test
# echo "" >> $OUTFILE
# echo "diffing .. warnings Test" >> $OUTFILE
# echo "" >> $OUTFILE
# diff "$INFILE.nc" "$GOLDDIR$INFILE$GOLDNC" >> $OUTFILE
# 
# INFILE=PureGangToolingTest
# echo "" >> $OUTFILE
# echo "diffing .. PureGangToolingTest" >> $OUTFILE
# echo "" >> $OUTFILEdiff PureGangToolingTest.nc ../Gold\ Files/PureGangToolingTest\ -\ gold.nc >> $OUTFILE
# diff "$INFILE.nc" "$GOLDDIR$INFILE$GOLDNC" >> $OUTFILE
# 
# INFILE=mill\ Turning\ Test
# echo "" >> $OUTFILE
# echo "diffing .. mill Turning Test" >> $OUTFILE
# echo "" >> $OUTFILE
# diff "$INFILE.nc" "$GOLDDIR$INFILE$GOLDNC" >> $OUTFILE
# 
# INFILE=millLathingError
# echo "" >> $OUTFILE
# echo "diffing .. millLathingError" >> $OUTFILE
# echo "" >> $OUTFILE
# diff "$INFILE.nc" "$GOLDDIR$INFILE$GOLDNC" >> $OUTFILE


