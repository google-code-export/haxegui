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

import flash.geom.Point;
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
import haxegui.controls.AbstractButton;
import haxegui.controls.Component;
import haxegui.managers.CursorManager;
import haxegui.managers.StyleManager;
import haxegui.utils.Opts;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;
import haxegui.controls.IAdjustable;
import haxegui.utils.Size;
import haxegui.utils.Color;
import feffects.Tween;


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
	override public function onResize(e:ResizeEvent) : Void {
		this.box.width = (cast parent).box.width;
		this.box.height = Math.max(20, this.box.height);
		this.box.height = Math.min(this.box.height, (cast parent).box.height - this.y);
	}


	public function onMouseMove(e:MouseEvent) {
		this.x=parent.x;
	}
	
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
class ScrollBarFrame extends AbstractButton
{	
	override public function init(opts:Dynamic=null) {
		super.init(opts);
		setAction("mouseOver","");
		setAction("mouseOut","");
		setAction("mouseDown","");
		setAction("mouseUp","");
		
	}
	
	static function __init__() {
		haxegui.Haxegui.register(ScrollBarFrame);
	}
}



/**
*
* ScrollBar with handle and buttons.<br/>
* <p></p>
* <pre class="code haxe">
* var scrollbar = new ScrollBar();
* scrollbar.init();
* </pre>
* 
* <i>note: When parented to an [IContainer], it does not resize.</i>
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class ScrollBar extends Component, implements IAdjustable
{

	public var frame	 			: 	ScrollBarFrame;
	public var handle	 			: 	ScrollBarHandle;
	public var up 		  			:	ScrollBarUpButton;
	public var down 	 			:	ScrollBarDownButton;
	
	/** The scroll target **/
	public var scrollee	 			:	Dynamic;
	/** Percent of scroll **/
	public var scroll	  			:	Float;
	/** the adjustment for this scrollbar **/
	public var adjustment	:	Adjustment;
	/** true for horizontal scrollbar **/
	public var horizontal			:	Bool;

	/**
	* @param opts.target Object to scroll, either a DisplayObject or TextField
	*/
	override public function init(opts:Dynamic=null) {
		color = DefaultStyle.BACKGROUND;
		scroll = 0;
		scrollee = null;
		adjustment = new Adjustment({ value: .0, min: Math.NEGATIVE_INFINITY, max: Math.POSITIVE_INFINITY, step: 50., page: 100.});
		box = new Size(20,80).toRect();	
		horizontal = false;
		
		super.init(opts);

		horizontal = Opts.optBool(opts, "horizontal", horizontal);
		if(horizontal) 
			rotation = -90;
		
		// Silently notify only when target is missing 	
		try {
			this.scrollee = Opts.classInstance(opts, "target", untyped [TextField, DisplayObject]);
		}
		catch(s:String) { 
			trace(s); 
			//~ var a = new haxegui.Alert();
			//~ a.init({label: this+"."+here.methodName+":\n\n\n"+s});
		}

		// 
		frame = new ScrollBarFrame(this);
		frame.init({color: this.color});
		frame.focusRect = false;
		frame.tabEnabled = false;
		frame.description = null;
		frame.filters = [new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 8, 8, disabled ? .35 : .75, BitmapFilterQuality.HIGH, true, false, false)];

		//
		handle = new ScrollBarHandle(this);
		handle.init({y: 20, color: this.color, disabled: this.disabled, horizontal: this.horizontal , width: this.box.width, height : 40});
		handle.filters = [new DropShadowFilter (0, 0, DefaultStyle.DROPSHADOW, 0.75, horizontal ? 8 : 0, horizontal ? 0 : 8, disabled ? .35 : .75, BitmapFilterQuality.LOW, false, false, false)];

		//
		up = new ScrollBarUpButton(this);
		up.init({color: this.color, disabled: this.disabled});

		//
		down = new ScrollBarDownButton(this);
		down.init({color: this.color, disabled: this.disabled});
		down.move(0, box.height - 20);

		//
		frame.addEventListener(MoveEvent.MOVE, onFrameMoved, false, 0, true);
		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);
		this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 0, true);

	}

	private function onFrameMoved(e:MoveEvent) {
		move(frame.x, frame.y);
		e.target.removeEventListener(MoveEvent.MOVE, onFrameMoved);
		e.target.moveTo(0,0);
		e.target.addEventListener(MoveEvent.MOVE, onFrameMoved, false, 0, true);		
			
	}


	/**
	*
	*
	*
	*/
	public function onParentResize(e:ResizeEvent)
	{
		if(Std.is(parent, haxegui.containers.IContainer)) return;
		
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
		//handle.box = new Size(20, 40).toRect();
		handle.y = Math.max( 20, Math.min( handle.y, this.box.height - handle.box.height - 20));
		
		dirty = true;
		frame.dirty = true;
		handle.dirty = true;

	}


	public override function onMouseWheel(e:MouseEvent)	{
		var self = this;
		var handleMotionTween = new Tween( 0, 1, 1000, feffects.easing.Expo.easeOut );
		handle.updatePositionTween( handleMotionTween, 
									new Point(0, e.delta * (horizontal ? 1 : -1)* adjustment.object.page),
									function(v) { self.adjust(); } );

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
	public function adjust(?v:Float) : Float {
		if(!scrollee) return scroll;

		if(scroll<0 || handle.y < 20) {
			scroll=0;
			handle.updatePositionTween();
			handle.moveTo(0,20);
			return scroll;
		}

		if(scroll>1 || handle.y > (box.height - handle.box.height - 20)) {
			scroll=1;
			handle.updatePositionTween();		
			handle.moveTo(0, box.height - handle.box.height - 20);
			adjustment.setValue(scroll);
			return scroll;
		}


		if(Std.is(scrollee, TextField))	{
			scroll = (handle.y-20) / (frame.box.height - handle.box.height + 2) ;
			if(horizontal)
				scrollee.scrollH = scrollee.maxScrollH * scroll;
			else
				scrollee.scrollV = scrollee.maxScrollV * scroll;
			return scroll;
		}

		//~ if(Std.is(scrollee, DisplayObject))	{
			if(scrollee.scrollRect==null || scrollee.scrollRect.isEmpty()) return scroll;

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
		//~ }

		return scroll;
		
	}

	static function __init__() {
		haxegui.Haxegui.register(ScrollBar,initialize);
	}

	static function initialize() {
	}

}
