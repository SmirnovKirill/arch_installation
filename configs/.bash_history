ssh ts62.pyn.ru
ssh oper
pacmd list-cards
pacmd set-card-profile 1 a2dp_sink
git reflog
mvn clean install
mvn clean install -DskipTests
mvn clean deploy
mvn clean deploy -DskipTests
eval `ssh-agent`
ssh-add ~/.ssh/pkey.hh
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk/
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk/
ps -ef | grep -i chrom | awk '{print $2}' | xargs kill -9
ps -ef | grep -i idea | awk '{print $2}' | xargs kill -9
ps -ef | grep -i lxpanel | awk '{print $2}' | xargs kill -9
pulseaudio -k
bluetoothctl
makepkg -si
ffplay /dev/video0
disown
reboot
sh -c 'xrandr --output HDMI-2 --off --output eDP-1 --mode 1920x1080 --rate 60'
sh -c 'xrandr --output HDMI-2 --mode 2560x1080 --rate 60.00 --output eDP-1 --off'