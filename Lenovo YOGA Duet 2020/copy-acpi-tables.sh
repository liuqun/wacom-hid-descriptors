#!/usr/bin/env bash

# Creates a copy of the ACPI tables in a tarball for sharing. An
# `acpi-tables.tar.gz` file will be created in the current directory.
#
# Simply pointing `tar` at sysfs sadly does not work, due to the
# files changing apparent size. It seems the preferred way to
# copy the files is with `cat`, so we define our own `catcopy`
# function that can be called for each file. Once everything
# has been copied out of sysfs we can safely tar up the the
# resulting directory tree.

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root or with sudo."
  exit 1
fi

function catcopy {
  SRCFILE="$1"
  SRCDIR=$(dirname "$1")

  mkdir -p "./$SRCDIR"
  cat "$SRCFILE" > "./$SRCFILE"
}
export -f catcopy

OUTDIR=$(mktemp -d)
pushd "$OUTDIR"
find /sys/firmware/acpi/tables -type f -print0 | xargs -0 -I{} bash -c 'catcopy "{}"' _
tar cvzf acpi-tables.tar.gz *
popd
mv $OUTDIR/acpi-tables.tar.gz .
rm -rf $OUTDIR
