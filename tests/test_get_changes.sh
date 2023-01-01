source './tests/assert.sh'

# Comparing real commits (where README.md and .yml's was added)
export BASE=778874b109457624c69e6c549c89b679a7650075
export COMMIT=76a3ee7318daa9431e21e0bcd68f97fbac13cd8f
export FETCH_DEPTH=100
# Let's see if we can find it.
export FILTERS="md: .md"
# Store output in a temp file
export GITHUB_OUTPUT="test_get_changes_output.txt"

bash get_changes.sh

expected="has_any_changes='false'
has_any_changes=true
md=true
md_files=[\"README.md\"]
md_count=1
changes=[\"md\"]"

actual=$(cat $GITHUB_OUTPUT)

assert_eq "$expected" "$actual"

# Cleanup temp file
rm "test_get_changes_output.txt"

# Let's find yamls too
export FILTERS="|
  md: .md
  yml: .yml
"

bash get_changes.sh

expected="has_any_changes='false'
has_any_changes=true
md=true
md_files=[\"README.md\"]
md_count=1
has_any_changes=true
yml=true
yml_files=[\".github/workflows/get_changes.yml\",\"action.yml\"]
yml_count=2
changes=[\"md\",\"yml\"]"

actual=$(cat $GITHUB_OUTPUT)

assert_eq "$expected" "$actual"

# Cleanup temp file
rm "test_get_changes_output.txt"


# Let's check with filter that should not match
export FILTERS="|
  python: .py
"

bash get_changes.sh

expected="has_any_changes='false'
changes=[]"

actual=$(cat $GITHUB_OUTPUT)

assert_eq "$expected" "$actual"

# Cleanup temp file
rm "test_get_changes_output.txt"

exit 1