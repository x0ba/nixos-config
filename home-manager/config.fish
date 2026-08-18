set -g theme_color_scheme dracula

set -g fish_color_normal normal
set -g fish_color_command F8F8F2
set -g fish_color_quote F1FA8C
set -g fish_color_redirection 8BE9FD
set -g fish_color_end 50FA7B
set -g fish_color_error FF5555
set -g fish_color_param 5FFFFF
set -g fish_color_comment 6272A4
set -g fish_color_match --background=brblue
set -g fish_color_selection white --bold --background=brblack
set -g fish_color_search_match bryellow --background=brblack
set -g fish_color_history_current --bold
set -g fish_color_operator 00a6b2
set -g fish_color_escape 00a6b2
set -g fish_color_cwd green
set -g fish_color_cwd_root red
set -g fish_color_valid_path --underline
set -g fish_color_autosuggestion BD93F9
set -g fish_color_user brgreen
set -g fish_color_host normal
set -g fish_color_cancel -r
set -g fish_pager_color_completion normal
set -g fish_pager_color_description B3A06D yellow
set -g fish_pager_color_prefix white --bold --underline
set -g fish_pager_color_progress brwhite --background=cyan

# Bobthefish sees a colocated jj repository as detached Git HEAD. Prefer jj's
# stable change ID (or its bookmark) and working-copy state in that case.
# Load the theme first: its monolithic fish_prompt.fish also defines this helper
# and would otherwise overwrite our version the first time the prompt is drawn.
functions fish_prompt >/dev/null
function __bobthefish_git_branch -S -d 'Get the current jj change or git branch'
    set -l jj_state (command jj log --ignore-working-copy --no-graph -r @ \
        -T 'change_id.shortest(8) ++ "\t" ++ bookmarks.map(|b| b.name()).join(",") ++ "\t" ++ if(empty, "empty", "dirty") ++ "\t" ++ if(conflict, "conflict", "") ++ "\n"' \
        2>/dev/null)

    if test -n "$jj_state"
        set -l fields (string split \t -- "$jj_state")
        set -l label $fields[2]
        test -n "$label"; or set label $fields[1]

        set -l state
        test "$fields[3]" = empty; and set state "$state∅"
        test "$fields[4]" = conflict; and set state "$state!"

        echo -n "jj $label"
        test -n "$state"; and echo -n " $state"
        return
    end

    set -l tag (command git describe --tags --exact-match 2>/dev/null)
    and echo "$tag_glyph $tag "

    set -l branch (command git symbolic-ref HEAD 2>/dev/null | string replace -r '^refs/heads/' '')
    and begin
        test -n "$theme_git_default_branches"
        or set -l theme_git_default_branches master main (git config init.defaultBranch)

        test "$theme_display_git_master_branch" != yes -a "$theme_display_git_default_branch" != yes
        and contains $branch $theme_git_default_branches
        and echo $branch_glyph
        and return

        set -l truncname $branch
        test "$theme_use_abbreviated_branch_name" = yes
        and set truncname (string replace -r '^(.{17}).{3,}(.{5})$' '$1…$2' $branch)

        echo $branch_glyph $truncname
        and return
    end

    if test -z "$tag"
        set -l branch (command git show-ref --head -s --abbrev | head -n1 2>/dev/null)
        echo "$detached_glyph $branch"
    end
end

function __bobthefish_prompt_nix -S -d 'Display current nix environment'
    [ "$theme_display_nix" = 'no' -o -z "$IN_NIX_SHELL" ]
    and return

    __bobthefish_start_segment $color_nix
    echo -ns N ' '

    set_color normal
end

alias fnix "nix-shell --run fish"
