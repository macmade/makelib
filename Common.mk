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

# Default target
.DEFAULT_GOAL := all

#-------------------------------------------------------------------------------
# Build type
#-------------------------------------------------------------------------------

# Checks operating system to determine the build type
OS_TYPE := $(shell uname)
ifeq ($(OS_TYPE),Linux)
    BUILD_TYPE  := linux
else ifeq ($(OS_TYPE),FreeBSD)
    BUILD_TYPE  := bsd
else
    BUILD_TYPE  := os-x
endif

# Host architecture
HOST_ARCH := $(shell uname -m)

#-------------------------------------------------------------------------------
# Commands
#-------------------------------------------------------------------------------

ifeq ($(BUILD_TYPE),bsd)
	MAKE  := gmake -s
	SHELL := /usr/local/bin/bash
else
	MAKE    := make -s
	SHELL   := /bin/bash
endif
_CC      = $(CC) $(FLAGS_WARN) -fPIC -$(FLAGS_OPTIM) $(FLAGS_OTHER) -I$(DIR_INC)

# C compiler - Debug mode
ifneq ($(findstring 1,$(DEBUG)),)
_CC     += -DDEBUG=1
_CC     += -g
endif

#-------------------------------------------------------------------------------
# Tools
#-------------------------------------------------------------------------------

# Make version (version 4 allows parallel builds with output sync) 
MAKE_VERSION_MAJOR  := $(shell echo $(MAKE_VERSION) | cut -f1 -d.)
MAKE_4              := $(shell [ $(MAKE_VERSION_MAJOR) -ge 4 ] && echo true)

# Check for the xctool utility
XCTOOL              := $(shell which xctool 2>/dev/null)
HAS_XCTOOL          := $(shell if [ -f "$(XCTOOL)" ]; then echo true; else echo false; fi )

# Check for the xcodebuild utility
XCBUILD             := $(shell which xcodebuild 2>/dev/null)
HAS_XCBUILD         := $(shell if [ -f "$(XCBUILD)" ]; then echo true; else echo false; fi )

ifeq ($(HAS_XCBUILD),true)
MAC_TARGET          := $(shell $(XCBUILD) -showsdks | grep macosx | tail -1 | perl -pe 's/[^-]+-sdk [^0-9]+(.*)/\1/g')
IOS_SDK             := $(shell $(XCBUILD) -showsdks | grep iphoneos | tail -1 | perl -pe 's/[^-]+-sdk [^0-9]+(.*)/\1/g')
IOS_SDK_PATH        := /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS$(IOS_SDK).sdk
XCODE_SDK_VALUE     := "$(shell /usr/libexec/PlistBuddy -c "Print $(1)" /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Info.plist)"
endif

#-------------------------------------------------------------------------------
# Paths
#-------------------------------------------------------------------------------

# Root build directory (debug or release)
ifeq ($(findstring 1,$(DEBUG)),)
    DIR_BUILD       := Build/Release/
else
    DIR_BUILD       := Build/Debug/
endif

# Relative build directories
DIR_BUILD_PRODUCTS  := $(DIR_BUILD)Products/
DIR_BUILD_TEMP      := $(DIR_BUILD)Intermediates/
DIR_BUILD_TESTS     := $(DIR)Build/Tests/

# Erases implicit rules
.SUFFIXES:

#-------------------------------------------------------------------------------
# Display
#-------------------------------------------------------------------------------

# Terminal colors
COLOR_NONE      := "\x1b[0m"
COLOR_GRAY      := "\x1b[30;01m"
COLOR_RED       := "\x1b[31;01m"
COLOR_GREEN     := "\x1b[32;01m"
COLOR_YELLOW    := "\x1b[33;01m"
COLOR_BLUE      := "\x1b[34;01m"
COLOR_PURPLE    := "\x1b[35;01m"
COLOR_CYAN      := "\x1b[36;01m"

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

# Gets every C file in a specific source directory
# 
# @1:   The directory with the source files
GET_C_FILES = $(foreach _DIR,$(1), $(wildcard $(_DIR)*$(EXT_C)))

# Gets every C++ file in a specific source directory
# 
# @1:   The directory with the source files
GET_CPP_FILES = $(foreach _DIR,$(1), $(wildcard $(_DIR)*$(EXT_CPP)))

# Gets every Objective-C file in a specific source directory
# 
# @1:   The directory with the source files
GET_M_FILES = $(foreach _DIR,$(1), $(wildcard $(_DIR)*$(EXT_M)))

# Gets every Objective-C++ file in a specific source directory
# 
# @1:   The directory with the source files
GET_MM_FILES = $(foreach _DIR,$(1), $(wildcard $(_DIR)*$(EXT_MM)))

# Gets an SDK value from Xcode
# 
# @1:   The key for which to get the SDK value
XCODE_SDK_VALUE = "$(shell /usr/libexec/PlistBuddy -c "Print $(1)" /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Info.plist)"

# Prints a message about a file
# 
# @1:   The first message part
# @2:   The architecture
# @3:   The file
PRINT_FILE = $(call PRINT,$(1),$(2),$(subst /,.,$(subst ./,,$(dir $(3))))"$(COLOR_GRAY)"$(notdir $(3))"$(COLOR_NONE)")

# Prints a message
# 
# @1:   The first message part# @2:   The architecture
# @3:   The second message part
ifeq ($(findstring 1,$(DEBUG)),)
PRINT = "["$(COLOR_GREEN)" $(PRODUCT) "$(COLOR_NONE)"]> $(1) [ "$(COLOR_CYAN)"Release - $(2)"$(COLOR_NONE)" ]: "$(COLOR_YELLOW)"$(3)"$(COLOR_NONE)
else
PRINT = "["$(COLOR_GREEN)" $(PRODUCT) "$(COLOR_NONE)"]> $(1) [ "$(COLOR_CYAN)"Debug - $(2)"$(COLOR_NONE)" ]: "$(COLOR_YELLOW)"$(3)"$(COLOR_NONE)
endif

#-------------------------------------------------------------------------------
# Includes
#-------------------------------------------------------------------------------

__DIR__ := $(dir $(lastword $(MAKEFILE_LIST)))

ifeq ($(BUILD_TYPE),os-x)
    include $(__DIR__)/Platform/OSX.mk
else ifeq ($(BUILD_TYPE),bsd)
    include $(__DIR__)/Platform/FreeBSD.mk
else
    include $(__DIR__)/Platform/Linux.mk
endif
