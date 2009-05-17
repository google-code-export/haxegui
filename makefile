#!/bin/bash

TARGET = assets.swf

all: compile

compile:
	swfmill  -v simple library.xml $(TARGET)
	haxe Compile.hxml


run:
	#~ flashplayer main.swf
	flashplayerd main.swf

runWin32:
	wine FlashPlayer.exe main.swf

style:
	cd assets/styles && stylecompiler default

