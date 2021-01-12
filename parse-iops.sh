!/bin/bash
# Copied from https://github.com/thecodeassassin/diskbench

ROOT_PATH="results"
TOTAL_WRITE=0
TOTAL_READ=0
TOTAL_READ_BAND=0
TOTAL_WRITE_BAND=0
NUM_PASS=0

for runset in `ls -1 $ROOT_PATH/`;
do
  FILE_PATH="${ROOT_PATH}/${runset}"
  for pass in `ls -1 $FILE_PATH/fio-* | awk -F'pass-' {'print \$2'} | uniq | sort | uniq`;
  do
    for file in `ls -1 $FILE_PATH/fio-*-$pass`;
    do
      cat $FILE_PATH/NAME > /dev/null
      JOB=`head -n 1 ${file} | awk -F: {'print \$1'}`
      READ_IOPS=`grep iops ${file}| grep read | awk -F'iops=' {'print \$2'} | awk {'print \$1'}`
      WRITE_IOPS=`grep iops ${file}| grep write | awk -F'iops=' {'print \$2'} | awk {'print \$1'}`
      READ_BANDWIDTH=`grep READ ${file} | awk -F'maxb=' {'print \$2'} | awk -F, {'print \$1'} | grep -o '[0-9]\{1,\}'`
      WRITE_BANDWIDTH=`grep WRITE ${file} | awk -F'maxb=' {'print \$2'} | awk -F, {'print \$1'} | grep -o '[0-9]\{1,\}'`

      if [ ${READ_IOPS} > 0 ] ; then
         TOTAL_READ=$(($READ_IOPS + ${TOTAL_READ}))
         TOTAL_READ_BAND=$(($READ_BANDWIDTH + ${TOTAL_READ_BAND}))
      fi

      if [ ${WRITE_IOPS} > 0 ] ; then
         TOTAL_WRITE=$(($WRITE_IOPS + ${TOTAL_WRITE}))
         TOTAL_WRITE_BAND=$(($WRITE_BANDWIDTH + ${TOTAL_WRITE_BAND}))
      fi

      # add one pass
      if [ ${READ_IOPS} > 0 ] || [ ${WRITE_IOPS} > 0 ]; then
        NUM_PASS=$(($NUM_PASS + 1))
      fi
    done
  done
done

echo "Total valid passes: ${NUM_PASS}"

echo "----------------------------------------------------------------"
echo "Total read IOPS: ${TOTAL_READ}"
echo "Total write IOPS: ${TOTAL_WRITE}"

echo "----------------------------------------------------------------"
echo "Average read bandwidth:  $((${TOTAL_READ_BAND} / ${NUM_PASS} / 1000)) Mb/sec"
echo "Average write bandwidth:  $((${TOTAL_WRITE_BAND} / ${NUM_PASS} / 1000)) Mb/sec"

echo "----------------------------------------------------------------"
echo "Average read IOPS: $((${TOTAL_READ} / ${NUM_PASS}))"
echo "Average write IOPS: $((${TOTAL_WRITE} / ${NUM_PASS}))"
echo "----------------------------------------------------------------"