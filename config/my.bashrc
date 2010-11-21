# Add this to your ~/.bashrc file
# if [ -f ~/.my.bashrc ]; then
#     . ~/.my.bashrc
# fi


# Set downloaded file max size to 2MB.
httrack()
{
  /usr/bin/httrack -m2000000 $1 -*.tar.gz -*.exe -*.zip -*.bz2
}

run()
{
  chmod +x $1
  source $1
}

########## Frequently used
alias cls=clear
alias p="ping google.com"
alias fgrep="find . -name \* -print0 | xargs -0 grep -i "
alias vi="/usr/bin/vim"
alias py="ipython -nobanner -noconfirm_exit -pprint"

export TEMP="/tmp"

export SCRIPTS_DIR="/scripts"
export SCRIPTY_DIR="/scripts/scripty"
export scripty="/scripts/scripty"
export PATH=$PATH:$SCRIPTS_DIR
# Add everything under scripty to path
export PATH="${PATH}$(find $SCRIPTY_DIR -name '.*' -prune -o -type d -printf ':%p')"

alias cds="cd $SCRIPTS_DIR"
alias cdss="cd $SCRIPTY_DIR"

alias hgsync="hg push; hg fetch"

########## Useful for server
alias arestart="sudo service apache2 restart"
alias nrestart="sudo service nginx restart"
alias rrestart="sudo service redmine restart"

alias psmem="sudo python $SCRIPTY_DIR/third_party/ps_mem.py"

########## Rackspace related
export MYSERVER="rmvadmin@173.203.194.68"

alias rackspace="sshfs $MYSERVER:/home/rmvadmin/ /media/rackspace"
alias sshrackspace="ssh $MYSERVER"

########## General
export WORKON_HOME=/virtualenvs
export PIP_DOWNLOAD_CACHE=/virtualenvs/download_cache
source /usr/local/bin/virtualenvwrapper.sh
source ~/.django_bash_completion

if [ -f ~/.my.secret.bashrc ]; then
    . ~/.my.secret.bashrc
fi
