#!/bin/sh

echo "This is updating all patch files in the patches folder!"

cd ./tgstation
if ! git diff HEAD > ../patches/patch.patch; then
    echo "An error has occurred! Check the logs, and submit a bug report if you're able to reproduce normally!"
    read -p "<Press Enter to continue>"
fi

exit 0