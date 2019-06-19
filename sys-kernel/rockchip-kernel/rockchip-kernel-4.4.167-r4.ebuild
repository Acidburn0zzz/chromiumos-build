# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_REPO="https://github.com/ayufan-rock64"
CROS_WORKON_COMMIT="a467cfa4f1fb9782fee4c85bd8b62dfcce0d57ad"
CROS_WORKON_EGIT_BRANCH="release-4.4-cros"
CROS_WORKON_PROJECT="linux-kernel"
CROS_WORKON_LOCALNAME="linux-kernel"
CROS_WORKON_INCREMENTAL_BUILD="1"

DEPEND="!sys-kernel/chromeos-kernel-4_4"
RDEPEND="${DEPEND}"

# AFDO_PROFILE_VERSION is the build on which the profile is collected.
# This is required by kernel_afdo.
#
# TODO: Allow different versions for different CHROMEOS_KERNEL_SPLITCONFIGs

# Auto-generated by PFQ, don't modify.
AFDO_PROFILE_VERSION="R77-12236.0-1559554500"

# Set AFDO_FROZEN_PROFILE_VERSION to freeze the afdo profiles.
# If non-empty, it overrides the value set by AFDO_PROFILE_VERSION.
# Note: Run "ebuild-<board> /path/to/ebuild manifest" afterwards to create new
# Manifest file.
AFDO_FROZEN_PROFILE_VERSION=""

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

HOMEPAGE="https://github.com/ayufan-rock64/linux-kernel/"
DESCRIPTION="Rockchip Linux Kernel 4.4"
KEYWORDS="*"

src_install() {
  local kernel_dir=$(cros-workon_get_build_dir)
  local kernel_arch=${CHROMEOS_KERNEL_ARCH:-$(tc-arch-kernel)}
  local kernel_version=$(kernelrelease)

  info "Install /boot/"
	dodir /boot
	kmake INSTALL_PATH="${D}/boot" install

  info "Install /usr/lib/debug/boot/"
	insinto /usr/lib/debug/boot
	doins "$(cros-workon_get_build_dir)/vmlinux"

  info "Install /lib/modules/"
  kmake INSTALL_MOD_PATH="${D}" INSTALL_MOD_STRIP="magic" \
    STRIP="$(eclass_dir)/strip_splitdebug" \
    modules_install

  info "Install /boot/dtbs/"
	kmake INSTALL_DTBS_PATH="${D}/boot/dtbs/$(kernelrelease)" dtbs_install

  info "Install ${D}/boot/extlinux.conf"
  cat > "${kernel_dir}/extlinux.conf" <<EOF
menu title Boot Menu
timeout 20

label dev-4.4.167-rockchip-dev
    kernel /boot/vmlinuz-4.4.167-rockchip-dev
    devicetreedir /boot/dtbs/4.4.167-rockchip-dev
    append earlyprintk console=ttyS2,1500000n8 rw root=/dev/mmcblk0p3 rootfstype=ext4 init=/sbin/init rootwait cros_debug loglevel=7 dm_verity.error_behavior=3 dm_verity.max_bios=-1 dm_verity.dev_wait=0 dm="1 vroot none ro 1,0 2539520 verity payload=/dev/mmcblk0p3 hashtree=HASH_DEV hashstart=2539520 alg=sha1 root_hexdigest=a1910fbe4a24a30d19a49b85d2889776251e54e3 salt=c520b38f1057e5bef0aa64c00cd0d2e50662e22bf19771278921f90a35fd616d" vt.global_cursor_default=0 ethaddr=\${ethaddr} eth1addr=\${eth1addr} serial=\${serial#}

label rockchip-${kernel_version}
    kernel /boot/vmlinuz-${kernel_version}
    devicetreedir /boot/dtbs/${kernel_version}
    append earlyprintk console=ttyS2,1500000n8 rw root=/dev/mmcblk0p3 rootfstype=ext4 init=/sbin/init rootwait cros_debug loglevel=7 dm_verity.error_behavior=3 dm_verity.max_bios=-1 dm_verity.dev_wait=0 dm="1 vroot none ro 1,0 2539520 verity payload=/dev/mmcblk0p3 hashtree=HASH_DEV hashstart=2539520 alg=sha1 root_hexdigest=a1910fbe4a24a30d19a49b85d2889776251e54e3 salt=c520b38f1057e5bef0aa64c00cd0d2e50662e22bf19771278921f90a35fd616d" vt.global_cursor_default=0 ethaddr=\${ethaddr} eth1addr=\${eth1addr} serial=\${serial#}

label rockchip-${kernel_version}-ro
    kernel /boot/vmlinuz-${kernel_version}
    devicetreedir /boot/dtbs/${kernel_version}
    append earlyprintk console=ttyS2,1500000n8 ro root=/dev/mmcblk0p3 rootfstype=ext4 init=/sbin/init rootwait cros_debug loglevel=7 dm_verity.error_behavior=3 dm_verity.max_bios=-1 dm_verity.dev_wait=0 dm="1 vroot none ro 1,0 2539520 verity payload=/dev/mmcblk0p3 hashtree=HASH_DEV hashstart=2539520 alg=sha1 root_hexdigest=a1910fbe4a24a30d19a49b85d2889776251e54e3 salt=c520b38f1057e5bef0aa64c00cd0d2e50662e22bf19771278921f90a35fd616d" vt.global_cursor_default=0 ethaddr=\${ethaddr} eth1addr=\${eth1addr} serial=\${serial#}
EOF

  insinto "/boot/extlinux"
  doins "${kernel_dir}/extlinux.conf"
}
