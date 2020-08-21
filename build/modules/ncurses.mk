include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,NCURSES_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,NCURSES_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,NCURSES_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,NCURSES_TARGET_MAKE_ARGS)

# ncurses make invocation macro.
ncurses_make = $(call autotools_target_make,$(1),$(NCURSES_TARGET_MAKE_ARGS))

################################################################################
# This module help message
################################################################################

define ncurses_align_help
$(subst $(space),$(newline)                                    ,$(strip $(1)))
endef

define module_help
Build and install ncurses, a programming framework providing an API to write
text-based user interfaces in a terminal-independent manner.

This module builds ncurses with terminal description database disabled.
Definitions of terminal capabilities will be embedded within the library. The
list of supported terminals may be specified using the «NCURSES_TERMS»
platform configuration variable (see below).

This module builds ncurses framework with a separate «libtinfo» terminfo
library.

::Configuration variable::
  NCURSES_SRCDIR                -- Path to source directory tree
                                   [$(NCURSES_SRCDIR)]
  NCURSES_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                   configure invocation time
                                   [$(call ncurses_align_help, \
                                           $(NCURSES_AUTOTOOLS_ENV))]
  NCURSES_TERMS                 -- Comma separated list of supported terminals
                                   [$(NCURSES_TERMS)]
  NCURSES_TARGET_PREFIX         -- Path to architecture-independent files
                                   install root directory
                                   [$(NCURSES_TARGET_PREFIX)]
  NCURSES_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                   configure time
                                   [$(call ncurses_align_help, \
                                           $(NCURSES_TARGET_CONFIGURE_ARGS))]
  NCURSES_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                   time
                                   [$(call ncurses_align_help, \
                                           $(NCURSES_TARGET_MAKE_ARGS))]

::Installed::
  $$(stagingdir)/bin/ncurses[0-9]-config  -- Compile and link helper script
  $$(stagingdir)/usr/include/*            -- Development headers
  $$(stagingdir)$(NCURSES_TARGET_PREFIX)/lib/libcurses*           -- Static and shared libraries
  $$(stagingdir)$(NCURSES_TARGET_PREFIX)/lib/libform*
  $$(stagingdir)$(NCURSES_TARGET_PREFIX)/lib/libmenu*
  $$(stagingdir)$(NCURSES_TARGET_PREFIX)/lib/libncurses*
  $$(stagingdir)$(NCURSES_TARGET_PREFIX)/lib/libpanel*
  $$(stagingdir)$(NCURSES_TARGET_PREFIX)/lib/libtinfo*
  $$(stagingdir)$(NCURSES_TARGET_PREFIX)/lib/pkgconfig/ncurses.pc -- pkg-config metadata file
  $$(stagingdir)$(NCURSES_TARGET_PREFIX)/lib/pkgconfig/tinfo.pc
  $$(stagingdir)$(NCURSES_TARGET_PREFIX)/lib/pkgconfig/panel.pc
  $$(stagingdir)$(NCURSES_TARGET_PREFIX)/lib/pkgconfig/menu.pc
  $$(stagingdir)$(NCURSES_TARGET_PREFIX)/lib/pkgconfig/form.pc

::Bundled::
  $$(bundle_rootdir)$(NCURSES_TARGET_PREFIX)/lib/ncurses.so.* -- Shared library
endef

################################################################################
# Configuration logic
################################################################################

define ncurses_configure
$(Q)$(call autotools_target_configure, \
           $(NCURSES_SRCDIR), \
           $(NCURSES_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datadir=/usr/share \
           --infodir=/usr/share/info \
           --mandir=/usr/share/man \
           --with-termlib \
           --with-fallbacks=$(if $(NCURSES_TERMS),$(NCURSES_TERMS),vt100) \
           --enable-pc-files \
           --with-pkg-config \
           --with-pkg-config-libdir="$(NCURSES_TARGET_PREFIX)/lib/pkgconfig" \
           --disable-database \
           --enable-db-install=no \
           --without-tests \
           --disable-stripping)
endef

$(call autotools_gen_config_rules,ncurses_configure)

################################################################################
# Build logic
################################################################################

define ncurses_build
+$(Q)$(call ncurses_make,all)
endef

$(call autotools_gen_build_rule,ncurses_build)

################################################################################
# Clean logic
################################################################################

define ncurses_clean
+$(Q)$(call ncurses_make,clean)
endef

$(call autotools_gen_clean_rule,ncurses_clean)

################################################################################
# Install logic
################################################################################

define ncurses_install
+$(Q)$(call ncurses_make,install.libs)
endef

$(call autotools_gen_install_rule,ncurses_install)

################################################################################
# Uninstall logic
################################################################################

define ncurses_uninstall
+$(Q)$(call ncurses_make,uninstall)
endef

$(call autotools_gen_uninstall_rule,ncurses_uninstall)
