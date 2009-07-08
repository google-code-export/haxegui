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

import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;
import haxegui.managers.StyleManager;
import haxegui.Window;

import haxegui.containers.Container;
import haxegui.controls.ScrollBar;

import hscript.Expr;

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
class Console extends Window, implements ITraceListener
{
	var parser : hscript.Parser;
	var history : Array<String>;
	var _pwd : DisplayObjectContainer;
	var pwd : Array<String>;

	var container : Container;
	var output : TextField;
	var input : TextField;
	var vert : ScrollBar;


	/**
	*
	*/
	public function new (?parent:DisplayObjectContainer, ?x:Float, ?y:Float)
	{
		super (parent, "Console", x, y);
	}

	public override function init(?opts:Dynamic)
	{
// 		if(opts == null) opts = {};
// 		super.init({name:"Console", x:x, y:y, width:width, height:height, sizeable:true, color: 0x666666});

		type = WindowType.ALWAYS_ON_TOP;
		super.init(opts);

		box = new Rectangle (0, 0, 640, 260);


		container = new Container(this, "Container", 10, 20);
		container.init();

		parser = new hscript.Parser();
		history = new Array<String>();

		//~ pwd = flash.Lib.current;
		pwd = ["root"];
		_pwd = cast root;

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

		parser = new hscript.Parser();
		history = new Array<String>();

		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}

/*
*
*
*/
	public function log( e : Dynamic, ?inf : haxe.PosInfos ) : Void
	{
		// var text:String =  "";
		output.htmlText = output.htmlText.split("#eeeeee").join("#666666");
		
		var text:String =  "<FONT FACE=\"MONO\" SIZE=\"10\" COLOR=\"#eeeeee\">";
		text += DateTools.format (Date.now (), "%H:%M:%S") + " " ;

		#if debug
			if(inf != null) {
				text += inf.fileName + ":" + inf.lineNumber + ":";
			}
		#end

		text += pwd.join(".") + "~> ";

		switch(Type.typeof(e)) {

			case TClass(c):
				switch(Type.getClassName(c).split(".").pop()) {
					case "Event":
						text += "<FONT COLOR=\"#00FF00\">EVENT</FONT>: ";
						text += "<B>"+e.target.name+"</B>";
					case "MouseEvent":
						text += "<FONT COLOR=\"#89FF00\">MOUSEEVENT</FONT>: ";
						text += "<B>"+e.target.name+"</B>";
						if(Std.is(e.target, Component)) {
						//~ var act =  "mouse"+e.type.charAt(0).toUpperCase()+e.type.substr(1,e.type.length);
						var act =  e.type;
						text += " hasOwnAction(" + act + "): " + e.target.hasOwnAction(act) + "\n";
						}
					
					}
			case TEnum(v):
				text += "<FONT COLOR=\"#FF0000\">ERROR</FONT>: ";
			case TFunction:
				text += "<FONT COLOR=\"#FFC600\">FUNCTION</FONT>: ";
			default:
				//~ text += Std.string(Type.typeof(e));
		}
		
		
		text += e ;

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

		if(container!=null)
			container.onParentResize(e);

	}

	public function onInputKeyDown(e:KeyboardEvent) : Void
	{

		switch(e.keyCode)
		{
		case Keyboard.ENTER :
			if(input.text=="")
			{
				trace("");
				return;
			}
				
				// some text replacements
				if(input.text=="ls") input.text="ls()";
				if(input.text=="cd") input.text="cd()";
				
				var program = parser.parseString(input.text);
				var interp = new hscript.Interp();

				var self = this;


				haxegui.utils.ScriptStandardLibrary.set(interp);
				interp.variables.set( "this", this );
				//~ interp.variables.set( "pwd", "root"+this.pwd.slice(1,-1).join("/") );
				interp.variables.set( "pwd", getPwd() );

				interp.variables.set( "help", help() );
				interp.variables.set( "clear", clear() );
				interp.variables.set( "print_r", Utils.print_r );
			
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

				
				history.push(input.text);
				input.text = "";

			try {
				trace(interp.execute(program));
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
		//return pwd.join(".");
		return _pwd;
	}
	

	public function clear() : String {
		output.text = "";
		return "";
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
