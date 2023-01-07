#!/bin/sh

echo "Are you ABSOLUTELY SURE you want to delete all changes in the TGStation submodule?"
read -p "Close this shell window if you don't wish to continue!"

cd ../tgstation
git reset --hard HEAD~1
git clean -fxd

read -p "Deleted, have a nice day."
exit 0