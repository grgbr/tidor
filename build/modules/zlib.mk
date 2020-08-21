include $(CRAFTERDIR)/core/module.mk

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,ZLIB_SRCDIR)
# Interrupt processing if platform specified no cross toolchain.
$(call dieon_undef_or_empty,ZLIB_CROSS_COMPILE)

# Basic zlib make invocation macro.
zlib_make := $(MAKE) -C $(module_builddir)

# Location of staged zlib shared library.
zlib_staging_lib := $(stagingdir)/lib/libz.so.[0-9].[0-9].[0-9]*

# Location of bundled zlib shared library.
zlib_bundle_libdir := $(bundle_rootdir)/lib

################################################################################
# This module help message
################################################################################

define zlib_align_help
$(subst $(space),$(newline)                         ,$(1))
endef

define module_help
Build and install zlib, a general purpose compression library.

::Configuration variable::
  ZLIB_SRCDIR        -- Path to source directory tree
                        [$(ZLIB_SRCDIR)]
  ZLIB_CROSS_COMPILE -- Path to cross compiling tool chain
                        [$(ZLIB_CROSS_COMPILE)]
  ZLIB_CFLAGS        -- Optional extra CFLAGS passed to zlib compile process
                        [$(call zlib_align_help,$(ZLIB_CFLAGS))]
  ZLIB_LDFLAGS       -- Optional extra LDFLAGS passed to zlib link process in
                        addition to ZLIB_CFLAGS
                        [$(call zlib_align_help,$(ZLIB_LDFLAGS))]

::Installed::
  $$(stagingdir)/usr/include/zlib.h    -- Development headers
  $$(stagingdir)/usr/include/zconf.h
  $$(stagingdir)/lib/libz.*            -- Static and shared libraries
  $$(stagingdir)/lib/pkgconfig/zlib.pc -- pkg-config metadata file

::Bundled::
  $$(bundle_rootdir)/lib/libz.so.* -- Shared library
endef

################################################################################
# Configure logic
################################################################################

$(config_target):
	$(Q)cd $(module_builddir) && \
	    env CROSS_PREFIX=$(ZLIB_CROSS_COMPILE) \
	        $(call ifdef,ZLIB_CFLAGS,CFLAGS="$(ZLIB_CFLAGS)") \
	        $(call ifdef,ZLIB_LDFLAGS,LDFLAGS="$(ZLIB_LDFLAGS)") \
	    $(ZLIB_SRCDIR)/configure --prefix=/usr --eprefix= --uname=linux
	$(Q)touch $(@)

################################################################################
# Build logic
################################################################################

$(build_target):
	+$(Q)$(zlib_make)
	$(Q)touch $(@)

################################################################################
# Clean logic
################################################################################

clean:
	+$(Q)$(zlib_make) clean

################################################################################
# Install logic
################################################################################

$(install_target):
	+$(Q)$(zlib_make) install DESTDIR:=$(stagingdir)
	$(Q)touch $(@)

################################################################################
# Uninstall logic
################################################################################

uninstall:
	+$(Q)$(zlib_make) uninstall DESTDIR:=$(stagingdir)

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	$(Q)$(call bundle_lib_cmd, \
	           $(wildcard $(zlib_staging_lib)), \
	           $(zlib_bundle_libdir))
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call drop_lib_cmd, \
	           $(wildcard $(zlib_staging_lib)), \
	           $(zlib_bundle_libdir))
