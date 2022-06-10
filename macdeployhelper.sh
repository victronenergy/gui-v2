#!/bin/sh

# macdeployhelper.sh - ease creation of deployment artifacts for MacOSX.

# modify the following variables to match your system's build kit settings
QT_LIBS_BIN_DIR=~/Qt/6.2.1/macos/bin

# modify the following variable to point to the build output directory
BUILD_OUT_DIR=../build-gui-v2-Qt_6_2_1_for_macOS-Release

# don't modify anything below
EXE_NAME=venus-gui-v2
PATH=$QT_LIBS_BIN_DIR:$PATH
APP_BUNDLE_DIR=$BUILD_OUT_DIR/bin/venus-gui-v2.app
DEPLOYMENT_DIR=$APP_BUNDLE_DIR/Contents/MacOS/
DHQML=$DEPLOYMENT_DIR/MacDeployHelper.qml
DHQMLDIR=$DEPLOYMENT_DIR/qmldir

echo import QtQml > $DHQML
echo import QtQuick >> $DHQML
echo import QtQuick.Window >> $DHQML
echo import QtQuick.Controls >> $DHQML
echo import QtQuick.Layouts >> $DHQML
echo import QtQuick.VirtualKeyboard >> $DHQML
echo >> $DHQML
echo Item { } >> $DHQML
echo >> $DHQML

echo module DeployHelper > $DHQMLDIR
echo MacDeployHelper 1.0 MacDeployHelper.qml >> $DHQMLDIR

$QT_LIBS_BIN_DIR/macdeployqt $APP_BUNDLE_DIR -qmldir=$DEPLOYMENT_DIR

rm $DHQML
rm $DHQMLDIR

