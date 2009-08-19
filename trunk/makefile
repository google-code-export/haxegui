#!/bin/bash

TARGET = assets.swf

all: style haxe

swfmill:
	swfmill  -v simple library.xml $(TARGET)

haxe:
	haxe Compile.hxml


run:
	#~ flashplayer main.swf
	flashplayerd main.swf

runWin32:
	wine FlashPlayer.exe main.swf

style:
	cd assets/styles && stylecompiler default

