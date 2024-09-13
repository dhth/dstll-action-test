#!/usr/bin/env bash

set -e

if [ $# -ne 4 ]; then
    echo "Usage: $0 <pattern> <start> <end> <output_file>"
    echo "eg: $0 '**.go' startcommit endcommit diff.patch"
    exit 1
fi

pattern="$1"
start="$2"
end="$3"
output_file="$4"

cwd=$(pwd)
current_branch=$(git rev-parse --abbrev-ref HEAD)

temp_dir=$(mktemp -d)
if [ ! -e ${temp_dir} ]; then
    echo "Failed to create temporary directory."
    exit 1
fi

changed=$(git diff --name-only "$start..$end" -- "$pattern")

if [ -z "$changed" ]; then
    echo "No changes detected." >>"${cwd}/${output_file}"
    exit 0
fi

git checkout "$start"
dstll write $(echo "$changed") -o "${temp_dir}/$start"

git checkout "$end"
dstll write $(echo "$changed") -o "${temp_dir}/$end"

git checkout $current_branch

cd $temp_dir
git --no-pager diff --no-index --relative "$start" "$end" >"${cwd}/${output_file}"
