include $(CRAFTERDIR)/core/module.mk

$(call gen_module_depends,tidor_rootfs)

################################################################################
# This module help message
################################################################################

define module_help
Generate Clearfog Pro platform based initRamFS.

::Bundled::
  $$(bundledir)/root.initramfs -- InitRamFS root file system
endef

################################################################################
# Bundle logic
#
# Bundle the flash'able rescue image given the FUT specification generated at
# build time.
################################################################################

tidor_initramfs := $(bundledir)/root.initramfs

$(bundle_target): $(tidor_initramfs)

# Build initRamFS
.PHONY: $(tidor_initramfs)
$(tidor_initramfs):
	@$(call log_action,GENRAMFS,$(@))
	$(Q)$(CRAFTER_SCRIPTDIR)/geninitramfs.sh \
		--fake $(bundle_fake_root_env) $(@) $(bundle_rootdir)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call rmf_cmd,$(tidor_initramfs))
