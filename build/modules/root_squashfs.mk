include $(CRAFTERDIR)/core/module.mk

# Interrupt processing if platform specified no dependencies.
$(call dieon_undef_or_empty,ROOT_SQUASHFS_DEPENDS)

$(call gen_module_depends,$(ROOT_SQUASHFS_DEPENDS))

################################################################################
# This module help message
################################################################################

define module_help
Generate platform root filesystem SquashFS image.

::Configuration variables::
  ROOT_SQUASHFS_OPTS     -- Options given to mksquashfs image builder.
                            [$(ROOT_SQUASHFS_OPTS)]

::Bundled::
  $$(bundledir)/root.sqfs -- squashFS root file system
endef

################################################################################
# Bundle logic
#
# Bundle the flash'able rescue image given the FUT specification generated at
# build time.
################################################################################

root_squashfs_path := $(bundledir)/root.sqfs

$(bundle_target): $(root_squashfs_path)

# Build squashFS
.PHONY: $(root_squashfs_path)
$(root_squashfs_path):
	@$(call log_action,GENSQUASHFS,$(@))
	$(Q)$(CRAFTER_SCRIPTDIR)/gensquashfs.sh \
		$(if $(strip $(ROOT_SQUASHFS_OPTS)), \
		     --squashfs-opts '$(strip $(ROOT_SQUASHFS_OPTS))') \
		--fake $(bundle_fake_root_env) \
		$(@) \
		$(bundle_rootdir)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call rmf_cmd,$(root_squashfs_opts))
