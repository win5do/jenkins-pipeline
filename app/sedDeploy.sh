#!/usr/bin/env bash

name=${name:='test'}
image=${image:='test'}
replicas=${replicas:=2}
port=${port:=0}

tpl=${tpl:=tpl/deploy.yaml}
output=out/deploy.yaml

test -e out && rm -rf out
mkdir out
# sed用?分隔，避免转义/
sed "s?{{name}}?$name?" ${tpl} | \
sed "s?{{image}}?$image?" | \
sed "s?{{port}}?$port?" | \
sed "s?{{replicas}}?$replicas?" > $output
