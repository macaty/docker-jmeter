#!/bin/bash
#
# Test the JMeter Docker image using a trivial test plan.


T_DIR=${JMETER_HOME}/testfiles/MPG-Backend

# Reporting dir: start fresh
R_DIR=${T_DIR}/report
rm -rf ${R_DIR} > /dev/null 2>&1
mkdir -p ${R_DIR}

/bin/rm -f ${T_DIR}/Backend_Test.jtl ${T_DIR}/jmeter.log  > /dev/null 2>&1

jmeter  -n -t ${T_DIR}/Backend_Test.jmx -l ${T_DIR}/Backend_Test.jtl -j ${T_DIR}/jmeter.log \
	-e -o ${R_DIR}

echo "==== jmeter.log ===="
cat ${T_DIR}/jmeter.log

echo "==== Raw Test Report ===="
cat ${T_DIR}/Backend_Test.jtl

echo "==== HTML Test Report ===="
echo "See HTML test report in ${R_DIR}/index.html"
