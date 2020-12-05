#!/bin/sh
#https://github.com/flutter/flutter/issues/46904#issuecomment-629363145
#run setupChromeCorsOverride.sh
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --disable-web-security --user-data-dir="/Users/bartonhammond/chrome-data-dir" $*
