#!/bin/sh
QT_VERSION=5.12.0
export QT_VERSION
QT_VER=5.12
export QT_VER
QT_VERSION_TAG=5120
export QT_VERSION_TAG
QT_INSTALL_DOCS=/home/frostasm/Qt/v5.12.0/5.12.0/gcc_64/doc
export QT_INSTALL_DOCS
BUILDDIR=/home/frostasm/dev/companies/gsc/zbs-qtquickcontrols/build/src/extras
export BUILDDIR
exec /home/frostasm/Qt/v5.12.0/5.12.0/gcc_64/bin/qdoc "$@"
