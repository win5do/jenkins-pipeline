#!/usr/bin/env bash

port=${port}

tpl=${tpl:=tpl/Dockerfile-go}
output=out/Dockfile

test -e out && rm -rf out
mkdir out
# sed用?分隔，避免转义/
sed "s?{{port}}?$port?" ${tpl} > $output