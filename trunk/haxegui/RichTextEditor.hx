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
import haxegui.controls.Button;
import haxegui.controls.Slider;
import haxegui.controls.Stepper;
import haxegui.controls.Input;
import haxegui.controls.ComboBox;

/**
*
*
*
*
*/
class RichTextEditor extends Window
{
	var tf : TextField;


	/**
	*
	*/
	public function new (?parent:DisplayObjectContainer, ?x:Float, ?y:Float)
	{
		super (parent, x, y);

	}

	public override function init(?initObj:Dynamic)
	{
		super.init({name:"RichTextEditor", x:x, y:y, width:width, height:height, type: WindowType.NORMAL });

		box = new Rectangle (0, 0, 512, 350);

		//
		var menubar = new MenuBar (this, "MenuBar", 10,20);
		menubar.init ();

		//~ var scrollpane = new ScrollPane(this, "ScrollPane", 10, 44);
		//~ scrollpane.init({width: 502, height: 260});

		//
		var container = new Container (this, "Container", 10, 44);
		container.init({width: 502, height: 310});

		
		tf = new TextField();
		tf.x = tf.y = 10;
		tf.width = container.box.width - 20;
		tf.height = 200;
		tf.type = flash.text.TextFieldType.INPUT;
		tf.background = true;
		tf.backgroundColor = DefaultStyle.INPUT_BACK;
		tf.border = true;
		tf.borderColor = DefaultStyle.BACKGROUND - 0x141414;
		tf.embedFonts = true;
		tf.multiline = true;
		tf.defaultTextFormat = DefaultStyle.getTextFormat();
		
		container.addChild(tf);

		var shadow = new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5,4, 4,0.75,flash.filters.BitmapFilterQuality.HIGH,true,false,false);
		container.filters = [shadow];

		var fontbox = new ComboBox(container, "FontBox", 10, 220);
		fontbox.init({width: 100});

		var sizebox = new ComboBox(container, "SizeBox", 120, 220);
		sizebox.init({width: 50});

		var btn = new Button(container, "Bold", 180, 220);
		btn.init({width: 20, height: 20 });

		btn = new Button(container, "Italic", 210, 220);
		btn.init({width: 20, height: 20 });

		btn = new Button(container, "UnderLine", 240, 220);
		btn.init({width: 20, height: 20 });

		btn = new Button(container, "AlignLeft", 10, 250);
		btn.init({width: 20, height: 20 });
		btn = new Button(container, "AlignCenter", 30, 250);
		btn.init({width: 20, height: 20 });
		btn = new Button(container, "AlignRight", 50, 250);
		btn.init({width: 20, height: 20 });


		//~ redraw(null);
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}







	public override function onRollOver(e:MouseEvent)  : Void
	{
		CursorManager.setCursor(Cursor.HAND);
	}

	public override function onRollOut(e:MouseEvent)
	{
	}


	public  function onMouseUpImage(e:MouseEvent)  : Void
	{
		if(e.target.hitTestObject( CursorManager.getInstance()._mc ))
			CursorManager.setCursor(Cursor.HAND);
	}





}
