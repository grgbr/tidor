include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/fakefs.mk

################################################################################
# This module help message
################################################################################

define module_help
Generate basic root filesystem skeleton.

::Configuration variables::
  BASE_ROOTFS_ROOT_PASSWD -- An optional clear text default root password ;
                             Root login will be allowed if none given
                             (or empty).
                             [$(BASE_ROOTFS_ROOT_PASSWD)]

::Installed::
  $$(stagingdir)/etc/passwd  -- Basic logon credential system files.
  $$(stagingdir)/etc/shadow
  $$(stagingdir)/etc/group
  $$(stagingdir)/etc/gshadow

::Bundled::
  $$(bundle_rootdir)/bin         -- Basic root filesystem entries
  $$(bundle_rootdir)/dev
  $$(bundle_rootdir)/dev/console
  $$(bundle_rootdir)/dev/null
  $$(bundle_rootdir)/etc
  $$(bundle_rootdir)/lib
  $$(bundle_rootdir)/proc
  $$(bundle_rootdir)/root
  $$(bundle_rootdir)/sbin
  $$(bundle_rootdir)/sys
  $$(bundle_rootdir)/var
  $$(bundle_rootdir)/var/run
endef

################################################################################
# Build logic
################################################################################

define base_rootfs_spec
dir   /                           755 0 0
dir   /bin                        755 0 0
dir   /dev                        755 0 0
nod   /dev/console                600 0 0 c 5 1
nod   /dev/null                   666 0 0 c 1 3
dir   /etc                        755 0 0
slink /etc/mtab /proc/self/mounts     0 0
dir   /lib                        755 0 0
dir   /proc                       555 0 0
dir   /root                       700 0 0
dir   /sbin                       755 0 0
dir   /sys                        555 0 0
dir   /var                        750 0 0
dir   /var/lib                    750 0 0
dir   /var/run                    755 0 0
endef

$(build_target): $(module_builddir)/fstable.txt

# We need an advanced shell for the build recipe. See usage of gen_fstable_cmd()
# macro into _ubifs_rules().
$(module_builddir)/fstable.txt: SHELL := /bin/bash

# Make sure filesystem table is generated on dependency modules changes
$(module_builddir)/fstable.txt:  $(CRAFTERDIR)/core/fakefs.mk \
                                 $(module_prereqs) \
                                 | $(module_builddir)
	$(Q)$(call gen_fstable_cmd,$(@),base_rootfs_spec)
	@touch $(@)

################################################################################
# clean logic
################################################################################

clean:
	$(Q)$(call rmrf_cmd,$(module_builddir))

################################################################################
# Install logic
################################################################################

$(install_target): $(stagingdir)/etc/passwd \
                   $(stagingdir)/etc/shadow \
                   $(stagingdir)/etc/group \
                   $(stagingdir)/etc/gshadow
	@touch $(@)

define _base_rootfs_mkcred_rule
$(1): SHELL := /bin/bash
$(1): $(build_target) | $(stagingdir)/etc
	$(Q)$(call log_action,MKCRED,$(1))
	$(Q)$$(call echo_multi_line_var_cmd,$$($(strip $(2)))) > $$(@)
endef

define base_rootfs_gen_cred_rule
$(eval $(call _base_rootfs_mkcred_rule,$(1),$(2)))
endef

# Define root user with shadowed password, /root home directory and /bin/sh as
# login shell.
#
# Fields are colon separated as following :
# login name:password:UID:GID:comment:home directory:shell
#
# See group(5) man page.
define base_rootfs_passwd
root:x:0:0:Super User,,,:/root:/bin/sh
endef

$(call base_rootfs_gen_cred_rule,$(stagingdir)/etc/passwd,base_rootfs_passwd)

# If BASE_ROOTFS_ROOT_PASSWD is not empty, define (shadowed) root user :
# * with SHA-512 salted / encrypted password,
# * requiring password change upon first logon,
# * with password aging disabled.
#
# If BASE_ROOTFS_ROOT_PASSWD is empty, define (shadowed) root user :
# * with no password required for logon,
# * with no required password change upon first logon,
# * with password aging disabled.
# (for development purpose only !!)
#
# Fields are colon separated as following :
# login name:password:UID:GID:comment:home directory:shell
#
# See shadow(5) man page.
define base_rootfs_shadow
root:$(call mkpasswd,SHA-512,$(BASE_ROOTFS_ROOT_PASSWD)):$(if $(BASE_ROOTFS_ROOT_PASSWD),0)::::::
endef

$(call base_rootfs_gen_cred_rule,$(stagingdir)/etc/shadow,base_rootfs_shadow)

# Define root group with shadowed group password and no members.
#
# Fields are colon separated as following :
# group name:password:GID:members
#
# See group(5) man page.
define base_rootfs_group
root:x:0:
endef

$(call base_rootfs_gen_cred_rule,$(stagingdir)/etc/group,base_rootfs_group)

# Define (shadowed) root group with group password disabled,
# no group administrators and no members.
#
# Fields are colon separated as following :
# group name:encrypted password:administrators:members
#
# See gshadow(5) man page.
define base_rootfs_gshadow
root:!::
endef

$(call base_rootfs_gen_cred_rule,$(stagingdir)/etc/gshadow,base_rootfs_gshadow)

################################################################################
# Uninstall logic
################################################################################

uninstall:
	$(Q)$(call rmf_cmd,$(stagingdir)/etc/passwd)
	$(Q)$(call rmf_cmd,$(stagingdir)/etc/shadow)
	$(Q)$(call rmf_cmd,$(stagingdir)/etc/group)
	$(Q)$(call rmf_cmd,$(stagingdir)/etc/gshadow)

################################################################################
# Bundle logic
################################################################################

$(bundle_target): $(call stamp,fakefs)

# Note: the last argument given to gen_fakefs_cmd() is unused here since
# base_rootfs_spec macro contains no 'file' directive.
# As gen_fakefs_cmd() macro requires one however, make it happy by giving it
# $(module_builddir).
.PHONY: $(call stamp,fakefs)
$(call stamp,fakefs): $(module_builddir)/fstable.txt \
                      $(install_target) \
                      | $(bundledir_rootdir)
	$(Q)$(call gen_fakefs_cmd, \
	           $(bundle_rootdir), \
	           $(<), \
	           $(bundle_fake_root_env), \
	           $(module_builddir))
	@touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call clean_fakefs_cmd, \
	           $(bundle_rootdir), \
	           $(module_builddir)/fstable.txt, \
	           $(bundle_fake_root_env))
