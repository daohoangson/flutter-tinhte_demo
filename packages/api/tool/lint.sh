#!/bin/sh

set -e

flutter format .

flutter analyze .
