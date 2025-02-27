# Define here which branches or tags you want to build for each project
SWAY_VERSION ?= v1.6
WLROOTS_VERSION ?= 0.13.0
KANSHI_VERSION ?= master
WAYBAR_VERSION ?= master
SWAYLOCK_VERSION ?= master
MAKO_VERSION ?= master
WF_RECORDER_VERSION ?= master
CLIPMAN_VERSION ?= master
PIPEWIRE_VERSION ?= master
WDISPLAYS_VERSION ?= master
XDG_DESKTOP_PORTAL_VERSION ?= master
NWG_PANEL_VERSION ?= master
WAYFIRE_VERSION ?= master
WF_CONFIG_VERSION ?= master
WF_SHELL_VERSION ?= master
WCM_VERSION ?= master

ifdef UPDATE
	UPDATE_STATEMENT = git pull;
endif

define BASE_CLI_DEPS
	git \
	mercurial \
	python3-pip
endef

define WLROOTS_DEPS
	wayland-protocols \
	libwayland-dev \
	libegl1-mesa-dev \
	libgles2-mesa-dev \
	libdrm-dev \
	libgbm-dev \
	libinput-dev \
	libxkbcommon-dev \
	libgudev-1.0-dev \
	libpixman-1-dev \
	libsystemd-dev \
	cmake \
	libpng-dev \
	libavutil-dev \
	libavcodec-dev \
	libavformat-dev \
	libxcb-composite0-dev \
	libxcb-icccm4-dev \
	libxcb-image0-dev \
	libxcb-render0-dev \
	libxcb-xfixes0-dev \
	libxkbcommon-dev \
	libxcb-xinput-dev \
	libx11-xcb-dev
endef

define SWAY_DEPS
	libjson-c-dev \
	libpango1.0-dev \
	libcairo2-dev \
	libgdk-pixbuf2.0-dev \
	scdoc
endef

define GTK_LAYER_DEPS
	libgtk-layer-shell-dev \
	libgtk-layer-shell0
endef

define WAYBAR_BUILD_DEPS
	libgtkmm-3.0-dev \
	libspdlog-dev \
	libjsoncpp-dev \
	libfmt-dev \
	libpulse-dev \
	libnl-3-dev \
	libnl-genl-3-dev \
	libappindicator3-dev \
	libdbusmenu-gtk3-dev
endef

define WAYBAR_RUNTIME_DEPS
	libgtkmm-3.0-1v5 \
	libspdlog1 \
	libjsoncpp24 \
	libnl-3-200 \
	libnl-genl-3-200 \
	libdbusmenu-gtk3-4
endef

define SWAYLOCK_DEPS
	libpam0g-dev
endef

define WF_RECORDER_DEPS
	libswscale-dev \
	libavdevice-dev \
	ocl-icd-opencl-dev \
	opencl-c-headers
endef

define CLIPMAN_DEPS
	golang-go
endef

define PIPEWIRE_DEPS
	libgstreamer1.0-dev \
	libgstreamer-plugins-base1.0-dev \
	libasound2-dev \
	libbluetooth-dev \
	libsbc-dev \
	libjack-jackd2-dev \
	libsdl2-dev \
	libsndfile1-dev
endef

define XDG_DESKTOP_PORTAL_DEPS
	libpipewire-0.3-dev \
	libinih-dev
endef

define WDISPLAYS_DEPS
	scour
endef

define NWG_PANEL_DEPS
	python3-pyalsa \
	python3-i3ipc \
	light
endef

define WAYFIRE_DEPS
	doctest-dev \
	libglm-dev \
	libxml2-dev
endef

PIP_PACKAGES=ninja meson

NINJA_CLEAN_BUILD_INSTALL=$(UPDATE_STATEMENT) sudo ninja -C build uninstall; sudo rm build -rf; meson build; ninja -C build; sudo ninja -C build install

## Meta installation targets
yolo: install-repos install-dependencies core apps
core: wlroots-build sway-build
apps: kanshi-build waybar-build swaylock-build mako-build wf-recorder-build clipman-build wofi-build nm-applet-install nwg-panel-install
wf: wf-config-build wayfire-build wf-shell-build wcm-build

## Build dependencies
install-repos:
	@git clone https://github.com/swaywm/sway.git || echo "Already installed"
	@git clone https://github.com/swaywm/wlroots.git || echo "Already installed"
	@git clone https://github.com/emersion/kanshi.git || echo "Already installed"
	@git clone https://github.com/Alexays/Waybar.git || echo "Already installed"
	@git clone https://github.com/mortie/swaylock-effects.git || echo "Already installed"
	@git clone https://github.com/emersion/mako.git || echo "Already installed"
	@git clone https://github.com/ammen99/wf-recorder.git || echo "Already installed"
	@git clone https://github.com/yory8/clipman.git || echo "Already installed"
	@git clone https://github.com/emersion/xdg-desktop-portal-wlr.git || echo "Already installed"
	@git clone https://github.com/luispabon/wdisplays.git || echo "Already installed"
	@git clone https://github.com/nwg-piotr/nwg-panel.git || echo "Already installed"
	@git clone https://github.com/WayfireWM/wf-config.git || echo "Already installed"
	@git clone https://github.com/WayfireWM/wayfire.git || echo "Already installed"
	@git clone https://github.com/WayfireWM/wf-shell.git || echo "Already installed"
	@git clone https://github.com/WayfireWM/wcm.git || echo "Already installed"
	@hg clone https://hg.sr.ht/~scoopta/wofi || echo "Already installed"

install-dependencies: libwayland-1.19
	sudo apt -y install --no-install-recommends \
		$(BASE_CLI_DEPS) \
		$(WLROOTS_DEPS) \
		$(SWAY_DEPS) \
		$(GTK_LAYER_DEPS) \
		$(WAYBAR_BUILD_DEPS) \
		$(WAYBAR_RUNTIME_DEPS) \
		$(SWAYLOCK_DEPS) \
		$(WF_RECORDER_DEPS) \
		$(CLIPMAN_DEPS) \
		$(PIPEWIRE_DEPS) \
		$(WDISPLAYS_DEPS) \
		$(WAYFIRE_DEPS) \
		$(NWG_PANEL_DEPS) \
		$(XDG_DESKTOP_PORTAL_DEPS)

	sudo apt -y install build-essential
	sudo pip3 install $(PIP_PACKAGES) --upgrade

clean-dependencies:
	sudo apt autoremove --purge $(WLROOTS_DEPS) $(SWAY_DEPS) $(GTK_LAYER_DEPS) $(WAYBAR_DEPS) $(SWAYLOCK_DEPS) $(WF_RECORDER_DEPS) $(WDISPLAYS_DEPS) $(XDG_DESKTOP_PORTAL_DEPS)

# Temporary workaround - Sway 1.6+ and wlroots need wayland 1.19 and hirsute does not have it
# packages in debs/ come from debian experimental soooooo.... so far they seem to work fine with sway. Might
# break ubuntu's gnome or kde, dunno
libwayland-1.19:
	sudo dpkg -i debs/libwayland*.deb
	sudo apt -f install

meson-ninja-build:
	cd $(APP_FOLDER); git fetch; git checkout $(APP_VERSION); $(NINJA_CLEAN_BUILD_INSTALL)

## Sway
wlroots-build:
	make meson-ninja-build -e APP_FOLDER=wlroots -e APP_VERSION=$(WLROOTS_VERSION)

sway-build:
	make meson-ninja-build -e APP_FOLDER=sway -e APP_VERSION=$(SWAY_VERSION)
	sudo cp -f $(PWD)/sway/contrib/grimshot /usr/local/bin/

## Apps
kanshi-build:
	make meson-ninja-build -e APP_FOLDER=kanshi -e APP_VERSION=$(KANSHI_VERSION)

waybar-build:
	make meson-ninja-build -e APP_FOLDER=Waybar -e APP_VERSION=$(WAYBAR_VERSION)

swaylock-build:
	make meson-ninja-build -e APP_FOLDER=swaylock-effects -e APP_VERSION=$(SWAYLOCK_VERSION)

mako-build:
	make meson-ninja-build -e APP_FOLDER=mako -e APP_VERSION=$(MAKO_VERSION)

wf-recorder-build:
	make meson-ninja-build -e APP_FOLDER=wf-recorder -e APP_VERSION=$(WF_RECORDER_VERSION)

wdisplays-build:
	make meson-ninja-build -e APP_FOLDER=wdisplays -e APP_VERSION=$(WDISPLAYS_VERSION)

clipman-build:
	cd clipman; git fetch; git checkout $(CLIPMAN_VERSION); go install
	sudo cp -f ~/go/bin/clipman /usr/local/bin/

wofi-build:
	cd wofi; hg pull; hg update; $(NINJA_CLEAN_BUILD_INSTALL)
	sudo cp -f $(shell pwd)/wofi/build/wofi /usr/local/bin/

nm-applet-install:
	sudo dpkg -i debs/network-manager*.deb || sudo apt -f install

nwg-panel-install:
	cd nwg-panel; git checkout $(NWG_PANEL_VERSION); $(UPDATE_STATEMENT) sudo python setup.py install --optimize=1

xdg-desktop-portal-wlr-build:
	cd xdg-desktop-portal-wlr; git fetch; git checkout $(XDG_DESKTOP_PORTAL_VERSION); $(NINJA_CLEAN_BUILD_INSTALL)
	sudo ln -sf /usr/local/libexec/xdg-desktop-portal-wlr /usr/libexec/
	sudo ln -sf /usr/local/share/xdg-desktop-portal/portals/wlr.portal /usr/share/xdg-desktop-portal/portals/

## Wayfire

wf-config-build:
	make meson-ninja-build -e APP_FOLDER=wf-config -e APP_VERSION=$(WF_CONFIG_VERSION)

wayfire-build:
	make meson-ninja-build -e APP_FOLDER=wayfire -e APP_VERSION=$(WAYFIRE_VERSION)

wf-shell-build:
	make meson-ninja-build -e APP_FOLDER=wf-shell -e APP_VERSION=$(WF_SHELL_VERSION)

wcm-build:
	make meson-ninja-build -e APP_FOLDER=wcm -e APP_VERSION=$(WCM_VERSION)
