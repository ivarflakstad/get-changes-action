#!/usr/bin/env bash

# The following command makes this bash script slightly more safe. It does the following things:
# If any command fails the whole script will exit.
# If any variable is not set it is treated as an error, and the script immediately exits.
# Disable filename expansion (globbing) upon seeing *, ?, etc..
# If any part of a pipeline fails the whole pipeline fails.
set -euf -o pipefail

# INPUT HANDLING
# The following sections attempt to prevent script injection from inputs, but it is up
# to the user to provide safe values.

# This should work - is there a good reason to use it instead of cat? (cat is not builtin)
# IFS='' read -r -d '' test <<"EOF" || true
#  $   {{ inputs.filters }}
# EOF
# echo "TEST------------------------"
# echo "${test}"

# Escape inputs
# shellcheck disable=SC2153
base=$BASE
# shellcheck disable=SC2153
commit=$COMMIT
# shellcheck disable=SC2153
filters=$FILTERS
# shellcheck disable=SC2153
fetch_depth=$FETCH_DEPTH

# Commit hashes / branch names can only have the following characters
branch_name_commit_characters="[:alnum:]/\_\-.=><@"
# Remove disallowed characters
base="$(tr -cd -- "$branch_name_commit_characters" <<< "$base")"
commit="$(tr -cd -- "$branch_name_commit_characters" <<< "$commit")"

# Limit the characters that one can send through inputs.filters.
regex_symbols=".+?[]<>()|^$\{}\`/"
filter_characters="[:alnum:][:space:]:*"
allowed_characters="$regex_symbols$filter_characters"
# Remove disallowed characters
filters="$(tr -cd -- "$allowed_characters" <<< "$filters")"
# Read filters into array
readarray -t filter_array -- <<< "$filters"

# INPUT DONE


# Set default 'has_any_changes' value
echo "has_any_changes='false'" >> "$GITHUB_OUTPUT"

git fetch -q --depth="$fetch_depth"
while [ -z "$( git merge-base "$base" "$commit" )" ]; do
    git fetch -q --deepen=100 "$base" "$commit";
done

# Retrieving diff
diff=$(git diff --name-only "$base".."$commit")

changes=()
for row in "${filter_array[@]}"; do

  # xargs echo removes leading and trailing whitespaces
  row_trimmed=$(echo "$row" | xargs -- echo)

  # Check if the row is empty or not.
  if (( ${#row_trimmed} )); then

    # If there is a row, split it into two parts on ':'
    IFS=":" read -r filter_key filter_regex <<< "$row"

    # filter keys can only be alphanumerical
    key="$(tr -cd -- "[:alnum:]" <<< "$filter_key")"

    # Remove surrounding whitespace from regex if present
    regex_trimmed=$(echo "$filter_regex" | xargs -- echo)

    # Skip this row if key or regex is empty
    if (( !${#key} || !${#regex_trimmed} )); then
      continue
    fi

    # The '|| true' suffix suppresses 'set -e' for this line. Otherwise we would exit the script
    # if grep didn't find any results.
    results=$(echo "$diff" | grep -E "$regex_trimmed" --) || true

    readarray -t result_array <<< "$results"
    results_json=$(jq -ncR '[inputs]' <<< "$results")

    if (( ${#result_array} )); then

      # If there are matches we write the values.
      # shellcheck disable=SC2129
      echo "has_any_changes=true" >> "$GITHUB_OUTPUT"
      echo "${key}=true" >> "$GITHUB_OUTPUT"
      echo "${key}_files=$results_json" >> "$GITHUB_OUTPUT"
      echo "${key}_count=${#result_array[@]}" >> "$GITHUB_OUTPUT"

      changes+=("$key")
    fi
  fi
done

# Save list of filter keys that had matches.
# shellcheck disable=SC2034
changes_json=$(jq -cnR '$ARGS.positional' --args -- "${changes[@]}")
echo "changes=$changes_json" >> "$GITHUB_OUTPUT"
