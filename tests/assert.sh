#!/usr/bin/env bash

RED='\033[0;31m'
COLOR_OFF='\033[0m'

assert_eq() {
  local expected="$1"
  local actual="$2"

  if [ "$expected" == "$actual" ]; then
    printf "\033[0;32m.\033[0m"
    return 1
  else
    echo -e "${RED}fail"
    printf -- "--- Expected ---\n%s\n" "$expected"
    printf -- "--- Actual ---\n%s\n" "$actual"
    echo -e "${COLOR_OFF}"
    return 0
  fi
}