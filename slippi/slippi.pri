
SLIPPC_SRC = $$PWD/slippc/src

INCLUDEPATH += \
    $$PWD \
    $$SLIPPC_SRC

HEADERS += \
    $$PWD/slippiparser.h \
    $$PWD/slippireplay.h \
    $$SLIPPC_SRC/analysis.h \
    $$SLIPPC_SRC/analyzer.h \
    $$SLIPPC_SRC/compressor.h \
    $$SLIPPC_SRC/enums.h \
    $$SLIPPC_SRC/lzma.h \
    $$SLIPPC_SRC/parser.h \
    $$SLIPPC_SRC/replay.h \
    $$SLIPPC_SRC/schema.h \
    $$SLIPPC_SRC/util.h

SOURCES += \
    $$PWD/slippiparser.cpp \
    $$PWD/slippireplay.cpp \
    $$SLIPPC_SRC/analysis.cpp \
    $$SLIPPC_SRC/analyzer.cpp \
    $$SLIPPC_SRC/compressor.cpp \
 #   $$SLIPPC_SRC/main.cpp \
    $$SLIPPC_SRC/parser.cpp \
    $$SLIPPC_SRC/replay.cpp

# Note: built from the lzma repository
# https://github.com/kobolabs/liblzma
win32 {
  # Build with windows/build.bash

  LIBS += -L $$PWD/slippc/lib-win -static

  contains(QT_ARCH, i386) {
    message(Load libzma windows 32 bit)
    LIBS += -llzma-x86
  }
  else {
    message(Load libzma windows 64 bit)
    LIBS += -llzma
  }
}
osx {
  message(Load libzma mac)
  LIBS += -llzma
}
