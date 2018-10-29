#!/bin/sh

set -ex

source installation_variables.sh

#локаль, время
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
timedatectl set-ntp true
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf 

#программы
#xorg-xrandr чтобы управлять разрешением экрана
#lxde-common минимальные требования lxde
#lxsession минимальные требования lxde
#pinta редактор
pacman -S \
  xorg-server \
  xorg-xrandr \
  openbox \
  lxde-common \
  lxsession \
  lxpanel \
  lxdm \
  lxterminal \
  pcmanfm \
  ttf-dejavu \
  zip \
  unzip \
  imagemagick \
  gpicview \
  pinta

#отключаем возможность логиниться рутом
passwd -l root

echo "EDITOR=vim" >> /etc/environment
echo "SUDO_EDITOR=vim" >> /etc/environment

#14 раскомментировать TotalDownload в /etc/pacman.conf

#15.2 systemctl enable lxdm
#15.3 положить lxdm.conf в /etc/lxdm/lxdm.conf

#Вытащить диск/флешку.

#1 ~/.config/openbox/lxde-rc.xml
#1.1 в desktops->number поменять с 2 на 1
#1.2 где <context name="Titlebar"> дописать
 #     <mousebind button="Left" action="Drag">
  #      <action name="if">
   #       <maximized>yes</maximized>
    #        <then>	
     #         <action name="Unmaximize"/>
      #        <action name="MoveResizeTo">
	     #   <x>center</x>
        #        <y>0</y>
         #     </action>
          #  </then>
	#</action>
  #      <action name="Move"/>
   #   </mousebind>
    #  <mousebind button="Left" action="DoubleClick">
     #   <action name="ToggleMaximizeFull"/>
     # </mousebind>
#1.3 поменять размер шрифтов с 10 на 14
#1.4 убрать биндинги execute
#1.5 добавить скриншоты


#2 ~/.config/lxpanel/LXDE/panels/panel
#2.1 стереть Button firefox.desktop, убрать следующий space, iconify, space, pager, space, cpu, launchbar
#2.2 добавить плагин xkb
#2.3 поставить tray перед звуком и сменой раскладки

#3 ~/.config/pcmanfm/LXDE/desktop*
#3.1 поменять обои

#cp desktop.jpg /usr/share/lxde/wallpapers/
#cp desktop-items-0.conf /home/kirill/.config/lxpanel/LXDE/panels/
#cp lxde-rc.xml /home/kirill/.config/openbox/
#cp lxdm.conf /etc/lxdm/
#cp panel /home/kirill/.config/lxpanel/LXDE/panels/
