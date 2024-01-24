#!/bin/bash

set -x

rm -f cscope.files
rm -f cscope.out

find -L . -type f -iname '*.[ch]' -o -iname '*.cpp' > cscope.files
find -L . -type l -iname '*.[ch]' -o -iname '*.cpp' -print -exec readlink -f {} \; >> cscope.files

cscope -b
