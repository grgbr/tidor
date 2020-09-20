include $(CRAFTERDIR)/core/module.mk

# Interrupt processing if platform specified no dependencies.
$(call dieon_undef_or_empty,INITRAMFS_DEPENDS)

$(call gen_module_depends,$(INITRAMFS_DEPENDS))

################################################################################
# This module help message
################################################################################

define module_help
Generate platform initRamFS.

::Bundled::
  $$(bundledir)/root.initramfs -- InitRamFS root file system
endef

################################################################################
# Bundle logic
################################################################################

initramfs_path := $(bundledir)/root.initramfs

$(bundle_target): $(initramfs_path)

# Build initRamFS
.PHONY: $(initramfs_path)
$(initramfs_path):
	@$(call log_action,GENRAMFS,$(@))
	$(Q)$(CRAFTER_SCRIPTDIR)/geninitramfs.sh \
		--fake $(bundle_fake_root_env) $(@) $(bundle_rootdir)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call rmf_cmd,$(initramfs_path)
