#!/bin/bash
rm -f /media/files/Temp/princess_journey.apk
flutter build apk --target-platform android-arm
cp ./build/app/outputs/apk/release/app-release.apk /run/user/1000/gvfs/dav:host=files.ninico.fr,ssl=true/Temp/princess_journey.apk
