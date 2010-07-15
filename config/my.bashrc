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

export TEMP="/tmp"

export SCRIPTS_DIR="$HOME/scripts"
export SCRIPTY_DIR="$HOME/scripts/scripty"
export PATH=$PATH:$SCRIPTS_DIR
# Add everything under scripty to path
export PATH="${PATH}$(find $SCRIPTY_DIR -name '.*' -prune -o -type d -printf ':%p')"

alias cds="cd $SCRIPTS_DIR"
alias cdss="cd $SCRIPTY_DIR"

########## Useful for server
alias arestart="sudo service apache2 restart"
alias lrestart="sudo service lighttpd restart"
alias nrestart="sudo service nginx restart"
alias rrestart="sudo service redmine restart"

alias psmem="sudo python $SCRIPTY_DIR/third_party/ps_mem.py"

########## Useful in intranet
export http_proxy=

########## Useful only in my laptop
alias wiki="wine /media/OS/wikitaxi/WikiTaxi.exe /media/OS/wikitaxi/enwiki-20100312-pages-articles.taxi Venkata"
alias mediacoder="wine /media/OS/Program\ Files/MediaCoder/mediacoder.exe"
alias selenium_rc_start="java -jar $HOME/scripts/selenium/selenium-server-1.0.3/selenium-server.jar"

alias mount_lan_server="smbmount //192.168.2.253/E\$ /media/lan_server -o user=SERVERMCA/bca3 password="

########## Rackspace related
export MYSERVER="rmvadmin@173.203.194.68"

alias rackspace="sshfs $MYSERVER:/home/rmvadmin/ /media/rackspace"
alias sshrackspace="ssh $MYSERVER"


if [ -f ~/.my.secret.bashrc ]; then
    . ~/.my.secret.bashrc
fi
