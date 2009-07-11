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
import haxegui.Component;
import haxegui.managers.CursorManager;
import haxegui.managers.StyleManager;
import haxegui.Opts;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;
import haxegui.IAdjustable;


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
	static function __init__() {
		haxegui.Haxegui.register(ScrollBarHandle);
	}
}


/**
*
* ScrollBarFrame Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class ScrollBarFrame extends Component
{
	static function __init__() {
		haxegui.Haxegui.register(ScrollBarFrame);
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
class ScrollBar extends Component
{

	public var frame	 			: 	ScrollBarFrame;
	public var handle	 			: 	ScrollBarHandle;
	public var up 		  			:	ScrollBarUpButton;
	public var down 	 			:	ScrollBarDownButton;
	
	/** The scroll target **/
	public var scrollee	 			:	Dynamic;
	/** Percent of scroll **/
	public var scroll	  			:	Float;
	//public var adjustment			:	Adjustment;
	
	public var horizontal			:	Bool;

	public var handleMotionTween 	:	Tween;


	/**
	* @param opts.target Object to scroll, either a DisplayObject or TextField
	*/
	override public function init(opts:Dynamic=null) {
		color = DefaultStyle.BACKGROUND;
		scroll = 0;
		scrollee = null;
		box = new Rectangle(0,0,20,80);	
		horizontal = false;
		
		super.init(opts);

		horizontal = Opts.optBool(opts, "horizontal", horizontal);
		if(horizontal) 
			rotation = -90;
		
		// Silently notify only when target is missing 	
		if(scrollee!=null)
		try {
			this.scrollee = Opts.classInstance(opts, "target", untyped [TextField, DisplayObject]);
		}
		catch(s:String) { 
			//trace(s); 
			var a = new haxegui.Alert();
			a.init({label: this+"."+here.methodName+":\n\n\n"+s});
		}

		// 
		frame = new ScrollBarFrame(this);
		frame.init({color: this.color});
		frame.focusRect = false;
		frame.tabEnabled = false;
		frame.text = null;

		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 8, 8, disabled ? .35 : .75, BitmapFilterQuality.HIGH, true, false, false);
		frame.filters = [shadow];

		//
		handle = new ScrollBarHandle(this);
		handle.init({y: 20, color: this.color, disabled: this.disabled});
		handle.redraw({h : 20, horizontal: this.horizontal });

		shadow = new DropShadowFilter (0, 0, DefaultStyle.DROPSHADOW, 0.75, horizontal ? 8 : 0, horizontal ? 0 : 8, disabled ? .35 : .75, BitmapFilterQuality.LOW, false, false, false);
		handle.filters = [shadow];

		//
		up = new ScrollBarUpButton(this);
		up.init({color: this.color, disabled: this.disabled});

		//
		down = new ScrollBarDownButton(this);
		down.init({color: this.color, disabled: this.disabled});
		down.move(0, box.height - 20);

		//
		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);
		this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 0, true);

	}



	/**
	*
	*
	*
	*/
	public function onParentResize(e:ResizeEvent)
	{

		if(Std.is(parent, Component)) untyped {
			if(horizontal) {
				box.height = parent.box.width;
				this.y = parent.box.height + 20;
				}
			else {
				box.height = parent.box.height;
				this.x = parent.box.width ;
			}
		}
		down.y = Math.max( 20, box.height - 20);
		
		dirty = true;
		frame.dirty = true;
		handle.dirty = true;

			//~ if(Std.is(scrollee, DisplayObject))
			//~ {
				//~ if(handle.y>20)
					//~ handle.y = scroll * ( frame.height - handle.height + 2) + 20;
			//~ }


	}


	public override function onMouseWheel(e:MouseEvent)	{

		//~ var y = handle.y + 50 * e.delta;
		var y = handle.y + 50 * -e.delta;
		if( y < 20 ) y = 20;
		if( y > box.height - handle.height + 20) y = box.height - handle.height + 20;

		if(handleMotionTween!=null)
			handleMotionTween.stop();

		handleMotionTween = new Tween( handle.y, y, 1000, handle, "y", feffects.easing.Expo.easeOut );
		var self = this;
		handleMotionTween.setTweenHandlers( function(v) { self.adjust(); } );
		handleMotionTween.start();
		
		super.onMouseWheel(e);
	}




	public function onMouseMove(e:MouseEvent) {
		//~ if(e.buttonDown)
			adjust();
	}


	/**
	*
	*
	*/
	public function adjust(?e:Dynamic) {
		if(!scrollee) return;

		if(scroll<0 || handle.y < 20) {
			scroll=0;
			handle.y = 20;
			return;
		}

		if(scroll>1 || handle.y > (frame.height - handle.height + 20)) {
			scroll=1;
			handle.y = frame.height - handle.height + 20;
			return;
		}


		if(Std.is(scrollee, TextField))	{
			scroll = (handle.y-20) / (frame.height - handle.height + 2) ;
			if(horizontal)
				scrollee.scrollH = scrollee.maxScrollH * scroll;
			else
				scrollee.scrollV = scrollee.maxScrollV * scroll;

			return;
		}

		if(Std.is(scrollee, DisplayObject))	{
			if(scrollee.scrollRect==null || scrollee.scrollRect.isEmpty()) return;

			var rect = scrollee.scrollRect.clone();

			var transform = scrollee.transform;
			var bounds = transform.pixelBounds.clone();

			scroll = (handle.y-20) / (frame.height - handle.height + 2) ;

			if(horizontal)
				rect.x = ( bounds.width - rect.width ) * scroll ;
			else
				rect.y = ( bounds.height - rect.height ) * scroll ;

			scrollee.scrollRect = rect;
			//~ trace(Std.int(scrollee.scrollRect.y)+"/"+(bounds.height)+" "+Std.int(100*scroll)+"% "+rect);
		}

	}

	static function __init__() {
		haxegui.Haxegui.register(ScrollBar,initialize);
	}

	static function initialize() {
	}

}
