#-------------------------------------------------------------------------------
# The MIT License (MIT)
# 
# Copyright (c) 2015 Jean-David Gadina - www-xs-labs.com
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Search paths
#-------------------------------------------------------------------------------

# Define the search paths for source files
vpath %$(EXT_C)     $(DIR_TESTS)
vpath %$(EXT_CPP)   $(DIR_TESTS)
vpath %$(EXT_M)     $(DIR_TESTS)
vpath %$(EXT_MM)    $(DIR_TESTS)
vpath %$(EXT_C)     $(DIR_SRC)
vpath %$(EXT_CPP)   $(DIR_SRC)
vpath %$(EXT_M)     $(DIR_SRC)
vpath %$(EXT_MM)    $(DIR_SRC)

#-------------------------------------------------------------------------------
# Built-in targets
#-------------------------------------------------------------------------------

# Declaration for phony targets, to avoid problems with local files
.PHONY: all        \
        clean      \
        debug      \
        release    \
        products   \
        test       \
        test-debug \
        _test

# Declaration for precious targets, to avoid cleaning of intermediate files
.PRECIOUS: $(DIR_BUILD_TEMP)%$(PRODUCT)$(EXT_O) $(DIR_BUILD_TEMP)%$(EXT_C)$(EXT_O) $(DIR_BUILD_TEMP)%$(EXT_CPP)$(EXT_O) $(DIR_BUILD_TEMP)%$(EXT_M)$(EXT_O) $(DIR_BUILD_TEMP)%$(EXT_MM)$(EXT_O)

#-------------------------------------------------------------------------------
# Common targets
#-------------------------------------------------------------------------------

# Main Target
all: release debug
	
	@:
	
# Release build (parallel if available)
release:
	
ifeq ($(MAKE_4),true)
	@$(MAKE) -j 50 --output-sync products
else
	@$(MAKE) products
endif

# Debug build (parallel if available)
debug:
	
ifeq ($(MAKE_4),true)
	@$(MAKE) -j 50 --output-sync products DEBUG=1
else
	@$(MAKE) products DEBUG=1
endif

# Cleans all build files
clean: _ARCHS         = $(foreach _PRODUCT,$(PRODUCTS),$(subst $(firstword $(subst |, ,$(_PRODUCT))),,$(subst |, ,$(_PRODUCT))))
clean: _CLEAN_ARCHS   = $(foreach _ARCH,$(_ARCHS),$(addprefix _clean_,$(_ARCH)))
clean:
	
	@$(MAKE) $(_CLEAN_ARCHS)
	@$(MAKE) $(_CLEAN_ARCHS) DEBUG=1

# Cleans architecture specific files
_clean_%:
	
	@echo -e $(call PRINT,Cleaning,$*,Cleaning all intermediate files)
	@rm -rf $(DIR_BUILD_TEMP)$*
	
	@echo -e $(call PRINT,Cleaning,$*,Cleaning all product files)
	@rm -rf $(DIR_BUILD_PRODUCTS)$*

# Release test target
test: release
	
	@$(MAKE) -s _test

# Debug test target
test-debug: debug
	
	@$(MAKE) -s _test DEBUG=1

# Test target
ifeq ($(HAS_XCTOOL),true)

_test:
	@echo -e $(call PRINT,Testing,n/a,Building and running unit tests)
	@$(XCTOOL) -project $(XCODE_PROJECT) -scheme "$(XCODE_TEST_SCHEME)" test

else
ifeq ($(HAS_XCBUILD),true)

_test:
	@echo -e $(call PRINT,Testing,n/a,Building and running unit tests)
	@$(XCBUILD) -project $(XCODE_PROJECT) -scheme "$(XCODE_TEST_SCHEME)" test

else

_test:
	
	@:
	
endif
endif

#-------------------------------------------------------------------------------
# Targets with second expansion
#-------------------------------------------------------------------------------

.SECONDEXPANSION:

# Products target
products: _PRODUCTS       = $(foreach _PRODUCT,$(PRODUCTS),$(foreach _ARCH,$(subst $(firstword $(subst |, ,$(_PRODUCT))),,$(subst |, ,$(_PRODUCT))),$(_ARCH)/$(firstword $(subst |, ,$(_PRODUCT)))))
products: _PRODUCTS_BUILD = $(foreach _PRODUCT,$(_PRODUCTS),$(addprefix $(DIR_BUILD_PRODUCTS),$(_PRODUCT)))
products: $$(_PRODUCTS_BUILD)
	
	@:

# Static library target
$(DIR_BUILD_PRODUCTS)%$(EXT_LIB): _ARCH  = $(firstword $(subst /, ,$*))
$(DIR_BUILD_PRODUCTS)%$(EXT_LIB): $$(shell mkdir -p $$(dir $$@)) $(DIR_BUILD_TEMP)$$(_ARCH)/$(PRODUCT)$(EXT_O)
	
	@echo -e $(call PRINT,$(notdir $@),$(_ARCH),Linking the $(_ARCH) binary)
	@$(AR) $(AR_FLAGS_$(_ARCH)) $@ $<

# Dynamic library target
$(DIR_BUILD_PRODUCTS)%$(EXT_DYLIB): _ARCH  = $(firstword $(subst /, ,$*))
$(DIR_BUILD_PRODUCTS)%$(EXT_DYLIB): $$(shell mkdir -p $$(dir $$@)) $(DIR_BUILD_TEMP)$$(_ARCH)/$(PRODUCT)$(EXT_O)
	
	@echo -e $(call PRINT,$(notdir $@),$(_ARCH),Linking the $(_ARCH) binary)
	@$(CC) $(LIBS) $(CC_FLAGS_DYLIB_$(_ARCH)) $(CC_FLAGS_$(_ARCH)) -o $@ $<

# Framework target
$(DIR_BUILD_PRODUCTS)%$(EXT_FRAMEWORK): _ARCH  = $(firstword $(subst /, ,$*))
$(DIR_BUILD_PRODUCTS)%$(EXT_FRAMEWORK): $$(shell mkdir -p $$(dir $$@)) $(DIR_BUILD_TEMP)$$(_ARCH)/$(PRODUCT)$(EXT_O)
	
	@echo -e $(call PRINT,$(notdir $@),$(_ARCH),Creating the directory structure)
	@rm -rf $@
	@mkdir -p $@/Versions/A/Headers/
	@mkdir -p $@/Versions/A/Resources/
	
	@echo -e $(call PRINT,$(notdir $@),$(_ARCH),Creating the symbolic links)
	@ln -s A/ $@/Versions/Current
	@ln -s Versions/A/Headers/ $@/Headers
	@ln -s Versions/A/Resources/ $@/Resources
	@ln -s Versions/A/$(notdir $(basename $@)) $@/$(notdir $(basename $@))
	
	@echo -e $(call PRINT,$(notdir $@),$(_ARCH),Copying the public header files)
	@cp -rf $(DIR_INC)$(PRODUCT).h $@/Versions/A/Headers/
	@cp -rf $(DIR_INC)$(PRODUCT)/* $@/Versions/A/Headers/
	
	@echo -e $(call PRINT,$(notdir $@),$(_ARCH),Copying the bundle resources)
	@:
	
	@echo -e $(call PRINT,$(notdir $@),$(_ARCH),Creating the Info.plist file)
	@cp -rf $(DIR_RES)Info.plist $@/Versions/A/Resources/Info.plist
	plutil -insert BuildMachineOSBuild -string $(shell sw_vers -buildVersion) $@/Versions/A/Resources/Info.plist
	plutil -insert DTSDKName -string macosx$(MAC_TARGET) $@/Versions/A/Resources/Info.plist
	plutil -insert DTCompiler -string $(call XCODE_SDK_VALUE,DTCompiler) $@/Versions/A/Resources/Info.plist
	plutil -insert DTPlatformBuild -string $(call XCODE_SDK_VALUE,DTPlatformBuild) $@/Versions/A/Resources/Info.plist
	plutil -insert DTPlatformVersion -string $(call XCODE_SDK_VALUE,DTPlatformVersion) $@/Versions/A/Resources/Info.plist
	plutil -insert DTSDKBuild -string $(call XCODE_SDK_VALUE,DTSDKBuild) $@/Versions/A/Resources/Info.plist
	plutil -insert DTXcode -string $(call XCODE_SDK_VALUE,DTXcode) $@/Versions/A/Resources/Info.plist
	plutil -insert DTXcodeBuild -string $(call XCODE_SDK_VALUE,DTXcodeBuild) $@/Versions/A/Resources/Info.plist
	
	@echo -e $(call PRINT,$(notdir $@),$(_ARCH),Linking the $(_ARCH) binary)
	@$(CC) $(LIBS) $(CC_FLAGS_FRAMEWORK_$(_ARCH)) $(CC_FLAGS_$(_ARCH)) -o $@/Versions/A/$(notdir $(basename $@)) $<

# Project object file target
$(DIR_BUILD_TEMP)%$(PRODUCT)$(EXT_O): _ARCH        = $(subst /,,$*)
$(DIR_BUILD_TEMP)%$(PRODUCT)$(EXT_O): _FILES       = $(foreach _FILE,$(FILES),$(patsubst $(DIR_SRC)%,%,$(_FILE)))
$(DIR_BUILD_TEMP)%$(PRODUCT)$(EXT_O): _FILES_OBJ   = $(addprefix $*,$(patsubst %$(EXT_C),%$(EXT_C)$(EXT_O),$(patsubst %$(EXT_CPP),%$(EXT_CPP)$(EXT_O),$(patsubst %$(EXT_M),%$(EXT_M)$(EXT_O),$(patsubst %$(EXT_MM),%$(EXT_MM)$(EXT_O),$(_FILES))))))
$(DIR_BUILD_TEMP)%$(PRODUCT)$(EXT_O): _FILES_BUILD = $(addprefix $(DIR_BUILD_TEMP),$(_FILES_OBJ))
$(DIR_BUILD_TEMP)%$(PRODUCT)$(EXT_O): $$(shell mkdir -p $$(dir $$@)) $$(_FILES_BUILD)
	
	@echo -e $(call PRINT,Linking object files,$(_ARCH),$(notdir $@))
	@$(LD) -r $(LD_FLAGS_$(_ARCH)) $(_FILES_BUILD) -o $@

# Object file target / C
$(DIR_BUILD_TEMP)%$(EXT_C)$(EXT_O): _ARCH      = $(firstword $(subst /, ,$(subst $(DIR_BUILD_TEMP),,$@)))
$(DIR_BUILD_TEMP)%$(EXT_C)$(EXT_O): _FILE      = $(subst $(_ARCH)/,,$*)$(EXT_C)
$(DIR_BUILD_TEMP)%$(EXT_C)$(EXT_O): $$(shell mkdir -p $$(dir $$@)) $$(_FILE)
	
	@echo -e $(call PRINT_FILE,"Compiling C file",$(_ARCH),$(_FILE))
	@$(_CC) $(CC_FLAGS_$(_ARCH)) -std=$(FLAGS_STD_C) $(FLAGS_C) -o $@ -c $(addprefix $(DIR_SRC),$(_FILE))

# Object file target / C++
$(DIR_BUILD_TEMP)%$(EXT_CPP)$(EXT_O): _ARCH      = $(firstword $(subst /, ,$(subst $(DIR_BUILD_TEMP),,$@)))
$(DIR_BUILD_TEMP)%$(EXT_CPP)$(EXT_O): _FILE      = $(subst $(_ARCH)/,,$*)$(EXT_CPP)
$(DIR_BUILD_TEMP)%$(EXT_CPP)$(EXT_O): $$(shell mkdir -p $$(dir $$@)) $$(_FILE)
	
	@echo -e $(call PRINT_FILE,"Compiling C++ file",$(_ARCH),$(_FILE))
	@$(_CC) $(CC_FLAGS_$(_ARCH)) -std=$(FLAGS_STD_CPP) $(FLAGS_CPP) -o $@ -c $(addprefix $(DIR_SRC),$(_FILE))

# Object file target / Objective-C
$(DIR_BUILD_TEMP)%$(EXT_M)$(EXT_O): _ARCH      = $(firstword $(subst /, ,$(subst $(DIR_BUILD_TEMP),,$@)))
$(DIR_BUILD_TEMP)%$(EXT_M)$(EXT_O): _FILE      = $(subst $(_ARCH)/,,$*)$(EXT_M)
$(DIR_BUILD_TEMP)%$(EXT_M)$(EXT_O): $$(shell mkdir -p $$(dir $$@)) $$(_FILE)
	
	@echo -e $(call PRINT_FILE,"Compiling Objective-C file",$(_ARCH),$(_FILE))
	@$(_CC) $(CC_FLAGS_$(_ARCH)) -std=$(FLAGS_STD_C) $(FLAGS_M) -o $@ -c $(addprefix $(DIR_SRC),$(_FILE))

# Object file target / Objective-C++
$(DIR_BUILD_TEMP)%$(EXT_MM)$(EXT_O): _ARCH      = $(firstword $(subst /, ,$(subst $(DIR_BUILD_TEMP),,$@)))
$(DIR_BUILD_TEMP)%$(EXT_MM)$(EXT_O): _FILE      = $(subst $(_ARCH)/,,$*)$(EXT_MM)
$(DIR_BUILD_TEMP)%$(EXT_MM)$(EXT_O): $$(shell mkdir -p $$(dir $$@)) $$(_FILE)
	
	@echo -e $(call PRINT_FILE,"Compiling Objective-C file",$(_ARCH),$(_FILE))
	@$(_CC) $(CC_FLAGS_$(_ARCH)) -std=$(FLAGS_STD_CPP) $(FLAGS_MM) -o $@ -c $(addprefix $(DIR_SRC),$(_FILE))
