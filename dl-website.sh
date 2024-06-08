#!/bin/bash
SITE=$1
ROUTE=$2

if [ -z "$SITE" ]; then
    echo "No value provided"
    exit 1
fi

if [ -z "$ROUTE" ]; then
    echo "No path provided"
	ROUTE='/'
fi

wget \
     --recursive \
     --no-clobber \
     --page-requisites \
     --html-extension \
     --convert-links \
     --restrict-file-names=windows \
     --domains $SITE \
     --no-parent \
         $SITE$ROUTE
		 
