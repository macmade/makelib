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
EXT_O       := .o
EXT_LIB     := .a
EXT_DYLIB   := .so

#-------------------------------------------------------------------------------
# Products and architectures to build
#-------------------------------------------------------------------------------

PRODUCTS = $(PRODUCT_LIB)$(EXT_LIB)|$(HOST_ARCH)     \
           $(PRODUCT_DYLIB)$(EXT_DYLIB)|$(HOST_ARCH)

#-------------------------------------------------------------------------------
# Tools
#-------------------------------------------------------------------------------

LD := ld
AR := ar

#-------------------------------------------------------------------------------
# Commands configuration
#-------------------------------------------------------------------------------

# Architecture specific flags for ld
LD_FLAGS_$(HOST_ARCH)       := -m elf_$(HOST_ARCH)

# Architecture specific flags for ar
AR_FLAGS_$(HOST_ARCH)       := rcs

# Architecture specific flags for the C compiler
CC_FLAGS_$(HOST_ARCH)       := 

# Architecture specific flags for the C compiler when creating a dynamic library
CC_FLAGS_DYLIB_$(HOST_ARCH) = -shared -Wl,-soname,$(PRODUCT_DYLIB)$(EXT_DYLIB)
