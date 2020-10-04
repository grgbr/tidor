include $(CRAFTERDIR)/core/module.mk

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,OPENSSL_SRCDIR)
# Interrupt processing if platform specified no cross compiling prefix.
$(call dieon_undef_or_empty,OPENSSL_CROSS_COMPILE)
# Interrupt processing if platform specified no build configuration arguments.
$(call dieon_undef_or_empty,OPENSSL_TARGET_CONFIGURE_ARGS)

# This module dependencies...
$(call gen_module_depends,zlib libdl cryptodev)

openssl_make_cmd = $(MAKE) --directory=$(module_builddir)

# Basename glob patterns of Openssl shared libraries.
openssl_solibs := libssl.so libcrypto.so

# Location of staged Openssl shared libraries.
openssl_staging_libdir := $(stagingdir)/lib

# Location of bundled Openssl shared libraries.
openssl_bundle_libdir := $(bundle_rootdir)/lib

# Location of staged Openssl binary.
openssl_staging_bindir := $(stagingdir)/bin

# Location of bundled Openssl binary.
openssl_bundle_bindir := $(bundle_rootdir)/bin

################################################################################
# This module help message
################################################################################

define openssl_align_help
$(subst $(space),$(newline)                                    ,$(strip $(1)))
endef

define module_help
Build and install openssl, a toolkit for the TLS and SSL protocols and
a general purpose cryptography library.

::Configuration variable::
  OPENSSL_SRCDIR                -- Path to source directory tree
                                   [$(OPENSSL_SRCDIR)]
  OPENSSL_CROSS_COMPILE         -- Cross compiling tool chain prefix
                                   [$(OPENSSL_CROSS_COMPILE)]
  OPENSSL_TARGET_CFLAGS         -- Optional extra CFLAGS passed to openssl
                                   compile process
                                   [$(call openssl_align_help, \
                                           $(OPENSSL_TARGET_CFLAGS))]
  OPENSSL_TARGET_CONFIGURE_ARGS -- Arguments passed to configure tool at
                                   configure time
                                   [$(call openssl_align_help, \
                                           $(OPENSSL_TARGET_CONFIGURE_ARGS))]

::Installed::
  $$(stagingdir)/etc/ssl/*                  -- Runtime configuration files and scripts
  $$(stagingdir)/bin/openssl                -- Command line tools
  $$(stagingdir)/bin/c_rehash
  $$(stagingdir)/lib/libssl.so.*            -- TLS / SSL shared library
  $$(stagingdir)/lib/libssl.a               -- TLS / SSL static library
  $$(stagingdir)/lib/libcrypto.so.*         -- Cryptography shared library
  $$(stagingdir)/lib/libcrypto.a            -- Cryptography static library
  $$(stagingdir)/usr/include/openssl/*.h    -- Development headers
  $$(stagingdir)/lib/pkgconfig/openssl.pc   -- pkg-config metadata file
  $$(stagingdir)/lib/pkgconfig/libcrypto.pc
  $$(stagingdir)/lib/pkgconfig/libssl

::Bundled::
  $$(bundle_rootdir)/bin/openssl          -- Command line tool
  $$(bundle_rootdir)/lib/libssl.so.*      -- TLS / SSL shared library
  $$(bundle_rootdir)/lib/libcrypto.so.*   -- Cryptography shared library
endef

################################################################################
# Configure logic
################################################################################

# Openssl does not really support out-of-tree builds...
#$(call stamp,extracted): $(module_prereqs) \
#                         | $(module_builddir) \
#                           $(call stampdir,$(MODULENAME))
#	$(Q)$(call mirror_cmd,--delete $(OPENSSL_SRCDIR)/,$(module_builddir))
#	$(Q)touch $(@)
#
#$(config_target): $(call stamp,extracted)
$(config_target):
	+$(Q)cd $(module_builddir) && \
	     env \
	         AR=gcc-ar \
	         RANLIB=gcc-ranlib \
	     $(OPENSSL_SRCDIR)/Configure --prefix="/" \
	     --openssldir="/etc/ssl" \
	     --cross-compile-prefix="$(OPENSSL_CROSS_COMPILE)" \
	     $(OPENSSL_TARGET_CONFIGURE_ARGS)
	+$(Q)$(openssl_make_cmd) depend
	$(Q)touch $(@)

################################################################################
# Build logic
################################################################################

$(build_target):
	+$(Q)$(openssl_make_cmd) all
	$(Q)touch $(@)

################################################################################
# Clean logic
################################################################################

clean:
	+$(if $(realpath $(config_target)),$(Q)$(openssl_make_cmd) clean)

################################################################################
# Install logic
################################################################################

$(install_target):
	+$(Q)$(openssl_make_cmd) install DESTDIR:=$(module_installdir)
	$(Q)rm -rf $(module_installdir)/usr/include; \
	    mkdir -p $(module_installdir)/usr; \
	    mv $(module_installdir)/include $(module_installdir)/usr
	$(Q)$(call mirror_cmd,$(module_installdir)/,$(stagingdir))
	$(Q)touch $(@)

################################################################################
# Uninstall logic
################################################################################

uninstall:
	$(Q)$(call unmirror_cmd,$(module_installdir)/,$(stagingdir))
	$(Q)$(call rmrf_cmd,$(module_installdir))

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	$(foreach l, \
	          $(openssl_solibs), \
	          $(Q)$(call bundle_lib_cmd, \
	                     $(openssl_staging_libdir)/$(l), \
	                     $(openssl_bundle_libdir))$(newline))
	$(Q)$(call bundle_bin_cmd, \
	           $(openssl_staging_bindir)/openssl, \
	           $(openssl_bundle_bindir))
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(foreach l, \
	          $(openssl_solibs), \
	          $(Q)$(call drop_lib_cmd, \
	                     $(wildcard $(openssl_staging_libdir)/$(l)), \
	                     $(openssl_bundle_libdir))$(newline))
	$(Q)$(call drop_cmd,$(openssl_bundle_bindir)/openssl)
