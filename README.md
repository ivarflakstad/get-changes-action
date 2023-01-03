# get-changes-action

This is a gitHub action that allows you to conditionally run
workflow steps based on changes between commits.
It is entirely based on a bash script and has no dependencies.

Why run your entire test suite when all you did was change a line in your README?

## Example

```yaml
- id: changes
  uses: ./
  with:
    filters: |
      py: .py

  # Run this step only if there are changes to files matching .py
- if: ${{ fromJson(steps.changes.outputs.result).py == 'true' }}
  run: ...
```

## How it works

The action compares two commits/features with `git diff --name-only <base>..<commit>`.
Then it loops through the filters and grep for matching changes.

grep is done with the `-E` flag, meaning that the filters should be specified using
the extended regex syntax
([ERE](https://en.wikibooks.org/wiki/Regular_Expressions/POSIX-Extended_Regular_Expressions))

grep documentation for basic vs extended can be seen
[here](https://www.gnu.org/software/grep/manual/html_node/Basic-vs-Extended.html)

Use the github action expression
[fromJson](https://docs.github.com/en/actions/learn-github-actions/expressions#fromjson)
to access the result.

## Options

```yaml
uses: ivarflakstad/get-changes-action
with:
  # The commit SHA, branch name, or tag that specifies the base of comparison
  # Defaults to 'origin/main'
  base:

  # The commit SHA, branch name, or tag that specifies that will be compared
  # against 'base'
  # Defaults to 'HEAD'
  commit:
    
  # The first depth of 'git fetch' used on 'base'.
  # The action will iteratively deepen the fetch by 100 until 'git merge-base' 
  # finds a common ancestor(s).
  # Defaults to '0' - which will fetch all remotes.
  fetch_depth:
  
  # Filters to match against 'git diff --name-only <base>..<commit>'
  # Uses grep with extended regex syntax.
  filters:

outputs:
  # JSON containing the matched changes.
  # Example:
  # {
  #   "has_any_changes":"true",
  #   "md":"true",
  #   "md_files":["README.md"],
  #   "md_count":1,
  #   "changes":["md"]
  # }
  # Use github action's `fromJson` expression to access the result:
  # - if: ${{ fromJson(steps.changes.outputs.result).md == 'true' }}
  result:
```
