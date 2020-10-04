include $(CRAFTERDIR)/core/module.mk

$(call gen_module_depends,linux)

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,CRYPTODEV_SRCDIR)
# Interrupt processing if platform specified no build arguments.
$(call dieon_undef_or_empty,CRYPTODEV_TARGET_ARGS)

# cryptodev make invocation macro.
cryptodev_target_args := $(CRYPTODEV_TARGET_ARGS) \
                         prefix:="/usr" \
                         execprefix:="/" \
                         KERNEL_DIR:="$(call builddir,linux)" \
                         ARCH:="$(LINUX_ARCH)" \
                         CROSS_COMPILE:="$(LINUX_CROSS_COMPILE)"

cryptodev_make        := $(MAKE) -C $(module_builddir) $(cryptodev_target_args)

# Staged / bundled components
cryptodev_header := /usr/include/crypto/cryptodev.h
linux_release     = \
	$(shell cat $(call builddir,linux)/include/config/kernel.release)
cryptodev_module  = /lib/modules/$(linux_release)/extra/cryptodev.ko

################################################################################
# This module help message
################################################################################

define cryptodev_align_help
$(subst $(space),$(newline)                                 ,$(strip $(1)))
endef

define module_help
Build and install cryptodev, a /dev/crypto Linux kernel device driver,
equivalent to those in OpenBSD or FreeBSD. The main idea is to access of
existing ciphers in kernel space from userspace, thus enabling the re-use of a
hardware implementation of a cipher.

::Warning::
Linux kernel must be built with module support enabled and
CONFIG_TRIM_UNUSED_KSYMS build option set to no since cryptodev is an external
module.

::Configuration variable::
  CRYPTODEV_SRCDIR           -- Path to source directory tree
                                [$(CRYPTODEV_SRCDIR)]
  CRYPTODEV_TARGET_MAKE_ARGS -- Arguments passed to make and configure
                                [$(call cryptodev_align_help, \
                                        $(cryptodev_target_args))]

::Installed::
  $$(stagingdir)$(cryptodev_header)         -- Development header
  $$(stagingdir)$(cryptodev_module) -- Kernel module

::Bundled::
  $$(bundle_rootdir)$(cryptodev_module) -- Kernel module
endef

################################################################################
# Configure logic
################################################################################

$(config_target):
	$(Q)$(call mirror_cmd,--delete $(CRYPTODEV_SRCDIR)/,$(module_builddir))
	$(Q)touch $(@)

################################################################################
# Build logic
################################################################################

$(build_target):
	+$(Q)$(cryptodev_make) build
	$(Q)touch $(@)

################################################################################
# Clean logic
################################################################################

clean:
	+$(Q)$(cryptodev_make) clean

################################################################################
# Install logic
################################################################################

$(install_target):
	+$(Q)$(cryptodev_make) install \
	     DESTDIR:="$(stagingdir)" \
	     INSTALL_PATH:="$(stagingdir)" \
	     INSTALL_MOD_PATH:="$(stagingdir)"
	$(Q)touch $(@)

################################################################################
# Uninstall logic
################################################################################

uninstall:
	$(Q)$(call rmf_cmd,$(stagingdir)$(cryptodev_header))
	$(Q)$(call rmf_cmd,$(stagingdir)$(cryptodev_module))

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	+$(Q)$(call fake_root_cmd, \
	            $(bundle_fake_root_env), \
	            $(MAKE) -C $(call builddir,linux) \
	                    M:="$(realpath $(module_builddir))" \
	                    ARCH:="$(LINUX_ARCH)" \
	                    CROSS_COMPILE:="$(LINUX_CROSS_COMPILE)" \
	                    INSTALL_MOD_STRIP:=1 \
	                    INSTALL_MOD_PATH:="$(bundle_rootdir)" \
	                    modules_install)
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call drop_cmd,$(bundle_rootdir)$(cryptodev_module))
