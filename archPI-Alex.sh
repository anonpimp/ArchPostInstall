#!/bin/bash
#
# Facilitate post installation Arch Linux in minutes personalizated.
#
# Website:       https://archlinux.org/
# Author:        Emanuel Pereira
# Maintenance:   Emanuel Pereira
#
# ------------------------------------------------------------------------ #
# WHAT IT DOES?
# This script can be called by the normal way using "./".
#
# CONFIGURATION?
# I recommend that you open it in your favorite text editor and customize it with whatever packages you want.
#
# HOW TO USE IT?
# Examples:
# $ ./post-installation_arch-linux.sh
#
# ------------------------------------------------------------------------ #
# Changelog:
#
#   v1.0 02/03/2023, Emanuel Pereira:
#     - Massive update!
#     - Bugs corrections
#     - Add new command lines
#
# ------------------------------------------------------------------------ #
# Tested on:
#   bash 5.1.016-3
#   zsh 5.9-3
# ------------------------------------------------------------------------ #
DIRETORY_TEMP='$HOME/.tpm/'
DIRETORY_DOWNLOAD='$HOME/Downloads/'
create_temporary_post_install_folder () {
	if [[ ! -d "$DIRETORY_TEMP" ]]; then
	mkdir .tmp
	fi
	cd .tmp
}
add_multilib_repository_color_cache_cleaner () {
	sudo nano /etc/pacman.conf
# uncomment the lines (remove the # in front):
#	CleanMethod = KeepInstalled KeepCurrent
#	Color
#	ILoveCandy
#	[mulitlib]
#	Include=/etc/pacman.d/mirrorlist
	sudo pacman -Syuu
	sudo pacman -Sy --needed --noconfirm curl rsync reflector git
	sudo reflector --country BR --sort rate --save /etc/pacman.d/mirrorlist
#	sudo reflector -c brazil -f 5 --save /etc/pacman.d/mirrorlist
# if necessary, acess https://archlinux.org/mirrorlist/, copy mirrors and use sudo nvim /etc/pacman.d/mirrorlist to customize mirrorlist.
#
## Brazil
#Server = https://mirror.ufscar.br/archlinux/$repo/os/$arch
## Brazil
#Server = http://mirror.ufscar.br/archlinux/$repo/os/$arch
## Brazil
#Server = http://archlinux.c3sl.ufpr.br/$repo/os/$arch
## Brazil
#Server = http://linorg.usp.br/archlinux/$repo/os/$arch
## Brazil
#Server = http://br.mirror.archlinux-br.org/$repo/os/$arch
}
install_yay () {
	sudo pacman -S git base-devel --noconfirm
	git clone https://aur.archlinux.org/yay.git 
	cd yay
	makepkg -si
	yay -Y --gendb
	rm -rf /yay
	cd ..
	sudo rm -rf yay/
	sudo nano /etc/makepkg.conf
# uncomment and add "j" (OBS.: beside the "J", add half of your processor's total cpu cores.
#   MAKEFLAGS="-j6"
}
install_zsh_terminal-customizations () {
	sudo pacman -S zsh yarn npm zsh-history-substring-search zsh-syntax-highlighting zsh-autosuggestions zsh-theme-powerlevel10k powerline-fonts awesome-terminal-fonts ttf-meslo-nerd --noconfirm
#	echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
	cargo install bat exa procs tokei ytop tealdeer grex rmesg zoxide   
# edit .zshrc include this parameters.
# Zsh plugins.
#   source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-history-substring-search.zsh
#   source /usr/share/zsh/pluginsl/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#   source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# LunarVim dependence.
#   export PATH=~/.cargo/bin:~/.local/bin:$PATH
	chsh -s /usr/bin/zsh
    mkdir ~/Imagens/Archlinux
    cp -r ~/post-installation_arch-linux/assets/images/archlinux-official-light2.png ~/Imagens/Archlinux
    cp -r ~/post-installation_arch-linux/.bash_aliases ~/post-installation_arch-linux/.bashrc ~/post-installation_arch-linux/.zsh_aliases ~/post-installation_arch-linux/.zshrc ~/
}
install_themes_wallpapers_and_extensions () {
	paru -S --noconfirm adw-gtk-theme adwaita-dark xcursor-simp1e-adw-dark
	sudo pacman -S archlinux-wallpaper papirus-icon-theme --noconfirm
	paru -S --noconfirm papirus-folders
	sudo papirus-folders -C yellow --theme Papirus-Dark
	mkdir ~/.themes
	cd /usr/share/themes
	sudo cp -fR Adw Adw-dark adw-gtk3 adw-gtk3-dark ~/.themes
	sudo flatpak override --filesystem=$HOME/.themes
	sudo flatpak override --env=GTK_THEME=Adw-dark
	cd DIRETORY_TEMP
	git clone https://github.com/rafaelmardojai/firefox-gnome-theme && cd firefox-gnome-theme
	./scripts/auto-install.sh
	cd DIRETORY_TEMP
    gnome-tweaks
# select themes and icon themes.
}
install_qt5ct () {
	sudo pacman -S qt5ct --noconfirm
	sudo nvim /etc/environment
# add "QT_QPA_PLATFORMTHEME=qt5ct" in end-line. 
}
install_plymouth_silent_boot_config_grub () {
	paru -S plymouth gdm-plymouth plymouth-theme-arch-charge-big
	git clone https://github.com/AdisonCavani/distro-grub-themes.git
	sudo nvim /etc/mkinitcpio.conf
# add:
# 	MODULES="btrfs i915"        
# 	HOOKS=(base udev systemd sd-plymouth ... filesystems resume fsck)
	sudo nvim /etc/sysctl.d/20-quiet-printk.conf
# add "kernel.printk = 3 3 3 3" in end-line.
	sudo nvim /etc/default/grub
# add:
#   GRUB_DEFAULT=“0”
#	GRUB_TIMEOUT=“0”
#	GRUB_RECORDFAIL_TIMEOUT=$GRUB_HIDDEN_TIMEOUT
#	GRUB_CMDLINE_LINUX_DEFAULT="rw quiet splash loglevel=3 bgrt_disable rd.systemd.show_status=auto rd.udev.log_priority=3 vt.global_cursor_default=0 vga=current"
#
#   GRUB_TIMEOUT_STYLE=“hidden”
#	GRUB_HIDDEN_TIMEOUT=3
#
	sudo pacman -S grub-customizer --noconfirm
	grub-customizer
# open the grub-customizer, click on the Arch Linux entry and click edit. After that, pay all the lines with echo:
# 	echo ‘Loading Linux linux …’
#	echo ‘Loading initial ramdisk …’
# install theme, click on "appearance settings" tab, in "Custom resolution" and select or type in your resolution, e.g 1920x1080.
# in "theme" tab, click on "+" and select your "theme.tar" favorite in "distro-grub-themes" folder.
#
	sudo systemctl edit --full systemd-fsck-root.service
# add below ExecStart:
# 	StandardOutput=null
# 	StandardError=journal+console
	sudo systemctl edit --full systemd-fsck@.service
# add below ExecStart:
#   	StandardOutput=null
#	StandardError=journal+console
#
	sudo nano /etc/plymouth/plymouthd.conf
# set "DeviceTimeout=5" in end-line
#
	sudo plymouth-set-default-theme -R arch-charge-big
	sudo mkinitcpio -P linux; sudo grub-mkconfig -o /boot/grub/grub.cfg
}
install_video_drivers_add-ons () {
# uncomment the respective brand of your video card.
#
# Nvidia
	sudo pacman -S --needed nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm		
# AMD
#	sudo pacman -S --needed lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm
# Intel
#	sudo pacman -S --needed lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm
}
app_store () {
	sudo pacman -Rsc gnome-software --noconfirm
#	sudo pacman -S gnome-software-packagekit-plugin
	paru -S pamac-flatpak-gnome
}
install_wine_staging_and_dependencies () {
	sudo pacman -S wine-staging winetricks wine-mono wine-gecko --noconfirm
	sudo pacman -S --needed wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls \
mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error \
lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo \
sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama \
ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 \
lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm
}
install_lutris_and_dependencies () {
	sudo pacman -S zenity gcc-libs gnutls vulkan-validation-layers vulkan-intel vulkan-radeon vulkan-icd-loader libva fontconfig lcms2 libxml2 libxcursor libxrandr libxdamage libxi gettext freetype2 glu libsm libpcap faudio giflib libpng libldap mpg123 openal v4l-utils libpulse alsa-lib alsa-plugins libjpeg-turbo libxcomposite libxinerama ocl-icd libxslt gst-plugins-base-libs vkd3d sdl2 sdl2_ttf sdl2_image sdl2_net libcups libidn11 pixman zlib mesa ncurses krb5 libxcb cairo libx11 libx86emu libxss libgphoto2 sane noto-fonts-emoji lib32-glibc lib32-gcc-libs lib32-gnutls lib32-vulkan-validation-layers lib32-vulkan-intel lib32-vulkan-radeon lib32-vulkan-icd-loader lib32-libva lib32-fontconfig lib32-lcms2 lib32-libxml2 lib32-libxcursor lib32-libxrandr lib32-libxdamage lib32-libxi lib32-gettext lib32-freetype2 lib32-glu lib32-libsm lib32-faudio lib32-libpcap lib32-giflib lib32-libpng lib32-libldap lib32-mpg123 lib32-openal lib32-v4l-utils lib32-libpulse lib32-alsa-lib lib32-alsa-plugins lib32-libjpeg-turbo lib32-libxcomposite lib32-libxinerama lib32-ocl-icd lib32-libxslt lib32-gst-plugins-base-libs lib32-vkd3d lib32-sdl2 lib32-sdl2_ttf lib32-sdl2_image lib32-libcups lib32-libidn11 lib32-pixman lib32-zlib lib32-mesa lib32-cairo lib32-libx11 lib32-libxcb lib32-krb5 lib32-ncurses lib32-libxss gamemode lib32-gamemode --noconfirm
}
install_remaining_drivers_and_dependencies () {
	sudo pacman -S bluez-utils libgda foomatic-db foomatic-db-engine foomatic-db-gutenprint-ppds foomatic-db-nonfree-ppds foomatic-db-ppds fprintd gutenprint libfprint system-config-printer cups cups-pdf bluez-cups print-manager sane-airscan sane-gt68xx-firmware noto-fonts ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid ttf-ibm-plex ttf-liberation inter-font gtk2 java-rhino openjdk-src jdk-openjdk jre-openjdk-headless jre-openjdk gvfs-goa gvfs-google mtpfs gvfs-mtp gvfs-gphoto2 bash-completion ffmpegthumbnailer ffmpegthumbs noto-fonts-emoji ntfs-3g android-tools unrar libquvi faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libxv opus wavpack x264 xvidcore ffmpeg ffmpeg4.4 gst-plugins-ugly gst-plugins-good gst-plugins-base gst-plugins-bad gst-libav gstreamer fwupd gnome-firmware gufw ufw-extras --noconfirm
	sudo systemctl enable --now cups
	sudo usermod -aG lp
	sudo usermod -aG saned,scanner
}
remove_startup_beep () {
	sudo rmmod pcspkr
	sudo nvim /etc/modprobe.d/nobeep.conf
# add "blacklist pcspkr" in end-line.
}
re-enable_GNOME_battery_consumption_modes-43 () {
	sudo pacman -S power-profiles-daemon --noconfirm
}
install_apps () {
	sudo pacman -S gnome-sound-recorder gnome-boxes --noconfirm
	paru -S menulibre freedownloadmanager gdm-settings adwaita-qt6 adwaita-qt5 gthumb qt6ct gparted python-librosa epson-inkjet-printer-escpr
	flatpak install flathub io.github.Foldex.AdwSteamGtk com.github.unrud.VideoDownloader org.gimp.GIMP com.heroicgameslauncher.hgl net.davidotek.pupgui2 com.github.neithern.g4music com.discordapp.Discord com.valvesoftware.Steam com.mattjakeman.ExtensionManager net.lutris.Lutris net.pcsx2.PCSX2 org.citra_emu.citra org.yuzu_emu.yuzu com.valvesoftware.Steam.Utility.MangoHud org.freedesktop.Platform.VulkanLayer.MangoHud net.rpcs3.RPCS3 org.gnome.World.PikaBackup -y
#
# put the apps you want to install together here.
# after installing the "Extension Manager", install your favorites extensions.
#	Alphabetical Grid Extension
#	Appindicator
#	Arc-menu 
#	Arch Update
#	Dash-to-dock
#	Gsconnect 
#	GTK Title Bar 
#	Just Perfection
#	Keep Awake
#	Panel-corners
#	Quick Settings Tweaker 
#	Rounded-window-corners
}
create_zramd () {
	paru -S zramd --noconfirm
	sudo nvim /etc/default/zramd
# add in "Max total swap size" in "MAX_SIZE=2048"
	sudo systemctl enable --now zramd.service
}
bugs_corrections () {
	nvim ~/.config/mimeapps.list
# add "inode/directory=org.gnome.Nautilus.desktop" in [Default Applications] line, to remove visual studio code for default.
}
install_cache_remove_and_remove_temporary_files () {
	sudo pacman -S pacman-contrib gnome-terminal --noconfirm
	sudo pacman -Rsc gnome-contacts gnome-console gnome-music htop vim epiphany gnome-maps eog
#	sudo pacman -Sc --noconfirm
#	sudo paccache -r --noconfirm
#	paccache -ruk0 --noconfirm
#	sudo flatpak uninstall --unused
	cd ..
	rm -rf /.tmp
}
finalization () {
    echo "Finished! Reboot your system now!" 
}
#------------------------------------------------------------------------ #
# Commands (uncomment the ones you want to use)
#------------------------------------------------------------------------ #
create_temporary_post_install_folder
add_multilib_repository_color_cache_cleaner
install_yay
#install_zsh_terminal-customizations
install_themes_wallpapers_and_extensions
install_qt5ct
install_plymouth_silent_boot_config_grub
install_video_drivers_add-ons
app_store
install_wine_staging_and_dependencies
install_lutris_and_dependencies
install_remaining_drivers_and_dependencies
add_locales
remove_startup_beep
re-enable_GNOME_battery_consumption_modes-43
install_apps
create_zramd
bugs_corrections
install_cache_remove_and_remove_temporary_files
finalization