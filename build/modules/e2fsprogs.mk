include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

$(call gen_module_depends,util_linux libdl)

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,E2FSPROGS_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,E2FSPROGS_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,E2FSPROGS_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,E2FSPROGS_TARGET_MAKE_ARGS)

# e2fsprogs make invocation macro.
e2fsprogs_make = $(call autotools_target_make, \
                        $(1), \
                        $(E2FSPROGS_TARGET_MAKE_ARGS))

# Location of staged e2fsprogs
e2fsprogs_staging_bindir  := $(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/bin
e2fsprogs_staging_sbindir := $(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/sbin
e2fsprogs_staging_libdir  := $(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/lib

# Location of bundled e2fsprogs
e2fsprogs_bundle_bindir  := $(bundle_rootdir)$(E2FSPROGS_TARGET_PREFIX)/bin
e2fsprogs_bundle_sbindir := $(bundle_rootdir)$(E2FSPROGS_TARGET_PREFIX)/sbin
e2fsprogs_bundle_libdir  := $(bundle_rootdir)$(E2FSPROGS_TARGET_PREFIX)/lib

# Installed / bundled util_linux components
e2fsprogs_bins           := lsattr chattr
e2fsprogs_sbins          := badblocks e2freefrag e2fsck e2mmpstatus e4defrag \
                            mke2fs mklost+found tune2fs filefrag
e2fsprogs_libs           := libext2fs.so.2 libcom_err.so.2 libe2p.so.2

################################################################################
# This module help message
################################################################################

define e2fsprogs_align_help
$(subst $(space),$(newline)                                      ,$(strip $(1)))
endef

define module_help
Build and install e2fsprogs, a tool used to query and control network device
driver and hardware settings, particularly for wired Ethernet devices.

::Configuration variable::
  E2FSPROGS_SRCDIR                -- Path to source directory tree
                                     [$(E2FSPROGS_SRCDIR)]
  E2FSPROGS_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                     configure invocation time
                                     [$(call e2fsprogs_align_help, \
                                           $(E2FSPROGS_AUTOTOOLS_ENV))]
  E2FSPROGS_TARGET_PREFIX         -- Path to architecture-independent files install
                                     root directory
                                     [$(E2FSPROGS_TARGET_PREFIX)]
  E2FSPROGS_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                     configure time
                                     [$(call e2fsprogs_align_help, \
                                             $(E2FSPROGS_TARGET_CONFIGURE_ARGS))]
  E2FSPROGS_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                     time
                                     [$(call e2fsprogs_align_help, \
                                             $(E2FSPROGS_TARGET_MAKE_ARGS))]
e2fsprogs_bins           := lsattr chattr
e2fsprogs_sbins          := badblocks e2freefrag e2fsck e2mmpstatus e4defrag \
                            mke2fs mklost+found tune2fs filefrag
e2fsprogs_libs           := libext2fs.so.2 libcom_err.so.2 libe2p.so.2


::Installed::
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/bin/lsattr               -- Utilities
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/bin/chattr
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/badblocks
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/e2freefrag
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/e2fsck
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/e2mmpstatus
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/e4defrag
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/mke2fs
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/mklost+found
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/tune2fs
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/filefrag
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/lib/libext2fs.so.2       -- Shared library
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/lib/libcom_err.so.2
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/lib/libe2p.so.2
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/lib/libss.so.2
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/lib/libext2fs.a          -- Static library
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/lib/libcom_err.a
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/lib/libe2p.a
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/lib/libss.a
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/lib/pkgconfig/com_err.pc -- pkg-config metadata file
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/lib/pkgconfig/ext2fs.pc
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/lib/pkgconfig/e2p.pc
  $$(stagingdir)$(E2FSPROGS_TARGET_PREFIX)/lib/pkgconfig/ss.pc
  $$(stagingdir)/usr/include/et           -- Development headers
  $$(stagingdir)/usr/include/ss
  $$(stagingdir)/usr/include/e2p
  $$(stagingdir)/usr/include/ext2fs

::Bundled::
  $$(bundle_rootdir)$(E2FSPROGS_TARGET_PREFIX)/bin/lsattr          -- Utilities
  $$(bundle_rootdir)$(E2FSPROGS_TARGET_PREFIX)/bin/chattr
  $$(bundle_rootdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/badblocks
  $$(bundle_rootdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/e2freefrag
  $$(bundle_rootdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/e2fsck
  $$(bundle_rootdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/e2mmpstatus
  $$(bundle_rootdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/e4defrag
  $$(bundle_rootdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/mke2fs
  $$(bundle_rootdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/mklost+found
  $$(bundle_rootdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/tune2fs
  $$(bundle_rootdir)$(E2FSPROGS_TARGET_PREFIX)/sbin/filefrag
  $$(bundle_rootdir)$(E2FSPROGS_TARGET_PREFIX)/lib/libext2fs.so.2  -- Shared library
  $$(bundle_rootdir)$(E2FSPROGS_TARGET_PREFIX)/lib/libcom_err.so.2
  $$(bundle_rootdir)$(E2FSPROGS_TARGET_PREFIX)/lib/libe2p.so.2
endef

################################################################################
# Configuration logic
################################################################################

define e2fsprogs_configure
$(Q)$(call autotools_target_configure, \
           $(E2FSPROGS_SRCDIR), \
           $(E2FSPROGS_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datarootdir=/usr/share)
endef

$(call autotools_gen_config_rules,e2fsprogs_configure)

################################################################################
# Build logic
################################################################################

define e2fsprogs_build
+$(Q)$(call e2fsprogs_make,all)
endef

$(call autotools_gen_build_rule,e2fsprogs_build)

################################################################################
# Clean logic
################################################################################

define e2fsprogs_clean
+$(Q)$(call e2fsprogs_make,clean)
endef

$(call autotools_gen_clean_rule,e2fsprogs_clean)

################################################################################
# Install logic
################################################################################

define e2fsprogs_install
+$(Q)$(call e2fsprogs_make,install)
endef

$(call autotools_gen_install_rule,e2fsprogs_install)

################################################################################
# Uninstall logic
################################################################################

define e2fsprogs_uninstall
+$(Q)$(call e2fsprogs_make,uninstall)
endef

$(call autotools_gen_uninstall_rule,e2fsprogs_uninstall)

################################################################################
# Bundle logic
################################################################################

define e2fsprogs_bundle
$(foreach b, \
          $(e2fsprogs_bins), \
          $(Q)$(call bundle_bin_cmd, \
                     $(e2fsprogs_staging_bindir)/$(b), \
                     $(e2fsprogs_bundle_bindir))$(newline))
$(foreach b, \
          $(e2fsprogs_sbins), \
          $(Q)$(call bundle_bin_cmd, \
                     $(e2fsprogs_staging_sbindir)/$(b), \
                     $(e2fsprogs_bundle_sbindir))$(newline))
$(foreach l, \
          $(e2fsprogs_libs), \
          $(Q)$(call bundle_lib_cmd, \
                     $(e2fsprogs_staging_libdir)/$(l), \
                     $(e2fsprogs_bundle_libdir))$(newline))
endef

$(call autotools_gen_bundle_rule,e2fsprogs_bundle)

################################################################################
# Drop logic
################################################################################

define e2fsprogs_drop
$(foreach b, \
          $(e2fsprogs_bins), \
          $(Q)$(call drop_cmd, \
                     $(e2fsprogs_bundle_bindir)/$(b))$(newline))
$(foreach b, \
          $(e2fsprogs_sbins), \
          $(Q)$(call drop_cmd, \
                     $(e2fsprogs_bundle_sbindir)/$(b))$(newline))
$(foreach l, \
          $(e2fsprogs_libs), \
          $(Q)$(call drop_lib_cmd, \
                     $(e2fsprogs_staging_libdir)/$(l), \
                     $(e2fsprogs_bundle_libdir))$(newline))
endef

$(call autotools_gen_drop_rule,e2fsprogs_drop)
