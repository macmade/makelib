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
# File suffixes
#-------------------------------------------------------------------------------

# File extensions
EXT_O           := .o
EXT_LIB         := .a
EXT_DYLIB       := .dylib
EXT_FRAMEWORK   := .framework

#-------------------------------------------------------------------------------
# Products and architectures to build
#-------------------------------------------------------------------------------

ifeq ($(BUILD_LEGACY_ARCHS),1)

PRODUCTS = $(PRODUCT_LIB)$(EXT_LIB)|i386|x86_64|armv7|armv7s|arm64 \
           $(PRODUCT_DYLIB)$(EXT_DYLIB)|i386|x86_64                \
           $(PRODUCT_FRAMEWORK)$(EXT_FRAMEWORK)|i386|x86_64

else

PRODUCTS = $(PRODUCT_LIB)$(EXT_LIB)|x86_64|armv7|armv7s|arm64 \
           $(PRODUCT_DYLIB)$(EXT_DYLIB)|x86_64                \
           $(PRODUCT_FRAMEWORK)$(EXT_FRAMEWORK)|x86_64

endif



#-------------------------------------------------------------------------------
# Tools
#-------------------------------------------------------------------------------

LD := ld
AR := ar

#-------------------------------------------------------------------------------
# Commands configuration
#-------------------------------------------------------------------------------

# Architecture specific flags for ld
LD_FLAGS_i386               := 
LD_FLAGS_x86_64             := 
LD_FLAGS_armv7              := 
LD_FLAGS_armv7s             := 
LD_FLAGS_arm64              := 

# Architecture specific flags for ar
AR_FLAGS_i386               := rcs
AR_FLAGS_x86_64             := rcs
AR_FLAGS_armv7              := rcs
AR_FLAGS_armv7s             := rcs
AR_FLAGS_arm64              := rcs

# Architecture specific flags for the C compiler
CC_FLAGS_i386               := -arch i386
CC_FLAGS_x86_64             := -arch x86_64
CC_FLAGS_armv7              := -arch armv7 -isysroot $(IOS_SDK_PATH)
CC_FLAGS_armv7s             := -arch armv7s -isysroot $(IOS_SDK_PATH)
CC_FLAGS_arm64              := -arch arm64 -isysroot $(IOS_SDK_PATH)

# Architecture specific flags for the C compiler when creating a dynamic library
CC_FLAGS_DYLIB_i386         := -dynamiclib -install_name $(PREFIX_DYLIB)$(PRODUCT_DYLIB)$(EXT_DYLIB)
CC_FLAGS_DYLIB_x86_64       := -dynamiclib -install_name $(PREFIX_DYLIB)$(PRODUCT_DYLIB)$(EXT_DYLIB)

# Architecture specific flags for the C compiler when creating a Mac OS X framework
CC_FLAGS_FRAMEWORK_i386     := -dynamiclib -install_name $(PREFIX_FRAMEWORK)$(PRODUCT_FRAMEWORK)$(EXT_FRAMEWORK) -single_module -compatibility_version 1 -current_version 1
CC_FLAGS_FRAMEWORK_x86_64   := -dynamiclib -install_name $(PREFIX_FRAMEWORK)$(PRODUCT_FRAMEWORK)$(EXT_FRAMEWORK) -single_module -compatibility_version 1 -current_version 1
