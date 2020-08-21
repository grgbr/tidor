include $(CRAFTERDIR)/core/module.mk

$(call dieon_empty,LIBC_SYSROOT_DIR)
$(call dieon_empty,LIBC_CROSS_COMPILE)

libc_solibs :=

libc_sofile := $(wildcard $(LIBC_SYSROOT_DIR)/lib/libc-[0-9].[0-9]*.so)
$(call dieon_empty,libc_sofile)
libc_solibs += $(libc_sofile)

libc_sofile := $(wildcard $(LIBC_SYSROOT_DIR)/lib/libgcc_s.so.[0-9])
$(call dieon_empty,libc_sofile)
libc_solibs += $(libc_sofile)

libc_loader := $(wildcard $(LIBC_SYSROOT_DIR)/lib/ld-[0-9].[0-9]*.so)
$(call dieon_empty,libc_loader)

libc_install_path := $(strip $(if $(strip $(LIBC_RUNTIME_DIR)), \
                                  $(LIBC_RUNTIME_DIR), \
                                  /lib))

################################################################################
# This module help message
################################################################################

define libc_sonames
$(foreach l, \
          $(libc_solibs), \
          $$(bundle_rootdir)/$(shell env READELF=$(LIBC_CROSS_COMPILE)readelf \
                                     $(CRAFTER_SCRIPTDIR)/so_name.sh $(l)))
endef

define module_help
Install basic C library objects from external toolchain.

::Configuration variable::
  LIBC_CROSS_COMPILE -- Path to C library cross compiling tool chain
                        [$(LIBC_CROSS_COMPILE)]
  LIBC_SYSROOT_DIR   -- Path to C library sysroot directory
                        [$(LIBC_SYSROOT_DIR)]
  LIBC_RUNTIME_DIR   -- Optional path to C library directory searched by the
                        dynamic loader at runtime (defaults to /lib)
                        [$(LIBC_RUNTIME_DIR)]

::Installed::
  $$(hostdir)/bin/gdb     -- Host side cross GNU debugger binary
  $$(hostdir)/etc/gdbinit -- Host side cross GNU debugger initialization command
                             file

::Bundled::
  $(subst $(space),$(newline)  ,$(strip $(libc_sonames)))
endef

################################################################################
# Install logic
################################################################################

define libc_gdbinit
# Setup gdb to point to the right directory locations when resolving library
# symbols.
# Warning: paths are not setup to search for libraries built in Thumb mode.
set sysroot $(LIBC_SYSROOT_DIR)
set solib-search-path $(stagingdir)/lib:$(LIBC_SYSROOT_DIR)/usr/lib:$(LIBC_SYSROOT_DIR)/lib
endef

$(hostdir)/etc/gdbinit: SHELL := /bin/bash
$(hostdir)/etc/gdbinit: | $(hostdir)/etc
	$(Q)$(call echo_multi_line_var_cmd,$(libc_gdbinit)) > $(@)

$(install_target): $(hostdir)/etc/gdbinit | $(hostdir)/bin
	$(Q)$(call lnck_cmd,$(LIBC_CROSS_COMPILE)gdb,$(hostdir)/bin/gdb)
	$(Q)touch $(@)

################################################################################
# Uninstall logic
################################################################################

uninstall:
	$(Q)$(call rmf_cmd,$(hostdir)/etc/gdbinit)
	$(Q)$(call rmf_cmd,$(hostdir)/bin/gdb)

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	$(foreach l, \
	          $(libc_solibs), \
	          $(Q)$(call bundle_lib_cmd, \
	                     $(l), \
	                     $(bundle_rootdir)$(libc_install_path))$(newline))
	$(Q)$(call bundle_lib_cmd,$(libc_loader),$(bundle_rootdir)/lib)
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(foreach l, \
	          $(libc_solibs), \
	          $(Q)$(call drop_lib_cmd, \
	                     $(l), \
	                     $(bundle_rootdir)$(libc_install_path))$(newline))
	$(Q)$(call drop_lib_cmd,$(libc_loader),$(bundle_rootdir)/lib)
