/*
 * Copyright (c) 2009, Russell Weir
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE CAFFEINE-HX PROJECT CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE CAFFEINE-HX PROJECT CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

import neko.FileSystem;
import neko.io.File;
import neko.io.FileOutput;
import neko.Lib;
import neko.Sys;

typedef Descriptor = {
	var path : Array<String>;
	var filename : String;
	var extension : String;
};

class StyleCompiler {
	static var ouputFile : String;
	static var indir : String;
	static var cpath		: Array<String>;
	static var xml : String;

	static var eHscript = ~/^(.+)\.(hscript)$/i;

	static var println : String->Void;
	static var print : String->Void;
	static var write : String->Void;

	static function usage() {
		var p = neko.Lib.println;

		println("stylecompiler [inputdirectory]");
		println("\nStyle compiler descends into the inputdirectory, finding all hscript files in component directory paths.");
		println("Valid actions are:");
		println(" redraw,mouseOver,mouseOut,mouseDown,mouseUp,mouseClick,validate");
		println(" gainingFocus,losingFocus,focusIn,focusOut");
	}

	/**
		Logs a string to stderr and exits program
	**/
	public static function error( s : String ) {
		neko.io.File.stderr().writeString("Error: " + s + "\n");
		neko.Sys.exit(1);
	}

	public static function main() {
		println = Lib.println;
		print = Lib.print;
		var cwd = Sys.getCwd();
		var argv = neko.Sys.args();
		if(argv.length != 1 || argv[0].indexOf("help") >= 0 ) {
			usage();
			neko.Sys.exit(1);
		}

		var indir = FileSystem.fullPath(argv[0]);
		if(!neko.FileSystem.isDirectory(indir))
				error("Specify a correct input directory");
		var styleName : String = indir.split("/").slice(-1)[0];

		var outputFile = cwd + "/" + styleName + "_style.xml";
		var fp = File.write(outputFile, false);

		write = fp.writeString;
		cpath = new Array();

		write("<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>\n");
		write("<haxegui:Style name=\"" + styleName + "\">\n");
		Sys.setCwd(indir);
		processDirectory(".");
		write("</haxegui:Style>\n\n");
		fp.flush();
		fp.close();
		Sys.setCwd(cwd);
	}

	public static function getDirs(p : String) {
		var a = neko.FileSystem.readDirectory(p);
		var b : Array<String> = new Array();
		for(d in a) {
			if(!FileSystem.isDirectory(d))
				continue;
			if(d == ".svn")
				continue;
			b.push(d);
		}
		return b;
	}

	public static function getFilesInCwd() : Array<Descriptor> {
		var a = neko.FileSystem.readDirectory(".");
		var b : Array<Descriptor> = new Array();
		for(f in a) {
			if(FileSystem.isDirectory(f)) continue;
			if(eHscript.match(f)) {
				b.push({
					path :		cpath.slice(1),
					filename: 	eHscript.matched(1),
					extension:	eHscript.matched(2),
				});
			}
		}
		return b;
	}

	static function processDirectory(p : String) : Void {
		cpath.push(p);
		Sys.setCwd(p);

		var node : String = try xmlNodePath() catch(e:Dynamic) null;

		if(node != null) {
			var files = getFilesInCwd();
			try {
				write("\n\t<" + node + ">\n");
				write("\t\t<events>\n");
				for(fd in files) {
					switch(fd.extension) {
					case "hscript":
						writeXmlCode(fd);
					default:
						println("Ignoring " + filename(fd));
					}
				}
				write("\t\t</events>\n");
				write("\t</" + node + ">\n");
			} catch(e:Dynamic) {
				error(e);
			}
		}

		// descend into subdirs
		var dirs = getDirs(".");
		for(d in dirs)
			processDirectory(d);

		cpath.pop();
		Sys.setCwd("./../");
	}

	/**
	* Returns the xml node path for a Descriptor
	**/
	static function xmlNodePath() {
		if(cpath.length < 2)
			throw cpath.join("/");
		var className = cpath.slice(-1)[0];

		// check capitalization
		var code = className.charCodeAt(0);
		if(code < 65 || code > 90) {
			throw "Class name does not start with a capital letter: " + cpath.join("/");
		}
		return "haxegui:" + cpath.slice(1).join(":");
	}

	/**
	* Writes the <script></script> for a file
	**/
	static function writeXmlCode(d : Descriptor) {
		var file = filename(d);
		var content = File.getContent(file);

		var lines = content.split("\n");

		// trim trailing blank lines
		var i = lines.length - 1;
		while(StringTools.trim(lines[i]) == "") {
			i--;
		}
		lines = lines.slice(0, i+1);
		// trim leading blank lines
		i = 0;
		while( lines.length > i && StringTools.trim(lines[i]) == "") {
			i++;
		}
		lines = lines.slice(i);
		// nothing to do?
		if(lines.length == 0)
			return;
		// write script
		write("\t\t\t<script type=\"text/hscript\" action=\""+d.filename+"\">\n");
		write("\t\t\t<![CDATA[\n");
		for(line in lines) {
			line = StringTools.rtrim(line);
			write("\t\t\t\t" + line + "\n");
		}
		write("\t\t\t]]>\n");
		write("\t\t\t</script>\n");
	}

	/**
	* Returns the full path filename of a Descriptor
	*/
	static function filename(d:Descriptor) {
		return d.filename + "." + d.extension;
	}

	static function fullPath(d:Descriptor) {
		if(d.path.length == 0)
			return filename(d);
		return d.path.join("/") + "/" + d.filename + "." + d.extension;
	}
}
