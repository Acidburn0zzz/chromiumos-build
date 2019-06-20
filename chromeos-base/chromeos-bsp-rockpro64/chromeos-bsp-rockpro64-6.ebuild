EAPI=5

DESCRIPTION="RockPro64 BSP package (meta package to pull in driver/tool dependencies)"

inherit systemd cros-audio-configs udev

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="-* arm64 arm"
IUSE="systemd"
USE="bt_deprecated_tools"

DEPEND="
  >=chromeos-base/tty-0.0.1-r99
  >=chromeos-base/chromeos-bsp-baseboard-gru-0.0.3
"

RDEPEND="
  $DEPEND
  net-wireless/bluez
  sys-boot/rockchip-uboot
"

# For now include all dev packages
RDEPEND="$RDEPEND virtual/target-os-dev"

S="${WORKDIR}"

src_install() {
  # Install hciattach to enable hci0
  if use systemd; then
    systemd_dounit "${FILESDIR}/systemd/sdio-hciattach.service"
		systemd_enable_service system-services.target sdio-hciattach.service
  else
    insinto /etc/init
    doins "${FILESDIR}/upstart/sdio-hciattach.conf"
  fi

  # Install mapping for brightness controls
  insinto "/etc/udev/hwdb.d"
  doins "${FILESDIR}"/hwdb/*

  # Install audio config files
  local audio_config_dir="${FILESDIR}/audio-config"
  install_audio_configs kevin "${audio_config_dir}"

  # Install additional scripts
  insinto "/usr/local/bin"
  doins "${FILESDIR}"/scripts/*
}
