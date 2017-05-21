#!/bin/bash -e
# vim:ts=2:sw=2:et:
if test -d autom4te.cache ; then
  rm -rf autom4te.cache
fi
if test -d config.status ; then
  rm -f config.status
fi

for p in glibtoolize FAIL; do
  test "$p" = FAIL && { echo "your system lacks glibtoolize" 1>&2; exit 1; } || :
  ( $p --version ) > /dev/null 2>&1 && { eval "glibtoolize() { env $p; }"; break; } || :
done
glibtoolize --no-warn -i -f

aclocal
autoheader
automake --add-missing --foreign

# This checks to make sure PKG_CHECK_MODULES is available to autoconf. This
# should be the case provided pkg-config is installed AND the above commands
# have been run to prep the source tree with local set-up. 
CHECK_PKG_CONFIG_M4='m4_ifdef([PKG_CHECK_MODULES], [errprint([ok])])'
if [ "x$(autoconf <(echo "$CHECK_PKG_CONFIG_M4") 2>&1)" != "xok" ] ; then
  echo 'pkg-config appears to be missing (not available to autoconf tools)'
  echo 'please install the pkg-config package for your system.'
  exit 1
fi

autoconf
