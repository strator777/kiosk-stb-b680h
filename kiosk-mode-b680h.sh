#!/bin/bash

# be new
apt-get update
apt-get upgrade

# get software
apt-get install \
    unclutter \
    xorg \
    xserver-xorg-video-fbdev \
    xinit \
    firefox-esr \
    openbox \
    lightdm \
    accountsservice \
    -y

# dir
mkdir -p /home/kiosk/.config/openbox
mkdir -p /var/lib/lightdm/data

# create group
groupadd kiosk

# create user if not exists
id -u kiosk &>/dev/null || useradd -m kiosk -g kiosk -s /bin/bash 

# rights
chown -R kiosk:kiosk /home/kiosk
chown lightdm:lightdm /var/lib/lightdm/data

# remove virtual consoles
if [ -e "/etc/X11/xorg.conf" ]; then
  mv /etc/X11/xorg.conf /etc/X11/xorg.conf.backup
fi
cat > /etc/X11/xorg.conf << EOF
Section "Device"
    Identifier "Framebuffer Device"
    Driver     "fbdev"
    Option     "fbdev" "/dev/fb0"  # Ganti ini sesuai dengan perangkat framebuffer kamu
    BusID      "PCI:0:0:0"          # Ganti ini jika BusID dibutuhkan (biasanya tidak diperlukan untuk framebuffer)
EndSection
EOF

# create config
if [ -e "/etc/lightdm/lightdm.conf" ]; then
  mv /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.backup
fi
cat > /etc/lightdm/lightdm.conf << EOF
[SeatDefaults]
autologin-user=kiosk
user-session=openbox
EOF

# create autostart
if [ -e "/home/kiosk/.config/openbox/autostart" ]; then
  mv /home/kiosk/.config/openbox/autostart /home/kiosk/.config/openbox/autostart.backup
fi
cat > /home/kiosk/.config/openbox/autostart << EOF
#!/bin/bash

unclutter -idle 0.1 -grab -root &

while :
do
  xrandr --auto
  firefox-esr --kiosk "https://chatgpt.com"
  xset s off
  xset s noblank
  xset -dpms
done &
EOF

echo "Done!"
