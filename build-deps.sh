#!/bin/bash
#
VENDOR_PATH=$PWD/vendor
VENDOR_BUILD_PATH=$VENDOR_PATH/build

VENDOR_LINUX=$VENDOR_PATH/linux
VENDOR_WINDOWS=$VENDOR_PATH/windows

VENDOR_LINUX_LIB=$VENDOR_LINUX/lib
VENDOR_LINUX_INCLUDE=$VENDOR_LINUX/include
VENDOR_LINUX_SRC=$VENDOR_LINUX/src

VENDOR_WINDOWS_LIB=$VENDOR_WINDOWS/lib
VENDOR_WINDOWS_INCLUDE=$VENDOR_WINDOWS/include
VENDOR_WINDOWS_SRC=$VENDOR_WINDOWS/src

mkdir -p $VENDOR_BUILD_PATH
mkdir -p $VENDOR_LINUX_LIB
mkdir -p $VENDOR_LINUX_INCLUDE
mkdir -p $VENDOR_LINUX_SRC
mkdir -p $VENDOR_WINDOWS_LIB
mkdir -p $VENDOR_WINDOWS_INCLUDE
mkdir -p $VENDOR_WINDOWS_SRC

function sdl_linux() {
	SDL_PATH=$VENDOR_PATH/SDL
	SDL_BUILD_PATH=$VENDOR_BUILD_PATH/SDL

	# cleanup previous artifacts
	rm -rf $SDL_BUILD_PATH

	cmake -S $SDL_PATH -B $SDL_BUILD_PATH
	cmake --build $SDL_BUILD_PATH
	cmake --install $SDL_BUILD_PATH --prefix $SDL_BUILD_PATH/out

	# move artifacts to include/ and lib/
	cp -r $SDL_BUILD_PATH/out/include/* $VENDOR_LINUX_INCLUDE
	cp $SDL_BUILD_PATH/out/lib/*SDL* $VENDOR_LINUX_LIB
}

function glfw_linux() {
	GLFW_PATH=$VENDOR_PATH/glfw
	GLFW_BUILD_PATH=$VENDOR_BUILD_PATH/glfw

	# cleanup previous artifacts
	rm -rf $GLFW_BUILD_PATH

	cmake -S $GLFW_PATH -B $GLFW_BUILD_PATH
	cd $GLFW_BUILD_PATH
	echo "set(CMAKE_INSTALL_PREFIX \"${GLFW_BUILD_PATH}/out\")" | cat - $GLFW_BUILD_PATH/cmake_install.cmake > cmake_install.tmp
	mv cmake_install.tmp $GLFW_BUILD_PATH/cmake_install.cmake
	make
	make install

	# move artifacts to include/ and lib/
	cp -r out/include/* $VENDOR_LINUX_INCLUDE
	cp out/lib/*glfw* $VENDOR_LINUX_LIB
	cd -
}

function glfw_win() {
	dir=/tmp/glfw_win
	version=3.4
	mkdir -p $dir
	curl -L -o $dir/glfw_win.zip "https://github.com/glfw/glfw/releases/download/${version}/glfw-${version}.bin.WIN64.zip"
	pushd $dir
	unzip glfw_win.zip
	cp -r glfw-$version.bin.WIN64/include/* $VENDOR_WINDOWS_INCLUDE
	cp glfw-$version.bin.WIN64/lib-mingw-w64/*.a $VENDOR_WINDOWS_LIB
	popd
}

function libepoxy() {
	EPOXY_PATH=$VENDOR_PATH/libepoxy
	EPOXY_BUILD_PATH=$VENDOR_BUILD_PATH/libepoxy

	# cleanup previous artifacts
	rm -rf $EPOXY_BUILD_PATH

	mkdir -p $EPOXY_BUILD_PATH
	mkdir -p $EPOXY_PATH/_build

	cd $EPOXY_PATH/_build
	meson
	ninja
	sudo ninja install
	mv * $EPOXY_BUILD_PATH
	cd -

	# keep submodule tidy
	rm -rf $EPOXY_PATH/_build

	# move artifacts to include/ and lib/
	cp -r $EPOXY_BUILD_PATH/include/epoxy $VENDOR_LINUX_INCLUDE
	cp -r $EPOXY_BUILD_PATH/src/*epoxy* $VENDOR_LINUX_LIB
}

function freetype() {
	FREETYPE_PATH=$VENDOR_PATH/freetype

	cd $FREETYPE_PATH
	./autogen.sh
	make
	make

	# move artifacts to include/ and lib/
	cp -r $FREETYPE_PATH/include/freetype $VENDOR_LINUX_INCLUDE/freetype
	cp $FREETYPE_PATH/objs/.libs/*freetype* $VENDOR_LINUX_LIB
}

function gl3w() {
	cd ./vendor/gl3w
	./gl3w_gen.py
	cp -r include/* $VENDOR_LINUX_INCLUDE
	cp -r include/* $VENDOR_WINDOWS_INCLUDE
	cp -r src/* $VENDOR_LINUX_SRC
	cp -r src/* $VENDOR_WINDOWS_SRC
	cd -
}

function miniaudio() {
	# there's a bug that prevents zig translate-c from properly converting miniaudio so we need
	# to patch it in order to use the auto-translation
	patch -p 1 -N < patch.diff
	cp $VENDOR_PATH/miniaudio/miniaudio.h $VENDOR_LINUX_INCLUDE
	cp $VENDOR_PATH/miniaudio/miniaudio.h $VENDOR_WINDOWS_INCLUDE
}

function stb() {
	cp $VENDOR_PATH/stb/*.h $VENDOR_LINUX_INCLUDE
	cp $VENDOR_PATH/stb/*.h $VENDOR_WINDOWS_INCLUDE
}

dep=$1

echo "Building $dep"
case $dep in
	"sdl")
		sdl
		;;
	"glfw")
		glfw_linux
		glfw_win
		;;
	"libepoxy")
		libepoxy
		;;
	"gl3w")
		gl3w
		;;
	"freetype")
		freetype
		;;
	"miniaudio")
		miniaudio
		;;
	"stb")
		stb
		;;
	*)
		glfw_linux
		glfw_win
		miniaudio
		stb
		gl3w
		# libepoxy
		# freetype
		# sdl
		;;
esac
