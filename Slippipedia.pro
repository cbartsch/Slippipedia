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
PRODUCT_VERSION_NAME = 1.1
PRODUCT_VERSION_CODE = 5

# license for at.cb.Slippipedia, version 5, plugins: Google Analytics
PRODUCT_LICENSE_KEY = "8C9C90BA2A0EBF16AA9F20299448C6518766E22156B1FF750575060B3948C72943399878C19317A6A109F10396A78110E0505CBECFA7151F12702A6AD9B7F474CFE5BD9A4EE26C76C61F456A85854E46C96A474215332DA5AC71B9E732F6A9FBEE50F7027DA2856A2C236622967AB177E683AA05BFD8DBAD6A45F390212490DED9466D5CA64628282FD3D1E870D49E839447CC42A3AA52FA48E0AAA002568FBFC458161869A525230B4F78E2F4B99BC9914A904BEDD5A8F681B495CD0A248364DA0DB4B2C9AB9EE75F41D864F172EFD3E3AF765B2FF7EBE354DB8463F94CA81018D8CD787CB9B0A8E34DA2A33B74171D689B671BFAA7A3A406D28B09B163C83EB881C77BC3E590492A0D6F06BA7C9138E517ACE6360C369141EA0FCD366081028EA991FB5F995F323500F7FE499C319BCC40446B4F875AB900AAB090921A031942D9FF0C11B617060E21633BF0AD6DD3"

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
