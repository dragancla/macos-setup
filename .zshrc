# P10K and ZSH config
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  z
)

source ~/.oh-my-zsh/oh-my-zsh.sh
source ~/.p10k.zsh

# Files
alias hosts="open -a 'Visual Studio Code' /private/etc/hosts"
alias zshrc="open -a 'Visual Studio Code' ~/.zshrc"
alias sourcezsh="source ~/.zshrc"

# Git
alias status='git status'
alias add='git add'
alias branch='git branch'
alias checkout='git checkout'
alias switch='git switch'
alias build='git commit --allow-empty -m '\''trigger build'\'' && push'
alias clone='git clone'
alias commit='git commit -m'
alias delete='git branch -D'
alias fetch='git fetch'
alias newbranch='git checkout -b'
alias prune='git prune'
alias pull='git pull'
alias push='git push --set-upstream origin "$(git rev-parse --abbrev-ref HEAD)"'
alias reset='git reset --hard'
alias resetfile='git checkout origin/master'
alias revert='git reset HEAD~1'
alias untrack='git restore --staged'
alias stash='git stash push -m'
unstash () {
  git stash apply stash^{/$1}
}
pr () {
  url=$(git config --get remote.origin.url) 
  removeHttps=(${url##https://}) 
  removeGit=(${removeHttps##*@}) 
  replaceColon=(${removeGit//://}) 
  parsedRemote=(${replaceColon//.git/}) 
  branch=$(git rev-parse --abbrev-ref HEAD) 
  prLink="https://$parsedRemote/compare/$branch" 
  echo -e "\e]8;;$prLink\e\\$prLink\e]8;;\e\\"
}

# Cleanup
killport () {
  lsof -nti:$1 | xargs kill -9
}
killapp () {
  GRN='\033[0;32m'
  YLW='\033[1;33m'
  NC='\033[0m'
  SUCCESS=$GRN"Success"$NC
  INFO=\\n$YLW"Info"$NC
  count=`ps aux | grep -v "grep" | grep -ci $1`
  klevel=${2:-9} 
  printf "$INFO: Terminating $count running processes matching the name $1...\n"
  ps aux | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} -i $1 | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} -v grep | awk '{print $2}' | xargs sudo kill -$klevel
  printf "$SUCCESS: Killed all processes!"
  secondCount=`ps aux | grep -v "grep" | grep -ci $1`
  printf "$INFO: Number of remaining processes with that name: $secondCount\n"
}
killprocess(){
  lsof -nti:$1 | xargs pkill 
}
dockerclean(){
  docker-compose down
  docker container prune -f
}
nuke_docker(){
  # containers=$(docker ps -a -q)
  # volumes=$(docker volume ls -q)
  # images=$(docker images -a -q)
  docker-compose down --rmi all
  docker container prune -f
  docker image prune -a -f
  docker volume prune -f
}
