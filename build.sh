#!/bin/bash
rm -f /media/files/Temp/princess_journey.apk
flutter build apk --target-platform android-arm
cp ./build/app/outputs/apk/release/app-release.apk /media/files/Temp/princess_journey.apk
