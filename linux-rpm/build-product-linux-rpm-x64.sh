#!/bin/bash

function printUsage() {
    echo "Usage:"
    echo "$0 [options]"
    echo "options:"
    echo "    -v (--version)"
    echo "        version of the product distribution"
    echo "    -p (--path)"
    echo "        path of the product distributions"
    echo "    -n (--name)"
    echo "        name of the product distribution"
    echo "    -t (--title)"
    echo "        title of the product distribution"
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
    PROD_PATH="$2"
    shift # past argument
    shift # past value
    ;;
    -n|--name)
    PRODUCT="$2"
    shift # past argument
    shift # past value
    ;;
    -t|--title)
    TITLE="$2"
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

if [ -z "$PROD_PATH" ]; then
    echo "Please enter the path of the product packs"
    printUsage
    exit 1
fi

if [ -z "$PRODUCT" ]; then
    echo "Please enter the name of the product."
    printUsage
    exit 1
fi

if [ -z "$TITLE" ]; then
    echo "Please enter the title of the product."
    printUsage
    exit 1
fi


PRODUCT_DISTRIBUTION_LOCATION=${PROD_PATH}
PRODUCT_NAME=${PRODUCT}-${PRODUCT_VERSION}
SPEC_FILE="installer.spec"
SPEC_DIRECTORY="rpmbuild/SPECS/"
SPEC_FILE_LOC=${SPEC_DIRECTORY}/${SPEC_FILE}
RPM_PRODUCT_VERSION=$(echo "${PRODUCT_VERSION//-/.}")

echo "Build started at" $(date +"%Y-%m-%d %H:%M:%S")

function extractPack() {
    echo "Extracting the PRODUCT distribution, " $1
    rm -rf rpmbuild/SOURCES
    mkdir -p rpmbuild/SOURCES
    unzip $1 -d rpmbuild/SOURCES/ > /dev/null 2>&1
    echo "Extracting completed!, " $1
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
    sed -i "/%define _title__/c\%define _title__ ${TITLE}" ${SPEC_FILE_LOC}
    sed -i "/%define _product__/c\%define _product__ ${PRODUCT}" ${SPEC_FILE_LOC}
    sed -i "/%define _product_name/c\%define _product_name ${PRODUCT}-${PRODUCT_VERSION}" ${SPEC_FILE_LOC}
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
    extractPack "$PRODUCT_DISTRIBUTION_LOCATION/$PRODUCT_NAME.zip"
    [ -f ${SPEC_FILE_LOC} ] && rm -f ${SPEC_FILE_LOC}
    cp resources/${SPEC_FILE} ${SPEC_DIRECTORY}
    setupInstaller
    rpmbuild -bb --define "_topdir  $(pwd)/rpmbuild" ${SPEC_FILE_LOC}
}


createInstaller

echo "Build completed at" $(date +"%Y-%m-%d %H:%M:%S")
