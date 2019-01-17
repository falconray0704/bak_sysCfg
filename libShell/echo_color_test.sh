#!/bin/bash

set +x

. ./echo_color.lib

for obj in "$@"
do
    echoR "red : $obj"
    echoG "green : $obj"
    echoY "yellow : $obj"
    echoB "blue : $obj"
    echoP "purple : $obj"
    echoC "cyan: $obj"
done


