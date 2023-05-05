_version=$1
_file="coreutils-${_version}.tar.xz"

# Repository
# wget https://ftp.gnu.org/gnu/coreutils/coreutils-8.31.tar.xz
# wget https://ftp.gnu.org/gnu/coreutils/${_file}

tar -xf ${_file} -C ./files
