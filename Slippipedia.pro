# allows to add DEPLOYMENTFOLDERS and links to the Felgo library and QtCreator auto-completion
CONFIG += felgo
CONFIG += c++11

QT += core gui widgets qml

#CONFIG += live_client
CONFIG += use_resources

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
PRODUCT_VERSION_NAME = 1.0-Release
PRODUCT_VERSION_CODE = 4

# Optionally set a license key that is used instead of the license key from
# main.qml file (App::licenseKey for your app or GameWindow::licenseKey for your game)
# Only used for local builds and Felgo Cloud Builds (https://felgo.com/cloud-builds)
# Not used if using Felgo Live
PRODUCT_LICENSE_KEY = "32C3D230409CB58A0A6A9C398C26B37678357C90AE6FC9DA1BBF8EAB41BA002C23130F033CEDF97C790B1E97CDB5D59440B81A0E15FFECF68D413A0F695EB79B9973BD0AF72CDBF8281A2378BF8A51AF38E58D21BC435989956BBD811287CF522B4333D86D567E8F5C2F3D4DB72C980BE4258F693CBB24C7C677504E34D9346A7E24563DE7604BF2E3C205579D4FAE0B29592A6660C29A5840BA1F5D856E75C06DEF2EF5675CCD99AA823FADCC22AEA8C6484CB4C27FB1EA4A1F27F740FC6F871EDA3C4DFDD265C7B8D4C5F63B421D7832FA9A86B9CA45D975A02E5733387FA8F3C380705008331C6800DD6EB2F82ED3864195E56085AFF67AC16AF66DDD7AE93A2EA9D1F0CAD09F7F67183926699B4B47D4FB62D8B0020C21C4C50939F66D72313212ED47B24A4780BE1B03F3C48A1D7D0401922EE7B98FB184E1E005397B16D2C6FBB23026BB13D530EB94BF2C97AE"

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

  SOURCES += utils_mac.mm
}

include(slippi/slippi.pri)

# always show qml files in Qt Creator
OTHER_FILES += $$files(qml/**, true)

DISTFILES += \
  qml/Slippipedia/controls/generic/GameCountRow.qml
