include $(CRAFTERDIR)/core/module.mk

$(call gen_module_depends,va38x_rootfs)

################################################################################
# This module help message
################################################################################

define module_help
Generate Qemu Armada 38x virtual platform based initRamFS.

::Bundled::
  $$(bundledir)/root.initramfs -- InitRamFS root file system
endef

################################################################################
# Bundle logic
#
# Bundle the flash'able rescue image given the FUT specification generated at
# build time.
################################################################################

va38x_initramfs := $(bundledir)/root.initramfs

$(bundle_target): $(va38x_initramfs)

# Build initRamFS
.PHONY: $(va38x_initramfs)
$(va38x_initramfs):
	@$(call log_action,GENRAMFS,$(@))
	$(Q)$(CRAFTER_SCRIPTDIR)/geninitramfs.sh \
		--fake $(bundle_fake_root_env) $(@) $(bundle_rootdir)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call rmf_cmd,$(va38x_initramfs))
