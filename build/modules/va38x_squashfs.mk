include $(CRAFTERDIR)/core/module.mk

$(call gen_module_depends,va38x_rootfs)

################################################################################
# This module help message
################################################################################

define module_help
Generate Qemu Armada 38x virtual platform based squashFS.

::Bundled::
  $$(bundledir)/root.sqfs -- squashFS root file system
endef

################################################################################
# Bundle logic
#
# Bundle the flash'able rescue image given the FUT specification generated at
# build time.
################################################################################

va38x_squashfs := $(bundledir)/root.sqfs

$(bundle_target): $(va38x_squashfs)

# Build squashFS
.PHONY: $(va38x_squashfs)
$(va38x_squashfs):
	@$(call log_action,GENSQUASHFS,$(@))
	$(Q)$(CRAFTER_SCRIPTDIR)/gensquashfs.sh \
		$(if $(strip $(VA38X_SQUASHFS_OPTS)), \
		     --squashfs-opts '$(strip $(VA38X_SQUASHFS_OPTS))') \
		--fake $(bundle_fake_root_env) \
		$(@) \
		$(bundle_rootdir)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call rmf_cmd,$(va38x_squashfs))
