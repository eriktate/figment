#!/bin/bash
#
VENDOR_PATH=$PWD/vendor
VENDOR_BUILD_PATH=$VENDOR_PATH/build
VENDOR_LIB=$VENDOR_PATH/lib
VENDOR_INCLUDE=$VENDOR_PATH/include

mkdir -p $VENDOR_BUILD_PATH
mkdir -p $VENDOR_LIB
mkdir -p $VENDOR_INCLUDE

function sdl() {
	SDL_PATH=$VENDOR_PATH/SDL
	SDL_BUILD_PATH=$VENDOR_BUILD_PATH/SDL

	# cleanup previous artifacts
	rm -rf $SDL_BUILD_PATH

	cmake -S $SDL_PATH -B $SDL_BUILD_PATH
	cmake --build $SDL_BUILD_PATH
	cmake --install $SDL_BUILD_PATH --prefix $SDL_BUILD_PATH/out

	# move artifacts to include/ and lib/
	cp -r $SDL_BUILD_PATH/out/include/* $VENDOR_INCLUDE
	cp $SDL_BUILD_PATH/out/lib/*SDL* $VENDOR_LIB
}

function glfw() {
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
	cp -r out/include/* $VENDOR_INCLUDE
	cp out/lib/*glfw* $VENDOR_LIB
	cd -
}

function glfw-win() {
	dir=/tmp/glfw-win
	version=3.4
	mkdir -p $dir
	curl -L -o $dir/glfw-win.zip "https://github.com/glfw/glfw/releases/download/${version}/glfw-${version}.bin.WIN64.zip"
	pushd $dir
	unzip glfw-win.zip
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
	cp -r $EPOXY_BUILD_PATH/include/epoxy $VENDOR_INCLUDE
	cp -r $EPOXY_BUILD_PATH/src/*epoxy* $VENDOR_LIB
}

function freetype() {
	FREETYPE_PATH=$VENDOR_PATH/freetype

	cd $FREETYPE_PATH
	./autogen.sh
	make
	make

	# move artifacts to include/ and lib/
	cp -r $FREETYPE_PATH/include/freetype $VENDOR_INCLUDE/freetype
	cp $FREETYPE_PATH/objs/.libs/*freetype* $VENDOR_LIB
}

function gl3w() {
	cd ./vendor/gl3w
	./gl3w_gen.py
	cd -
}

function miniaudio() {
	patch -p 1 -N < patch.diff
	cp $VENDOR_PATH/miniaudio/miniaudio.h $VENDOR_INCLUDE
}

function miniaudio() {
	cp $VENDOR_PATH/miniaudio/miniaudio.h $VENDOR_INCLUDE
}

function stb() {
	cp $VENDOR_PATH/stb/*.h $VENDOR_INCLUDE
}

dep=$1

echo "Building $dep"
case $dep in
	"sdl")
		sdl
		;;
	"glfw")
		glfw
		;;
	"glfw-win")
		glfw-win
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
		glfw
		glfw-win
		libepoxy
		# freetype
		miniaudio
		stb
		# sdl
		# gl3w
		;;
esac
