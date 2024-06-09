import os
from typing import Iterable
from pyinfra import host
from pyinfra.operations import git, server, files, brew, dnf
from pyinfra.facts.server import Kernel

def cmd(*parts: Iterable[str]):
    return " ".join(parts)

kernel = host.get_fact(Kernel)

src = "https://github.com/keepassxreboot/keepassxc.git"
version = "2.7.8"
code_directory_path = os.path.expanduser("~/Code/repos/keepassxc")
dest = code_directory_path
build_directory_path = f"{dest}/build"
install_directory_path = None
install_with_sudo = True
vcpkg_root = os.getenv("VCPKG_ROOT")
vcpkg_root = vcpkg_root if vcpkg_root else host.data.vcpkg_root
use_vcpkg = False

if kernel == "Darwin":
    use_vcpkg = True
    target_triplet = "x64-osx-dynamic-release" # TODO ARM
    install_directory_path = f"{build_directory_path}/install"
    install_with_sudo = False
elif kernel == "Linux":
    target_triplet = "x64-linux-dynamic-release"
else:
    raise Exception(f"Unsupported OS {server.Kernel}")

if use_vcpkg and not os.path.exists(vcpkg_root):
    raise Exception(f"Expected directory vcpkg_root {vcpkg_root} to exist")

if kernel == "Darwin":
    brew.packages(
        name='Install build dependencies',
        packages=[ "asciidoctor", "cmake" ],
        update=True,
    )

dnf.packages(
    name="Install build dependencies (dnf)",
    packages=[ 
        "make", "automake", "gcc-c++", "cmake", "rubygem-asciidoctor",
        "qt5-qtbase-devel", "qt5-qtbase-private-devel", "qt5-linguist", "qt5-qttools",
        "qt5-qtsvg-devel", "libargon2-devel", "qrencode-devel", "botan2-devel", "readline-devel",
        "keyutils-libs-devel", "zlib-devel", "pcsc-lite-devel", "libusb1-devel", "libXi-devel",
        "libXtst-devel", "qt5-qtx11extras-devel", "minizip-compat-devel" ],
    update=True,
    _use_sudo_password=True,
    _sudo=True)


git.repo(src, dest, branch=version, pull=False)

files.directory (
    name="Create a build directory",
    path=build_directory_path,
)

build_commands = []

if use_vcpkg:
    build_commands = [
        cmd("cmake",
            "-DCMAKE_BUILD_TYPE=Release",
            f"-DCMAKE_INSTALL_PREFIX={install_directory_path}" if install_directory_path else "",
            f"-DCMAKE_TOOLCHAIN_FILE={vcpkg_root}/scripts/buildsystems/vcpkg.cmake " \
            f"-DVCPKG_TARGET_TRIPLET={target_triplet} " \
            "-DWITH_XC_ALL=ON ..",),
    "make -j 8" ]
else:
    build_commands = [
        cmd("cmake --fresh",
            "-DCMAKE_BUILD_TYPE=Release",
            f"-DCMAKE_INSTALL_PREFIX={install_directory_path}" if install_directory_path else "",
            "-DWITH_XC_ALL=ON ..",),
        "make -j 8" ]

server.shell(
    name="Build KeepassXC",
    commands=build_commands,
    _chdir=build_directory_path
)

server.shell(
    name="Make install",
    commands=[ "make install" ],
    _chdir=build_directory_path,
    _sudo=bool(install_with_sudo),
    _use_sudo_password=bool(install_with_sudo))
