#!/bin/bash

find * -type d -a -name .git | while read f
do
    echo -- ${f%/.git}
    (cd ${f%/.git}; git pull)
done
