#!/bin/bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"
_toolPath="$( pwd )"
_dataPath="$_toolPath/.data"
_srcPath="$( dirname "$_toolPath" )"

touch "$_toolPath/.data/.packages"

exec docker run --rm -it \
  -v "$_srcPath:/src" -w '/src' \
  -v "$_dataPath/.dart_tool:/src/.dart_tool" \
  -v "$_dataPath/.packages:/src/.packages" \
  -v "$_dataPath/.pub-cache:/root/.pub-cache" \
  google/dart bash
