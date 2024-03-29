#!/usr/bin/env bash

source ./tests/assert.sh

# Comparing real commits (where README.md was added)
export BASE=778874b109457624c69e6c549c89b679a7650075
export COMMIT=76a3ee7318daa9431e21e0bcd68f97fbac13cd8f
export FETCH_DEPTH=100
# Let's see if we can find it.
FILTERS="
&lt;!--#exec%20cmd=&quot;/bin/cat%20/etc/passwd&quot;--&gt;
&lt;!--#exec%20cmd=&quot;/bin/cat%20/etc/shadow&quot;--&gt;
&lt;!--#exec%20cmd=&quot;/usr/bin/id;--&gt;
&lt;!--#exec%20cmd=&quot;/usr/bin/id;--&gt;
/index.html|id|
;id;
;id
;netstat -a;
;id;
|id
|/usr/bin/id
|id|
|/usr/bin/id|
||/usr/bin/id|
|id;
||/usr/bin/id;
;id|
;|/usr/bin/id|
\n/bin/ls -al\n
\n/usr/bin/id\n
\nid\n
\n/usr/bin/id;
\nid;
\n/usr/bin/id|
\nid|
;/usr/bin/id\n
;id\n
|usr/bin/id\n
|nid\n
\`id\`
\`/usr/bin/id\`
a);id
a;id
a);id;
a;id;
a);id|
a;id|
a)|id
a|id
a)|id;
a|id
|/bin/ls -al
a);/usr/bin/id
a;/usr/bin/id
a);/usr/bin/id;
a;/usr/bin/id;
a);/usr/bin/id|
a;/usr/bin/id|
a)|/usr/bin/id
a|/usr/bin/id
a)|/usr/bin/id;
a|/usr/bin/id
;system('cat%20/etc/passwd')
;system('id')
;system('/usr/bin/id')
%0Acat%20/etc/passwd
%0A/usr/bin/id
%0Aid
%0A/usr/bin/id%0A
%0Aid%0A
& ping -i 30 127.0.0.1 &
& ping -n 30 127.0.0.1 &
%0a ping -i 30 127.0.0.1 %0a
\`ping 127.0.0.1\`
| id
& id
; id
%0a id %0a
\`id\`
$;/usr/bin/id"

export FILTERS

# Store output in a temp file
export GITHUB_OUTPUT="tests/test_get_changes_output.txt"

bash get_changes.sh

expected='result={"has_any_changes":"false","changes":[]}'

actual=$(cat "$GITHUB_OUTPUT")

assert_eq "$expected" "$actual"

exit $?