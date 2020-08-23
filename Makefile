SCRIPTDIR             := $(CURDIR)/scripts
OUTDIR                := $(CURDIR)/out
XTCHAIN_HOST_DIR      := $(HOME)/dev/tools/xtchain/a38x
XTCHAIN_TARGET_DIR    := $(XTCHAIN_HOST_DIR)/armv7_a38x-xtchain-linux-gnueabihf
PATH                  := $(XTCHAIN_TARGET_DIR)/bin:$(XTCHAIN_HOST_DIR)/bin:$(PATH)
CRAFTER_PLATFORM_VARS := XTCHAIN_HOST_DIR XTCHAIN_TARGET_DIR PATH
CRAFTERDIR            := $(CURDIR)/src/crafter
PLATFORMDIR           := $(CURDIR)/build/platforms
MODULEDIR             := $(CURDIR)/build/modules
TFTPDIR               := /srv/tftp/$(USER)

ifeq ($(strip $(JOBS)),)
# Compute number of available CPUs.
# Note: we should use the number of online CPUs...
cpu_nr := $(shell grep '^processor[[:blank:]]\+:' /proc/cpuinfo | wc -l)

# Compute maximum number of Makefile jobs.
job_nr := $(shell echo $$(($(cpu_nr) * 3 / 2)))
else
job_nr := $(JOBS)
endif

MAKEFLAGS += --jobs $(job_nr)

# Include main crafter makefile.
include $(CRAFTERDIR)/core/bootstrap.mk

# Override default crafter short help message to include tftp target related
# help
define help_short_message
===== Build usage =====

::Main targets:: Applicable to all platforms
  list-boards              -- display available build\'able boards
  list-<BOARD>-flavours    -- display build flavours available for BOARD
  list-modules             -- display all known modules

  show-platform            -- display default platform tuple
  select-<BOARD>-<FLAVOUR> -- setup default platform using BOARD / FLAVOUR tuple
  unselect-platform        -- disable default platform setup

  help                     -- a short help message
  help-full                -- a more complete help message


::Platform targets:: Applicable to default platform only !
  all                      -- construct all modules
  clobber                  -- remove all generated objects
  show-modules             -- display modules the default platform depends on

  tftp                     -- deploy deliverables into TFTP area


::Module targets:: Applicable to MODULE and default platform only !
  <MODULE>                 -- construct

  defconfig-<MODULE>       -- setup default construction configuration (forced)
  saveconfig-<MODULE>      -- save current construction configuration  (forced)
  guiconfig-<MODULE>       -- run the GUI construction configurator    (forced)
  config-<MODULE>          -- configure construction                   (forced)

  build-<MODULE>           -- build intermediate objects               (forced)
  install-<MODULE>         -- install final objects                    (forced)
  bundle-<MODULE>          -- install deliverable objects              (forced)

  drop-<MODULE>            -- remove bundled objects
  uninstall-<MODULE>       -- drop-<MODULE> + remove staged objects
  clean-<MODULE>           -- uninstall-<MODULE> + remove intermediate objects
  clobber-<MODULE>         -- remove all generated objects

  help-<MODULE>            -- display help message


::Where::
  BOARD       -- a platform board as listed by the list-boards target
  FLAVOUR     -- a board specific build flavour as listed by the
                 list-<BOARD>-flavours target
  MODULE      -- a default platform MODULE as listed by the show-modules target
endef

# Also override default crafter full help message to include tftp targets
# related help.
define help_full_message
$(help_short_message)


::Areas::
  build       -- directory under which intermediate built objects will be
                 generated
                 [$$(OUTDIR)/<BOARD>/<FLAVOUR>/build/<MODULE>/]
  staging     -- directory under which final platform objects will be installed
                 [$$(OUTDIR)/<BOARD>/<FLAVOUR>/staging/]
  bundle      -- directory under which platform deliverables will be bundled
                 [$$(OUTDIR)/<BOARD>/<FLAVOUR>/]
  tftp        -- directory under which platform deliverables will be deployed
                 for TFTP server usage
                 [$$(TFTPDIR)/<BOARD>/<FLAVOUR>]


::Variables::
  TARGET_PLATFORM -- override default platform using a tuple of the form:
                     <BOARD>-<FLAVOUR> ; cannot be mixed with explicit
                     TARGET_BOARD and / or TARGET_FLAVOUR definitions
  TARGET_BOARD    -- override default platform board ; in addition,
                     TARGET_FLAVOUR MUST also be defined
  TARGET_FLAVOUR  -- override default platform flavour ; in additon,
                     TARGET_BOARD MUST also be defined
  OUTDIR          -- directory path under which all crafter generated objects
                     will be located
                     [$(OUTDIR)]
  PLATFORMDIR     -- directory path under which crafter user / platform specific
                     logic is located
                     [$(PLATFORMDIR)]
  MODULEDIR       -- directory path under which user / platform module
                     implementation makefiles are seached for
                     [$(MODULEDIR)]
  CRAFTERDIR      -- directory path under which core crafter logic is located
                     [$(CRAFTERDIR)]
  CONFIGDIR       -- directory path under which end-user configurations files
                     are searched for
                     [$(CONFIGDIR)]
  TFTPDIR         -- directory path under which all deliverables meant to be
                     served over TFTP will be deployed
                     [$(TFTPDIR)]
  JOBS            -- Request make to build using JOBS jobs
  V               -- crafter verbosity setting
                     0 => quiet build (default), 1 => verbose build
endef

################################################################################
# TFTP management
################################################################################

# Declare deliverables to deploy.
#tftp_prod_files  := bootrom.bin \
#                    clkgen.fw \
#                    u-boot.bin \
#                    u-boot_default.env \
#                    u-boot-spl.kwb \
#                    cometh.itb
#
#tftp_devel_files := $(tftp_prod_files) \
#                    u-boot_dev.env
#
## Path to the base directory where default platform deliverables will be
## deployed for TFTP usage.
#tftpdir := $(TFTPDIR)/$(TARGET_BOARD)/$(TARGET_FLAVOUR)
#
## tftp: - Target deploying current platform deliverables for TFTP usage.
##
## Will build the current platform as a prerequisite.
#.PHONY: tftp
#tftp: all
#	$(call log_target,tftp,DEPLOY)
#	$(Q)$(call mkdir_cmd,$(tftpdir))
#	$(Q)$(foreach f, \
#	              $(tftp_$(TARGET_FLAVOUR)_files), \
#	              $(call rsync_cmd, \
#	                     $(outdir)/$(f), \
#	                     $(tftpdir)/$(notdir $(f)));)
