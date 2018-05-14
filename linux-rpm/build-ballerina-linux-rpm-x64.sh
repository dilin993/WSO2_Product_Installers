#!/bin/bash
PRODUCT="wso2am"

function printUsage() {
    echo "Usage:"
    echo "$0 [options]"
    echo "options:"
    echo "    -v (--version)"
    echo "        version of the product distribution"
    echo "    -p (--path)"
    echo "        path of the product distributions"
    # echo "    -d (--dist)"
    # echo "        PRODUCT distribution type either of the followings"
    # echo "        If not specified both distributions will be built"
    # echo "        1. PRODUCT-platform"
    # echo "        2. PRODUCT-runtime"
    # echo "eg: $0 -v 1.0.0 -p /home/username/Packs"
    # echo "eg: $0 -v 1.0.0 -p /home/username/Packs -d PRODUCT-platform"
}

BUILD_ALL_DISTRIBUTIONS=false
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case ${key} in
    -v|--version)
    PRODUCT_VERSION="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--path)
    DIST_PATH="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--dist)
    DISTRIBUTION="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

if [ -z "$PRODUCT_VERSION" ]; then
    echo "Please enter the version of the product pack"
    printUsage
    exit 1
fi

if [ -z "$DIST_PATH" ]; then
    echo "Please enter the path of the product packs"
    printUsage
    exit 1
fi

# if [ -z "$DISTRIBUTION" ]; then
#     BUILD_ALL_DISTRIBUTIONS=true
# fi




PRODUCT_DISTRIBUTION_LOCATION=${DIST_PATH}
PRODUCT_INSTALL_DIRECTORY=${PRODUCT}-${PRODUCT_VERSION}
SPEC_FILE="installer.spec"
SPEC_FILE_LOCATION="rpmbuild/SPECS/"
SPEC_FILE_LOC=${SPEC_FILE_LOCATION}/${SPEC_FILE}
RPM_PRODUCT_VERSION=$(echo "${PRODUCT_VERSION//-/.}")

echo "Build started at" $(date +"%Y-%m-%d %H:%M:%S")

function extractPack() {
    echo "Extracting the PRODUCT distribution, " $1
    rm -rf rpmbuild/SOURCES
    mkdir -p rpmbuild/SOURCES
    unzip $1 -d rpmbuild/SOURCES/ > /dev/null 2>&1
}

# Set variables in SPEC file
# Globals:
#   PRODUCT_VERSION
#   RPM_PRODUCT_VERSION
#   SPEC_FILE
# Arguments:
# Returns:
#   None
function setupInstaller() {
    sed -i "/Version:/c\Version:        ${RPM_PRODUCT_VERSION}" ${SPEC_FILE_LOC}
    sed -i "/%define _product_version/c\%define _product_version ${PRODUCT_VERSION}" ${SPEC_FILE_LOC}
    sed -i "/%define _PRODUCT_tools_dir/c\%define _PRODUCT_tools_dir ${PRODUCT_RUNTIME}" ${SPEC_FILE_LOC}
    sed -i "s/export PRODUCT_HOME=/export PRODUCT_HOME=\/usr\/lib64\/PRODUCT\/PRODUCT-runtime-${PRODUCT_VERSION}/" ${SPEC_FILE_LOC}
    sed -i "s?SED_PRODUCT_HOME?/usr/lib64/PRODUCT/PRODUCT-runtime-${PRODUCT_VERSION}?" ${SPEC_FILE_LOC}
}

# Set variables in SPEC file
# Globals:
#   PRODUCT_VERSION
#   RPM_PRODUCT_VERSION
#   PLATFORM_SPEC_FILE
# Arguments:
# Returns:
#   None

function createInstaller() {
    echo "Creating PRODUCT platform installer"
    extractPack "$PRODUCT_DISTRIBUTION_LOCATION/$PRODUCT_PLATFORM.zip"
    [ -f ${PLATFORM_SPEC_FILE_LOC} ] && rm -f ${PLATFORM_SPEC_FILE_LOC}
    cp resources/${PLATFORM_SPEC_FILE} ${SPEC_FILE_LOCATION}
    setupInstaller
    rpmbuild -bb --define "_topdir  $(pwd)/rpmbuild" ${PLATFORM_SPEC_FILE_LOC}

}


createInstaller

echo "Build completed at" $(date +"%Y-%m-%d %H:%M:%S")
