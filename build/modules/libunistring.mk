include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,LIBUNISTRING_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,LIBUNISTRING_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,LIBUNISTRING_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,LIBUNISTRING_TARGET_MAKE_ARGS)

# libunistring make invocation macro.
libunistring_make = $(call autotools_target_make, \
                           $(1), \
                           $(LIBUNISTRING_TARGET_MAKE_ARGS))

# Location of libunistring components
libunistring_staging_libdir := $(stagingdir)$(LIBUNISTRING_TARGET_PREFIX)/lib
libunistring_bundle_libdir  := $(bundle_rootdir)$(LIBUNISTRING_TARGET_PREFIX)/lib

libunistring_libs := libunistring.so

################################################################################
# This module help message
################################################################################

define libunistring_align_help
$(subst $(space),$(newline)                                         ,$(strip $(1)))
endef

define module_help
Build and install libunistring, a library that provides functions for
manipulating Unicode strings and for manipulating C strings according to the
Unicode standard.

::Configuration variable::
  LIBUNISTRING_SRCDIR                -- Path to source directory tree
                                        [$(LIBUNISTRING_SRCDIR)]
  LIBUNISTRING_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                        configure invocation time
                                        [$(call libunistring_align_help, \
                                                $(LIBUNISTRING_AUTOTOOLS_ENV))]
  LIBUNISTRING_TARGET_PREFIX         -- Path to architecture-independent files install
                                        root directory
                                        [$(LIBUNISTRING_TARGET_PREFIX)]
  LIBUNISTRING_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                        configure time
                                        [$(call libunistring_align_help, \
                                                $(LIBUNISTRING_TARGET_CONFIGURE_ARGS))]
  LIBUNISTRING_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                        time
                                        [$(call libunistring_align_help, \
                                                $(LIBUNISTRING_TARGET_MAKE_ARGS))]

::Installed::
  $$(stagingdir)$(LIBUNISTRING_TARGET_PREFIX)/lib/libunistring.so*             -- Shared library
  $$(stagingdir)$(LIBUNISTRING_TARGET_PREFIX)/lib/libunistring.a               -- Static library
  $$(stagingdir)$(LIBUNISTRING_TARGET_PREFIX)/lib/libunistring.la              -- Libtool library
  $$(stagingdir)/usr/include/unistring/*          -- Development headers
  $$(stagingdir)/usr/share/info/libunistring.info -- Info file
  $$(stagingdir)/usr/share/doc/libunistring/*     -- Documentation

::Bundled::
  $$(bundle_rootdir)$(LIBUNISTRING_TARGET_PREFIX)/lib/libunistring.so* -- Shared library
endef

################################################################################
# Configuration logic
################################################################################

define libunistring_configure
$(Q)$(call autotools_target_configure, \
           $(LIBUNISTRING_SRCDIR), \
           $(LIBUNISTRING_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datarootdir=/usr/share)
endef

$(call autotools_gen_config_rules,libunistring_configure)

################################################################################
# Build logic
################################################################################

define libunistring_build
+$(Q)$(call libunistring_make,all)
endef

$(call autotools_gen_build_rule,libunistring_build)

################################################################################
# Clean logic
################################################################################

define libunistring_clean
+$(Q)$(call libunistring_make,clean)
endef

$(call autotools_gen_clean_rule,libunistring_clean)

################################################################################
# Install logic
################################################################################

define libunistring_install
+$(Q)$(call libunistring_make,install)
endef

$(call autotools_gen_install_rule,libunistring_install)

################################################################################
# Uninstall logic
################################################################################

define libunistring_uninstall
+$(Q)$(call libunistring_make,uninstall)
endef

$(call autotools_gen_uninstall_rule,libunistring_uninstall)

################################################################################
# Bundle logic
################################################################################

define libunistring_bundle
$(foreach l, \
          $(libunistring_libs), \
          $(Q)$(call bundle_lib_cmd, \
                     $(libunistring_staging_libdir)/$(l), \
                     $(libunistring_bundle_libdir))$(newline))
endef

$(call autotools_gen_bundle_rule,libunistring_bundle)

################################################################################
# Drop logic
################################################################################

define libunistring_drop
$(foreach l, \
          $(libunistring_libs), \
          $(Q)$(call drop_lib_cmd, \
                     $(libunistring_staging_libdir)/$(l), \
                     $(libunistring_bundle_libdir))$(newline))
endef

$(call autotools_gen_drop_rule,libunistring_drop)
