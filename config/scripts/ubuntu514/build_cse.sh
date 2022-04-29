#!/usr/bin/env bash
set -ex
BUILD_NUMBER="${BUILD_NUMBER:-1}"
LINUX_HEADERS_VERSION="linux-headers-5.14.0-1008-oem"
GFX_ASSETS_NO_PROXY="gfx-assets-build.intel.com DIRECT" 
KWPREFIXKDIF=
KWPREFIXDKMCS=
if [ "$KLOCWORK" == "1" ]; then
  KWPREFIXKDIF="/kw/agent/bin/kwinject --output /kw/kwbuildspec/${KW_PROJECT_BRANCH}/all_vars1.out"
  KWPREFIXDKMS="/kw/agent/bin/kwinject --output /kw/kwbuildspec/${KW_PROJECT_BRANCH}/all_vars2.out"
fi

sudo apt-get -o Acquire::http::proxy="$GFX_ASSETS_NO_PROXY" update
sudo apt-get -o Acquire::http::proxy="$GFX_ASSETS_NO_PROXY" install $LINUX_HEADERS_VERSION -y
MODULES_DIR="/usr/src/$LINUX_HEADERS_VERSION"
(
cd $PRODUCT_DIR
$KWPREFIXKDIF make KDIR="$MODULES_DIR"
)

(
cd $PRODUCT_DIR
$KWPREFIXDKMS make -f Makefile.dkms BUILD_VERSION="$BUILD_NUMBER" dkmsdeb-pkg
)

if [ "$KLOCWORK" == "1" ]; then
  python3 /kw/scripts/SupportScripts/kw_wrapper.py \
  /kw/agent/bin/kwbuildproject --jobs-num auto \
  --verbose --url $KW_URL/$KW_PROJECT_BRANCH \
  --license-host $KW_LIC_HOST --license-port $KW_LIC_PORT \
  --tables-directory /kw/kwtables/$KW_PROJECT_BRANCH \
  --replace-path /opt/src/=/ \
  /kw/kwbuildspec/$KW_PROJECT_BRANCH/all_vars1.out \
  /kw/kwbuildspec/$KW_PROJECT_BRANCH/all_vars2.out

  python3 /kw/scripts/SupportScripts/kw_wrapper.py \
  /kw/agent/bin/kwadmin --ssl --url $KW_URL load $KW_PROJECT_BRANCH \
  /kw/kwtables/$KW_PROJECT_BRANCH --name $BUILD_VERSION
  
  python3 /kw/scripts/ReportScripts/generate_report.py \
  --klocworkApiUrl $KW_URL/review/api \
  --klocworkBaseUrl $KW_URL/review/insight-review.html \
  --jsonFilePath /kw/scripts/config/$COMPONENT_PROJECT/$COMPONENT_BRANCH/kw_linux_projects.json \
  --outputHtmlFileName /kw/report/klocwork_report \
  --reportArchitecture 64-bit \
  --outputDetailsJsonFile /kw/report/projectData.json \
  --outputSummaryJsonFile /kw/report/summaryData.json \
  --changes $GIT_REVISION \
  --buildVersion $BUILD_VERSION \
  --system $SYSTEM
fi

mkdir -p output/cse
cp $PRODUCT_DIR/*.deb output/cse/
