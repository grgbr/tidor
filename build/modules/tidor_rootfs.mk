include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/fakefs.mk

$(call dieon_undef_or_empty,TIDOR_ROOTFS_SRCDIR)

ifneq ($(wildcard $(TIDOR_ROOTFS_CONFIG_FILES)),)
include $(TIDOR_ROOTFS_CONFIG_FILES)
endif

# To protect from simultaneously calling fakeroot...
.NOTPARALLEL:

# This module depends on all other ones except final tidor filesystem images
# generation modules (and itself but gen_module_depends() is cyclic dependency
# safe).
$(call gen_module_depends,$(filter-out initramfs root_squashfs,$(MODULES)))

################################################################################
# This module help message
################################################################################

define module_help
Generate Qemu Armada 38x virtual platform based root filesystem.

::Bundled::
  Complete me !!
endef

LIBNSS_NSSWITCH_CONF_PATH := $(PLATFORMDIR)/tidor/nsswitch.conf

################################################################################
# Build logic
################################################################################

define tidor_rootfs_spec
file  /etc/passwd                $(stagingdir)/etc/passwd                   644 0 0
file  /etc/shadow                $(stagingdir)/etc/shadow                   640 0 0
file  /etc/group                 $(stagingdir)/etc/group                    644 0 0
file  /etc/gshadow               $(stagingdir)/etc/gshadow                  640 0 0
file  /etc/hosts                 $(TIDOR_ROOTFS_SRCDIR)/etc/hosts           644 0 0
file  /etc/profile               $(TIDOR_ROOTFS_SRCDIR)/etc/profile         644 0 0
file  /etc/nsswitch.conf         $(TIDOR_ROOTFS_SRCDIR)/etc/nsswitch.conf   644 0 0
dir   /etc/init                                                             755 0 0
file  /etc/init/start            $(TIDOR_ROOTFS_SRCDIR)/etc/init/start      755 0 0
dir   /etc/init/ttyS0                                                       755 0 0
file  /etc/init/ttyS0/run        $(TIDOR_ROOTFS_SRCDIR)/etc/init/ttyS0/run  755 0 0
slink /etc/init/ttyS0/supervise  /var/run/init/ttyS0                            0 0
dir   /etc/init/usb                                                         755 0 0
file  /etc/init/usb/run          $(TIDOR_ROOTFS_SRCDIR)/etc/init/usb/run    755 0 0
slink /etc/init/usb/supervise    /var/run/init/usb                              0 0
dir   /etc/init/klog                                                        755 0 0
file  /etc/init/klog/run         $(TIDOR_ROOTFS_SRCDIR)/etc/init/klog/run   755 0 0
slink /etc/init/klog/supervise   /var/run/init/klog                             0 0
dir   /etc/init/syslog                                                      755 0 0
file  /etc/init/syslog/run       $(TIDOR_ROOTFS_SRCDIR)/etc/init/syslog/run 755 0 0
slink /etc/init/syslog/supervise /var/run/init/syslog                           0 0
dir   /etc/init/nwif                                                        755 0 0
file  /etc/init/nwif/run         $(TIDOR_ROOTFS_SRCDIR)/etc/init/nwif/run   755 0 0
slink /etc/init/nwif/supervise   /var/run/init/nwif                             0 0
dir   /etc/init/current                                                     755 0 0
slink /etc/init/current/ttyS0    /etc/init/ttyS0                                0 0
slink /etc/init/current/usb      /etc/init/usb                                  0 0
slink /etc/init/current/klog     /etc/init/klog                                 0 0
slink /etc/init/current/syslog   /etc/init/syslog                               0 0
slink /etc/init/current/nwif     /etc/init/nwif                                 0 0
dir   /mnt                                                                  750 0 0
dir   /mnt/config                                                           750 0 0
endef

$(build_target): $(module_builddir)/fstable.txt

# We need an advanced shell for the build recipe. See usage of gen_fstable_cmd()
# macro into _ubifs_rules().
$(module_builddir)/fstable.txt: SHELL := /bin/bash

# Make sure filesystem table is generated on dependency modules changes
$(module_builddir)/fstable.txt:  $(CRAFTERDIR)/core/fakefs.mk \
                                 $(module_prereqs) \
                                 | $(module_builddir)
	$(Q)$(call gen_fstable_cmd,$(@),tidor_rootfs_spec)
	@touch $(@)

################################################################################
# clean logic
################################################################################

clean:
	$(Q)$(call rmrf_cmd,$(module_builddir))

################################################################################
# Bundle logic
################################################################################

$(bundle_target): $(call stamp,fakefs) \
                  $(bundle_rootdir)/etc/ld.so.cache

.PHONY: $(call stamp,fakefs)
$(call stamp,fakefs): $(module_builddir)/fstable.txt \
                      $(install_target) \
                      | $(bundledir_rootdir)
	$(Q)$(call gen_fakefs_cmd, \
	           $(bundle_rootdir), \
	           $(<), \
	           $(bundle_fake_root_env), \
	           /)
	@touch $(@)

$(bundle_rootdir)/etc/ld.so.cache: $(call stamp,fakefs)
	$(Q)$(call log_action,LDCONF,$(@))
	$(Q)$(call fake_root_cmd, \
	           $(bundle_fake_root_env), \
	           $(LIBC_CROSS_COMPILE)ldconfig -r $(bundle_rootdir) \
	                                         --format=new \
	                                         -C /etc/ld.so.cache \
	                                         --ignore-aux-cache \
	                                         -X \
	                                         $(redirect) 2>/dev/null)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call drop_cmd,$(bundle_rootdir)/etc/ld.so.cache)
	$(Q)$(call clean_fakefs_cmd, \
	           $(bundle_rootdir), \
	           $(module_builddir)/fstable.txt, \
	           $(bundle_fake_root_env))
