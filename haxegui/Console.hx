//
// Copyright (c) 2009 The haxegui developers
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

package haxegui;

import flash.geom.Rectangle;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import flash.text.TextField;
import flash.text.TextFormat;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import flash.events.EventDispatcher;

import flash.ui.Keyboard;
import flash.ui.Mouse;

import flash.system.Capabilities;

import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;
import haxegui.managers.StyleManager;
import haxegui.Window;

import haxegui.containers.Container;
import haxegui.controls.ScrollBar;

import hscript.Expr;
import hscript.Parser;

import haxegui.logging.ILogger;
import haxegui.logging.ErrorType;
import haxegui.logging.LogLevel;

import haxegui.utils.Printing;
import haxegui.utils.Opts;

/**
*
* Console for debugging, contains two TextFields, one output for tracing messages
* and another hscript-parsing input field.
*
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class Console extends Window, implements ILogger
{
	/** hscript parser **/
	var parser : hscript.Parser;

	/** 
	* hscript interpreter 
	*	
	* can be used in the console like this:
	* <pre class="code haxe">
	* // returns [object Interp]
	* this.interp
	*
	* // returns the interpreter's variables hash, where objects are packages and fields are classes
	* this.interp.variables
	* </pre>
	**/
	var interp : hscript.Interp;

	/** the console's input history, press up to pop a command **/
	var history : Array<String>;

	/**
	* the current console "working directory"
	* the [_pwd] variable is for internal use, use "pwd" in the console:
	* <pre class="code haxe">
	* pwd.move(20,20);
	* </pre>
	**/
	var _pwd : DisplayObjectContainer;

	/**
	* the current console "working directory", in its array form.
	* you can use it with commands like:
	* <pre class="code haxe">
	* this.pwd.push("Container20");
	* this.pwd.pop();
	* this.pwd = "root.Window13.ScrollPane18.Container20.Button24".split(".");
	* </pre>
	**/
	var pwd : Array<String>;

	var container : Container;
	var output : TextField;
	var input : TextField;
	var vert : ScrollBar;

	public override function new (parent:DisplayObjectContainer=null, name:String=null, ?x:Float, ?y:Float) {
		super(parent, "Console", x, y);
	}
	
	public override function init(?opts:Dynamic) {
		////////////////////////////////////////////////////////////////////////
		// Visual 
		////////////////////////////////////////////////////////////////////////
		type = WindowType.ALWAYS_ON_TOP;
		super.init(opts);

		box = new Rectangle (0, 0, 640, 260);

		container = new Container(this, "Container", 10, 20);
		container.init();

		// Output TextField for trace and log messages
		output = new TextField();
		output.name = "output";
		output.htmlText = "";
		output.width = box.width - 40;
		output.height = box.height - 70;
		output.border = true;
		output.wordWrap = true;
		output.multiline = true;
		output.autoSize = flash.text.TextFieldAutoSize.NONE;
		output.type = flash.text.TextFieldType.DYNAMIC;
		output.selectable = true;
		output.mouseEnabled = true;
		output.focusRect = true;
		output.tabEnabled = true;
		output.defaultTextFormat = DefaultStyle.getTextFormat();

		// Input TextField for hscript execution
		input = new TextField();
		input.name = "input";
		input.defaultTextFormat = DefaultStyle.getTextFormat(8, 0xFFFFFF);
		input.type = flash.text.TextFieldType.INPUT;
		input.background = true;
		input.backgroundColor = 0x4D4D4D;
		input.border = true;
		input.width = box.width - 40;
		input.height = 20;
		input.addEventListener (KeyboardEvent.KEY_DOWN, onInputKeyDown);

		// Container
		container.init({
			color: Opts.optInt(opts,"bgcolor", 0x222222),
			alpha: Opts.optFloat(opts, "bgalpha", 0.85),
		});

		container.addChild(output);
		container.addChild(input);

		// Vertical Scrollbar
		vert = new ScrollBar(container, "vscrollbar");
		vert.init({target : output, color: this.color});
		vert.removeEventListener(ResizeEvent.RESIZE, vert.onParentResize);

		// if(isSizeable())
		// {
			// bl.y = frame.height - 32;
			// br.x = frame.width - 32;
			// br.y = frame.height - 32;
		// }

		////////////////////////////////////////////////////////////////////////
		// Non-visual 
		////////////////////////////////////////////////////////////////////////
		pwd = ["root"];
		_pwd = cast root;
		history = new Array<String>();

		parser = new hscript.Parser();
		interp = new hscript.Interp();
			var self = this;
			haxegui.utils.ScriptStandardLibrary.set(interp);
			interp.variables.set( "this", this );
			//~ interp.variables.set( "pwd", "root"+this.pwd.slice(1,-1).join("/") );
			interp.variables.set( "pwd", getPwd() );

			interp.variables.set( "help", help() );
			interp.variables.set( "clear", function(){ self.clear(); } );
			interp.variables.set( "print_r", Printing.print_r );
			interp.variables.set( "history", history );
			interp.variables.set( "interp", interp );
			interp.variables.set( "dir", function() { trace( self.interp.variables); } );
			interp.variables.set( "get", function() { self.getPwdOnNextClick(); } );
			interp.variables.set( "tree", function() { Printing.print_r(self._pwd); } );
		
			interp.variables.set("where", function() { trace(untyped self._pwd.name+" "+self._pwd.box.toString().substr(1).split("=").join("=\"").split(",").join("\"").split(")").join("\"").split("h").join("height").split("w").join("width")); });
			
		
			interp.variables.set( "cd", function(?v) { 
				if(v==null) return "";
					switch(v) {
						case ".":
						case "..":
							self.pwd.pop();
						case "/":
							self.pwd = ["root"];
						default:
							self.pwd.push(v);
					}

				var o = cast flash.Lib.current;
				for(i in 1...self.pwd.length)
					o = cast(o.getChildByName(self.pwd[i]), flash.display.DisplayObjectContainer);
				self._pwd = cast o;
				
				return self.pwd.join(".");
				});

			interp.variables.set( "ls", function(?v,?h) {
				/*
				if(Std.is(v, DisplayObjectContainer)) 
					return "ls "+v + Printing.print_r(v);	
				else {
					var o = cast flash.Lib.current;
					for(i in 1...self.pwd.length)
						o = cast(o.getChildByName(self.pwd[i]), flash.display.DisplayObjectContainer);
					return "ls "+self.pwd.join(".") + Printing.print_r(o);	
				}
				*/
					var o = cast flash.Lib.current;
					for(i in 1...self.pwd.length)
						o = untyped o.getChildByName(self.pwd[i]);
				var txt="";
				for(i in 0...o.numChildren) {
					var c = o.getChildAt(i);
					txt += c.name + "\t";
					//~ txt += Std.string(Type.typeof((cast o).getChildAt(i)));
					txt += "\t";
				}
				trace(txt);
				});
	
	}

	/*
	* Log a message to console
	*
	* @param Object to log, can be text, events and errors.
	* @param here
	* @param Optional error level
	*/
	public function log( msg : Dynamic, ?inf : haxe.PosInfos, ?error:ErrorType ) : Void {
		if(msg==null) return;
		// var text:String =  "";
		//~ output.htmlText = output.htmlText.split("#eeeeee").join("#666666");
		
		var text:String =  "<FONT FACE=\"MONO\" SIZE=\"10\" COLOR=\"#eeeeee\">";
		text += DateTools.format (Date.now (), "%H:%M:%S") + " " ;

		#if debug
			if(inf != null) {
				text += inf.fileName + ":" + inf.lineNumber + ":";
			}
		#end

		text += pwd.join(".") + "~> ";

		switch(Type.typeof(msg)) {
			case TClass(c):
/*
				switch(Type.getClassName(c).split(".").pop()) {
					case "Event":
						text += "<FONT COLOR=\"#00FF00\">EVENT</FONT>: ";
						text += "<B>"+msg.target.name+"</B>";
					case "MouseEvent":
						text += "<FONT COLOR=\"#89FF00\">MOUSEEVENT</FONT>: ";
						text += "<B>"+msg.target.name+"</B>";
						if(Std.is(msg.target, Component)) {
						//~ var act =  "mouse"+e.type.charAt(0).toUpperCase()+e.type.substr(1,e.type.length);
						var act =  msg.type;
						text += " hasOwnAction(" + act + "): " + msg.target.hasOwnAction(act) + "\n";
						}
					case "FocusEvent":
						text += "<FONT COLOR=\"#00FF98\">FOCUSEVENT</FONT>: ";
						text += "<B>"+msg.target.name+"</B>";
						if(Std.is(msg.target, Component)) {
						//~ var act =  "mouse"+e.type.charAt(0).toUpperCase()+e.type.substr(1,e.type.length);
						var act =  msg.type;
						text += " hasOwnAction(" + act + "): " + msg.target.hasOwnAction(act) + "\n";
						}
					case "LoaderInfo":
					default:
					}
*/					
			case TEnum(e):
				switch(Type.getEnumName(e)) {
				case "hscript.Error":
					//text += "<FONT COLOR=\"#FF0000\">ERROR</FONT>: ";
					error = ErrorType.ERROR;
				}
			case TFunction:
				text += "<FONT COLOR=\"#FFC600\">FUNCTION</FONT>: ";
			default:
				//~ text += Std.string(Type.typeof(e));
		}
		
		switch(error) {
		case ErrorType.ERROR:
			text += "<FONT COLOR=\"#FF0000\">ERROR</FONT>: ";
		case ErrorType.WARNNING:
			text += "<FONT COLOR=\"#FF7700\">WARNNING</FONT>: ";
		case ErrorType.NOTICE:
			text += "<FONT COLOR=\"#FF7700\">NOTICE</FONT>: ";
		case ErrorType.INFO:
			text += "<FONT COLOR=\"#FF7700\">INFO</FONT>: ";
		}
		
		text += msg ;

		output.htmlText += text;
		output.htmlText += "</FONT>";
		output.scrollV = output.maxScrollV + 1;
	}

	override public function onResize (e:ResizeEvent) : Void {
		if(vert==null) return;
				
		super.onResize(e);

		output.width = box.width - 30;
		output.height = box.height - 40;

		input.width = box.width - 30;
		input.y = box.height - 40;

		vert.box.height = box.height - 20;
		vert.x = box.width - 30;
		vert.down.y = Math.max( 20, box.height - 40);	
		vert.dirty = true;
		vert.frame.dirty = true;
	}

	/** Process keyboard input **/
	public function onInputKeyDown(e:KeyboardEvent) : Void {

		//~ vert.handle.y = box.height - vert.handle.y - 20;
		//~ vert.scroll=1;
		//~ vert.adjust();
		
		switch(e.keyCode) {
		
		case Keyboard.ENTER :
			if(input.text=="")	{
				trace("");
				return;
			}
				
			// text replacement for shell functions 
			if(input.text.substr(0,2)=="ls") {
				var args = input.text.split(" ");
				var dir = args.pop();
				//for(a in args)
				input.text="ls(\""+dir+"\","+Lambda.has(args, "-l")+")";
			}
			
			if(input.text.substr(0,2)=="cd") {
				var dir=input.text.split(" ").pop();
				if(dir!="cd")
				input.text="cd(\""+dir+"\")";
			}			
			
			if(input.text=="clear") input.text="clear()";
			if(input.text=="dir") input.text="dir()";
			if(input.text=="get") input.text="get()";

			// set the program
			var program = parser.parseString(input.text);

			// set the current pwd
			interp.variables.set("pwd", getPwd());

			// clear the command and push to history
			history.push(input.text);
			input.text = "";

			try {
				var rv = interp.execute(program);
				if(rv!=null)
					trace(rv);
			}
			catch(e:hscript.Error) {
				switch(e) {
					case EUnknownVariable(v):
						switch(v) {
						default:
							log("Unknown variable: "+"<B>"+v+"</B>", ErrorType.ERROR);
						}
					case EUnexpected(s):
						switch(s) {
						case "<eof>":
							log("Unexpected: "+"<B>"+s+"</B>", ErrorType.ERROR);
							
						default:
							log("Unexpected: "+"<B>"+s+"</B>", ErrorType.ERROR);
						}
					case EUnterminatedString:
						trace(e);
					default:
						trace(e);
				}
			}
			catch(e : Dynamic) {
				
				trace(e);
			}


		case Keyboard.UP :
			input.text = history.pop();
		}
	}
	
	public function getPwdOnNextClick() {
		stage.addEventListener(MouseEvent.MOUSE_DOWN, getPwdFromClick, false, 0, true);
		trace("Waiting for click event....");
	}

	public function getPwdFromClick(e:MouseEvent) {
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, getPwdFromClick);
		_pwd = e.target;
		//pwd = e.target.ancestors().join(".");
		var o = _pwd;
		pwd = [];
		while(o!=flash.Lib.current) {
			pwd.push(o.name);
			o = o.parent;
		}
		pwd.push("root");
		pwd.reverse();
		trace(e.target);
	}

	
	/**
	* Traverses the display list according to the current path 
	* @return The DisplayObject of the current "working directory"
	**/
	public function getPwd() : Dynamic {
		var o = cast flash.Lib.current;
		for(i in 1...pwd.length)
			o = cast(o.getChildByName(pwd[i]), flash.display.DisplayObjectContainer);
		_pwd = cast o;
		return _pwd;
	}
	
	/** Clear the output **/
	public function clear() : Void {
		this.output.text = "";
		trace("");
	}

	/**
	* @return Short help for available console commands
	**/
	public function help() : String {
		var text = "\n";
		var commands = {
			pwd 	 : "\tcurrent path",
			cd 		 : "\tpush an object name to current path, ex. cd(\"Component\"), cd(\"..\"), cd(\"/\") ",
			ls		 : "\tprints current object",
			get 	 : "\tgrab the path target from next mouse click",
			dir		 : "\tprints the interpreter's variables list",
			clear 	 : "clear the console",
			help 	 : "display this help",
			
		}
		
		for(i in Reflect.fields(commands))
			text += "\t<I>" + i + "</I>\t\t" + Reflect.field(commands, i) + "\n";
			
		return text;
	}
	
}
