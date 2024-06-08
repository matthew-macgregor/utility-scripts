import os
from pyinfra import host
from pyinfra.operations import git, server 

project = "vcpkg"
#code_directory_path = os.path.expanduser(f"~/Code/repos/{project}")

src = "https://github.com/microsoft/vcpkg.git"
#dest = code_directory_path

git.repo(src, host.data.vcpkg_path)
server.shell(
    name="Bootstrap vcpkg",
    commands=[
        "./bootstrap-vcpkg.sh",
    ],
    _chdir=host.data.vcpkg_path,
    _shell_executable="/bin/bash"
)
  
