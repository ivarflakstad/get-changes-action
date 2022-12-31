source './assert.sh'

export BASE=origin/main
export COMMIT=HEAD
export FILTERS="txt: .txt"
export GITHUB_OUTPUT="test_injection_output.txt"

# Create a difference
touch test_file_1.txt
touch test_file_2.md
touch test_file_3.yaml
git add -A

rm $GITHUB_OUTPUT || true

bash ../get_changes.sh


expected="has_any_changes='false'
has_any_changes=true
md=true
md_files=[\"README.md\"]
md_count=1
changes=[\"md\"]"

actual=$(cat $GITHUB_OUTPUT)

assert_eq "$expected" "$actual"

