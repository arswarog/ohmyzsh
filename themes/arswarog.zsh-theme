# Colors vary depending on time lapsed.
ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$fg[green]%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$fg[yellow]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$fg[red]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$fg[white]%}"

# Git prompt settings
ZSH_THEME_GIT_PROMPT_PREFIX="[%{$fg_bold[green]%}±%{$reset_color%}%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}]"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[yellow]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"

# Git prompt settings
ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX="%{$fg[cyan]%}▴%{$reset_color%}"
ZSH_THEME_GIT_COMMITS_BEHIND_PREFIX="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%}✚ "
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}⚑ "
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}✖ "
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}▴ "
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[cyan]%}§ "

# LS colors, made with https://geoff.greer.fm/lscolors/
export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS='di=34;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:'
export GREP_COLOR='1;33'

# settings
typeset +H _current_dir="%{$fg_bold[blue]%}%2~%{$reset_color%}"
typeset +H _hist_no="%{$fg[grey]%}%h%{$reset_color%}"

MODE_INDICATOR="%{$fg_bold[yellow]%}❮%{$reset_color%}%{$fg[yellow]%}❮❮%{$reset_color%}"

PROMPT='
$(_user_host)${_current_dir} $(_git_prompt) ▶%{$reset_color%} '

# PROMPT2='%{%(!.${fg[red]}.${fg[white]})%}◀%{$reset_color%} '

RPROMPT='$(vi_mode_prompt_info)%{$(echotc UP 1)%}$(_upstream) $(_git_time_since_commit) %{$reset_color%}%{$(echotc DO 1)%}'

function _upstream() {
  # If we are on a folder not tracked by git, get out.
  # Otherwise, check for hide-info at global and local repository level
  if ! __git_prompt_git rev-parse --git-dir &>/dev/null ||
    [[ "$(__git_prompt_git config --get oh-my-zsh.hide-info 2>/dev/null)" == 1 ]]; then
    return 0
  fi

  local ref
  ref=$(__git_prompt_git symbolic-ref --short HEAD 2>/dev/null) ||
    ref=$(__git_prompt_git rev-parse --short HEAD 2>/dev/null) ||
    return 0

  local upstream
  upstream=$(__git_prompt_git rev-parse --abbrev-ref --symbolic-full-name "@{upstream}" 2>/dev/null)
  if [[ -n "$upstream" ]]; then
    upstream="$(_remote_status) %{$fg_bold[white]%}${upstream}%{$reset_color%}"
  else
    upstream="%{$fg_bold[red]%}✗ no upstream%{$reset_color%}"
  fi

  echo "${upstream}"
}

function _remote_status() {
  local result
  local commits_ahead="$(git_commits_ahead)"
  local commits_behind="$(git_commits_behind)"
  if [[ -n "$commits_ahead" && -n "$commits_behind" ]]; then
    result="$commits_ahead $commits_behind"
  elif [[ -n "$commits_ahead$commits_behind" ]]; then
    result="$commits_ahead$commits_behind"
  else
    result="%{$fg_bold[green]%}✓%{$reset_color%}"
  fi
  echo "$result"
}

function _user_host() {
  local me
  if [[ -n $SSH_CONNECTION ]]; then
    echo "%{$fg[green]%}%n%B@%m%b%{$reset_color%}:"
  else
    echo "%{$fg[green]%}%n:%{$reset_color%}"
  fi
}

# Determine the time since last commit. If branch is clean,
# use a neutral color, otherwise colors will vary according to time.
function _git_time_since_commit() {
  local last_commit now seconds_since_last_commit
  local minutes hours days years commit_age
  # Only proceed if there is actually a commit.
  if last_commit=$(git log --pretty=format:'%at' -1 2>/dev/null); then
    now=$(date +%s)
    seconds_since_last_commit=$((now - last_commit))

    # Totals
    minutes=$((seconds_since_last_commit / 60))
    hours=$((minutes / 60))
    days=$((hours / 24))
    years=$((days / 365))

    if [[ $years -gt 0 ]]; then
      commit_age="${years}y$((days % 365))d"
    elif [[ $days -gt 0 ]]; then
      commit_age="${days}d$((hours % 24))h"
    elif [[ $hours -gt 0 ]]; then
      commit_age+="${hours}h$((minutes % 60))m"
    else
      commit_age="${minutes}m"
    fi

    echo "${ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL}${commit_age}%{$reset_color%}"
  fi
}

function _git_branch() {
  ref=$(command git symbolic-ref HEAD 2>/dev/null) ||
    ref=$(command git rev-parse --short HEAD 2>/dev/null) || return
  echo "${ref#refs/heads/}"
}

function _git_status() {
  _STATUS=""

  # check status of files
  _INDEX=$(command git status --porcelain 2>/dev/null)
  if [[ -n "$_INDEX" ]]; then
    if $(echo "$_INDEX" | command grep -q '^[AMRD]. '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
    fi
    if $(echo "$_INDEX" | command grep -q '^.[MTD] '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
    fi
    if $(echo "$_INDEX" | command grep -q -E '^\?\? '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    fi
    if $(echo "$_INDEX" | command grep -q '^UU '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
    fi
  else
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi

  # check status of local repository
  _INDEX=$(command git status --porcelain -b 2>/dev/null)
  if $(echo "$_INDEX" | command grep -q '^## .*ahead'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
  if $(echo "$_INDEX" | command grep -q '^## .*behind'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi
  if $(echo "$_INDEX" | command grep -q '^## .*diverged'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_DIVERGED"
  fi

  if $(command git rev-parse --verify refs/stash &>/dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STASHED"
  fi

  echo $_STATUS
}

function _git_prompt() {
  local _branch=$(_git_branch)
  local _status=$(_git_status)
  local _result=""
  if [[ "${_branch}x" != "x" ]]; then
    _result="$ZSH_THEME_GIT_PROMPT_PREFIX$_branch"
    if [[ "${_status}x" != "x" ]]; then
      _result="$_result $_status"
    fi
    _result="$_result$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
  echo $_result
}
