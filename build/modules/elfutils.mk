include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

$(call gen_module_depends,zlib)

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,ELFUTILS_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,ELFUTILS_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,ELFUTILS_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,ELFUTILS_TARGET_MAKE_ARGS)

elfutils_make = $(call autotools_target_make,$(1),$(ELFUTILS_TARGET_MAKE_ARGS))

# Location of staged elfutils binary
elfutils_staging_libdir := $(stagingdir)$(ELFUTILS_TARGET_PREFIX)/lib

# Location of bundled elfutils binary.
elfutils_bundle_libdir := $(bundle_rootdir)$(ELFUTILS_TARGET_PREFIX)/lib

################################################################################
# This module help message
################################################################################

define elfutils_align_help
$(subst $(space),$(newline)                                     ,$(strip $(1)))
endef

define module_help
Build and install elfutils, a collection of utilities and libraries to read,
create and modify ELF binary files, find and handle DWARF debug data, symbols,
thread state and stacktraces for processes and core files on GNU/Linux.

::Configuration variable::
  ELFUTILS_SRCDIR                -- Path to source directory tree
                                    [$(ELFUTILS_SRCDIR)]
  ELFUTILS_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                    configure invocation time
                                    [$(call elfutils_align_help, \
                                            $(ELFUTILS_AUTOTOOLS_ENV))]
  ELFUTILS_TARGET_PREFIX         -- Path to architecture-independent files
                                    install root directory
                                    [$(ELFUTILS_TARGET_PREFIX)]
  ELFUTILS_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                    configure time
                                    [$(call elfutils_align_help, \
                                            $(ELFUTILS_TARGET_CONFIGURE_ARGS))]
  ELFUTILS_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                    time
                                    [$(call elfutils_align_help, \
                                            $(ELFUTILS_TARGET_MAKE_ARGS))]

::Installed::
  $$(stagingdir)$(ELFUTILS_TARGET_PREFIX)/bin/eu-*                         -- binaries
  $$(stagingdir)$(ELFUTILS_TARGET_PREFIX)/lib/libelf*so*                   -- shared libraries
  $$(stagingdir)$(ELFUTILS_TARGET_PREFIX)/lib/libdw*so*
  $$(stagingdir)$(ELFUTILS_TARGET_PREFIX)/lib/libasm*so*
  $$(stagingdir)$(ELFUTILS_TARGET_PREFIX)/lib/pkgconfig/libelf.pc          -- pkg-config metadat files
  $$(stagingdir)$(ELFUTILS_TARGET_PREFIX)/lib/pkgconfig/libdw.pc
  $$(stagingdir)/usr/include/libelf.h             -- development headers
  $$(stagingdir)/usr/include/gelf.h
  $$(stagingdir)/usr/include/nlist.h
  $$(stagingdir)/usr/include/elfutils/*.h
  $$(stagingdir)/usr/include/dwarf.h
  $$(stagingdir)/usr/share/man/man[13]/*elf*.[13] -- man pages

::Bundled::
  $$(bundle_rootdir)$(ELFUTILS_TARGET_PREFIX)/lib/libdw.so.1  -- ELF access shared library
  $$(bundle_rootdir)$(ELFUTILS_TARGET_PREFIX)/lib/libelf.so.1 -- DWARF acces shared library
endef

################################################################################
# Configuration logic
################################################################################

define elfutils_configure
$(Q)$(call autotools_target_configure, \
           $(ELFUTILS_SRCDIR), \
           $(ELFUTILS_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datarootdir=/usr/share)
endef

$(call autotools_gen_config_rules,elfutils_configure)

################################################################################
# Build logic
################################################################################

define elfutils_build
+$(Q)$(call elfutils_make,all)
endef

$(call autotools_gen_build_rule,elfutils_build)

################################################################################
# Clean logic
################################################################################

define elfutils_clean
+$(Q)$(call elfutils_make,clean)
endef

$(call autotools_gen_clean_rule,elfutils_clean)

################################################################################
# Install logic
################################################################################

define elfutils_install
+$(Q)$(call elfutils_make,install)
endef

$(call autotools_gen_install_rule,elfutils_install)

################################################################################
# Uninstall logic
################################################################################

define elfutils_uninstall
+$(Q)$(call elfutils_make,uninstall)
endef

$(call autotools_gen_uninstall_rule,elfutils_uninstall)

################################################################################
# Bundle logic
################################################################################

define elfutils_bundle
$(Q)$(call bundle_lib_cmd, \
           $(elfutils_staging_libdir)/libelf.so.1, \
           $(elfutils_bundle_libdir))
$(Q)$(call bundle_lib_cmd, \
           $(elfutils_staging_libdir)/libdw.so.1, \
           $(elfutils_bundle_libdir))
endef

$(call autotools_gen_bundle_rule,elfutils_bundle)

################################################################################
# Drop logic
################################################################################

define elfutils_drop
$(Q)$(call drop_lib_cmd, \
           $(elfutils_staging_libdir)/libdw.so.1, \
           $(elfutils_bundle_libdir))
$(Q)$(call drop_lib_cmd, \
           $(elfutils_staging_libdir)/libelf.so.1, \
           $(elfutils_bundle_libdir))
endef

$(call autotools_gen_drop_rule,elfutils_drop)
