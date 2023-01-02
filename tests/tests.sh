#!/usr/bin/env bash

# Store get_changes.sh output in a temp file
export GITHUB_OUTPUT="tests/test_get_changes_output.txt"

GREEN='\033[0;32m'
RED='\033[0;31m'
COLOR_OFF='\033[0m'

passed=0
failed=0

for test_file in tests/test_*.sh; do
  if [ -f "$test_file" ]; then
    printf "${GREEN}Running${COLOR_OFF} %s " "$test_file"
    if bash "$test_file"; then
      echo -e "${COLOR_OFF}"
      passed=$((passed+1))
    else
      echo -e "${RED}$test_file failed with the above error."
      failed=$((failed+1))
    fi
  fi

  # Cleanup temp file
  rm $GITHUB_OUTPUT || true
done
echo -e "${COLOR_OFF}-------"

total=$((failed+passed))
echo -e "${GREEN}Summary${COLOR_OFF} $total tests run: $passed ${GREEN}passed${COLOR_OFF}, $failed tests ${RED}failed${COLOR_OFF}"

if ((failed!=0)); then
  exit 1
else
  exit 0
fi