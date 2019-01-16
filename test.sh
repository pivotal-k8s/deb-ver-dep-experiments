#!/usr/bin/env bash

set -e
set -u
set -o pipefail

readonly IMG='debtest'
readonly TEST_DIR="$(pwd)/tests"

bash_flags=''
[ -n "${DEBUG:-}" ] && bash_flags+='-x'

. "${TEST_DIR}/shared.inc.sh"

for t in "$TEST_DIR"/*test.sh
do
	start "${t}"
	docker run --rm -e "TERM=${TERM}" --workdir="${TEST_DIR}" -v "${TEST_DIR}:${TEST_DIR}" "$IMG" bash ${bash_flags} "$t"
	ok
done
