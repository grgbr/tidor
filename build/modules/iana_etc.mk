include $(CRAFTERDIR)/core/module.mk

# Interrupt processing if platform specified no source tree.
$(call dieon_undef_or_empty,IANA_ETC_SRCDIR)

# iana_etc make command
iana_etc_make_cmd := $(MAKE) -C $(module_builddir) ETC_DIR:=/etc STRIP=yes

################################################################################
# This module help message
################################################################################

define module_help
Build and install services and protocols databases using data from the Internet
Assigned Numbers Authority.

::Configuration variable::
  IANA_ETC_SRCDIR           -- Path to source directory tree
                               [$(IANA_ETC_SRCDIR)]

::Bundled::
  $$(bundle_rootdir)/etc/protocols -- Protocols database
  $$(bundle_rootdir)/etc/services  -- Services database
endef

################################################################################
# Config logic
################################################################################

$(config_target):
	$(Q)$(call rmrf_cmd,$(module_builddir))
	$(Q)$(call mirror_cmd,$(IANA_ETC_SRCDIR)/,$(module_builddir))
	$(Q)touch $(@)

################################################################################
# Build logic
################################################################################

$(build_target):
	+$(Q)$(iana_etc_make_cmd)
	$(Q)touch $(@)

################################################################################
# Clean logic
################################################################################

clean:
	+$(Q)$(iana_etc_make_cmd) clean

################################################################################
# Bundle logic
################################################################################

$(bundle_target):
	+$(Q)$(call fake_root_cmd, \
	            $(bundle_fake_root_env), \
	            $(iana_etc_make_cmd) install DESTDIR:=$(bundle_rootdir))
	$(Q)touch $(@)

################################################################################
# Drop logic
################################################################################

drop:
	$(Q)$(call drop_cmd,$(bundle_rootdir)/etc/protocols)
	$(Q)$(call drop_cmd,$(bundle_rootdir)/etc/services)
