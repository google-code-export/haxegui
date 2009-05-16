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
import haxegui.StyleManager;

import haxegui.controls.Scrollbar;

/**
*
*
*
*
*/
class Console extends Window, implements ITraceListener
{
	var parser : hscript.Parser;
	var history : Array<String>;
	var pwd : DisplayObjectContainer;

	var container : Container;
	var output : TextField;
	var input : TextField;
	var vert : Scrollbar;


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
		super.init(opts);

		box = new Rectangle (0, 0, 640, 240);

		input = new TextField();
		
		container = new Container(this, "Container", 10, 20);
		container.init();
		
		vert = new Scrollbar(container, "vscrollbar");
		parser = new hscript.Parser();
		history = new Array<String>();

		pwd = flash.Lib.current;


		//
		output = new TextField();
		output.name = "output";
		output.htmlText = "";
		output.width = box.width - 40;
		output.height = box.height - 70;
		//~ output.background = true;
		//~ output.backgroundColor = 0x222222;
		output.border = true;
		output.wordWrap = true;
		output.multiline = true;
		output.autoSize = flash.text.TextFieldAutoSize.NONE;
		output.type = flash.text.TextFieldType.DYNAMIC;
		output.selectable = true;
		output.mouseEnabled = true;
		output.focusRect = true;
		output.tabEnabled = true;

		//
		input.name = "input";
		input.defaultTextFormat = DefaultStyle.getTextFormat(8, 0xFFFFFF);
		input.type = flash.text.TextFieldType.INPUT;
		input.background = true;
		input.backgroundColor = 0x4D4D4D;
		input.border = true;
		input.width = box.width - 40;
		input.height = 20;
		input.addEventListener (KeyboardEvent.KEY_DOWN, onInputKeyDown);

		//~ container.box.width -= 20;
		//~ vert = new Scrollbar(container, "vscrollbar");
		//~ vert = new Scrollbar(this, "vscrollbar");
		//~ vert.x = box.width - 20;
		//~ vert.y = 20;
		//~ vert.color = color;
		//~ vert.init(content);
		vert.init({target : output});

		//
		container.init({
			color: Opts.optInt(opts,"bgcolor", 0x222222),
			alpha: Opts.optFloat(opts, "bgalpha", 0.85),
		});

		container.addChild(output);
		container.addChild(input);

		if(isSizeable())
		{
			bl.y = frame.height - 32;
			br.x = frame.width - 32;
			br.y = frame.height - 32;
		}

		parser = new hscript.Parser();
		history = new Array<String>();

		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}

/*
*
*
*/
	public  function log( e : Dynamic, ?inf : haxe.PosInfos ) : Void
	{
		//~ var text:String =  "";
		var text:String =  "<FONT FACE=\"MONO\" SIZE=\"10\" COLOR=\"#eeeeee\">";
		text += DateTools.format (Date.now (), "%H:%M:%S") + "\t" ;

		if(Std.is(e,Event))
		{
			text += "<B>"+e.target;
			if(Reflect.hasField(e.target, "name"))
				text += ":"+e.target.name;
			text += "</B>\t" ;
		}

		text += e ;

		output.htmlText += text;
		output.htmlText += "</FONT>";
		output.scrollV = output.maxScrollV + 1;
	}

	override public function onResize (e:ResizeEvent) : Void
	{
		super.onResize(e);

		e.stopImmediatePropagation ();
		//~ e.stopPropagation ();

		output.width = box.width - 30;
		output.height = box.height - 40;

		input.width = box.width - 30;
		input.y = box.height - 40;


		vert.x = box.width - 20;
		//~ vert.y = 40;
		vert.box.height = box.height - 20;
		//~ vert.box.width = box.width - 40;
		//~ vert.onResize(null);

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

			try {
				var program = parser.parseString(input.text);
				history.push(input.text);
				input.text = "";

				var interp = new hscript.Interp();
				haxegui.utils.ScriptStandardLibrary.set(interp);
				interp.variables.set( "this", this );
				interp.variables.set( "pwd", this.pwd );

				interp.variables.set( "clear", clear() );
				interp.variables.set( "print_r", Utils.print_r );
				interp.variables.set( "ls", Utils.print_r(pwd) );

					//~ trace( ret==null ? "\n" : ret );
				trace(interp.execute(program));
			} 
			catch(e : Dynamic) 
			{
				trace("ERROR: " + e);
			}

		case Keyboard.UP :
			input.text = history.pop();
		}
	}

	public function clear()
	{
		output.text = "";
	}


}
