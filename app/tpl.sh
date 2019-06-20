#!/usr/bin/env bash

name='hello'
image='win5do/first'
port='5100'
output=out/$name.yaml

test -e out && rm -rf out
mkdir out
# sed用?分隔，避免转义/
sed "s?{{name}}?$name?" tpl/deploy.yaml | sed "s?{{image}}?$image?" | sed "s?{{port}}?$port?" > $output