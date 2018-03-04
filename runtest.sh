#!/bin/bash
#
# Test the JMeter Docker image using a trivial test plan.


T_DIR=${JMETER_HOME}/testfiles/MPG-Backend
RESULT_BUCKET=mpg-test-result
DATETIME=`date '+%Y-%m-%d_%H-%M-%S'`
TEST_FILE_URL=https://s3-ap-northeast-1.amazonaws.com/mpg-test-result/Backend_Test.jmx
RESULT_URL=https://s3-ap-northeast-1.amazonaws.com/mpg-test-result/Backend_API_Test/${DATETIME}/index.html
PAYLOAD=`echo "See test report at ${RESULT_URL}" | python build_payload.py`

# Reporting dir: start fresh
R_DIR=${T_DIR}/report
rm -rf ${R_DIR} > /dev/null 2>&1
mkdir -p ${R_DIR}
mkdir -p ${T_DIR}
curl -sSL -o ${T_DIR}/Backend_Test.jmx ${TEST_FILE_URL} > /dev/null 2>&1

/bin/rm -f ${T_DIR}/Backend_Test.jtl ${T_DIR}/jmeter.log  > /dev/null 2>&1

jmeter  -n -t ${T_DIR}/Backend_Test.jmx -l ${T_DIR}/Backend_Test.jtl -j ${T_DIR}/jmeter.log \
	-e -o ${R_DIR}

echo "==== jmeter.log ===="
cat ${T_DIR}/jmeter.log

echo "==== Raw Test Report ===="
cat ${T_DIR}/Backend_Test.jtl

echo "==== HTML Test Report ===="
echo "See HTML test report in ${R_DIR}/index.html"
aws s3 cp --recursive ${R_DIR} s3://${RESULT_BUCKET}/Backend_API_Test/${DATETIME}
aws lambda invoke --invocation-type Event --function-name CodePipelineNotification --region ap-northeast-1 --log-type None --payload '${PAYLOAD}'
