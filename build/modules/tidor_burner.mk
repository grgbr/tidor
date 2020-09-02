include $(CRAFTERDIR)/core/module.mk
include $(CRAFTERDIR)/core/fakefs.mk

$(call dieon_undef_or_empty,TIDOR_BURNER_SRCDIR)

# To protect from simultaneously calling fakeroot...
.NOTPARALLEL:

$(call gen_module_depends,util_linux e2fsprogs linux busybox)

################################################################################
# This module help message
################################################################################

define module_help
Build and install TiDor target installer.

::Bundled::
  Complete me !!
endef

################################################################################
# Build logic
################################################################################

define tidor_burner_spec
dir  /etc                                                            755 0 0
file /etc/mke2fs.conf             $(TIDOR_BURNER_SRCDIR)/mke2fs.conf 644 0 0
dir  /usr                                                            755 0 0
dir  /usr/share                                                      755 0 0
dir  /usr/share/burner                                               755 0 0
file /usr/share/burner/sdhc.parts $(TIDOR_BURNER_SRCDIR)/sdhc.parts  644 0 0
dir  /sbin                                                           755 0 0
file /sbin/burn.sh                $(TIDOR_BURNER_SRCDIR)/burn.sh     755 0 0
endef

$(build_target): $(module_builddir)/fstable.txt

# We need an advanced shell for the build recipe. See usage of gen_fstable_cmd()
# macro into _ubifs_rules().
$(module_builddir)/fstable.txt: SHELL := /bin/bash

# Make sure filesystem table is generated on dependency modules changes
$(module_builddir)/fstable.txt:  $(CRAFTERDIR)/core/fakefs.mk \
                                 $(module_prereqs) \
                                 | $(module_builddir)
	$(Q)$(call gen_fstable_cmd,$(@),tidor_burner_spec)
	@touch $(@)

################################################################################
# clean logic
################################################################################

clean:
	$(Q)$(call rmrf_cmd,$(module_builddir))

################################################################################
# Bundle logic
################################################################################

$(bundle_target): $(call stamp,fakefs)

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

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call clean_fakefs_cmd, \
	           $(bundle_rootdir), \
	           $(module_builddir)/fstable.txt, \
	           $(bundle_fake_root_env))
