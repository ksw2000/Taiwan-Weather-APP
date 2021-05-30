@echo off

echo build web app...
cmd /c flutter build web --web-renderer html
echo build Android APP...
cmd /c flutter build apk
echo copy build\web to docs\
copy build\web\favicon.png docs\favicon.png
copy build\web\flutter_service_worker.js docs\flutter_service_worker.js
copy build\web\index.html docs\index.html
copy build\web\main.dart.js docs\main.dart.js
copy build\web\main.exe docs\main.exe
xcopy build\web\icons\ docs\icons\ /Y
