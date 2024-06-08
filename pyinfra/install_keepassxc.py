import os
from typing import Iterable
from pyinfra import host
from pyinfra.operations import git, server, files, brew
from pyinfra.facts.server import Kernel

def cmd(*parts: Iterable[str]):
    return " ".join(parts)

src = "https://github.com/keepassxreboot/keepassxc.git"
version = "2.7.8"
code_directory_path = os.path.expanduser("~/Code/repos/keepassxc")
dest = code_directory_path
build_directory_path = f"{dest}/build"
install_directory_path = f"{build_directory_path}/install"
vcpkg_root = os.getenv("VCPKG_ROOT")
vcpkg_root = vcpkg_root if vcpkg_root else host.data.vcpkg_root
kernel = host.get_fact(Kernel)

if not os.path.exists(vcpkg_root):
    raise Exception(f"Expected directory vcpkg_root {vcpkg_root} to exist")

if kernel == "Darwin":
    target_triplet = "x64-osx-dynamic-release" # TODO ARM
elif kernel == "Linux":
    target_triplet = "x64-linux-dynamic-release"
else:
    raise Exception(f"Unsupported OS {server.Kernel}")

brew.packages(
    name='Install build dependencies',
    packages=[ "asciidoctor", "cmake" ],
    update=True,
)

git.repo(src, dest, branch=version, pull=False)

files.directory (
    name="Create a build directory",
    path=build_directory_path,
    _chdir=vcpkg_root
)

server.shell(
    name="Build KeepassXC",
    commands=[
        cmd("cmake",
            "-DCMAKE_BUILD_TYPE=Release",
            f"-DCMAKE_INSTALL_PREFIX={install_directory_path}",
            f"-DCMAKE_TOOLCHAIN_FILE={vcpkg_root}/scripts/buildsystems/vcpkg.cmake " \
            f"-DVCPKG_TARGET_TRIPLET={target_triplet} " \
            "-DWITH_XC_ALL=ON ..",),
        "make -j 8",
        "make install"
    ],
    _chdir=build_directory_path
)