pacmd list-cards
pacmd set-card-profile 1 a2dp_sink
git reflog
mvn clean deploy -Dmaven.compiler.showDeprecation -DskipTests
mvn clean deploy -Dmaven.compiler.showDeprecation
mvn clean install -Dmaven.compiler.showDeprecation -DskipTests
mvn clean install -Dmaven.compiler.showDeprecation
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk/
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk/
ps -ef | grep -i chrom | awk '{print $2}' | xargs kill -9
ps -ef | grep -i idea | awk '{print $2}' | xargs kill -9
ps -ef | grep -i lxpanel | awk '{print $2}' | xargs kill -9
bluetoothctl power on
bluetoothctl power off
makepkg -si
ffplay /dev/video0
disown
reboot
sh -c 'xrandr --output HDMI-2 --off --output eDP-1 --mode 1920x1080 --rate 60'
sh -c 'xrandr --output HDMI-2 --mode 2560x1080 --rate 60.00 --output eDP-1 --off'
git clone git@github.com:SmirnovKirill/subtitle_merger.git
git remote set-url origin git@github.com:SmirnovKirill/arch_installation.git
setxkbmap -model pc105 -layout us,ru -option grp:alt_shift_toggle
pcmanfm .
ffmpeg -i ~/in.mkv -map 0:v -map 0:a -map 0:s -vcodec copy -acodec aac -b:a 384k -scodec copy ~/out.mkv
ffmpeg -i ~/in.mp3 -map 0:a -acodec copy -map_metadata -1 ~/out.mp3
/opt/AmneziaVPN/client/AmneziaVPN.sh &
sudo systemctl restart dnsmasq
sudo systemctl restart nftables
sudo pacman -S archlinux-keyring
sudo yay -Syu
sudo pacman -Syu
/opt/intellij-idea-ultimate-edition/bin/idea disableNonBundledPlugins nosplash
sudo journalctl -g 'error' -r