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
	var _color : UInt;

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

		box = new Rectangle (0, 0, 512, 380);

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
		tf.width = container.box.width - 24;
		tf.height = 240;
		tf.type = flash.text.TextFieldType.INPUT;
		tf.background = true;
		tf.backgroundColor = DefaultStyle.INPUT_BACK;
		tf.border = true;
		tf.borderColor = DefaultStyle.BACKGROUND - 0x141414;
		tf.embedFonts = true;
		tf.multiline = true;
		tf.wordWrap = true;
		tf.defaultTextFormat = DefaultStyle.getTextFormat();

		tf.htmlText = "<p>Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. Aenean ultricies mi vitae est. Mauris placerat eleifend leo. Quisque sit amet est et sapien ullamcorper pharetra. Vestibulum erat wisi, condimentum sed, commodo vitae, ornare sit amet, wisi. Aenean fermentum, elit eget tincidunt condimentum, eros ipsum rutrum orci, sagittis tempus lacus enim ac dui. Donec non enim in turpis pulvinar facilisis. Ut felis. Praesent dapibus, neque id cursus faucibus, tortor neque egestas augue, eu vulputate magna eros eu erat. Aliquam erat volutpat. Nam dui mi, tincidunt quis, accumsan porttitor, facilisis luctus, metus</p>";
		tf.htmlText += "<br><ul><li>Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</li><li>Aliquam tincidunt mauris eu risus.</li><li>Vestibulum auctor dapibus neque.</li></ul><ul><li>Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</li><li>Aliquam tincidunt mauris eu risus.</li><li>Vestibulum auctor dapibus neque.</li></ul>";

		container.addChild(tf);

		var shadow = new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5,4, 4,0.75,flash.filters.BitmapFilterQuality.HIGH,true,false,false);
		container.filters = [shadow];

		var fontbox = new ComboBox(container, "FontBox", 10, 262);
		fontbox.init({width: 100});

		var sizebox = new ComboBox(container, "SizeBox", 120, 262);
		sizebox.init({width: 50});

		var btn = new Button(container, "Bold", 180, 260);
		btn.init({width: 24, height: 24, label: null });
		var icon = new Image(btn, "icon", 1, 1);
		icon.init({src: "assets/icons/format-text-bold.png"});


		btn = new Button(container, "Italic", 204, 260);
		btn.init({width: 24, height: 24, label: null });
		icon = new Image(btn, "icon", 1, 1);
		icon.init({src: "assets/icons/format-text-italic.png"});


		btn = new Button(container, "UnderLine", 228, 260);
		btn.init({width: 24, height: 24, label: null });
		icon = new Image(btn, "icon", 1, 1);
		icon.init({src: "assets/icons/format-text-underline.png"});


		btn = new Button(container, "AlignLeft", 10, 290);
		btn.init({width: 24, height: 24, label: null });
		icon = new Image(btn, "icon", 1, 1);
		icon.init({src: "assets/icons/format-justify-left.png"});


		btn = new Button(container, "AlignCenter", 34, 290);
		btn.init({width: 24, height: 24, label: null });
		icon = new Image(btn, "icon", 1, 1);
		icon.init({src: "assets/icons/format-justify-center.png"});

		btn = new Button(container, "AlignRight", 58, 290);
		btn.init({width: 24, height: 24, label: null });
		icon = new Image(btn, "icon", 1, 1);
		icon.init({src: "assets/icons/format-justify-right.png"});

		btn = new Button(container, "AlignFill", 82, 290);
		btn.init({width: 24, height: 24, label: null });
		icon = new Image(btn, "icon", 1, 1);
		icon.init({src: "assets/icons/format-justify-fill.png"});

		btn = new Button(container, "Color", 260, 260);

		btn.setAction("mouseClick",
		"
		new haxegui.ColorPicker().init();
		"
		);
		btn.init({width: 32, height: 24, label: null });



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


	public function onMouseUpImage(e:MouseEvent)  : Void
	{
		if(e.target.hitTestObject( CursorManager.getInstance()._mc ))
			CursorManager.setCursor(Cursor.HAND);
	}


	public override function onResize(e:ResizeEvent) {

		super.onResize(e);

		if(tf!=null) {
			tf.width = this.box.width - 30;
		}
	}


}
