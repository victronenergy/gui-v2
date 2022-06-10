# windeployhelper.bat - ease creation of deployment artifacts for Windows.
# the `bin` subdirectory of the BUILD_OUT_DIR will contain the deployment artifacts.
# Run this batch file from a "Developer command prompt for VS 2019".

# modify the following variables to match your system's build kit settings
SET QT_LIBS_BIN_DIR=c:\Development\Qt\6.2.0\msvc2019_64\bin

# modify the following variable to point to the build output directory
SET BUILD_OUT_DIR=%cd%\..\build-gui-v2-Desktop_Qt_6_2_0_MSVC2019_64bit-Release

# don't modify anything below
SET EXE_NAME=venus-gui-v2.exe
SET PATH=%QT_LIBS_BIN_DIR%;%PATH%
SET DEPLOYMENT_DIR=%BUILD_OUT_DIR%\bin
SET DHQML=%DEPLOYMENT_DIR%\WinDeployHelper.qml
SET DHQMLDIR=%DEPLOYMENT_DIR%\qmldir

echo import QtQml > %DHQML%
echo import QtQuick >> %DHQML%
echo import QtQuick.Window >> %DHQML%
echo import QtQuick.Controls >> %DHQML%
echo import QtQuick.Layouts >> %DHQML%
echo import QtQuick.VirtualKeyboard >> %DHQML%
echo= >> %DHQML%
echo Item { } >> %DHQML%
echo= >> %DHQML%

echo module DeployHelper > %DHQMLDIR%
echo WinDeployHelper 1.0 WinDeployHelper.qml >> %DHQMLDIR%

%QT_LIBS_BIN_DIR%\windeployqt.exe --compiler-runtime --qmldir %DEPLOYMENT_DIR% %DEPLOYMENT_DIR%\%EXE_NAME%

del %DHQML%
del %DHQMLDIR%

