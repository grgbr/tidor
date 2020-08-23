include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

$(call gen_module_depends,libtinfo)

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,READLINE_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,READLINE_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,READLINE_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,READLINE_TARGET_MAKE_ARGS)

# Readline make invocation macro.
# Use SHLIB_XLDFLAGS to enforce flags at link time to prevent a RPATH from being
# inserted by the default readline construction process...
#
# Also enforce linkage using libtinfo so that indirect shared library
# dependencies are resolved without requiring the user to run ld with explicit
# "-ltinfo" linker switch.
readline_make = $(call autotools_target_make, \
                       $(1), \
                       $(READLINE_TARGET_MAKE_ARGS) \
                       SHLIB_XLDFLAGS:="-L$(stagindir)/usr/lib -L$(stagingdir)/lib" \
                       SHLIB_LIBS:="-ltinfow")

# Location of staged readline shared library.
readline_staging_lib := \
	$(stagingdir)$(READLINE_TARGET_PREFIX)/lib/libreadline.so.[0-9].[0-9]

# Location of staged readline history shared library.
readline_history_staging_lib := \
	$(stagingdir)$(READLINE_TARGET_PREFIX)/lib/libhistory.so.[0-9].[0-9]

# Location of bundled readline shared library.
readline_bundle_libdir := $(bundle_rootdir)$(READLINE_TARGET_PREFIX)/lib

################################################################################
# This module help message
################################################################################

define readline_align_help
$(subst $(space),$(newline)                                     ,$(strip $(1)))
endef

define module_help
Build and install readline, a library providing a set of functions for use by
applications that allow users to edit command lines as they are typed in.

The history facilities are also placed into a separate library, the History
library, as part of the build process.

::Configuration variable::
  READLINE_SRCDIR                -- Path to source directory tree
                                    [$(READLINE_SRCDIR)]
  READLINE_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                    configure invocation time
                                    [$(call readline_align_help, \
                                            $(READLINE_AUTOTOOLS_ENV))]
  READLINE_TARGET_PREFIX         -- Path to architecture-independent files
                                    install root directory
                                    [$(READLINE_TARGET_PREFIX)]
  READLINE_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                    configure time
                                    [$(call readline_align_help, \
                                            $(READLINE_TARGET_CONFIGURE_ARGS))]
  READLINE_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                    time
                                    [$(call readline_align_help, \
                                            $(READLINE_TARGET_MAKE_ARGS))]

::Installed::
  $$(stagingdir)/usr/include/readline/* -- Development headers
  $$(stagingdir)$(READLINE_TARGET_PREFIX)/lib/libreadline.*      -- Static and shared readline libraries
  $$(stagingdir)$(READLINE_TARGET_PREFIX)/lib/libhistory.*       -- Static and shared history libraries

::Bundled::
  $$(bundle_rootdir)$(READLINE_TARGET_PREFIX)/lib/libreadline.so.* -- Shared readline library
  $$(bundle_rootdir)$(READLINE_TARGET_PREFIX)/lib/libhistory.so.*  -- Shared history library
endef

################################################################################
# Configuration logic
################################################################################

define readline_configure
$(Q)$(call autotools_target_configure, \
           $(READLINE_SRCDIR), \
           $(READLINE_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datarootdir=/usr/share \
           --without-curses)
endef

$(call autotools_gen_config_rules,readline_configure)

################################################################################
# Build logic
################################################################################

define readline_build
+$(Q)$(call readline_make,all)
endef

$(call autotools_gen_build_rule,readline_build)

################################################################################
# Clean logic
################################################################################

define readline_clean
+$(Q)$(call readline_make,clean)
endef

$(call autotools_gen_clean_rule,readline_clean)

################################################################################
# Install logic
################################################################################

define readline_install
$(Q)$(call install_cmd,-m755 -d $(stagingdir)/usr/lib)
+$(Q)$(call readline_make,install)
endef

$(call autotools_gen_install_rule,readline_install)

################################################################################
# Uninstall logic
################################################################################

define readline_uninstall
+$(Q)$(call readline_make,uninstall)
endef

$(call autotools_gen_uninstall_rule,readline_uninstall)

################################################################################
# Bundle logic
################################################################################

define readline_bundle
$(Q)$(call bundle_lib_cmd, \
           $(wildcard $(readline_staging_lib)), \
           $(readline_bundle_libdir))
$(Q)$(call bundle_lib_cmd, \
           $(wildcard $(readline_history_staging_lib)), \
           $(readline_bundle_libdir))
endef

$(call autotools_gen_bundle_rule,readline_bundle)

################################################################################
# Drop logic
################################################################################

define readline_drop
$(Q)$(call drop_lib_cmd, \
           $(wildcard $(readline_staging_lib)), \
           $(readline_bundle_libdir))
$(Q)$(call drop_lib_cmd, \
           $(wildcard $(readline_history_staging_lib)), \
           $(readline_bundle_libdir))
endef

$(call autotools_gen_drop_rule,readline_drop)
