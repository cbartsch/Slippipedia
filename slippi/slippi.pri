
SLIPPC_SRC = $$PWD/slippc/src

INCLUDEPATH += \
    $$PWD \
    $$SLIPPC_SRC

HEADERS += \
    $$PWD/slippiparser.h \
    $$PWD/slippireplay.h \
    $$SLIPPC_SRC/analysis.h \
    $$SLIPPC_SRC/analyzer.h \
    $$SLIPPC_SRC/enums.h \
    $$SLIPPC_SRC/parser.h \
    $$SLIPPC_SRC/replay.h \
    $$SLIPPC_SRC/util.h

SOURCES += \
    $$PWD/slippiparser.cpp \
    $$PWD/slippireplay.cpp \
    $$SLIPPC_SRC/analysis.cpp \
    $$SLIPPC_SRC/analyzer.cpp \
 #   $$SLIPPC_SRC/main.cpp \
    $$SLIPPC_SRC/parser.cpp \
    $$SLIPPC_SRC/replay.cpp
