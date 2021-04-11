# allows to add DEPLOYMENTFOLDERS and links to the Felgo library and QtCreator auto-completion
CONFIG += felgo
CONFIG += c++11

QT += core gui widgets qml

#CONFIG += live_client
#CONFIG += use_resources

QML_IMPORT_PATH += $$PWD/qml

DEFINES += "QML_MODULE_NAME=\\\"Slippipedia\\\""

wasm {
  QMAKE_CXXFLAGS += --emrun
}
else {

}

live_client {
  CONFIG += felgo-live
  DEFINES += FELGO_LIVE
}

use_resources {
  RESOURCES += resources.qrc
}
# do not deploy when using live client, it deploys manually to cache folder
else:!live_client {
  qmlFolder.source = qml
  DEPLOYMENTFOLDERS += qmlFolder

  assetsFolder.source = assets
  DEPLOYMENTFOLDERS += assetsFolder
}

FELGO_PLUGINS += googleanalytics

# Project identifier and version
# More information: https://felgo.com/doc/felgo-publishing/#project-configuration
PRODUCT_IDENTIFIER = at.cb.Slippipedia
PRODUCT_VERSION_NAME = 1.0-RC
PRODUCT_VERSION_CODE = 2

# Optionally set a license key that is used instead of the license key from
# main.qml file (App::licenseKey for your app or GameWindow::licenseKey for your game)
# Only used for local builds and Felgo Cloud Builds (https://felgo.com/cloud-builds)
# Not used if using Felgo Live
PRODUCT_LICENSE_KEY = ""

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
  utils.cpp

HEADERS += \
  utils.h

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    OTHER_FILES += android/AndroidManifest.xml       android/build.gradle
}

ios {
    QMAKE_INFO_PLIST = ios/Project-Info.plist
    OTHER_FILES += $$QMAKE_INFO_PLIST
}

# set application icons for win and macx
win32 {
    RC_ICONS = win/icon.ico
}
macx {
    ICON = macx/app_icon.icns
}

include(slippi/slippi.pri)

# always show qml files in Qt Creator
OTHER_FILES += $$files(qml/**, true)
