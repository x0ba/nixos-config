# Compact jj status for the default fish prompt.
# On a bookmark:  (main *3)
# Off a bookmark: (main:: @k *)
# Conflict:       (main ×)
if not command -sq jj
    return 1
end

# One read of @. Failure means we are not in a jj repo, so git can take over.
set -l at (
    jj log --no-pager --ignore-working-copy --no-graph --color=never -r @ -T '
        if(conflict, "1", "0") ++ "|" ++
        if(empty, "1", "0") ++ "|" ++
        if(divergent, "1", "0") ++ "|" ++
        change_id.shortest() ++ "|" ++
        self.diff().files().len() ++ "|" ++
        local_bookmarks.map(|b| b.name() ++ if(b.conflict(), "??", "")).join(" ")
    ' 2>/dev/null
)
or return 1

set -l parts (string split '|' -- $at)
set -l is_conflict $parts[1]
set -l is_empty $parts[2]
set -l is_divergent $parts[3]
set -l change_id $parts[4]
set -l files $parts[5]
set -l bookmarks $parts[6]

set -l loc
if test -n "$bookmarks"
    set loc $bookmarks
else
    set -l nearest (
        jj log --no-pager --ignore-working-copy --no-graph --color=never \
            -r 'heads(::@ & bookmarks())' \
            -T 'local_bookmarks.map(|b| b.name()).join(" ") ++ "\n"' 2>/dev/null
    )
    set -l anchor
    for line in $nearest
        if test -n "$line"
            set anchor $line
            break
        end
    end
    if test -n "$anchor"
        set loc "$anchor:: @$change_id"
    else
        set loc "@$change_id"
    end
    if test "$is_divergent" = 1
        set loc "$loc??"
    end
end

set -l flags
if test "$is_conflict" = 1
    set -a flags '×'
end
if test "$is_empty" = 0
    set -a flags "*$files"
end

printf ' (%s' $loc
if test (count $flags) -gt 0
    printf ' %s' (string join '' $flags)
end
printf ')'
