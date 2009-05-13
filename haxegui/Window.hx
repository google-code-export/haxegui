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


//TODO: frame rendering to hscript
//TODO: corners to components


package haxegui;


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
import flash.events.FocusEvent;

import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;

import flash.ui.Mouse;
import flash.ui.Keyboard;

import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.BevelFilter;

import haxegui.WindowManager;
import haxegui.MouseManager;
import haxegui.CursorManager;
import haxegui.StyleManager;

import haxegui.controls.Component;
import haxegui.controls.TitleBar;

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
* @version 0.1
*/
class Window extends Component, implements Dynamic
{
	public var titlebar:TitleBar;

	public var frame:Sprite;
	public var br:Sprite;
	public var bl:Sprite;


	public var color:UInt;
	public var type:WindowType;

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

	/**
	*
	* Initialize a new window
	*
	* @param opts Dynamic object containing attributes
	*
	*
	*/
	override public function init(opts : Dynamic=null)
	{
		super.init(opts);
		type = WindowType.NORMAL;
		sizeable = true ;
		box = new Rectangle (0, 0, 512, 512);
		color = DefaultStyle.BACKGROUND;
		text = "Window";

		if (Reflect.isObject (opts))
		{
			for (f in Reflect.fields (opts))
			if (Reflect.hasField (this, f))
				if (f != "width" && f != "height")
				Reflect.setField (this, f, Reflect.field (opts, f));

			//~ name = (opts.name == null) ? name : opts.name;
			//~ move(opts.x, opts.y);
			box.width = (Math.isNaN (opts.width)) ? box.width : opts.width;
			box.height = (Math.isNaN (opts.height)) ? box.height : opts.height;
			//~ color = (opts.color==null) ? color : opts.color;
			//~ sizeable = ( opts.sizeable == null ) ? true : opts.sizeable;

			//~ trace(Std.string(opts));
		}



		this.buttonMode = false;
		this.mouseEnabled = false;
		this.tabEnabled = false;


		//
		draw ();

		// add a titlebar
		titlebar = new TitleBar(this, "titlebar");
		titlebar.init({w:this.width, title:this.name});
		titlebar.redraw();

		titlebar.addEventListener (DragEvent.DRAG_START, DragManager.getInstance ().onStartDrag, false, 0, true);
		titlebar.addEventListener (DragEvent.DRAG_COMPLETE, DragManager.getInstance ().onStopDrag, false, 0, true);

		// add mouse event listeners
		//~ this.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		this.addEventListener (MouseEvent.MOUSE_DOWN, onRaise, false, 0, true);


		// register with focus manager
		FocusManager.getInstance ().addEventListener (FocusEvent.MOUSE_FOCUS_CHANGE, redraw, false, 0, true);


		// add to stage
		//~ flash.Lib.current.addChild (this);
		parent.addChild (this);


		this.dispatchEvent (new ResizeEvent (ResizeEvent.RESIZE));


		redraw (null);

		//~ return this;
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
		frame = new Sprite ();
		frame.name = "frame";
		frame.buttonMode = false;

		var shadow:DropShadowFilter =
		new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.9, 8, 8, 0.85,
					BitmapFilterQuality.HIGH, false, false, false);

		//~ var bevel:BevelFilter = new BevelFilter( 4, 45 ,color | 0x323232 ,1 ,0x000000, .5, 4, 4, 2, BitmapFilterQuality.HIGH , flash.filters.BitmapFilterType.INNER, false );
		//~ frame.filters = [shadow, bevel];
		frame.filters = [shadow];

		this.addChild (frame);

		// corners
		if (isSizeable ())
		{
			br = new Sprite ();
			br.name = "br";
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

			this.addChild (br);

			//
			bl = new Sprite ();
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

			this.addChild (bl);

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
		CursorManager.getInstance ().inject (e.stageX, e.stageY);
		e.stopImmediatePropagation ();
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
		}				//buttonDown
	}				// onMouseMove


	/**
	* Resize listener to position corners and redraw frame
	*
	*
	*/
	override public function onResize (e:ResizeEvent)
	{
		//~ trace(e);
		if (sizeable)
		{
			bl.y = box.height - 22;
			br.y = box.height - 22;
			br.x = box.width - 22;
		}
		redraw (null);
		//~ e.updateAfterEvent();
	}



	/**
	*
	*/
	override public function onMouseDown (e:MouseEvent):Void
	{
		if (!Std.is (e.target, Sprite))
		return;

		//
		FocusManager.getInstance ().setFocus (this);

		// raise window
		parent.setChildIndex (this, parent.numChildren - 1);


		if (e.target == titlebar || e.target.name == "br"	|| e.target.name == "bl")
		{
			e.target.dispatchEvent (new DragEvent (DragEvent.DRAG_START));
			e.target.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			//~ flash.Lib.current.stage.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
			//~ this.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
			//~ flash.Lib.current.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);


			// raise target
			e.target.parent.setChildIndex (e.target, e.target.parent.numChildren - 1);
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


	}				//onMouseDown


	/**
	*
	*
	*
	*/
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
	* Redraw just frame
	*
	*/
	public function redrawFrame (fill:UInt, color:UInt)
	{
		frame.graphics.clear ();
		frame.graphics.beginFill (fill, 0.5);
		frame.graphics.lineStyle (2, color);
		frame.graphics.drawRoundRect (0, 0, box.width + 10, box.height + 10, 8, 8);
		frame.graphics.drawRect (10, 20, box.width - 10, box.height - 20);
		//~ frame.graphics.endFill ();
		//~ frame.graphics.beginFill (0x8C8C8C, 0.5);
		//~ frame.graphics.drawRect (10, 20, box.width - 20, box.height - 30);
		frame.graphics.endFill ();
	}


	/**
	* Redraw entire window
	*
	*/
	override public function redraw (e:Dynamic=null):Void
	{

		var color:UInt = this.color - 0x141414;
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
		redrawFrame (fill, color);

		// titlebar
		titlebar.redraw (fill, box.width+10);

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
		parent.setChildIndex (this, parent.numChildren - 1);
	}
}
