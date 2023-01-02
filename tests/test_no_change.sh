#!/usr/bin/env bash

source ./tests/assert.sh

# Comparing real commits (where README.md and .yml's was added)
export BASE=778874b109457624c69e6c549c89b679a7650075
export COMMIT=76a3ee7318daa9431e21e0bcd68f97fbac13cd8f
export FETCH_DEPTH=100

# Filter on python files. Should not match.
export FILTERS="|
  python: .py
"

bash get_changes.sh

expected='result={"has_any_changes":"false","changes":[]}'

actual=$(cat "$GITHUB_OUTPUT")

assert_eq "$expected" "$actual"

exit $?