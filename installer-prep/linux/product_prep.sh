function printUsage() {
    echo "Usage:"
    echo "$0 [options]"
    echo "options:"
    echo "    -v (--version)"
    echo "        version of the product distribution"
    echo "    -p (--path)"
    echo "        path of the working directory"
    echo "    -n (--name)"
    echo "        name of the product distribution"
    echo "    -j (--jre)"
    echo "        name of jre directory"
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case ${key} in
    -v|--version)
    VERSION="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--path)
    WORKING_DIR="$2"
    shift # past argument
    shift # past value
    ;;
    -n|--name)
    PRODUCT="$2"
    shift # past argument
    shift # past value
    ;;
    -j|--jre)
    JRE="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

if [ -z "$VERSION" ]; then
    echo "Please enter the version of the product pack"
    printUsage
    exit 1
fi

if [ -z "$WORKING_DIR" ]; then
    echo "Please enter the path of the working directory"
    printUsage
    exit 1
fi

if [ -z "$PRODUCT" ]; then
    echo "Please enter the name of the product."
    printUsage
    exit 1
fi

if [ -z "$JRE" ]; then
    echo "Please enter the name of the jre directory."
    printUsage
    exit 1
fi

cd $WORKING_DIR

rm -rf $PRODUCT-$VERSION

unzip $PRODUCT-$VERSION.zip

mkdir $PRODUCT-$VERSION/jre

cp -r $JRE $PRODUCT-$VERSION/jre

sed -i "s/AXIS2_HOME=\"\$CARBON_HOME\"/AXIS2_HOME=\"\$CARBON_HOME\"\n\[ -z \"\$JAVA_HOME\" \] \&\& JAVA_HOME=\"\$CARBON_HOME\/jre\/$JRE\"/g" $PRODUCT-$VERSION/bin/wso2server.sh

mkdir $PRODUCT-$VERSION-Pack

zip -r $PRODUCT-$VERSION-Pack/$PRODUCT-$VERSION.zip $PRODUCT-$VERSION
