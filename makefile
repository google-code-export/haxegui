#!/bin/bash

all: style haxe

# alias for assets.swf
swfmill: assets.swf
assets.swf:
	swfmill  -v simple library.xml $(TARGET)

# alias for main.swf
haxe: main.swf

main.swf: assets.swf
	haxe Compile.hxml
	@echo "run make run to laurch main.swf"


run:    main.swf
	#~ flashplayer main.swf
	flashplayerd main.swf || { echo;  echo '!! flashplayerd failed. open main.swf using your browser, please !!'; }

runWin32:
	wine FlashPlayer.exe main.swf

Tools/stylecompiler:
	cd Tools; haxe build.hxml

style:  Tools/stylecompiler
	cd assets/styles && Tools/stylecompiler default

