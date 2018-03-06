#!/bin/bash
#
# Test the JMeter Docker image using a trivial test plan.

TESTMODE=${TESTMODE:-api}
T_DIR=${JMETER_HOME}/testfiles/MPG-Backend
RESULT_BUCKET=${RESULT_BUCKET:-mpg-test-result}
RESULT_PATH_PREFIX=${RESULT_PATH_PREFIX:-/Backend_API_Test}
DATETIME=`date '+%Y-%m-%d_%H-%M-%S'`
TEST_FILE_URL=${TEST_FILE_URL:-https://s3-ap-northeast-1.amazonaws.com/mpg-test-result/Backend_Test.jmx}
RESULT_URL=${RESULT_URL:-https://s3-ap-northeast-1.amazonaws.com/${RESULT_BUCKET}${RESULT_PATH_PREFIX}/${DATETIME}/index.html}
MESSAGE=${MESSAGE:-See test report at __RESULT_URL__}
PAYLOAD=`echo "${MESSAGE/__RESULT_URL__/$RESULT_URL}" | python build_payload.py`

# Reporting dir: start fresh
R_DIR=${T_DIR}/report
rm -rf ${R_DIR} > /dev/null 2>&1
mkdir -p ${R_DIR}
mkdir -p ${T_DIR}
curl -sSL -o ${T_DIR}/Backend_Test.jmx ${TEST_FILE_URL} > /dev/null 2>&1

/bin/rm -f ${T_DIR}/Backend_Test.jtl ${T_DIR}/jmeter.log  > /dev/null 2>&1

jmeter  -n -t ${T_DIR}/Backend_Test.jmx -l ${T_DIR}/Backend_Test.jtl -j ${T_DIR}/jmeter.log \
	-e -o ${R_DIR}

if [ $TESTMODE = 'pagespeed' ]; then
  PAYLOAD=`python transform_csv_result.py result.csv | python build_payload.py`

echo "==== jmeter.log ===="
cat ${T_DIR}/jmeter.log

echo "==== Raw Test Report ===="
cat ${T_DIR}/Backend_Test.jtl

echo "==== HTML Test Report ===="
echo "See HTML test report in ${R_DIR}/index.html"
aws s3 cp --recursive ${R_DIR} s3://${RESULT_BUCKET}${RESULT_PATH_PREFIX}/${DATETIME}
aws s3 cp result.csv s3://${RESULT_BUCKET}${RESULT_PATH_PREFIX}/${DATETIME}/result.csv
aws lambda invoke --invocation-type Event --function-name CodePipelineNotification --region ap-northeast-1 --log-type None --payload "${PAYLOAD}" outputfile.txt
