include $(CRAFTERDIR)/core/module.mk

$(call gen_module_depends,ncurses)

# Location of staged tinfo shared library.
libtinfo_staging_lib := \
	$(stagingdir)$(LIBTINFO_TARGET_PREFIX)/lib/libtinfow.so.[0-9].[0-9]

# Location of bundled tinfo shared library.
libtinfo_bundle_libdir := $(bundle_rootdir)$(LIBTINFO_TARGET_PREFIX)/lib

################################################################################
# This module help message
################################################################################

define module_help
Bundle libtinfo, the terminfo library.

::Configuration variable::
  NCURSES_TARGET_PREFIX -- Path to ncurses architecture-independent files
                           install root directory
                           [$(NCURSES_TARGET_PREFIX)]

::Bundled::
  $$(bundle_rootdir)$(NCURSES_TARGET_PREFIX)/lib/libtinfo.so.* -- Shared library
endef

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	$(Q)$(call bundle_lib_cmd, \
	           $(wildcard $(libtinfo_staging_lib)), \
	           $(libtinfo_bundle_libdir))
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call drop_lib_cmd, \
	           $(wildcard $(libtinfo_staging_lib)), \
	           $(libtinfo_bundle_libdir))
