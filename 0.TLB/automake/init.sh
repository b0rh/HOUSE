#Debbuging
set -x			# activate debugging from here

_basePath=$(pwd)

# Download sourcecode
# wget https://ftp.gnu.org/gnu/automake/automake-1.16.3.tar.gz


mkdir src

tar xfvz automake-1.16.3.tar.gz -C src

mkdir $_basePath/files

# Compile and install AFL follow standar stucture name
cd src/automake-1.16.3
./configure --prefix=${_basePath}/files
make install

# No es necesario DESTDIR si se usa PREFIX
#make install DESTDIR=${_basePath}/files

cd ..
