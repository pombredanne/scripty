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

alias cls=clear

alias wiki="wine /media/OS/wikitaxi/WikiTaxi.exe /media/OS/wikitaxi/enwiki-20100312-pages-articles.taxi Venkata"
alias mediacoder="wine /media/OS/Program\ Files/MediaCoder/mediacoder.exe"
alias p="ping google.com"
alias mount_mca="smbmount //192.168.1.250/f\$ /media/mca_server -o user=mca1"

export TEMP="/tmp"

export SCRIPTS_DIR="~/scripts"
export SCRIPTY_DIR="~/scripts/scripty"
export PATH=$PATH:$SCRIPTS_DIR:$SCRIPTY_DIR

export MYSERVER="rmvadmin@173.203.194.68"

alias cds="cd $SCRIPTS_DIR"
alias rackspace="sshfs $MYSERVER:/home/rmvadmin/ /media/rackspace"
alias sshrackspace="ssh $MYSERVER"
alias fgrep="find . -name \* -print0 | xargs -0 grep -i "
alias selenium_rc_start="java -jar /home/ramana/Scripts/selenium/selenium-server-1.0.3/selenium-server.jar"
alias psmem="sudo python $SCRIPTY_DIR/third_party/ps_mem.py"

alias vi="/usr/bin/vim"

alias arestart="sudo service apache2 restart"
alias lrestart="sudo service lighttpd restart"
alias nrestart="sudo service nginx restart"
alias rrestart="sudo service redmine restart"

if [ -f ~/.my.secret.bashrc ]; then
    . ~/.my.secret.bashrc
fi
