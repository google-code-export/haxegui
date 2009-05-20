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
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.FocusEvent;

import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;

import flash.ui.Mouse;
import flash.ui.Keyboard;

import haxegui.managers.CursorManager;
import haxegui.managers.MouseManager;
import haxegui.managers.StyleManager;
import haxegui.managers.WindowManager;
import haxegui.managers.DragManager;
import haxegui.managers.FocusManager;
import haxegui.managers.ScriptManager;
import haxegui.Component;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;

import haxegui.controls.AbstractButton;
import haxegui.Opts;
import haxegui.windowClasses.TitleBar;
import haxegui.windowClasses.WindowFrame;


enum WindowType
{
	NORMAL;
	MODAL;
	ALWAYS_ON_TOP;
}


/**
*
* Window class
*
* Dragable & Resizable  window.
*
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
* @todo frame rendering to hscript
* @todo corners to components
*/
class Window extends Component
{
	public var titlebar : TitleBar;
	public var frame : WindowFrame;
	public var type:WindowType;

	private var lazyResize:Bool;
	private var sizeable:Bool;
	
	//~ private var _mask:Sprite;

	public function new (? parent : DisplayObjectContainer, ? name : String,
				? x : Float, ? y : Float, ? width : Float,
				? height : Float, ? sizeable : Bool)
	{
		if (parent == null || !Std.is (parent, DisplayObjectContainer))
		parent = flash.Lib.current;

		super (parent, name, x, y);
	}

	public function getInnerRectangle() : Rectangle {
		return new Rectangle();
	}

	override public function init(opts : Dynamic=null)
	{
		box = new Rectangle (0, 0, 320, 240);
		color = DefaultStyle.BACKGROUND;
		text = "Window";

		super.init(opts);

		type = WindowType.NORMAL;
		sizeable = Opts.optBool(opts, "sizeable", true);
		lazyResize = Opts.optBool(opts, "lazyResize", true);


		// frame
		frame = new WindowFrame(this, "frame");
		frame.init({color: this.color});
		frame.buttonMode = false;
		
		// add a titlebar
		titlebar = new TitleBar(this, "titlebar");
		titlebar.init({title:this.name, color: this.color });

		// register with focus manager
		//~ FocusManager.getInstance ().addEventListener (FocusEvent.MOUSE_FOCUS_CHANGE, redraw, false, 0, true);

	}


	public function isSizeable ():Bool
	{
		return sizeable;
	}


	/**
	* Returns true if the window is modal
	**/
	public function isModal() : Bool {
		return switch(type) {
		case MODAL: true;
		default : false;
		}
	}

	static function __init__() {
		haxegui.Haxegui.register(Window,initialize);
	}

	static function initialize() {
	}
	
	
	override public function redraw(opts:Dynamic=null):Void
	{

		this.parent.dispatchEvent( new haxegui.events.ResizeEvent(haxegui.events.ResizeEvent.RESIZE));

		//~ this.box.width = this.frame.br.x + 22;
		//~ this.box.height = this.frame.bl.y + 22;
		//~ 
		frame.redraw();
		//~ titlebar.redraw({box: this.box.clone()});
		
		ScriptManager.exec(this,"redraw",
			{
				color: Opts.optInt(opts, "color", color),
			});

	}

	
}
