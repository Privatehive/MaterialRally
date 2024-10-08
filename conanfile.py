#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json, os
from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain
from conan.errors import ConanInvalidConfiguration
from conan.tools.env import VirtualBuildEnv

required_conan_version = ">=2.0"

class MaterialRallyConan(ConanFile):
    jsonInfo = json.load(open("info.json", 'r'))
    # ---Package reference---
    name = jsonInfo["projectName"].lower()
    version = "%u.%u.%u" % (jsonInfo["version"]["major"], jsonInfo["version"]["minor"], jsonInfo["version"]["patch"])
    user = jsonInfo["domain"]
    channel = "%s" % ("snapshot" if jsonInfo["version"]["snapshot"] else "stable")
    # ---Metadata---
    description = jsonInfo["projectDescription"]
    license = jsonInfo["license"]
    author = jsonInfo["vendor"]
    topics = jsonInfo["topics"]
    homepage = jsonInfo["homepage"]
    url = jsonInfo["repository"]
    # ---Requirements---
    requires = ("qt/[>=6.5.0]@%s/stable" % user, "qtappbase/[~1]@%s/snapshot" % user)
    tool_requires = ["cmake/[>=3.21.7]", "ninja/[>=1.11.1]"]
    # ---Sources---
    exports = ["info.json", "LICENSE"]
    exports_sources = ["info.json", "LICENSE", "*.txt", "src/*", "CMake/*"]
    # ---Binary model---
    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False], "fPIC": [True, False], "lto": [True, False], }
    default_options = {"shared": True,
                       "fPIC": True,
                       "lto": False,
                       "qtappbase/*:qml": True,
                       "qt/*:GUI": True,
                       "qt/*:opengl": "desktop",
                       "qt/*:qtbase": True,
                       "qt/*:qtdeclarative": True,
                       "qt/*:qtsvg": True,
                       "qt/*:qt5compat": True}
    # ---Build---
    generators = []
    # ---Folders---
    no_copy_source = False

    def validate(self):
        valid_os = ["Windows", "Linux", "Android"]
        if str(self.settings.os) not in valid_os:
            raise ConanInvalidConfiguration(f"{self.name} {self.version} is only supported for the following operating systems: {valid_os}")
        valid_arch = ["x86_64", "x86", "armv7", "armv8"]
        if str(self.settings.arch) not in valid_arch:
            raise ConanInvalidConfiguration(f"{self.name} {self.version} is only supported for the following architectures on {self.settings.os}: {valid_arch}")
        if not self.dependencies["qt"].options.qtbase:
            raise ConanInvalidConfiguration("qt qtbase options is required")
        if not self.dependencies["qt"].options.GUI:
            raise ConanInvalidConfiguration("qt GUI options is required")
        if not self.dependencies["qt"].options.qtdeclarative:
            raise ConanInvalidConfiguration("qt qtdeclarative options is required")
        if not self.dependencies["qt"].options.qtsvg:
            raise ConanInvalidConfiguration("qt qtsvg options is required")
        if not self.dependencies["qt"].options.qt5compat:
            raise ConanInvalidConfiguration("qt qt5compat options is required")
        if self.dependencies["qt"].options.opengl == "no":
            raise ConanInvalidConfiguration("qt opengl options must contain a value != no") 

    def generate(self):
        ms = VirtualBuildEnv(self)
        tc = CMakeToolchain(self, generator="Ninja")
        tc.variables["CMAKE_INTERPROCEDURAL_OPTIMIZATION"] = self.options.lto
        tc.generate()
        ms.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        cmake = CMake(self)
        cmake.install()

    def package_info(self):
        self.cpp_info.builddirs = ["lib/cmake"]
        self.runenv_info.prepend_path("QML_IMPORT_PATH", os.path.join(self.package_folder, "qml"))
