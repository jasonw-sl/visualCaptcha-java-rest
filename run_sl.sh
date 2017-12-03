#!/bin/bash
{ set +x; } 2>/dev/null

command -v mvn >/dev/null 2>&1 || { echo >&2 "Could not locate mvn, please make sure its in the PATH"; exit 1; }

if [ ! -f sltoken.txt ]; then
  echo "Please download a token (sltoken.txt) from the SeaLights dashboard and place it here"
  exit 1
fi
BUILD_NUMBER=$(date +%Y%m%d%H%M%S)

if [ ! -f chromedriver.linux ]; then
  latest=`curl http://chromedriver.storage.googleapis.com/LATEST_RELEASE`
  version="2.9"
  download_location="http://chromedriver.storage.googleapis.com/$latest/chromedriver_linux64.zip"
  rm /tmp/chromedriver_linux64.zip
  wget -P /tmp $download_location
  unzip /tmp/chromedriver_linux64.zip -d .
  mv ./chromedriver ./chromedriver.linux
  chmod u+x ./chromedriver.linux
fi

# ----- Checking that agents exist, download if not -----
mkdir -p SeaLights
cd SeaLights
if [ ! -f sl-build-scanner.jar ]; then
  if [ -z "${SL_AGENTS_LOCATION}" ]; then
    echo Need to download the SeaLights agents
    echo Please set SL_AGENTS_LOCATION with their location
    exit 1
  fi
  rm -f sealights-java-*.zip *.jar
  wget ${SL_AGENTS_LOCATION}
  unzip sealights-java-*.zip
  mv sl-build-scanner-*.jar sl-build-scanner.jar
  mv sl-test-listener-*.jar sl-test-listener.jar
fi
cd ..

java -jar SeaLights/sl-build-scanner.jar -config -tokenfile sltoken.txt -appname "visualCaptcha" -branchname "master" -buildname "${BUILD_NUMBER}" -pi "com.kuhniverse.*"

mvn -f pom_sl.xml clean install  -Dmaven.test.failure.ignore=true -Psealights_build

nohup mvn -f pom_sl.xml -Dmaven.test.failure.ignore=true spring-boot:run &

sleep 60

mvn -f pom_sl.xml -Dmaven.test.failure.ignore=true test -PseleniumTests

pkill -f server.port=8888
