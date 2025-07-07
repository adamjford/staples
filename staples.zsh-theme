# oh-my-zsh Bureau Theme
# Wildly hacked on to add context sensitive tags on right side

### Colour Variables
# Customize these to change the colour scheme
GREY_COLOUR="%F{242}"
TIME_COLOUR="${GREY_COLOUR}"
PATH_COLOUR="%{$fg[blue]%}"
SHOPWORLD_COLOUR="%{$fg_bold[green]%}"
GIT_BRACKETS_COLOUR="${GREY_COLOUR}"
GIT_BRANCH_NAME_COLOUR="%F{136}" # bronze
USABLES_COLOUR="%{$fg[magenta]%}"
VI_MODE_COLOUR="%{$fg[magenta]%}"
SSH_COLOUR="%{$fg[red]%}"
ERROR_COLOUR="%{$fg[red]%}"
PROMPT_SYMBOL_COLOUR="${GREY_COLOUR}"
ROOT_SYMBOL_COLOUR="%{$fg[red]%}"

### NVM

ZSH_THEME_NVM_PROMPT_PREFIX="%B⬡%b "
ZSH_THEME_NVM_PROMPT_SUFFIX=""

### Shared Truncation Function

truncate_name() {
  local name="$1"
  local max_length=60
  
  if [[ ${#name} -gt $max_length ]]; then
    echo "${name:0:$((max_length-1))}…"
  else
    echo "$name"
  fi
}

### Git [±master ▾●]

ZSH_THEME_GIT_PROMPT_PREFIX="${GIT_BRACKETS_COLOUR}[%{$reset_color%}${GIT_BRANCH_NAME_COLOUR}"
ZSH_THEME_GIT_PROMPT_SUFFIX="${GIT_BRACKETS_COLOUR}]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[blue]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[red]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[yellow]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[green]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[cyan]%}●%{$reset_color%}"

bureau_git_branch () {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  local branch_name="${ref#refs/heads/}"
  
  echo "$(truncate_name "$branch_name")"
}

bureau_git_status () {
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

  echo $_STATUS
}

bureau_git_prompt () {
  local _branch=$(bureau_git_branch)
  local _status=$(bureau_git_status)
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

  # Check if we're in any worktree (~/world/trees/*/...)
  if [[ "$path" =~ ^~/world/trees/[^/]+(/|$) ]]; then
    # Extract worktree name from path
    local full_path="${PWD}"
    
    if [[ "$full_path" =~ /world/trees/([^/]+)/src/(.*) ]]; then
      # Inside src with subdirectory
      local worktree_name="${match[1]}"
      local src_path="${match[2]}"
    elif [[ "$full_path" =~ /world/trees/([^/]+)/src$ ]]; then
      # At src root
      local worktree_name="${match[1]}"
      local src_path=""
    elif [[ "$full_path" =~ /world/trees/([^/]+)$ ]]; then
      # At worktree root
      local worktree_name="${match[1]}"
      local src_path=""
    elif [[ "$full_path" =~ /world/trees/([^/]+)/(.*) ]]; then
      # In worktree but not in src
      local worktree_name="${match[1]}"
      local src_path="${match[2]}"
    else
      local worktree_name="unknown"
      local src_path=""
    fi
  fi

  # Common worktree processing (shared between all cases above)
  if [[ "$path" =~ ^~/world/trees/[^/]+(/|$) ]]; then
    # Truncate worktree name using shared function
    worktree_name="$(truncate_name "$worktree_name")"

    # Choose color based on worktree name
    local worktree_colour
    if [[ "$worktree_name" == "root" ]]; then
      worktree_colour="${SHOPWORLD_COLOUR}"
    else
      worktree_colour="${GREY_COLOUR}"
    fi

    # Display path based on location within worktree
    if [[ "$full_path" =~ /world/trees/[^/]+/src ]]; then
      # We're in the src directory or subdirectory
      if [[ -n "$src_path" ]]; then
        echo "${SHOPWORLD_COLOUR}//${src_path}%{$reset_color%} ${worktree_colour}🌳{${worktree_name}}%{$reset_color%}"
      else
        echo "${SHOPWORLD_COLOUR}//%{$reset_color%} ${worktree_colour}🌳{${worktree_name}}%{$reset_color%}"
      fi
    else
      # We're in the worktree but not in src (e.g., worktree root or other directory)
      if [[ -n "$src_path" ]]; then
        echo "${PATH_COLOUR}~${src_path}%{$reset_color%} ${worktree_colour}🌳{${worktree_name}}%{$reset_color%}"
      else
        echo "${PATH_COLOUR}${path}%{$reset_color%} ${worktree_colour}🌳{${worktree_name}}%{$reset_color%}"
      fi
    fi
  else
    # Not in a shop/world path
    echo "${PATH_COLOUR}$path%{$reset_color%}"
  fi
}

if [[ $EUID -eq 0 ]]; then
  _USERNAME="%{$fg_bold[red]%}%n"
  _LIBERTY="${ROOT_SYMBOL_COLOUR}#"
else
  _USERNAME="%{$fg_bold[white]%}%n"
  _LIBERTY="${PROMPT_SYMBOL_COLOUR}$"
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
		echo "${USABLES_COLOUR}$usables%{$reset_color%}"
	fi
}

setopt prompt_subst

#_1LEFT="$_USERNAME $_PATH"
_1RIGHT=''
_1LEFT="${TIME_COLOUR}[%D{%r %Z}]%{$reset_color%} \$(shop_world_path) \$(bureau_git_prompt) \$(get_usables)"

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
  echo "%(?::❌ )"
}


function set-prompt () {
  case ${KEYMAP} in
    (vicmd)      VI_MODE="<NORMAL>" ;;
    (main|viins) VI_MODE="<INSERT>" ;;
    (*)          VI_MODE="<INSERT>" ;;
  esac

  PROMPT='$(last_status)${SSH_COLOUR}$(ssh_status_prompt)${VI_MODE_COLOUR}$VI_MODE%{$reset_color%} $_LIBERTY '
}

function zle-line-init zle-keymap-select {
  set-prompt
  zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

autoload -U add-zsh-hook
add-zsh-hook precmd bureau_precmd
