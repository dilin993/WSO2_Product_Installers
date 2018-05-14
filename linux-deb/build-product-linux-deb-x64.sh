#!/bin/bash

function printUsage() {
    echo "Usage:"
    echo "$0 [options]"
    echo "options:"
    echo "    -v (--version)"
    echo "        version of the product distribution"
    echo "    -p (--path)"
    echo "        path of the product distribution"
    echo "    -n (--name)"
    echo "        name of the product distribution"
}

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
    -n|--name)
    PRODUCT="$2"
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
    echo "Please enter the version of the product."
    printUsage
    exit 1
fi

if [ -z "$PRODUCT" ]; then
    echo "Please enter the name of the product."
    printUsage
    exit 1
fi

if [ -z "$DIST_PATH" ]; then
    echo "Please enter the path of the product."
    printUsage
    exit 1
fi

PRODUCT_DISTRIBUTION_LOCATION=${DIST_PATH}
echo $PRODUCT_DISTRIBUTION_LOCATION
PRODUCT_NAME=${PRODUCT}-${PRODUCT_VERSION}
echo $PRODUCT_NAME
PRODUCT_INSTALL_DIRECTORY=${PRODUCT}-${PRODUCT_VERSION}
echo $PRODUCT_INSTALL_DIRECTORY

echo "Build started at" $(date +"%Y-%m-%d %H:%M:%S")

function deleteTargetDirectory() {
    echo "Deleting target directory"
    rm -rf target
}

function extractPack() {
    echo "Extracting the ${PRODUCT} distribution, " $1
    rm -rf target/original
    mkdir -p target/original
    unzip $1 -d target/original
}

function createPackInstallationDirectory() {
    rm -rf target/${PRODUCT_INSTALL_DIRECTORY}/opt/${PRODUCT}
    mkdir -p target/${PRODUCT_INSTALL_DIRECTORY}/opt/${PRODUCT}
    mkdir -p target/${PRODUCT_INSTALL_DIRECTORY}/usr/share/${PRODUCT}
    mv target/original/${PRODUCT_INSTALL_DIRECTORY} target/${PRODUCT_INSTALL_DIRECTORY}/opt/${PRODUCT}
    chmod -R o+w target/${PRODUCT_INSTALL_DIRECTORY}/opt/${PRODUCT}
}

function copyDebianDirectory() {
    cp -R resources/DEBIAN target/${PRODUCT_INSTALL_DIRECTORY}/DEBIAN
    chmod -R 755 target/${PRODUCT_INSTALL_DIRECTORY}/DEBIAN
    cp resources/copyright target/${PRODUCT_INSTALL_DIRECTORY}/usr/share/${PRODUCT}
    sed -i -e 's/__PRODUCT_VERSION__/'${PRODUCT_VERSION}'/g' target/${PRODUCT_INSTALL_DIRECTORY}/DEBIAN/postinst
    sed -i -e 's/__PRODUCT__/'${PRODUCT}'/g' target/${PRODUCT_INSTALL_DIRECTORY}/DEBIAN/postinst
    sed -i -e 's/__PRODUCT_VERSION__/'${PRODUCT_VERSION}'/g' target/${PRODUCT_INSTALL_DIRECTORY}/DEBIAN/postrm
    sed -i -e 's/__PRODUCT__/'${PRODUCT}'/g' target/${PRODUCT_INSTALL_DIRECTORY}/DEBIAN/postrm
    sed -i -e 's/__PRODUCT_VERSION__/'${PRODUCT_VERSION}'/g' target/${PRODUCT_INSTALL_DIRECTORY}/DEBIAN/control
    sed -i -e 's/__PRODUCT__/'${PRODUCT}'/g' target/${PRODUCT_INSTALL_DIRECTORY}/DEBIAN/control
}

function createInstaller() {
    echo "Creating ${PRODUCT} platform installer"

    extractPack "$PRODUCT_DISTRIBUTION_LOCATION/$PRODUCT_NAME.zip" ${PRODUCT_NAME}
    createPackInstallationDirectory
    copyDebianDirectory
    mv target/${PRODUCT_INSTALL_DIRECTORY} target/${PRODUCT_NAME}-linux-installer-x64
    dpkg-deb --build target/${PRODUCT_NAME}-linux-installer-x64
}

deleteTargetDirectory
createInstaller
echo "Build completed at" $(date +"%Y-%m-%d %H:%M:%S")