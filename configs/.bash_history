ssh ts62.pyn.ru
ssh oper1
pacmd list-cards
pacmd set-card-profile 1 a2dp_sink
git reflog
mvn clean deploy -Dmaven.compiler.showDeprecation -DskipTests
mvn clean deploy -Dmaven.compiler.showDeprecation
mvn clean install -Dmaven.compiler.showDeprecation -DskipTests
mvn clean install -Dmaven.compiler.showDeprecation
mvn test-stand:skaffold-debug-start
mvn clean compile -PopenapiFromStand -Dcheckstyle.skip=true 
eval `ssh-agent`
ssh-add ~/.ssh/pkey.hh
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk/
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk/
ps -ef | grep -i chrom | awk '{print $2}' | xargs kill -9
ps -ef | grep -i idea | awk '{print $2}' | xargs kill -9
ps -ef | grep -i lxpanel | awk '{print $2}' | xargs kill -9
pulseaudio -k
bluetoothctl power on
bluetoothctl power off
makepkg -si
ffplay /dev/video0
disown
reboot
sh -c 'xrandr --output HDMI-2 --off --output eDP-1 --mode 1920x1080 --rate 60'
sh -c 'xrandr --output HDMI-2 --mode 2560x1080 --rate 60.00 --output eDP-1 --off'
git clone git@forgejo.pyn.ru:hhru/hh.ru
setxkbmap -model pc105 -layout us,ru -option grp:alt_shift_toggle
scp k.smirnov@log2:/tmp/file /tmp/
python -m venv venv
source venv/bin/activate
python -m pip install -r requirements.txt
poetry install
poetry run pytest
pys format .
pcmanfm .
ffmpeg -i ~/in.mkv -map 0:v -map 0:a -map 0:s -vcodec copy -acodec aac -b:a 384k -scodec copy ~/out.mkv
ffmpeg -i ~/in.mp3 -map 0:a -acodec copy -map_metadata -1 ~/out.mp3
/opt/AmneziaVPN/client/AmneziaVPN.sh &
/opt/cisco/anyconnect/bin/vpnui &
sudo resolvectl status
sudo systemctl restart systemd-resolved
sudo pacman -S archlinux-keyring
sudo yay -Syu
sudo pacman -Syu
~/.local/bin/hhtilt java -a negotiations -m server -t ts62.pyn.ru -d 4205 -f
ncdu