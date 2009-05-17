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

package haxegui.controls;

import feffects.Tween;

import flash.geom.Rectangle;
import flash.geom.Transform;
import flash.text.TextField;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;

import haxegui.CursorManager;
import haxegui.Opts;
import haxegui.StyleManager;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;

enum ScrollBarType {
	VERTICAL;
	HORIZONTAL;
}



/**
*
* ScrollBarUpButton Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class ScrollBarUpButton extends AbstractButton
{
	public function new(?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float) {
		super (parent, name, x, y);
		this.addEventListener(MouseEvent.CLICK,onMouseClick,false,0,true);
	}

	static function __init__() {
		haxegui.Haxegui.register(ScrollBarUpButton);
	}
}



/**
*
* ScrollBarDownButton Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class ScrollBarDownButton extends AbstractButton
{
	public function new(?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float) {
		super (parent, name, x, y);
		this.addEventListener(MouseEvent.CLICK,onMouseClick,false,0,true);
	}

	static function __init__() {
		haxegui.Haxegui.register(ScrollBarDownButton);
	}
}

/**
*
* ScrollBarHandle Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class ScrollBarHandle extends AbstractButton
{
	public function new(?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float) {
		super (parent, name, x, y);
		this.addEventListener(MouseEvent.CLICK,onMouseClick,false,0,true);
	}

	static function __init__() {
		haxegui.Haxegui.register(ScrollBarHandle);
	}
}

/**
*
* ScrollBar class
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class ScrollBar extends haxegui.controls.Component
{

	var frame : Component;
	var handle : ScrollBarHandle;
	var up : ScrollBarUpButton;
	var down : ScrollBarDownButton;
	public var scrollee : Dynamic;
	public var scroll : Float;
	var horizontal : Bool;

	private var handleMotionTween : Tween;

	public function new(?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float, ?horz : Bool)
	{
		super(parent, name, x, y);
		horizontal = horz;
		if(horizontal)
			rotation = -90;
	}


	/**
	* @param opts.target Object to scroll, either a DisplayObject or TextField
	*/
	override public function init(opts:Dynamic=null)
	{
		super.init(opts);

		scroll = 0;
		//~ box = new Rectangle(0,0,20,90);
		this.scrollee = Opts.classInstance(opts, "target", untyped [TextField, DisplayObject]);

		frame = new Component(this, "frame", 0, 20);
		frame.init({color: this.color});
		//~ frame.mouseEnabled = false;
		frame.buttonMode = false;
		frame.focusRect = false;
		frame.tabEnabled = false;


		frame.graphics.beginFill (color - 0x0A0A0A);
		frame.graphics.drawRect (0, 0, box.width, box.height - 40 );
		frame.graphics.endFill ();

		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 8, 8, .75, BitmapFilterQuality.HIGH, true, false, false);
		frame.filters = [shadow];


		handle = new ScrollBarHandle(this, "handle", 0, 20);
		handle.init({color: this.color});
		handle.redraw({h : 20, horizontal: this.horizontal });

		shadow = new DropShadowFilter (0, 0, DefaultStyle.DROPSHADOW, 0.75, horizontal ? 8 : 0, horizontal ? 0 : 8, 0.75, BitmapFilterQuality.LOW, false, false, false);
		handle.filters = [shadow];

		handle.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
		handle.addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);


		up = new ScrollBarUpButton(this, "up" );
		up.init({color: this.color});
		up.redraw({color: this.color});

		down = new ScrollBarDownButton(this, "down" );
		down.init({color: this.color});
		down.move(0, box.height - 20);
		down.redraw({color: this.color});

		//~ var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 4, 4, .75, BitmapFilterQuality.HIGH, true, false, false);
		//~ down.filters = [shadow];


		up.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
		up.addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
		down.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
		down.addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);

		this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 0, true);

		//
		parent.addEventListener(ResizeEvent.RESIZE, onResize, false, 0, true);




	}//init



	/**
	*
	*
	* @param
	*
	*/
	override public function onResize(e:ResizeEvent)
	{

		//~ if(box.isEmpty())
		box = untyped parent.box.clone();

		//~ up.redraw({color: this.color});
		//~ down.redraw({color: this.color});
		//~ handle.redraw({h : 20 + .5*(frame.height - handle.height + 20), color: this.color, horizontal: this.horizontal });
		handle.redraw({h : 40, color: this.color, horizontal: this.horizontal });

		dirty = true;


		frame.graphics.clear();

		frame.graphics.beginFill (color - 0x0A0A0A);

		if(horizontal)
		{
			this.y = box.height + 20;
			down.y = box.width - 20;
			frame.graphics.drawRect (0, 0, 20, box.width - 40 );
		}
		else
		{
			this.x = box.width ;
			down.y = box.height - 20 ;

			frame.graphics.drawRect (0, 0, 20, box.height - 40 );
			//~ adjust();

			if(Std.is(scrollee, DisplayObject))
			{
				if(handle.y>20)
					handle.y = scroll * ( frame.height - handle.height + 2) + 20;
			}

		}

		frame.graphics.endFill ();


		if(e != null)
			e.updateAfterEvent();

	}


	public function onMouseWheel(e:MouseEvent)
	{

		//~ redrawHandle(color | 0x666666);

		//~ var y = handle.y + 50 * e.delta;
		var y = handle.y + 50 * -e.delta;
		if( y < 20 ) y = 20;
		if( y > frame.height - handle.height + 20) y = frame.height - handle.height + 20;
		//~ e.target.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		//~ var t = new Tween( handle.y, handle.y - 50, 500, handle, "y", Linear.easeNone );

		if(handleMotionTween!=null)
			handleMotionTween.stop();

		handleMotionTween = new Tween( handle.y, y, 1000, handle, "y", feffects.easing.Expo.easeOut );
		var scope = this;
		handleMotionTween.setTweenHandlers( function ( e ) { scope.adjust(); } );
		handleMotionTween.start();
	}

	override public function onMouseDown(e:MouseEvent)
	{
		//~ redrawHandle(color | 0x4D4D4D);


		switch(e.target)
			{
			case handle:
				//~ redrawHandle( color | 0x666666);
				if(horizontal)
					e.target.startDrag(false,new Rectangle(0,up.height-2, 0, box.width - 2*down.height - handle.height + 4));
				else
					e.target.startDrag(false,new Rectangle(0,up.height-2, 0, box.height - 2*down.height - handle.height + 4));

				//~ e.target.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
				flash.Lib.current.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);

				CursorManager.setCursor (Cursor.DRAG);

			case up:
				var y = handle.y - 50;
				if( y < 20 ) y = 20;
				//~ e.target.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
				//~ var t = new Tween( handle.y, handle.y - 50, 500, handle, "y", Linear.easeNone );
				if(handleMotionTween!=null)
					handleMotionTween.stop();

				handleMotionTween = new Tween( handle.y, y, 1500, handle, "y", feffects.easing.Expo.easeOut );
				var scope = this;
				handleMotionTween.setTweenHandlers( function ( e ) { scope.adjust(); } );
				handleMotionTween.start();
				//~ t.setTweenHandlers( function ( e ) scope.update( sprite, e ) );

				CursorManager.setCursor (Cursor.HAND2);

			case down:
				var y = handle.y + 50;
				if( y > frame.height - handle.height + 20) y = frame.height - handle.height + 20;


				//~ e.target.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
				if(handleMotionTween!=null)
					handleMotionTween.stop();


				handleMotionTween = new Tween( handle.y, y, 1500, handle, "y", feffects.easing.Expo.easeOut );
				var scope = this;
				handleMotionTween.setTweenHandlers( function ( e ) { scope.adjust(e); } );
				handleMotionTween.start();

				CursorManager.setCursor (Cursor.HAND2);

			case frame:
				CursorManager.setCursor (Cursor.HAND2);

				var y = e.target.mouseY ;
				if(y+handle.height+20 > frame.height ) y = frame.height - handle.height + 20;

				if(handleMotionTween!=null)
					handleMotionTween.stop();


				handleMotionTween = new Tween( handle.y, y, 500, handle, "y", feffects.easing.Back.easeInOut );
				var scope = this;
				handleMotionTween.setTweenHandlers( function ( e ) { scope.adjust(e); } );
				handleMotionTween.start();

				haxe.Timer.delay( function(){CursorManager.setCursor (Cursor.DRAG);}, 500 );

				if(horizontal)
					handle.startDrag(false,new Rectangle(0,up.height-2, 0, box.width - 2*down.height - handle.height + 4));
				else
					handle.startDrag(false,new Rectangle(0,up.height-2, 0, box.height - 2*down.height - handle.height + 4));

				flash.Lib.current.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			}
		adjust();
		//~ e.stopImmediatePropagation ();
		e.updateAfterEvent ();

	}


	/**
	*
	* @param
	*
	*/
	public function onEnterFrame(e:Event)
	{
		switch(e.target)
		{
			case up:
				//~ handle.y -= ( frame.height - handle.height ) / 20 ;
				handle.y -=2 ;
			case down:
		//~ }		handle.y += ( frame.height - handle.height ) / 20 ;
		}		handle.y ++ ;

		adjust();
	}


	override public function onMouseUp(e:MouseEvent)
	{

		var c = 0;

		if(e.target.hitTestObject( CursorManager.getInstance()._mc ))
		{
			//~ redrawHandle(color | 0x4D4D4D);
			c = 50;
			CursorManager.setCursor (Cursor.HAND);
		}

	}


	public function onMouseMove(e:MouseEvent)
	{
		//~ if(e.buttonDown)
			adjust();
	}


	/**
	*
	* @param
	*
	*/
	public function adjust(?e:Dynamic)
	{
		if(!scrollee) return;

		if(scroll<0 || handle.y < 20)
		{
			scroll=0;
			handle.y = 20;
			return;
		}


		if(scroll>1 || handle.y > frame.height - handle.height + 20)
		{
			scroll=1;
			handle.y = frame.height - handle.height + 20;
			return;
		}


		if(Std.is(scrollee, TextField))
		{
			scroll = (handle.y-20) / (frame.height - handle.height + 2) ;
			if(horizontal)
				scrollee.scrollH = scrollee.maxScrollH * scroll;
			else
				scrollee.scrollV = scrollee.maxScrollV * scroll;

			return;
		}

		if(Std.is(scrollee, DisplayObject))
		{
			if(scrollee.scrollRect==null || scrollee.scrollRect.isEmpty()) return;

			var rect = scrollee.scrollRect.clone();

			var transform = scrollee.transform;
			var bounds = transform.pixelBounds.clone();

			scroll = (handle.y-20) / (frame.height - handle.height + 2) ;

			if(horizontal)
			{
				rect.x = ( bounds.width - rect.width ) * scroll ;
			}
			else
			{
				rect.y = ( bounds.height - rect.height ) * scroll ;
			}

			scrollee.scrollRect = rect;
			//~ trace(Std.int(scrollee.scrollRect.y)+"/"+(bounds.height)+" "+Std.int(100*scroll)+"% "+rect);
		}

	}//adjust



	static function __init__() {
		haxegui.Haxegui.register(ScrollBar,initialize);
	}
	static function initialize() {
	}



}//ScrollBar
