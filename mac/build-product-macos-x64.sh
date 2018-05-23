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
    echo "        name of the product distributions"
    echo "    -t (--title)"
    echo "        title of the product distributions"
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

if [ -z "$DIST_PATH" ]; then
    echo "Please enter the path of the product packs"
    printUsage
    exit 1
fi

if [ -z "$PRODUCT" ]; then
    echo "Please enter the name of the product packs"
    printUsage
    exit 1
fi

if [ -z "$TITLE" ]; then
    echo "Please enter the title of the product packs"
    printUsage
    exit 1
fi


PRODUCT_DISTRIBUTION_LOCATION=${DIST_PATH}
PRODUCT_DIRECTORY=${PRODUCT}-${PRODUCT_VERSION}

echo "Build started at" $(date +"%Y-%m-%d %H:%M:%S")

function deleteTargetDirectory() {
    echo "Deleting target directory"
    rm -rf target
}

function extractPack() {
    echo "Extracting the PRODUCT distribution, " $1
    rm -rf target/original
    mkdir -p target/original
    unzip $1 -d target/original > /dev/null 2>&1
    mv target/original/__MACOSX/$2 target/original/${PRODUCT_DIRECTORY}
    rm -rf target/original/__MACOSX
}

function createPackInstallationDirectory() {
    rm -rf target/darwin
    cp -r darwin target/darwin

    sed -i -e 's/__PRODUCT_VERSION__/'${PRODUCT_VERSION}'/g' target/darwin/scripts/postinstall
    sed -i -e 's/__PRODUCT__/'${PRODUCT}'/g' target/darwin/scripts/postinstall
    sed -i -e 's/__TITLE__/'${TITLE}'/g' target/darwin/scripts/postinstall
    chmod -R 755 target/darwin/scripts/postinstall

    sed -i -e 's/__PRODUCT_VERSION__/'${PRODUCT_VERSION}'/g' target/darwin/Distribution
    sed -i -e 's/__PRODUCT__/'${PRODUCT}'/g' target/darwin/Distribution
    sed -i -e 's/__TITLE__/'${TITLE}'/g' target/darwin/Distribution
    chmod -R 755 target/darwin/Distribution

    rm -rf target/darwinpkg
    mkdir -p target/darwinpkg
    chmod -R 755 target/darwinpkg

    mkdir -p target/darwinpkg/Library/WSO2/$TITLE/$PRODUCT_VERSION
    mv target/original/${PRODUCT_DIRECTORY}/* target/darwinpkg/Library/WSO2/$TITLE/$PRODUCT_VERSION
    chmod -R 755 target/darwinpkg/Library/WSO2/$TITLE/$PRODUCT_VERSION

    rm -rf target/package
    mkdir -p target/package
    chmod -R 755 target/package

    mkdir -p target/pkg
    chmod -R 755 target/pkg
}

function buildPackage() {
    pkgbuild --identifier org.${PRODUCT}.${PRODUCT_VERSION} \
    --version ${PRODUCT_VERSION} \
    --scripts target/darwin/scripts \
    --root target/darwinpkg \
    target/package/$PRODUCT.pkg > /dev/null 2>&1
}

function buildProduct() {
    productbuild --distribution target/darwin/Distribution \
    --resources target/darwin/Resources \
    --package-path target/package \
    target/pkg/$1 > /dev/null 2>&1
}

function signProduct() {
    mkdir -p target/pkg-signed
    chmod -R 755 target/pkg-signed

    productsign --sign "Developer ID Installer: WSO2, Inc. (QH8DVR4443)" \
    target/pkg/$1 \
    target/pkg-signed/$1

    pkgutil --check-signature target/pkg-signed/$1
}

function createInstaller() {
    echo "Creating PRODUCT platform installer"
    extractPack "$PRODUCT_DISTRIBUTION_LOCATION/$PRODUCT-$PRODUCT_VERSION.zip" ${PRODUCT_DIRECTORY}
    createPackInstallationDirectory
    buildPackage
    buildProduct $PRODUCT-$PRODUCT_VERSION-macos-installer-x64.pkg
    signProduct $PRODUCT-$PRODUCT_VERSION-macos-installer-x64.pkg
}

deleteTargetDirectory
createInstaller

echo "Build completed at" $(date +"%Y-%m-%d %H:%M:%S")
