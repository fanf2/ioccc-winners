#!/usr/bin/env bash
#
# try.sh - demonstrate IOCCC winner 2012/endoh2
#

# make sure CC is set so that when we do make CC="$CC" it isn't empty. Doing it
# this way allows us to have the user specify a different compiler in an easy
# way.
if [[ -z "$CC" ]]; then
    CC="cc"
fi

make CC="$CC" everything >/dev/null || exit 1

# clear screen after compilation so that only the entry is shown
clear

run()
{
    local program="$1"
    echo "" 1>&2
    read -r -n 1 -p "Press any key to run: ./${program} (space = next page, q = quit): "
    "./${program}" | less -K -E -X
}
run pi
run 314
run 3141
run 31415
run 314159
run 3141592
run 31415926
run 314159265
run 3141592653
run 31415926535
run e 271
run 2718
run 27182
run 271828
run 2718281
run 27182818
run 271828182
run 2718281828
run 27182818284
