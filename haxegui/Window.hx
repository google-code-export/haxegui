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
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.LineScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.FocusEvent;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.BevelFilter;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.Mouse;
import flash.ui.Keyboard;

import haxegui.CursorManager;
import haxegui.MouseManager;
import haxegui.StyleManager;
import haxegui.WindowManager;
import haxegui.controls.Component;
import haxegui.controls.TitleBar;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;

enum WindowType
{
	NORMAL;
	MODAL;
	ALWAYS_ON_TOP;
}

class WindowFrame extends Component
{
	static function __init__() {
		haxegui.Haxegui.register(WindowFrame);
	}
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
	public var br : Component;
	public var bl : Component;

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
		box = new Rectangle (0, 0, 512, 512);
		color = DefaultStyle.BACKGROUND;
		text = "Window";

		super.init(opts);

		type = WindowType.NORMAL;
		sizeable = Opts.optBool(opts, "sizeable", true);
		lazyResize = Opts.optBool(opts, "lazyResize", false);

		this.buttonMode = false;
		this.mouseEnabled = false;
		this.tabEnabled = false;


		//
		draw ();

		// add a titlebar
		titlebar = new TitleBar(this, "titlebar");
		titlebar.init({w:this.width, title:this.name, color: this.color });
		titlebar.redraw();

		titlebar.addEventListener (DragEvent.DRAG_START, DragManager.getInstance ().onStartDrag, false, 0, true);
		titlebar.addEventListener (DragEvent.DRAG_COMPLETE, DragManager.getInstance ().onStopDrag, false, 0, true);

		// add mouse event listeners
		//~ this.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		this.addEventListener (MouseEvent.MOUSE_DOWN, onRaise, false, 0, true);


		// register with focus manager
		FocusManager.getInstance ().addEventListener (FocusEvent.MOUSE_FOCUS_CHANGE, redraw, false, 0, true);


		this.dispatchEvent (new ResizeEvent (ResizeEvent.RESIZE));
	}


	public function isSizeable ():Bool
	{
		return sizeable;
	}



	public function onMove (e:MoveEvent)
	{
		//trace(e);
	}


	/**
	*
	*/
	public function draw ()
	{
		// frame
		frame = new WindowFrame(this, "frame");
		frame.buttonMode = false;

		var shadow =
		  new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.9, 8, 8, 0.85,
					flash.filters.BitmapFilterQuality.HIGH, false, false, false);

		frame.filters =[shadow];


		// corners
		if (isSizeable ())
		{
			if(br != null && br.parent == this)
				removeChild(br);
			br = new Component(this, "br");
			br.graphics.beginFill (DefaultStyle.BACKGROUND + 0x202020, 0.5);
			br.graphics.drawRoundRectComplex (0, 0, 32, 32, 0, 0, 0, 4);
			br.graphics.drawRect (0, 0, 22, 22);
			br.graphics.endFill ();
			br.x = box.width - 22;
			br.y = box.height - 22;

			br.buttonMode = true;
			br.focusRect = false;
			br.tabEnabled = false;

			br.addEventListener (MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
			br.addEventListener (MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
			br.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			br.addEventListener (DragEvent.DRAG_START, DragManager.getInstance ().onStartDrag, false, 0, true);
			br.addEventListener (DragEvent.DRAG_COMPLETE, DragManager.getInstance ().onStopDrag, false, 0, true);

			//
			if(bl != null && bl.parent == this)
				removeChild(bl);
			bl = new Component();
			bl.name = "bl";
			bl.graphics.beginFill (0x1A1A1A, 0.5);
			bl.graphics.drawRoundRectComplex (0, 0, 32, 32, 0, 0, 4, 0);
			bl.graphics.drawRect (10, 0, 22, 22);
			bl.graphics.endFill ();
			bl.y = box.height - 22;

			bl.buttonMode = true;
			bl.focusRect = false;
			bl.tabEnabled = false;

			bl.addEventListener (MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
			bl.addEventListener (MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
			bl.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			bl.addEventListener (DragEvent.DRAG_START,
					DragManager.getInstance ().onStartDrag, false, 0, true);
			bl.addEventListener (DragEvent.DRAG_COMPLETE,
					DragManager.getInstance ().onStopDrag, false, 0, true);

		}
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

	/**
	*
	*
	*/
	override public function onRollOut (e:MouseEvent):Void
	{
		if (this.hasFocus ())
			redraw ( {damaged: true, fill: 0x4D4D4D, color:0xBFBFBF} );
		else
			redraw (null);
		//
		//~CursorManager.getInstance ().setCursor (Cursor.ARROW);
	}

	/**
	*
	*
	*/
	override public function onRollOver (e:MouseEvent)
	{
		//~ redraw (true, 0x595959, 0x737373);
		//
		CursorManager.setCursor (Cursor.HAND);
	}

	/**
	*
	*
	*
	*/
	public function onMouseMove (e:MouseEvent)
	{

		//
		//~ CursorManager.getInstance ().inject (e);
		//~ e.stopImmediatePropagation ();
		//
		var damaged:Bool = true;
		if (e.buttonDown)
		{
			var resizeEvent = new ResizeEvent (ResizeEvent.RESIZE);
			resizeEvent.oldWidth = box.width;
			resizeEvent.oldHeight = box.height;

			switch (e.target)
			{
			case titlebar:
				this.move (e.target.x, e.target.y);
				e.target.x = e.target.y = 0;
				damaged = false;
			case br:
				bl.y = e.target.y;
				box.width = e.target.x + 22;
				box.height = e.target.y + 22;
			case bl:
				br.y = e.target.y;
				box.width -= e.target.x;
				box.height = e.target.y + 22;
				move (e.target.x, 0);
				e.target.x = 0;
				br.x = box.width - 22;
			//~ case "frame":
				//~ move (e.target.x, e.target.y);
				//~ e.target.x = e.target.y = 0;
				//~ damaged = false;
			}

			if (damaged)
			{
				this.dispatchEvent (resizeEvent);
				//~ redraw(null);
			}

			e.updateAfterEvent ();
		}//buttonDown
	}// onMouseMove

	/**
	* Resize listener to position corners and redraw frame
	*
	*
	*/
	override public function onResize (e:ResizeEvent)
	{
		//~ trace(e);
		if (isSizeable())
		{
			bl.y = box.height - 22;
			br.y = box.height - 22;
			br.x = box.width - 22;
		}

		if(lazyResize)
			dirty = true ;
		else
			redraw();
		//~ e.updateAfterEvent();
	}

	override public function onMouseDown (e:MouseEvent):Void
	{
		//~ trace("WindowManager.onMouseDown target : " + e.target);
		if (!this.contains(e.target))
			return;


		if (e.target == titlebar || e.target == br || e.target == bl)
		//~ if (e.target == titlebar || isSizeable() && (e.target == br || e.target == bl) )
		{
			// raise target
 			e.target.parent.setChildIndex (e.target, e.target.parent.numChildren - 1);

			e.target.dispatchEvent (new DragEvent (DragEvent.DRAG_START));
			e.target.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			//~ flash.Lib.current.stage.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
			//~ this.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
			//~ flash.Lib.current.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);

		}

		switch (e.target)
		{
		case titlebar:
			CursorManager.setCursor (Cursor.SIZE_ALL);
		case bl:
			CursorManager.setCursor (Cursor.NE);
		case br:
			CursorManager.setCursor (Cursor.NW);
		}
	}

	override public function onMouseUp (e:MouseEvent):Void
	{
		//~ if(!Std.is(e.target, Sprite)) return;

		e.target.dispatchEvent (new DragEvent (DragEvent.DRAG_COMPLETE));
		e.target.removeEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);


		//~ if (this.hasFocus())
		//~ redraw ({damaged:true, fill:0x4D4D4D, color:0xBFBFBF});
		//~ else
		//~ redraw ({target: e.target});

		this.dispatchEvent (new ResizeEvent (ResizeEvent.RESIZE));

		//~ redraw (false);
		e.updateAfterEvent ();
	}



	/**
	* Redraw entire window
	*
	*/
	override public function redraw (e:Dynamic=null):Void
	{
		var color:UInt = this.color - 0x282828;
		var fill:UInt = this.color;
		var damaged:Bool = true;

		if (e != null && Reflect.isObject (e))
			if (!Std.is (e, ResizeEvent))
				if (!Std.is (e, FocusEvent))
				{
					color = Opts.optInt(e,"color",color);
					fill = Opts.optInt(e, "fill", fill);
					damaged = Opts.optBool(e, "damaged", damaged);
				}

		if (!damaged)
			return;

		if (this.hasFocus ())
		{
			color = this.color | 0x141414;
			fill = this.color | 0x191919;
		}

		// frame
		//~ redrawFrame (fill, color);
		frame.redraw ({box: this.box, fillColor: fill, strokeColor: color});

		// titlebar
		titlebar.redraw({fillColor: fill, width:box.width+10});

		// corners
		if (isSizeable ())
		{
			//
			bl.graphics.clear ();
			bl.graphics.beginFill (fill, 0.5);
			bl.graphics.drawRoundRectComplex (0, 0, 32, 32, 0, 0, 4, 0);
			bl.graphics.drawRect (10, 0, 22, 22);

			//
			br.graphics.clear ();
			br.graphics.beginFill (fill, 0.5);
			br.graphics.drawRoundRectComplex (0, 0, 32, 32, 0, 0, 0, 4);
			br.graphics.drawRect (0, 0, 22, 22);
			br.graphics.endFill ();
		}

		if (Std.is (e, ResizeEvent))
			e.updateAfterEvent ();
	}				//redraw

	public function onRaise(e:Event)
	{
// 		parent.setChildIndex (this, parent.numChildren - 1);
	}

	static function __init__() {
		haxegui.Haxegui.register(Window,initialize);
	}
	static function initialize() {
	}
}
