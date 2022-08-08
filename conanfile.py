import json, os
from conans import ConanFile, CMake, tools


class MaterialRallyConan(ConanFile):
    jsonInfo = json.loads(tools.load("info.json"))
    name = jsonInfo["projectName"]
    version = "%u.%u.%u%s" % (jsonInfo["version"]["major"], jsonInfo["version"]["minor"], jsonInfo["version"]["patch"],
                              "-SNAPSHOT" if jsonInfo["version"]["snapshot"] else "")
    license = jsonInfo["license"]
    url = jsonInfo["repository"]
    description = jsonInfo["projectDescription"]
    author = jsonInfo["vendor"]
    homepage = jsonInfo["repository"]
    requires = "Qt/[^5.14]@tereius/stable"
    settings = ("os", "compiler", "arch", "build_type")
    generators = "cmake"
    exports = "info.json", "LICENSE"
    exports_sources = "*"
    options = {"shared": [True, False]}
    default_options = (
        "shared=True",
        "Qt:shared=True",
        "Qt:GUI=True",
        "Qt:widgets=True",
        "Qt:qtbase=True",
        "Qt:qtsvg=True",
        "Qt:qtdeclarative=True",
        "Qt:qttools=True",
        "Qt:qttranslations=True",
        "Qt:qtgraphicaleffects=True",
        "Qt:qtquickcontrols2=True")

    def build_requirements(self):
        self.build_requires("extra-cmake-modules/5.95.0@tereius/stable", force_host_context=True)

    def configure(self):
        if self.settings.os == 'Android':
            self.options["Qt"].qtandroidextras = True
        elif self.settings.os == 'Emscripten':
            self.options.shared = False
            self.options["Qt"].shared = False

    def build(self):
        cmake = CMake(self)
        if not self.options.shared:
            cmake.definitions["BUILD_SHARED_LIBS"] = "OFF"
        cmake.configure()
        cmake.build()
        cmake.install()

    def package(self):
        self.copy("MaterialRally/*")

    def package_info(self):
        self.env_info.QML_IMPORT_PATH.append(os.path.join(self.package_folder, "lib", "qml"))
