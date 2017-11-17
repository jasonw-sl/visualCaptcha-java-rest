IF EXIST sealights.json del /q sealights.json
IF EXIST sealights-config.properties del /q sealights-config.properties

where /q mvn || ECHO Could not find the Maven (mvn) executable && EXIT /B 1
if not exist sltoken.txt echo Please download a token (sltoken.txt) from the SeaLights dashboard and place it here && EXIT /B 1

echo Building application
call mvn clean install  -Dmaven.test.failure.ignore=true

echo Installing SeaLights Node.JS agent
call npm i slnodejs
echo Creating a session ID
call .\node_modules\.bin\slnodejs config --tokenfile sltoken.txt --appname "visualCaptcha-JS" --branch "origin/master" --build "%DATE% %RANDOM%"
copy buildSessionId buildSessionId.txt /y
echo Instrumenting the JS files
call .\node_modules\.bin\slnodejs build --tokenfile sltoken.txt --buildsessionidfile buildSessionId --resolveWithoutHash --instrumentForBrowsers --outputpath js_browser --workspacepath src\main\webapp --scm git
echo Replacing the original JS files with the instrumented files
rename src\main\webapp webapp_bak
mkdir src\main\webapp
xcopy /E /Y js_browser\* src\main\webapp

echo Starting the server
START mvn -Dmaven.test.failure.ignore=true spring-boot:run

echo Sleeping for 20 seconds to allow server to come up
ping 127.0.0.1 -n 40 > nul

echo Running the tests
call mvn -Dmaven.test.failure.ignore=true test -PseleniumTests -f pom_sl.xml

echo Restoring the original JS files
rmdir /s /q src\main\webapp
rename src\main\webapp_bak webapp

echo All done, You can close the server now.
echo Go to the dashboard to see the results.
