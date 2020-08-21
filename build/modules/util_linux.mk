include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

$(call gen_module_depends,linux ncurses readline libtinfo librt)

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,UTIL_LINUX_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,UTIL_LINUX_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,UTIL_LINUX_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,UTIL_LINUX_TARGET_MAKE_ARGS)

# util_linux make invocation macro.
util_linux_make = $(call autotools_target_make, \
                         $(1), \
                         $(UTIL_LINUX_TARGET_MAKE_ARGS))

# Location of staged util_linux
util_linux_staging_bindir  := $(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/bin
util_linux_staging_sbindir := $(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/sbin
util_linux_staging_libdir  := $(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/lib

# Location of bundled util_linux
util_linux_bundle_bindir   := $(bundle_rootdir)$(UTIL_LINUX_TARGET_PREFIX)/bin
util_linux_bundle_sbindir  := $(bundle_rootdir)$(UTIL_LINUX_TARGET_PREFIX)/sbin
util_linux_bundle_libdir   := $(bundle_rootdir)$(UTIL_LINUX_TARGET_PREFIX)/lib

# Installed / bundled util_linux components
util_linux_bins            := mount umount mountpoint lsblk
util_linux_sbins           := sfdisk fdisk fstrim blockdev
util_linux_libs            := libuuid.so libblkid.so libmount.so \
                              libsmartcols.so libfdisk.so

################################################################################
# This module help message
################################################################################

define util_linux_align_help
$(subst $(space),$(newline)                                       ,$(strip $(1)))
endef

define module_help
Build and install util_linux, a tool used to query and control network device
driver and hardware settings, particularly for wired Ethernet devices.

::Configuration variable::
  UTIL_LINUX_SRCDIR                -- Path to source directory tree
                                      [$(UTIL_LINUX_SRCDIR)]
  UTIL_LINUX_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                      configure invocation time
                                      [$(call util_linux_align_help, \
                                              $(UTIL_LINUX_AUTOTOOLS_ENV))]
  UTIL_LINUX_TARGET_PREFIX         -- Path to architecture-independent files install
                                      root directory
                                      [$(UTIL_LINUX_TARGET_PREFIX)]
  UTIL_LINUX_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                      configure time
                                      [$(call util_linux_align_help, \
                                              $(UTIL_LINUX_TARGET_CONFIGURE_ARGS))]
  UTIL_LINUX_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                      time
                                      [$(call util_linux_align_help, \
                                              $(UTIL_LINUX_TARGET_MAKE_ARGS))]

::Installed::
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/bin/lsblk                   -- Utitilies
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/bin/mount
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/bin/mountpoint
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/bin/umount
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/sbin/blockdev
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/sbin/fstrim
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/sbin/sfdisk
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/sbin/fdisk
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/libuuid.so              -- Shared libraries
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/libblkid.so
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/libmount.so
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/libsmartcols.so
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/libfdisk.so
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/libuuid.la              -- Libtool libraries
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/libblkid.la
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/libmount.la
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/libsmartcols.la
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/libfdisk.la
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/pkgconfig/uuid.pc       -- pkg-config metadata files
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/pkgconfig/blkid.pc
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/pkgconfig/mount.pc
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/pkgconfig/smartcols.pc
  $$(stagingdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/pkgconfig/fdisk.pc
  $$(stagingdir)/usr/include/blkid           -- Development headers
  $$(stagingdir)/usr/include/libfdisk
  $$(stagingdir)/usr/include/libmount
  $$(stagingdir)/usr/include/libsmartcols
  $$(stagingdir)/usr/include/uuid

::Bundled::
  $$(bundle_rootdir)$(UTIL_LINUX_TARGET_PREFIX)/bin/lsblk           -- Utitilies
  $$(bundle_rootdir)$(UTIL_LINUX_TARGET_PREFIX)/bin/mount
  $$(bundle_rootdir)$(UTIL_LINUX_TARGET_PREFIX)/bin/mountpoint
  $$(bundle_rootdir)$(UTIL_LINUX_TARGET_PREFIX)/bin/umount
  $$(bundle_rootdir)$(UTIL_LINUX_TARGET_PREFIX)/sbin/blockdev
  $$(bundle_rootdir)$(UTIL_LINUX_TARGET_PREFIX)/sbin/fstrim
  $$(bundle_rootdir)$(UTIL_LINUX_TARGET_PREFIX)/sbin/sfdisk
  $$(bundle_rootdir)$(UTIL_LINUX_TARGET_PREFIX)/sbin/fdisk
  $$(bundle_rootdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/libuuid.so      -- Shared libraries
  $$(bundle_rootdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/libblkid.so
  $$(bundle_rootdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/libmount.so
  $$(bundle_rootdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/libsmartcols.so
  $$(bundle_rootdir)$(UTIL_LINUX_TARGET_PREFIX)/lib/libfdisk.so
endef

################################################################################
# Configuration logic
################################################################################

define util_linux_configure
$(Q)$(call autotools_target_configure, \
           $(UTIL_LINUX_SRCDIR), \
           $(UTIL_LINUX_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datarootdir=/usr/share \
           --disable-makeinstall-chown \
           --disable-makeinstall-setuid)
endef

$(call autotools_gen_config_rules,util_linux_configure)

################################################################################
# Build logic
################################################################################

define util_linux_build
+$(Q)$(call util_linux_make,all)
endef

$(call autotools_gen_build_rule,util_linux_build)

################################################################################
# Clean logic
################################################################################

define util_linux_clean
+$(Q)$(call util_linux_make,clean)
endef

$(call autotools_gen_clean_rule,util_linux_clean)

################################################################################
# Install logic
################################################################################

define util_linux_install
+$(Q)$(call util_linux_make,install)
endef

$(call autotools_gen_install_rule,util_linux_install)

################################################################################
# Uninstall logic
################################################################################

define util_linux_uninstall
+$(Q)$(call util_linux_make,uninstall)
endef

$(call autotools_gen_uninstall_rule,util_linux_uninstall)

################################################################################
# Bundle logic
################################################################################

define util_linux_bundle
$(foreach b, \
          $(util_linux_bins), \
          $(Q)$(call bundle_bin_cmd, \
                     $(util_linux_staging_bindir)/$(b), \
                     $(util_linux_bundle_bindir))$(newline))
$(foreach b, \
          $(util_linux_sbins), \
          $(Q)$(call bundle_bin_cmd, \
                     $(util_linux_staging_sbindir)/$(b), \
                     $(util_linux_bundle_sbindir))$(newline))
$(foreach l, \
          $(util_linux_libs), \
          $(Q)$(call bundle_lib_cmd, \
                     $(util_linux_staging_libdir)/$(l), \
                     $(util_linux_bundle_libdir))$(newline))
endef

$(call autotools_gen_bundle_rule,util_linux_bundle)

################################################################################
# Drop logic
################################################################################

define util_linux_drop
$(foreach b, \
          $(util_linux_bins), \
          $(Q)$(call drop_cmd, \
                     $(util_linux_bundle_bindir)/$(b))$(newline))
$(foreach b, \
          $(util_linux_sbins), \
          $(Q)$(call drop_cmd, \
                     $(util_linux_bundle_sbindir)/$(b))$(newline))
$(foreach l, \
          $(util_linux_libs), \
          $(Q)$(call drop_lib_cmd, \
                     $(util_linux_staging_libdir)/$(l), \
                     $(util_linux_bundle_libdir))$(newline))
endef

$(call autotools_gen_drop_rule,util_linux_drop)
