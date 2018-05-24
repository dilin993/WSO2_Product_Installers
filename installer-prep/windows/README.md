# Product Pack Preperation for Windows

1) Download product pack (zip) and extract
2) Download jre and extract
3) Make a directory `jre` inside extracted product pack and copy extracted jre there
4) Create a <product name>-<product version>.bat in bin folder with following content

`
if "%JAVA_HOME%"=="" set JAVA_HOME=%~sdp0..\jre\jre1.8.0_171
%~sdp0wso2server.bat
`
* Note: Replace `jre1.8.0_171` with your extracted jre version