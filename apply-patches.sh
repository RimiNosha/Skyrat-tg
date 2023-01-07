#!/bin/sh
redfont="\e[31m"
greenfont="\e[32m"
nofont="\e[0m"
arrow="${greenfont}>${nofont} "
print="echo -e"

$print "${arrow}This is applying all patch files in the patches folder!"
$print
$print "${arrow}IF THIS FAILS TO PRODUCE COMPILEABLE CODE, STASH ANY CHANGES IN THE \"tgstation\" SUBMODULE BEFORE RUNNING CLEAN"
$print
$print "${arrow}IF MERGE CONFLICTS ARE REPRODUCABLE ON A FRESH INSTALL, CONTACT A ${redfont}MAINTAINER${nofont}, THEY FUCKED UP"
$print

cd ./tgstation
if ! git apply --3way ../patches/patch.patch; then
    $print
    $print "${arrow}${redfont}An error has occurred! Check the logs, and submit a bug report if you're able to reproduce normally!${nofont}"
    read -p "<Press Enter to continue>"
fi

exit 0