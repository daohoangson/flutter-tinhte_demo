#!/bin/sh

set -e

dartfmt -w .

dartanalyzer .
