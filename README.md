makelib
=======

[![Build Status](https://img.shields.io/travis/macmade/makelib.svg?branch=master&style=flat)](https://travis-ci.org/macmade/makelib)
[![Issues](http://img.shields.io/github/issues/macmade/makelib.svg?style=flat)](https://github.com/macmade/makelib/issues)
![Status](https://img.shields.io/badge/status-active-brightgreen.svg?style=flat)
![License](https://img.shields.io/badge/license-mit-brightgreen.svg?style=flat)
[![Contact](https://img.shields.io/badge/contact-@macmade-blue.svg?style=flat)](https://twitter.com/macmade)

About
-----

makelib is a generic cross-platform makefile for building C/C++/Objective-C libraries.  
Its purpose is to ease the build process of libraries for cross-platform projects.

### Available targets by system

Building on **OSX**, the following files will be produced:

  - **Static library** (`.a`): `i386` `x86_64` `armv7` `armv7s` `arm64`
  - **Dynamic library** (`.dylib`): `i386` `x86_64`
  - **Mac framework** (`.framework`): `i386` `x86_64`

On **Linux**:

  - **Static library** (`.a`): host architecture
  - **Dynamic library** (`.dylib`): host architecture

Note that on OS X builds, ARM libraries are obviously targeted for iOS.

Configuration
-------------

### Recommended project structure

You may use `makelib` as a submodule of your project.

You'll need a **build** directory with a specific structure, a directory with **sources**, a directory with **includes** and finally a **Makefile** with configuration options.

Here's an example project structure:

    Build/                    (Build directory)
        Debug/                (Files produced by "debug" builds)
            Intermediates/    (Debug intermediate object files by architecture)
            Products/         (Debug products by architecture)
        Release/              (Files produced by "release" builds)
            Intermediates/    (Release intermediate object files by architecture)
            Products/         (Release products by architecture)
    Makefile                  (Makefile with makelib configuration values)
    makelib/                  (makelib submodule)
    MyProject/                (Project directory)
        include/              (Directory with include files)
        Info.plist            (Info.plist file - Required for building a Mac framework)
        source/               (Directory with source files)
        tests/                (Directory with unit test files, if any)

### Configuration Makefile

A makefile containing configuration values for makelib is required.  
Assuming the previous project structure and a C++ project, this makefile may look like:
    
    BUILD_LEGACY_ARCHS  := 0
    
    include makelib/Common.mk
    
    PRODUCT             := MyProject
    PRODUCT_LIB         := libMyProject
    PRODUCT_DYLIB       := libMyProject
    PRODUCT_FRAMEWORK   := MyProject
    PREFIX_DYLIB        := /usr/local/lib/
    PREFIX_FRAMEWORK    := /Library/Frameworks/
    DIR_INC             := MyProject/include/
    DIR_SRC             := MyProject/source/
    DIR_RES             := MyProject/
    DIR_TESTS           := MyProject/tests
    EXT_C               := .c
    EXT_CPP             := .cpp
    EXT_M               := .m
    EXT_MM              := .mm
    EXT_H               := .h
    FILES               := $(call GET_CPP_FILES, $(DIR_SRC))
    FILES_TESTS         := $(call GET_CPP_FILES, $(DIR_TESTS))
    CC                  := clang
    LIBS                := 
    FLAGS_OPTIM         := -Os
    FLAGS_WARN          := -Wall -Werror
    FLAGS_STD_C         := c99
    FLAGS_STD_CPP       := c++11
    FLAGS_OTHER         := 
    FLAGS_C             := 
    FLAGS_CPP           := 
    FLAGS_M             := -fobjc-arc
    FLAGS_MM            := -fobjc-arc
    
    include makelib/Targets.mk 

Please read the section below for details about each configuration value.

#### Configuration values

**PRODUCT**  
The name of your product/project.

**PRODUCT_LIB**  
The name for the generated static library.  
Note: always use a `lib` prefix.

**PRODUCT_DYLIB**  
The name for the generated dynamic library.  
Note: always use a `lib` prefix.

**PRODUCT_FRAMEWORK**  
The name for the generated Mac framework package.

**PREFIX_DYLIB**  
The directory in which the dynamic library is intended to be installed.

**PREFIX_FRAMEWORK**  
The directory in which the Mac framework is intended to be installed.

**DIR_INC**  
The directory with include files.

**DIR_SRC**  
The directory with source files.

**DIR_RES**  
The directory with resource files, link `Info.plist`.

**DIR_TESTS**  
The directory with unit test files, if any.

**EXT_C**  
The file extension for your C source files (typically `.c`).

**EXT_CPP**  
The file extension for your C++ source files (typically `.cpp`).

**EXT_M**  
The file extension for your Objective-C source files (typically `.m`).

**EXT_MM**  
The file extension for your Objective-C++ source files (typically `.mm`).

**EXT_H**  
The file extension for your header files (`.h`, `.hpp`, etc).

**FILES**  
The project files to compile.  
Note that you can use the `GET_C_FILES` function for convenience:

    FILES := $(call GET_C_FILES, some/dir/) $(call GET_C_FILES, some/other/dir/)

**FILES_TESTS**  
The unit test files to compile.
Note that you can use the `GET_C_FILES` function for convenience:

    FILES := $(call GET_C_FILES, some/dir/) $(call GET_C_FILES, some/other/dir/)

**CC**  
The compiler to use (`clang`, `gcc`, `g++`, etc).

**LIBS**  
Any libraries to link with when building the project.  
Eg: `-lpthread -lz -lc++`

**FLAGS_OPTIM**  
Optimisation flags for the compiler (`Os`, `O3`, etc).

**FLAGS_WARN**  
Warning flags for the compiler.  
Eg: `-Wall -Werror -Wpedantic`

**FLAGS_STD_C**  
The C language standard to use (`c99`, `c11`, etc).

**FLAGS_STD_CPP**  
The C++ language standard to use (`c++11`, `c++14`, etc).

**FLAGS_OTHER**  
Any other flags to pass to the compiler.

**FLAGS_C**  
Specific flags for the C compiler.

**FLAGS_CPP**  
Specific flags for the C++ compiler.

**FLAGS_M**  
Specific flags for the Objective-C compiler.

**FLAGS_MM**  
Specific flags for the Objective-C++ compiler.

**BUILD_LEGACY_ARCHS**
Builds legacy architectures (eg. i386 on macOS).  
Note: define it before including `Common.mk`

Demo / Example
--------------

You'll find a working example C project in the `Demo` subdirectory.

License
-------

makelib is released under the terms of the MIT license.

Repository Infos
----------------

    Owner:			Jean-David Gadina - XS-Labs
    Web:			www.xs-labs.com
    Blog:			www.noxeos.com
    Twitter:		@macmade
    GitHub:			github.com/macmade
    LinkedIn:		ch.linkedin.com/in/macmade/
    StackOverflow:	stackoverflow.com/users/182676/macmade
