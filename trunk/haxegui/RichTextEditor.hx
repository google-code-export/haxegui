// Copyright (c) 2409 The haxegui developers
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

import Type;

import flash.geom.Rectangle;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.LineScaleMode;

import flash.text.TextField;
import flash.text.TextFormat;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import flash.events.TextEvent;
import flash.events.EventDispatcher;

import flash.ui.Keyboard;

import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;
import haxegui.events.MenuEvent;

import flash.ui.Mouse;

import flash.Error;
import haxe.Timer;
//~ import flash.utils.Timer;

import flash.display.Bitmap;
import flash.display.BitmapData;



import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;

import haxegui.managers.CursorManager;
import haxegui.managers.StyleManager;
import haxegui.Window;
import haxegui.windowClasses.StatusBar;
import haxegui.controls.Label;
import haxegui.controls.Button;
import haxegui.controls.Slider;
import haxegui.controls.Stepper;
import haxegui.controls.Input;
import haxegui.controls.ComboBox;

/**
*
* RTE class
* 
*
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class RichTextEditor extends Window
{
	var tf : TextField;
	var _color : UInt;
	var _html : Bool;
	/**
	*
	*/
	public function new (?parent:DisplayObjectContainer, ?x:Float, ?y:Float)
	{
		super (parent, x, y);

	}

	public override function init(?opts:Dynamic)
	{
		super.init({name:"RichTextEditor", x:x, y:y, width:width, height:height, type: WindowType.NORMAL });
		_color = 0x000000;
		_html = true;
		box = new Rectangle (0, 0, 512, 380);

		//
		var menubar = new MenuBar (this, "MenuBar", 10,20);
		menubar.init ();

		//~ var scrollpane = new ScrollPane(this, "ScrollPane", 10, 44);
		//~ scrollpane.init({width: 502, height: 12});
		
		//
		var toolbar = new ToolBar(this, "Toolbar", 10, 44);
		toolbar.init();
		
		
		

		var fontbox = new ComboBox(toolbar, "FontBox", 14, 10);
		fontbox.init({width: 100});

		var sizebox = new ComboBox(toolbar, "SizeBox", 124, 10);
		sizebox.init({width: 50});

		var btn = new Button(toolbar, "Bold", 180, 8);
		btn.init({width: 24, height: 24, label: null });
		var icon = new Image(btn, "icon", 4, 4);
		icon.init({src: "assets/icons/format-text-bold.png"});
		btn.setAction("mouseClick",
		"
		var tf = this.getParentWindow().getChildByName(\"Container1\").getChildByName(\"tf\");
		/*
		var sel = tf.selectedText;
		var begin = StringTools.htmlEscape(tf.htmlText.substr(0, tf.selectionBeginIndex));
		var end = StringTools.htmlEscape(tf.htmlText.substr( tf.selectionEndIndex, tf.htmlText.length));
		var txt = begin + \"<B>\" + sel + \"</B>\" + end;
		tf.htmlText = txt;
		*/
		tf.replaceSelectedText( \"<B>\" + tf.selectedText + \"</B>\" );
		"
		);

		btn = new Button(toolbar, "Italic", 204, 8);
		btn.init({width: 24, height: 24, label: null });
		icon = new Image(btn, "icon", 4, 4);
		icon.init({src: "assets/icons/format-text-italic.png"});
		btn.setAction("mouseClick",
		"
		var tf = this.getParentWindow().getChildByName(\"Container1\").getChildByName(\"tf\");
		tf.replaceSelectedText( \"<I>\" + tf.selectedText + \"</I>\" );
		"
		);

		btn = new Button(toolbar, "UnderLine", 228, 8);
		btn.init({width: 24, height: 24, label: null });
		icon = new Image(btn, "icon", 4, 4);
		icon.init({src: "assets/icons/format-text-underline.png"});
		btn.setAction("mouseClick",
		"
		var tf = this.getParentWindow().getChildByName(\"Container1\").getChildByName(\"tf\");
		tf.replaceSelectedText( \"<U>\" + tf.selectedText + \"</U>\" );
		"
		);



		btn = new Button(toolbar, "AlignLeft", 252, 8);
		btn.init({width: 24, height: 24, label: null });
		icon = new Image(btn, "icon", 4, 4);
		icon.init({src: "assets/icons/format-justify-left.png"});


		btn = new Button(toolbar, "AlignCenter", 276, 8);
		btn.init({width: 24, height: 24, label: null });
		icon = new Image(btn, "icon", 4, 4);
		icon.init({src: "assets/icons/format-justify-center.png"});

		btn = new Button(toolbar, "AlignRight", 300, 8);
		btn.init({width: 24, height: 24, label: null });
		icon = new Image(btn, "icon", 4, 4);
		icon.init({src: "assets/icons/format-justify-right.png"});

		btn = new Button(toolbar, "AlignFill", 324, 8);
		btn.init({width: 24, height: 24, label: null });
		icon = new Image(btn, "icon", 4, 4);
		icon.init({src: "assets/icons/format-justify-fill.png"});

		btn = new Button(toolbar, "Color", 400, 8);
		btn.init({width: 32, height: 24, label: null });
		var col = new Sprite();
		col.graphics.lineStyle(1, DefaultStyle.BACKGROUND - 0x141414, 1);
		col.graphics.beginFill(_color);
		col.graphics.drawRect(4,4,24,16);
		col.graphics.endFill();
		var shadow = new flash.filters.DropShadowFilter (2, 45, DefaultStyle.DROPSHADOW, 0.5,4, 4,0.75,flash.filters.BitmapFilterQuality.HIGH,true,false,false);
		col.filters = [shadow];

		btn.addChild(col);
		btn.setAction("mouseClick",
			"
				var win = this.getParentWindow();
				var tf = win.getChildByName(\"Container1\").getChildByName(\"tf\");
				var spr = this.getChildAt(0);
				
				var c = new haxegui.ColorPicker();
				c.currentColor = win._color;
				c.init();
				var container = c.getChildByName(\"Container\");
				var ok = container.getChildByName(\"Ok\");
				var cancel = container.getChildByName(\"Cancel\");
				
				cancel.setAction(\"mouseClick\",\"this.getParentWindow().destroy();\");
				ok.addEventListener(flash.events.MouseEvent.MOUSE_UP,
				function(e) {
					win._color = c.currentColor;
					c.destroy();
					spr.graphics.clear();
					spr.graphics.beginFill(win._color);
					spr.graphics.drawRect(4,4,24,16);
					spr.graphics.endFill();
					var hex = StringTools.hex(win._color);
					tf.replaceSelectedText( \"<FONT COLOR='#\"+hex+\"' >\" + tf.selectedText + \"</FONT>\" );
					});
			"
		);
		


		btn = new Button(toolbar, "Html", 432, 8);
		icon = new Image(btn, "icon", 4, 4);
		icon.init({src: "assets/icons/text-html.png"});
		btn.setAction("mouseClick",
		"
		var html = this.getParentWindow()._html;
		var tf = this.getParentWindow().getChildByName(\"Container1\").getChildByName(\"tf\");
		if(html)
			tf.text = tf.htmlText;
			/*tf.text = StringTools.htmlEscape(tf.htmlText);*/
		else
			tf.htmlText = tf.text;
			/*tf.htmlText = StringTools.htmlUnescape(tf.text);*/
		
		tf.setSelection(0,tf.htmlText.length);
		tf.scrollV = 0;
		
		this.removeChild(this.getChildByName(\"icon\"));
		
		var img = new haxegui.Image(this, \"icon\", 4, 4);
		if(html)
			img.src = \"assets/icons/text-html.png\";
		else
			img.src = \"assets/icons/text-x-generic.png\";
		img.init();
		
		this.getParentWindow()._html = !this.getParentWindow()._html;
		"
		);
		btn.init({width: 24, height: 24, label: null });



		
		//~ flash.system.System.useCodePage = false;

		//
		var container = new Container (this, "Container1", 10, 84);
		container.init({width: 502, height: 310});

		tf = new TextField();
		tf.name = "tf";
		tf.x = tf.y = 10;
		tf.width = this.box.width - 40;
		tf.height = this.box.height - 124;
		tf.type = flash.text.TextFieldType.INPUT;
		tf.background = true;
		tf.backgroundColor = DefaultStyle.INPUT_BACK;
		tf.textColor = DefaultStyle.INPUT_TEXT;
		tf.border = true;
		tf.borderColor = DefaultStyle.BACKGROUND - 0x141414;
		tf.autoSize = flash.text.TextFieldAutoSize.NONE;
		/*tf.embedFonts = true;*/
		tf.multiline = true;
		tf.wordWrap = true;
		tf.alwaysShowSelection = true;
		
		//~ var fmt = DefaultStyle.getTextFormat();
		//~ fmt.leading = 4;
		//~ tf.defaultTextFormat = fmt;
		
		tf.htmlText = "<FONT SIZE=\"14\" FACE=\"Times\" COLOR=\"#000000\">";	
		tf.htmlText += "<p>Lorem ipsum dolor sit amet.</p><p>Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. Aenean ultricies mi vitae est. Mauris placerat eleifend leo. Quisque sit amet est et sapien ullamcorper pharetra. Vestibulum erat wisi, condimentum sed, commodo vitae, ornare sit amet, wisi. Aenean fermentum, elit eget tincidunt condimentum, eros ipsum rutrum orci, sagittis tempus lacus enim ac dui. Donec non enim in turpis pulvinar facilisis. Ut felis. Praesent dapibus, neque id cursus faucibus, tortor neque egestas augue, eu vulputate magna eros eu erat. Aliquam erat volutpat. Nam dui mi, tincidunt quis, accumsan porttitor, facilisis luctus, metus</p>";
		tf.htmlText += "<br><ul><li>Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</li><li>Aliquam tincidunt mauris eu risus.</li><li>Vestibulum auctor dapibus neque.</li></ul><ul><li>Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</li><li>Aliquam tincidunt mauris eu risus.</li><li>Vestibulum auctor dapibus neque.</li></ul>";
		tf.htmlText += "</FONT>";
		
		container.addChild(tf);

		var shadow = new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5,4, 4,0.75,flash.filters.BitmapFilterQuality.HIGH,false,false,false);
		tf.filters = [shadow];


		shadow = new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5,4, 4,0.75,flash.filters.BitmapFilterQuality.HIGH,true,false,false);
		container.filters = [shadow];

		//
		var statusbar = new StatusBar(this, "StatusBar", 10, 360);
		statusbar.init();

		//
		var info = new Label(statusbar, "Info", 4, 4);
		info.init();

		tf.addEventListener(TextEvent.TEXT_INPUT, updateInfo);
		tf.addEventListener(Event.CHANGE, updateInfo);
		tf.addEventListener(MouseEvent.MOUSE_DOWN, updateInfo);
		tf.addEventListener(MouseEvent.MOUSE_UP, updateInfo);
		tf.addEventListener(KeyboardEvent.KEY_DOWN, updateInfo);
		//~ redraw(null);
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}



	public function updateInfo(e:Dynamic) {
		var container = cast this.getChildByName("Container1");
		var tf = cast container.getChildByName("tf");
		
		
		var status = cast this.getChildByName("StatusBar");
		var info = cast status.getChildByName("Info");

		var l = 0;
		var c = 0;
		if(Std.is(e, MouseEvent)) {
			l = tf.getLineIndexAtPoint(e.localX, e.localY);
			c = tf.getCharIndexAtPoint(e.localX, e.localY);
			}
		if(Std.is(e, KeyboardEvent)) {
			l = tf.getLineIndexOfChar( tf.caretIndex );
			}
		
		var o = {
			line: l,
			col: c,
			numLines: tf.numLines,
			pos: tf.caretIndex,
			sel: tf.selectedText.length
			};
		var txt = Std.string(o);
		txt = txt.substr(1, txt.length-2);
		txt = txt.split(",").join("\t ");
		info.tf.text = txt;
		
	}
	



	public override function onRollOver(e:MouseEvent)  : Void
	{
		CursorManager.setCursor(Cursor.HAND);
	}

	public override function onRollOut(e:MouseEvent)
	{
	}


	public function onMouseUpImage(e:MouseEvent)  : Void
	{
		if(e.target.hitTestObject( CursorManager.getInstance()._mc ))
			CursorManager.setCursor(Cursor.HAND);
	}


	public override function onResize(e:ResizeEvent) {

		super.onResize(e);

		if(tf!=null) {
			tf.width = this.box.width - 30;
			tf.height = this.box.height - 124;
		}
		
		
	}


}
