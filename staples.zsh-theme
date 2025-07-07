# oh-my-zsh Bureau Theme
# Wildly hacked on to add context sensitive tags on right side

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

### Git [±master ▾●]

ZSH_THEME_GIT_PROMPT_PREFIX="${GIT_BRACKETS_COLOUR}[%{$reset_color%}${GIT_BRANCH_NAME_COLOUR}"
ZSH_THEME_GIT_PROMPT_SUFFIX="${GIT_BRACKETS_COLOUR}]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[blue]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[red]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[yellow]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[green]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[cyan]%}●%{$reset_color%}"

truncate_name() {
  local name="$1"
  local max_length=60

  if [[ ${#name} -gt $max_length ]]; then
    echo "${name:0:$((max_length-1))}…"
  else
    echo "$name"
  fi
}

bureau_git_branch() {
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
  local branch=$(bureau_git_branch)
  local git_status=$(bureau_git_status)
  local result=""

  if [[ -n "$branch" ]]; then
    result="$ZSH_THEME_GIT_PROMPT_PREFIX$branch"
    if [[ -n "$git_status" ]]; then
      result="$result $git_status"
    fi
    result="$result$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi

  echo $result
}

_PATH="%{$fg_bold[white]%}%~%{$reset_color%}"

get_worktree_colour() {
  local name="$1"
  if [[ "$name" == "root" ]]; then
    echo "${SHOPWORLD_COLOUR}"
  else
    echo "${GREY_COLOUR}"
  fi
}

format_src_path() {
  local src_path="$1"
  local worktree_colour="$2"
  local worktree_name="$3"

  echo "${SHOPWORLD_COLOUR}//${src_path}%{$reset_color%} ${worktree_colour}🌳{${worktree_name}}%{$reset_color%}"
}

shop_world_path() {
  local path="${PWD/#$HOME/~}"

  if [[ "$PWD" =~ /world/trees/([^/]+)(/.*)?$ ]]; then
    local worktree_name="$(truncate_name "${match[1]}")"
    local sub_path="${match[2]}"
    local worktree_colour="$(get_worktree_colour "$worktree_name")"

    if [[ "$sub_path" =~ ^/src(/.*)?$ ]]; then
      local src_path="${sub_path#/src}"
      src_path="${src_path#/}"
      format_src_path "$src_path" "$worktree_colour" "$worktree_name"
    else
      echo "${PATH_COLOUR}${path}%{$reset_color%} ${worktree_colour}🌳{${worktree_name}}%{$reset_color%}"
    fi
  else
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

_1LEFT="${TIME_COLOUR}[%D{%r %Z}]%{$reset_color%} \$(shop_world_path) \$(bureau_git_prompt) \$(get_usables)"
_1RIGHT=''

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
