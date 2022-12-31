GREEN='\033[0;32m'
RED='\033[0;31m'
COLOR_OFF='\033[0m'

passed=0
failed=0

for test_file in test_*.sh; do
  if [ -f "$test_file" ]; then
    printf "${GREEN}Running${COLOR_OFF} %s ... " "$test_file"
    if bash "$test_file"; then
      echo -e "${RED}$test_file failed with the above error."
      failed=$((failed+1))
    else
      passed=$((passed+1))
    fi
  fi
  echo "${COLOR_OFF}"
done

total=$((failed+passed))
echo -e "${GREEN}Summary${COLOR_OFF}"
echo -e "$total tests run: $passed ${GREEN}passed${COLOR_OFF}, $failed tests ${RED}failed${COLOR_OFF}"

if ((failed!=0)); then
  return 1
else
  return 0
fi