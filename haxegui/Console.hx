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

import haxegui.logging.ILogger;
import haxegui.logging.ErrorType;
import haxegui.logging.LogLevel;


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
	var parser : hscript.Parser;
	var interp : hscript.Interp;

	
	var history : Array<String>;
	var _pwd : DisplayObjectContainer;
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

		// Vertical Scrollbar
		vert = new ScrollBar(container, "vscrollbar");
		vert.init({target : output, color: this.color});

		// Container
		container.init({
			color: Opts.optInt(opts,"bgcolor", 0x222222),
			alpha: Opts.optFloat(opts, "bgalpha", 0.85),
		});

		container.addChild(output);
		container.addChild(input);

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
			interp.variables.set( "print_r", Utils.print_r );
			interp.variables.set( "history", history );
			interp.variables.set( "interp", interp );
		
			interp.variables.set( "cd", function(?v) { 
				if(v==null) return "";
					switch(v) {
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

			interp.variables.set( "ls", function(?v) {
				if(Std.is(v, DisplayObjectContainer))
					return "ls "+v + Utils.print_r(v);	
				else {
					var o = cast flash.Lib.current;
					for(i in 1...self.pwd.length)
						o = cast(o.getChildByName(self.pwd[i]), flash.display.DisplayObjectContainer);
					return "ls "+self.pwd.join(".") + Utils.print_r(o);	
				}
				});
	

		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}

/*
*
*
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
					}
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

	override public function onResize (e:ResizeEvent) : Void
	{
		super.onResize(e);

		if(output!=null)
		{
			output.width = box.width - 30;
			output.height = box.height - 40;
		}

		if(input!=null)
		{
			input.width = box.width - 30;
			input.y = box.height - 40;
		}

		if(vert!=null)
		{
			vert.box.height = box.height - 20;
		}

	}

	public function onInputKeyDown(e:KeyboardEvent) : Void
	{

		switch(e.keyCode)
		{
		case Keyboard.ENTER :
			if(input.text=="")	{
				trace("");
				return;
			}
				
			// text replacement for shell functions 
			if(input.text=="ls") input.text="ls()";
			if(input.text=="cd") input.text="cd()";
			if(input.text=="clear") input.text="clear()";

			var program = parser.parseString(input.text);

			interp.variables.set("pwd", getPwd());
			
			history.push(input.text);
			input.text = "";

			try {
				var rv = interp.execute(program);
				if(rv!=null)
					trace(rv);
			}
			catch(e : hscript.Error) {
				switch(e) {
					case EUnknownVariable(v):
						switch(v) {
						default:
							log("Unknown variable: "+"<B>"+v+"</B>", ErrorType.ERROR);
						}
					case EUnexpected(s):
						switch(s) {
						default:
							log("Unexpected: "+"<B>"+s+"</B>", ErrorType.ERROR);
						}
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
	
	public function getPwd() : Dynamic {
		var o = cast flash.Lib.current;
		for(i in 1...pwd.length)
			o = cast(o.getChildByName(pwd[i]), flash.display.DisplayObjectContainer);
		_pwd = cast o;
		return _pwd;
	}
	

	public function clear() : Void {
		this.output.text = "";
		trace("");
	}

	public function help() : String {
		var text = "\n";
		var commands = {
			pwd 	 : "\tcurrent path",
			cd 		 : "\tpush an object name to current path, ex. cd(\"Component\"), cd(\"..\"), cd(\"/\") ",
			ls		 : "\tprints current object",
			clear 	 : "clear the console",
			help 	 : "display this help",
			
		}
		
		for(i in Reflect.fields(commands))
			text += "\t<I>" + i + "</I>\t\t" + Reflect.field(commands, i) + "\n";
			
		return text;
	}
	
}
