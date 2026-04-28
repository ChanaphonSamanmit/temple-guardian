#!/bin/bash
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
mkdir -p build
~/godot4 --headless --path ~/swarm-game/godot-project --export-release "Android" ~/swarm-game/build/TempleGuardian.apk "$@"
