
file(GLOB_RECURSE QmlFolder RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.qml)

qt_add_library(Slippipedia STATIC
  ${QmlFolder}
)

# Define singleton QML files before adding the QML module
set_source_files_properties(
  model/data/MeleeData.qml
  model/Constants.qml
  PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(Slippipedia
    URI Slippipedia
    NO_PLUGIN
    VERSION 1.0
    RESOURCE_PREFIX "qml/"
    OUTPUT_DIRECTORY ""
    QML_FILES ${QmlFolder}
    ${NO_CACHEGEN_OPTION}
)
