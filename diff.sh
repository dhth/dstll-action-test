#!/usr/bin/env bash

set -e

if [ $# -ne 5 ]; then
    echo "Usage: $0 <workdir> <output_file> <pattern> <start> <end>"
    echo "eg: $0 '**.go' startcommit endcommit diff.patch"
    exit 1
fi

wd="$1"
output_file="$2"
pattern="$3"
start="$4"
end="$5"

cwd=$(pwd)
cd "${wd}"
current_branch=$(git rev-parse --abbrev-ref HEAD)

temp_dir=$(mktemp -d)
if [ ! -e ${temp_dir} ]; then
    echo "Failed to create temporary directory."
    exit 1
fi

changed=$(git diff --name-only "$start..$end" -- "$pattern")

if [ -z "$changed" ]; then
    echo "No changes detected." >"${cwd}/${output_file}"
    exit 0
fi

git checkout "$start"
dstll write $(echo "$changed") -o "${temp_dir}/$start"

git checkout "$end"
dstll write $(echo "$changed") -o "${temp_dir}/$end"

git checkout $current_branch

cd $temp_dir
git --no-pager diff --no-index --relative "$start" "$end" >"${cwd}/${output_file}" || true
