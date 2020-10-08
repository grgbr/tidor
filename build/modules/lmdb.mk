include $(CRAFTERDIR)/core/module.mk

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,LMDB_SRCDIR)
# Interrupt processing if platform specified no cross toolchain.
$(call dieon_undef_or_empty,LMDB_CROSS_COMPILE)

# Basic lmdb make invocation macro.
# Use the SOLIBS make variable to enforce the library name to allow soname.sh to
# properly probe liblmdb.so as a library at bundling time.
lmdb_make := $(MAKE) -C $(module_builddir) \
                     prefix:=/usr \
                     exec_prefix:= \
                     CC:="$(LMDB_CROSS_COMPILE)gcc" \
                     AR:="$(LMDB_CROSS_COMPILE)gcc-ar" \
                     XCFLAGS:="$(LMDB_CFLAGS)" \
                     LDFLAGS:="$(LMDB_LDFLAGS)" \
                     SOLIBS:="-Wl,-soname,liblmdb.so"

# Location of lmdb components.
lmdb_staging_libdir := $(stagingdir)/lib
lmdb_staging_bindir := $(stagingdir)/bin
lmdb_bundle_libdir  := $(bundle_rootdir)/lib
lmdb_bundle_bindir  := $(bundle_rootdir)/bin

# List of binary tools to install / bundle amongst mdb_stat, mdb_copy,
# mdb_dump, mdb_load, mtest, mtest2, mtest3, mtest4 and mtest5.
lmdb_bins := $(LMDB_BINARIES)

lmdb_libs := liblmdb.so

################################################################################
# This module help message
################################################################################

define lmdb_align_help
$(subst $(space),$(newline)                         ,$(strip $(1)))
endef

define module_help
Build and install the Lighting Memory-Mapped Database (LMDB), an ultra-fast,
ultra-compact key-value embedded data store developed for the OpenLDAP Project.
It uses memory-mapped files, so it has the read performance of a pure in-memory
database while still offering the persistence of standard disk-based databases,
and is only limited to the size of the virtual address space, (it is not limited
to the size of physical RAM).

::Configuration variable::
  LMDB_SRCDIR        -- Path to source directory tree
                        [$(LMDB_SRCDIR)]
  LMDB_CROSS_COMPILE -- Path to cross compiling tool chain
                        [$(LMDB_CROSS_COMPILE)]
  LMDB_CFLAGS        -- Optional extra CFLAGS passed to lmdb compile process
                        [$(call lmdb_align_help,$(LMDB_CFLAGS))]
  LMDB_LDFLAGS       -- Optional extra LDFLAGS passed to lmdb link process in
                        addition to LMDB_CFLAGS
                        [$(call lmdb_align_help,$(LMDB_LDFLAGS))]
  LMDB_BINARIES      -- List of lmdb binary tools to install / bundle.
                        [$(call lmdb_align_help,$(LMDB_BINARIES))]

::Installed::
  $$(stagingdir)/bin/mdb_*                  -- Utilities
  $$(stagingdir)/lib/liblmdb.so*            -- Shared library
  $$(stagingdir)/usr/include/lmdb.h         -- Development header
  $$(stagingdir)/usr/share/man/man1/mdb_*.1 -- Man pages

::Bundled::
  $$(bundle_rootdir)/bin/mdb_*       -- Utilities
  $$(bundle_rootdir)/lib/liblmdb.so* -- Shared library
endef

################################################################################
# Config logic
################################################################################

$(config_target):
	$(Q)$(call mirror_cmd, \
	           --delete $(LMDB_SRCDIR)/libraries/liblmdb/, \
	           $(module_builddir))
	$(Q)touch $(@)

################################################################################
# Build logic
################################################################################

$(build_target):
	+$(Q)$(lmdb_make)
	$(Q)touch $(@)

################################################################################
# Clean logic
################################################################################

clean:
	+$(Q)$(lmdb_make) clean

################################################################################
# Install logic
################################################################################

$(install_target):
	+$(Q)$(lmdb_make) install DESTDIR:="$(stagingdir)"
	$(Q)touch $(@)

################################################################################
# Uninstall logic
################################################################################

uninstall:
	$(Q)$(call rmf_cmd,$(stagingdir)/bin/mdb_*)
	$(Q)$(call rmf_cmd,$(stagingdir)/bin/mtest*)
	$(Q)$(call rmf_cmd,$(stagingdir)/lib/liblmdb.*)
	$(Q)$(call rmf_cmd,$(stagingdir)/usr/include/lmdb.h)
	$(Q)$(call rmf_cmd,$(stagingdir)/usr/share/man/man1/mdb_*)

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	$(foreach b, \
	          $(lmdb_bins), \
	          $(Q)$(call bundle_bin_cmd, \
	                     $(lmdb_staging_bindir)/$(b), \
	                     $(lmdb_bundle_bindir))$(newline))
	$(foreach l, \
	          $(lmdb_libs), \
	          $(Q)$(call bundle_lib_cmd, \
	                     $(lmdb_staging_libdir)/$(l), \
	                     $(lmdb_bundle_libdir))$(newline))
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(foreach b, \
	          $(lmdb_bins), \
	          $(Q)$(call drop_cmd, \
	                     $(lmdb_bundle_bindir)/$(b))$(newline))
	$(foreach l, \
	          $(lmdb_libs), \
	          $(Q)$(call drop_lib_cmd, \
	                     $(lmdb_staging_libdir)/$(l), \
	                     $(lmdb_bundle_libdir))$(newline))
