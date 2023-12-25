#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json, os
from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain
from conan.tools.build import cross_building
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
    tool_requires = ["cmake/3.21.7", "ninja/1.11.1"]
    # ---Sources---
    exports = ["info.json", "LICENSE"]
    exports_sources = ["info.json", "*.txt", "src/*", "CMake/*"]
    # ---Binary model---
    settings = "os", "compiler", "build_type", "arch"
    options = {}
    default_options = {"qt/*:GUI": True,
                       "qt/*:opengl": "desktop",
                       "qt/*:qtbase": True,
                       "qt/*:widgets": True,
                       "qt/*:qtdeclarative": True,
                       "qt/*:qtsvg": True,
                       "qt/*:qt5compat": True}
    # ---Build---
    generators = []
    # ---Folders---
    no_copy_source = False

    def generate(self):
        ms = VirtualBuildEnv(self)
        tc = CMakeToolchain(self, generator="Ninja")
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
