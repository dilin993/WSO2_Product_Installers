# Product Pack Preperation for Mac

1) Download and extract product pack
2) Download and prepare jre as in `https://www.ihash.eu/2015/11/how-to-install-java-jre-8-on-mac-os-x-10-11-el-capitan/`
3) Make a directory jre inside product pack and move the prepared jre there
4) Add a line in `wso2server.sh` (after `CARBON_HOME` is loaded) to load included jre as follows

```
[-z "$JAVA_HOME"] && JAVA_HOME="$CARBON_HOME/jre1.8.0_171.jre/Contents/Home"
```

* Note: Replace `jre1.8.0_171.jre` with your jre name