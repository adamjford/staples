# oh-my-zsh Bureau Theme
# Wildly hacked on to add context sensitive tags on right side

### NVM

ZSH_THEME_NVM_PROMPT_PREFIX="%B⬡%b "
ZSH_THEME_NVM_PROMPT_SUFFIX=""

### Git [±master ▾●]

ZSH_THEME_GIT_PROMPT_PREFIX="[%{$fg_bold[green]%}%{$reset_color%}%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}]"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[blue]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[red]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[yellow]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[green]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[cyan]%}●%{$reset_color%}"

# Cache for git operations to speed up large repos
typeset -A _git_cache
typeset -A _git_cache_time

bureau_git_branch () {
  local cache_key="${PWD}_branch"
  local current_time=$(date +%s)
  
  # Use cached result if less than 2 seconds old
  if [[ -n "${_git_cache_time[$cache_key]}" ]] && 
     (( current_time - _git_cache_time[$cache_key] < 2 )); then
    echo "${_git_cache[$cache_key]}"
    return
  fi
  
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  local branch="${ref#refs/heads/}"
  
  # Cache result
  _git_cache[$cache_key]="$branch"
  _git_cache_time[$cache_key]="$current_time"
  
  echo "$branch"
}

bureau_git_status () {
  local cache_key="${PWD}_status"
  local current_time=$(date +%s)
  
  # Use cached result if less than 2 seconds old
  if [[ -n "${_git_cache_time[$cache_key]}" ]] && 
     (( current_time - _git_cache_time[$cache_key] < 2 )); then
    echo "${_git_cache[$cache_key]}"
    return
  fi
  
  _INDEX=$(command git status -uno --porcelain -b 2> /dev/null)
  _STATUS=""
  if $(echo "$_INDEX" | grep '^[AMRD]. ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
  fi
  if $(echo "$_INDEX" | grep '^.[MTD] ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
  fi
  if $(echo "$_INDEX" | command grep -E '^\?\? ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
  fi
  if $(echo "$_INDEX" | grep '^UU ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
  fi
  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STASHED"
  fi
  if $(echo "$_INDEX" | grep '^## .*ahead' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
  if $(echo "$_INDEX" | grep '^## .*behind' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi
  if $(echo "$_INDEX" | grep '^## .*diverged' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_DIVERGED"
  fi

  # Cache result
  _git_cache[$cache_key]="$_STATUS"
  _git_cache_time[$cache_key]="$current_time"

  echo $_STATUS
}

bureau_git_prompt () {
  local _branch=$(bureau_git_branch)
  # if [ -n "$SSH_CLIENT" ]; then
  #   _status=""
  # else
    local _status=$(bureau_git_status)
  # fi

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

_PATH="%{$fg_bold[white]%}%~%{$reset_color%}"

shop_world_path() {
  local path="${PWD}"
  # First convert to home-relative path
  path="${path/#$HOME/~}"

  # Define the prefix to replace
  local prefix="~/world/trees/root/src"

  # Replace ~/world/trees/root/src with //
  if [[ "$path" == "$prefix" ]]; then
    echo "%{$fg_bold[green]%}//%{$reset_color%}"
  elif [[ "$path" == "$prefix"/* ]]; then
    # Remove the prefix and add //
    echo "%{$fg_bold[green]%}//${path#$prefix/}%{$reset_color%}"
  else
    echo "%{$fg_bold[white]%}$path%{$reset_color%}"
  fi
}

if [[ $EUID -eq 0 ]]; then
  _USERNAME="%{$fg_bold[red]%}%n"
  _LIBERTY="%{$fg[red]%}#"
else
  _USERNAME="%{$fg_bold[white]%}%n"
  _LIBERTY="%{$fg[green]%}$"
fi
_USERNAME="$_USERNAME%{$reset_color%}@%m"
_LIBERTY="$_LIBERTY%{$reset_color%}"

get_usables () {
	local usables='';
	if [[ -a gulpfile.js ]]; then
		usables="<gulp> $usables"
	fi

	if [[ -a 'composer.json' ]]; then
		usables="<composer> $usables"
	fi

	if [[ -f 'package.json' ]]; then
		usables="<npm> $usables"
	fi

	if [[ -f 'VagrantFile' ]]; then
		usables="<vagrant> $usables"
	fi

	if [[ -f 'Gemfile' ]]; then
		usables="<bundler> $usables"
	fi

	if [[ -n $usables ]]; then
		echo "%{$fg[magenta]%}$usables%{$reset_color%}"
	fi
}

setopt prompt_subst

#_1LEFT="$_USERNAME $_PATH"
_1RIGHT=''
_1LEFT="[%D{%r %Z}] \$(shop_world_path) \$(bureau_git_prompt) \$(get_usables)"

bureau_precmd () {
  print
  print -rP "$_1LEFT"
}

ssh_status_prompt () {
	if [[ -n "$SSH_CLIENT" ]]; then
		echo '%n@%m '
	fi
}

last_status () {
  echo "%(?:%{$fg_bold[green]%}:%{$fg_bold[red]%})"
}

function set-prompt () {
  case ${KEYMAP} in
    (vicmd)      VI_MODE="<NORMAL>" ;;
    (main|viins) VI_MODE="<INSERT>" ;;
    (*)          VI_MODE="<INSERT>" ;;
  esac

  PROMPT='%{$fg[red]%}$(ssh_status_prompt)%{$fg[magenta]%}$VI_MODE%{$reset_color%} $_LIBERTY '
}

function zle-line-init zle-keymap-select {
  set-prompt
  zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

autoload -U add-zsh-hook
add-zsh-hook precmd bureau_precmd
