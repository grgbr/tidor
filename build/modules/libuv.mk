include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/autotools.mk

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,LIBUV_SRCDIR)
# Interrupt processing if platform specified no autotools environment.
$(call dieon_undef_or_empty,LIBUV_AUTOTOOLS_ENV)
# Interrupt processing if platform specified no configure arguments.
$(call dieon_undef_or_empty,LIBUV_TARGET_CONFIGURE_ARGS)
# Interrupt processing if platform specified no make arguments.
$(call dieon_undef_or_empty,LIBUV_TARGET_MAKE_ARGS)

# libuv make invocation macro.
libuv_make = $(call autotools_target_make,$(1),$(LIBUV_TARGET_MAKE_ARGS))

# Location of libuv components
libuv_staging_libdir := $(stagingdir)$(LIBUV_TARGET_PREFIX)/lib
libuv_bundle_libdir  := $(bundle_rootdir)$(LIBUV_TARGET_PREFIX)/lib

libuv_libs := libuv.so

################################################################################
# This module help message
################################################################################

define libuv_align_help
$(subst $(space),$(newline)                                  ,$(strip $(1)))
endef

define module_help
Build and install libuv, a multi-platform support library with a focus on
asynchronous I/O.

::Configuration variable::
  LIBUV_SRCDIR                -- Path to source directory tree
                                 [$(LIBUV_SRCDIR)]
  LIBUV_AUTOTOOLS_ENV         -- Environment variables passed at autotools and
                                 configure invocation time
                                 [$(call libuv_align_help, \
                                         $(LIBUV_AUTOTOOLS_ENV))]
  LIBUV_TARGET_PREFIX         -- Path to architecture-independent files install
                                 root directory
                                 [$(LIBUV_TARGET_PREFIX)]
  LIBUV_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                 configure time
                                 [$(call libuv_align_help, \
                                         $(LIBUV_TARGET_CONFIGURE_ARGS))]
  LIBUV_TARGET_MAKE_ARGS      -- Arguments passed to make at build / install
                                 time
                                 [$(call libuv_align_help, \
                                         $(LIBUV_TARGET_MAKE_ARGS))]

::Installed::
  $$(stagingdir)$(LIBUV_TARGET_PREFIX)/lib/libuv.so*          -- Shared library
  $$(stagingdir)$(LIBUV_TARGET_PREFIX)/lib/libuv.a            -- Static library
  $$(stagingdir)$(LIBUV_TARGET_PREFIX)/lib/libuv.la           -- Libtool library
  $$(stagingdir)$(LIBUV_TARGET_PREFIX)/lib/pkgconfig/libuv.pc -- pkg-config metadata file
  $$(stagingdir)/usr/include/uv/*       -- Development headers

::Bundled::
  $$(bundle_rootdir)$(LIBUV_TARGET_PREFIX)/lib/libuv.so* -- Shared library
endef

################################################################################
# Configuration logic
################################################################################

define libuv_configure
$(Q)$(call autotools_target_configure, \
           $(LIBUV_SRCDIR), \
           $(LIBUV_TARGET_CONFIGURE_ARGS) \
           --includedir=/usr/include \
           --datarootdir=/usr/share)
endef

$(call autotools_gen_config_rules,libuv_configure)

################################################################################
# Build logic
################################################################################

define libuv_build
+$(Q)$(call libuv_make,all)
endef

$(call autotools_gen_build_rule,libuv_build)

################################################################################
# Clean logic
################################################################################

define libuv_clean
+$(Q)$(call libuv_make,clean)
endef

$(call autotools_gen_clean_rule,libuv_clean)

################################################################################
# Install logic
################################################################################

define libuv_install
+$(Q)$(call libuv_make,install)
endef

$(call autotools_gen_install_rule,libuv_install)

################################################################################
# Uninstall logic
################################################################################

define libuv_uninstall
+$(Q)$(call libuv_make,uninstall)
endef

$(call autotools_gen_uninstall_rule,libuv_uninstall)

################################################################################
# Bundle logic
################################################################################

define libuv_bundle
$(foreach l, \
          $(libuv_libs), \
          $(Q)$(call bundle_lib_cmd, \
                     $(libuv_staging_libdir)/$(l), \
                     $(libuv_bundle_libdir))$(newline))
endef

$(call autotools_gen_bundle_rule,libuv_bundle)

################################################################################
# Drop logic
################################################################################

define libuv_drop
$(foreach l, \
          $(libuv_libs), \
          $(Q)$(call drop_cmd, \
                     $(libuv_bundle_libdir)/$(l))$(newline))
endef

$(call autotools_gen_drop_rule,libuv_drop)
