#########################################
##      vinizap4 - theme for zsh       ##
##  based on Comfyline - theme for zsh ##
##  Author: vinizap4                   ##
#########################################

setopt PROMPT_SUBST
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# --- Segment separators ---
: ${COMFYLINE_SEGSEP:='\ue0b4'}
: ${COMFYLINE_SEGSEP_REVERSE:='\ue0b6'}

# --- Segment ranks (positive = left prompt, negative = right prompt) ---
: ${RETVAL_RANK:=1}
: ${BASEDIR_RANK:=2}
: ${GIT_RANK:=3}
: ${VENV_RANK:=4}
: ${DATE_RANK:=-2}
: ${TIME_RANK:=-1}

# --- Colors ---
: ${RETVAL_b:='#8a8bd8'}   ${RETVAL_f:='#61355c'}
: ${BASE_b:='#b3b5fb'}     ${BASE_f:='#4a4b87'}
: ${GIT_b:='#f6b3b3'}      ${GIT_f:='#d95353'}
: ${GIT_CLEAN_b:='#b3f58c'} ${GIT_CLEAN_f:='#568459'}
: ${VENV_b:='#a8ddf9'}     ${VENV_f:='#0066a4'}
: ${DATE_b:='#f8bbe5'}     ${DATE_f:='#874c80'}
: ${TIME_b:='#e1bff2'}     ${TIME_f:='#844189'}

# --- Segment builder ---
# Args: $1=bg, $2=fg, $3=text, $4=rank
function create_segment() {
    if [[ $4 -lt $RIGHTMOST_RANK ]]; then
        echo -n "%F{$1}$COMFYLINE_SEGSEP_REVERSE%K{$1}%F{$2} $3 "
    elif [[ $4 -gt $LEFTMOST_RANK ]]; then
        echo -n "%K{$1}$COMFYLINE_SEGSEP %F{$2}$3%F{$1} "
    elif [[ $4 -eq $RIGHTMOST_RANK ]]; then
        if [[ $COMFYLINE_NO_START -eq 1 ]]; then
            echo -n "%F{$1}$COMFYLINE_SEGSEP_REVERSE%K{$1}%F{$2} $3"
        else
            echo -n "%F{$1}$COMFYLINE_SEGSEP_REVERSE%K{$1}%F{$2} $3 %k%F{$1}$COMFYLINE_SEGSEP"
        fi
    elif [[ $4 -eq $LEFTMOST_RANK ]]; then
        if [[ $COMFYLINE_NO_START -eq 1 ]]; then
            echo -n "%K{$1} %F{$2}$3%F{$1} "
        else
            echo -n "%F{$1}$COMFYLINE_SEGSEP_REVERSE%K{$1} %F{$2}$3%F{$1} "
        fi
    fi
}

# --- Segments ---

function retval() {
    local symbol
    if [[ $COMFYLINE_RETVAL_NUMBER -eq 0 ]]; then
        symbol="\UF8FF"
    elif [[ $COMFYLINE_RETVAL_NUMBER -eq 2 ]]; then
        symbol="%(?..✘ %?)"
    elif [[ $COMFYLINE_RETVAL_NUMBER -eq 1 ]]; then
        symbol="%?"
    else
        symbol="%(?..✘)"
    fi
    create_segment $RETVAL_b $RETVAL_f $symbol $RETVAL_RANK
}

function basedir() {
    create_segment $BASE_b $BASE_f "${PWD##*/}" $BASEDIR_RANK
}

# --- Git prompt config ---
ZSH_THEME_GIT_PROMPT_PREFIX=" \ue0a0 "
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_ADDED=" ✚"
ZSH_THEME_GIT_PROMPT_MODIFIED=" ±"
ZSH_THEME_GIT_PROMPT_DELETED=" \u2796"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" !"
ZSH_THEME_GIT_PROMPT_RENAMED=" \u21b7"
ZSH_THEME_GIT_PROMPT_UNMERGED=" \u21e1"
ZSH_THEME_GIT_PROMPT_AHEAD=" \u21c5"
ZSH_THEME_GIT_PROMPT_BEHIND=" \u21b1"
ZSH_THEME_GIT_PROMPT_DIVERGED=" \u21b0"

function gitrepo() {
    [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]] || return

    local branch_name=$(git rev-parse --abbrev-ref HEAD)
    local git_status=""

    if [[ -n $(git status --porcelain) ]]; then
        git_status="$ZSH_THEME_GIT_PROMPT_MODIFIED"
    fi

    local full_git_prompt="$ZSH_THEME_GIT_PROMPT_PREFIX$branch_name$git_status$ZSH_THEME_GIT_PROMPT_SUFFIX"

    if [[ -z $git_status ]]; then
        create_segment $GIT_CLEAN_b $GIT_CLEAN_f "$full_git_prompt" $GIT_RANK
    else
        create_segment $GIT_b $GIT_f "$full_git_prompt" $GIT_RANK
    fi
}

function venv() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        create_segment $VENV_b $VENV_f ${VIRTUAL_ENV:t:gs/%/%%} $VENV_RANK
    fi
}

function tmux_session() {
    local info=""
    if tmux ls &>/dev/null; then
        info=$(tmux display-message -p '#I #W')
    fi
    create_segment $DATE_b $DATE_f $info $DATE_RANK
}

function tmux_name() {
    local info=""
    if tmux ls &>/dev/null; then
        info=$(tmux display-message -p '#S')
    fi
    create_segment $TIME_b $TIME_f $info $TIME_RANK
}

function endleft() {
    echo -n "%k$COMFYLINE_SEGSEP%f"
}

# --- Prompt assembly ---

segments=("retval" "basedir" "gitrepo" "venv" "tmux_name" "tmux_session")
segment_ranks=($RETVAL_RANK $BASEDIR_RANK $GIT_RANK $VENV_RANK $TIME_RANK $DATE_RANK)

left_prompt=()
right_prompt=()
left_ranks=()
right_ranks=()

for ((i = 1; i <= ${#segments[@]}; i++)); do
    if [[ segment_ranks[$i] -gt 0 ]]; then
        left_prompt+=(${segments[$i]})
        left_ranks+=(${segment_ranks[$i]})
    elif [[ segment_ranks[$i] -lt 0 ]]; then
        right_prompt+=(${segments[$i]})
        right_ranks+=(${segment_ranks[$i]#-})
    fi
done

# Sort prompts by rank and find left/right boundaries
LEFTMOST_RANK=100
declare -A sorted_left
for ((i = 1; i <= ${#left_prompt[@]}; i++)); do
    if [[ $left_ranks[$i] -lt $LEFTMOST_RANK ]]; then LEFTMOST_RANK=$left_ranks[$i] fi
    sorted_left[$left_ranks[$i]]="$left_prompt[$i]"
done

RIGHTMOST_RANK=100
declare -A sorted_right
for ((i = 1; i <= ${#right_prompt[@]}; i++)); do
    if [[ $right_ranks[$i] -lt $RIGHTMOST_RANK ]]; then RIGHTMOST_RANK=$right_ranks[$i] fi
    sorted_right[$right_ranks[$i]]="$right_prompt[$i]"
done
((RIGHTMOST_RANK *= -1))

make_left_prompt() {
    for ((j = 1; j <= ${#left_prompt[@]}; j++)); do
        type $sorted_left[$j] &>/dev/null && $sorted_left[$j]
    done
}

make_right_prompt() {
    for ((j = ${#right_prompt[@]}; j > 0; j--)); do
        type $sorted_right[$j] &>/dev/null && $sorted_right[$j]
    done
}

# --- Export prompts ---

export PROMPT='%{%f%b%k%}$(make_left_prompt)$(endleft) '
export RPROMPT='      %{%f%b%k%}$(make_right_prompt)'

: ${COMFYLINE_NEXT_LINE_CHAR:='➟'}
: ${COMFYLINE_NEXT_LINE_CHAR_COLOR:="grey"}

next_line_maker() {
    echo -n "%F{$COMFYLINE_NEXT_LINE_CHAR_COLOR}$COMFYLINE_NEXT_LINE_CHAR %f"
}

if [[ COMFYLINE_START_NEXT_LINE -eq 1 ]]; then
    PROMPT=$PROMPT'
'$(next_line_maker)
elif [[ COMFYLINE_NO_GAP_LINE -eq 1 ]]; then
else
    PROMPT='
'$PROMPT
fi
