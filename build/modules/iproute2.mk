include $(CRAFTERDIR)/core/module.mk

$(call gen_module_depends,linux libmnl libdb elfutils libcap)

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,IPROUTE2_SRCDIR)
# Interrupt processing if platform specified no build arguments.
$(call dieon_undef_or_empty,IPROUTE2_TARGET_ARGS)

# iproute2 make invocation macro.
iproute2_target_args := $(IPROUTE2_TARGET_ARGS) \
                        AR="$(strip $(if $(IPROUTE2_CROSS_COMPILE), \
                                         $(IPROUTE2_CROSS_COMPILE)gcc-ar))" \
                        CC="$(strip $(if $(IPROUTE2_CROSS_COMPILE), \
                                         $(IPROUTE2_CROSS_COMPILE)gcc))" \
                        $(call ifdef, \
                               IPROUTE2_TARGET_CFLAGS, \
                               EXTRA_CFLAGS="$(IPROUTE2_TARGET_CFLAGS)") \
                        $(call ifdef, \
                               IPROUTE2_TARGET_LDFLAGS, \
                               LDFLAGS="$(IPROUTE2_TARGET_LDFLAGS)") \
                        HOSTCC="gcc" \
                        PREFIX="" \
                        DATADIR="/usr/share" \
                        HDRDIR="/usr/include/iproute2" \
                        KERNEL_INCLUDE="$(stagingdir)/usr/include"

iproute2_make      := $(MAKE) -C $(module_builddir) $(iproute2_target_args)

# Location of staged iproute2
iproute2_staging_sbindir   := $(stagingdir)$(IPROUTE2_TARGET_PREFIX)/sbin
iproute2_staging_configdir := $(stagingdir)$(IPROUTE2_TARGET_PREFIX)/etc/iproute2

# Location of bundled iproute2
iproute2_bundle_sbindir    := $(bundle_rootdir)$(IPROUTE2_TARGET_PREFIX)/sbin
iproute2_bundle_configdir  := $(bundle_rootdir)$(IPROUTE2_TARGET_PREFIX)/etc/iproute2

# Bundled components
iproute2_sbins   := ip \
                    rtmon \
                    tc \
                    bridge \
                    ss \
                    nstat \
                    ifstat \
                    lnstat \
                    genl \
                    devlink
iproute2_configs := rt_tables \
                    rt_protos \
                    bpf_pinning \
                    ematch_map \
                    nl_protos \
                    group \
                    rt_dsfield \
                    rt_scopes \
                    rt_realms

################################################################################
# This module help message
################################################################################

define iproute2_align_help
$(subst $(space),$(newline)                                ,$(strip $(1)))
endef

define module_help
Build and install iproute2, a collection of userspace utilities for controlling
and monitoring Linux kernel networking stack.

::Configuration variable::
  IPROUTE2_SRCDIR           -- Path to source directory tree
                               [$(IPROUTE2_SRCDIR)]
  IPROUTE2_CROSS_COMPILE    -- Path to iproute2 cross compiling toolchain
                               [$(call iproute2_align_help, \
                                       $(IPROUTE2_CROSS_COMPILE))]
  IPROUTE2_TARGET_MAKE_ARGS -- Arguments passed to make and configure
                               [$(call iproute2_align_help, \
                                       $(iproute2_target_args))]

::Installed::
  $$(stagingdir)/sbin/ip                                  -- Binaries
  $$(stagingdir)/sbin/rtmon
  $$(stagingdir)/sbin/ifcfg
  $$(stagingdir)/sbin/rtpr
  $$(stagingdir)/sbin/routel
  $$(stagingdir)/sbin/routef
  $$(stagingdir)/sbin/tc
  $$(stagingdir)/sbin/bridge
  $$(stagingdir)/sbin/ss
  $$(stagingdir)/sbin/nstat
  $$(stagingdir)/sbin/ifstat
  $$(stagingdir)/sbin/rtacct
  $$(stagingdir)/sbin/lnstat
  $$(stagingdir)/sbin/rtstat
  $$(stagingdir)/sbin/ctstat
  $$(stagingdir)/sbin/genl
  $$(stagingdir)/sbin/tipc
  $$(stagingdir)/sbin/devlink
  $$(stagingdir)/sbin/rdma
  $$(stagingdir)/lib/tc/*                                 -- tc dynamic objects
  $$(stagingdir)/etc/iproute2/*                           -- Configuration files
  $$(stagingdir)/usr/include/iproute2/bpf_elf.h           -- Development header
  $$(stagingdir)/usr/share/man/man3/libnetlink.3          -- Man pages
  $$(stagingdir)/usr/share/man/man7/tc-hfsc.7
  $$(stagingdir)/usr/share/man/man8/ip-*.8
  $$(stagingdir)/usr/share/man/man8/tc*.8
  $$(stagingdir)/usr/share/man/man8/tipc*.8
  $$(stagingdir)/usr/share/man/man8/rtacct.8
  $$(stagingdir)/usr/share/man/man8/rtpr.8
  $$(stagingdir)/usr/share/man/man8/arpd.8
  $$(stagingdir)/usr/share/man/man8/devlink*.8
  $$(stagingdir)/usr/share/man/man8/genl.8
  $$(stagingdir)/usr/share/man/man8/rdma*.8
  $$(stagingdir)/usr/share/man/man8/rtstat.8
  $$(stagingdir)/usr/share/man/man8/ctstat.8
  $$(stagingdir)/usr/share/man/man8/routef.8
  $$(stagingdir)/usr/share/man/man8/routel.8
  $$(stagingdir)/usr/share/man/man8/rtmon.8
  $$(stagingdir)/usr/share/man/man8/ss.8
  $$(stagingdir)/usr/share/man/man8/lnstat.8
  $$(stagingdir)/usr/share/man/man8/nstat.8
  $$(stagingdir)/usr/share/man/man8/ifstat.8
  $$(stagingdir)/usr/share/man/man8/ifcfg.8
  $$(stagingdir)/usr/share/man/man8/bridge.8
  $$(stagingdir)/usr/share/bash-completion/completions/tc -- Bash completion scripts

::Bundled::
  $$(bundle_rootdir)/sbin/ip        -- Binaries
  $$(bundle_rootdir)/sbin/rtmon
  $$(bundle_rootdir)/sbin/tc
  $$(bundle_rootdir)/sbin/bridge
  $$(bundle_rootdir)/sbin/ss
  $$(bundle_rootdir)/sbin/nstat
  $$(bundle_rootdir)/sbin/ifstat
  $$(bundle_rootdir)/sbin/lnstat
  $$(bundle_rootdir)/sbin/genl
  $$(bundle_rootdir)/sbin/devlink
  $$(bundle_rootdir)/etc/iproute2/* -- Configuration files
endef

################################################################################
# Configure logic
################################################################################

$(config_target):
	$(Q)$(call mirror_cmd,--delete $(IPROUTE2_SRCDIR)/,$(module_builddir))
	$(Q)cd $(module_builddir) && \
	    env $(iproute2_target_args) \
	    $(IPROUTE2_SRCDIR)/configure
	$(Q)touch $(@)

################################################################################
# Build logic
################################################################################

$(build_target):
	+$(Q)$(iproute2_make)
	$(Q)touch $(@)

################################################################################
# Clean logic
################################################################################

clean:
	+$(Q)$(iproute2_make) clean

################################################################################
# Install logic
################################################################################

$(install_target):
	+$(Q)$(iproute2_make) install DESTDIR="$(module_installdir)"
	$(Q)$(call mirror_cmd,$(module_installdir)/,$(stagingdir))
	$(Q)touch $(@)

################################################################################
# Uninstall logic
################################################################################

uninstall:
	$(Q)$(call unmirror_cmd,$(module_installdir),$(stagingdir))
	$(Q)$(call rmrf_cmd,$(module_installdir))

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	$(foreach b, \
	          $(iproute2_sbins), \
	          $(Q)$(call bundle_bin_cmd, \
	                     $(iproute2_staging_sbindir)/$(b), \
	                     $(iproute2_bundle_sbindir))$(newline))
	$(Q)$(call bundle_dir_cmd,-m755,$(iproute2_bundle_configdir))
	$(foreach c, \
	          $(iproute2_configs), \
	          $(Q)$(call bundle_cmd, \
	                     -m644, \
	                     $(iproute2_staging_configdir)/$(c), \
	                     $(iproute2_bundle_configdir))$(newline))
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(foreach b, \
	          $(iproute2_sbins), \
	          $(Q)$(call drop_cmd, \
	                     $(iproute2_bundle_sbindir)/$(b))$(newline))
	$(foreach c, \
	          $(iproute2_configs), \
	          $(Q)$(call drop_cmd, \
	                     $(iproute2_bundle_configdir)/$(c))$(newline))
