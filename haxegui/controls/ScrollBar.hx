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

//{{{ Import
import feffects.Tween;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.DropShadowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Transform;
import flash.text.TextField;
import haxegui.controls.AbstractButton;
import haxegui.controls.Component;
import haxegui.controls.IAdjustable;
import haxegui.events.DragEvent;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.managers.CursorManager;
import haxegui.managers.StyleManager;
import haxegui.toys.Socket;
import haxegui.utils.Color;
import haxegui.utils.Opts;
import haxegui.utils.Size;
//}}}


using haxegui.controls.Component;


//{{{ ScrollBarUpButton
/**
*
* Button for scrolling up.<br/>
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class ScrollBarUpButton extends AbstractButton, implements IAggregate
{
	static function __init__() {
		haxegui.Haxegui.register(ScrollBarUpButton);
	}
}
//}}}

//{{{ ScrollBarDownButton
/**
*
* Button for scrolling down.<br/>
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class ScrollBarDownButton extends AbstractButton, implements IAggregate
{
	static function __init__() {
		haxegui.Haxegui.register(ScrollBarDownButton);
	}
}
//}}}

//{{{ ScrollBarHandle
/**
*
* Draggable handle for a [ScrollBar].<br/>
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class ScrollBarHandle extends AbstractButton, implements IComposite {
	//{{{ onResize
	override public function onResize(e:ResizeEvent) : Void {
		box.width =  parent.asComponent().box.width;
		box.height = Math.max(20, box.height);
		box.height = Math.min(box.height, parent.asComponent().box.height - y);
	}
	//}}}


	//{{ onMouseMove
	public function onMouseMove(e:MouseEvent) {
		this.x=parent.x;
	}
	//}}}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(ScrollBarHandle);
	}
	//}}}
}
//}}}

//{{{ ScrollBarFrame
/**
*
* ScrollBarFrame Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class ScrollBarFrame extends AbstractButton, implements IComposite {
	//{{{ init
	override public function init(opts:Dynamic=null) {
		super.init(opts);
		setAction("mouseOver","");
		setAction("mouseOut","");
		setAction("mouseDown","");
		setAction("mouseUp","");

	}
	//}}}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(ScrollBarFrame);
	}
	//}}}
}
//}}}

//{{{ ScrollBar
/**
*
* ScrollBar with handle and buttons.<br/>
* <p></p>
* <pre class="code haxe">
* var scrollbar = new ScrollBar();
* scrollbar.init();
* </pre>
*
* <i>note: When parented to anything other than a [ScrollPane], it does not resize automatically.</i>
*
* @todo fix problems when adding extra buttons
* @todo handle resizing to reflect content's height
* @todo adjustment...
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class ScrollBar extends Component, implements IAdjustable {
	//{{{ Members
	public var frame	 			: 	ScrollBarFrame;
	public var handle	 			: 	ScrollBarHandle;
	public var up 		  			:	ScrollBarUpButton;
	public var down 	 			:	ScrollBarDownButton;

	/** The scroll target **/
	public var scrollee	 			:	Dynamic;
	/** Percent of scroll **/
	public var scroll	  			:	Float;
	/** the adjustment for this scrollbar **/
	public var adjustment			:	Adjustment;
	/** true for horizontal scrollbar **/
	public var horizontal			:	Bool;

	public var slot					: 	Socket;
	//}}}

	//{{{ Functions
	//{{{ init
	/**
	* @param opts.target Object to scroll, either a DisplayObject or TextField
	*/
	override public function init(opts:Dynamic=null) {
		adjustment = new Adjustment({ value: .0, min: Math.NEGATIVE_INFINITY, max: Math.POSITIVE_INFINITY, step: 50., page: 100.});
		box = new Size(20,80).toRect();
		color = DefaultStyle.BACKGROUND;
		horizontal = false;
		scroll = 0;
		scrollee = null;


		// adjustment.object.value = Opts.optFloat(opts, "value", adjustment.object.value);
		// adjustment.object.min   = Opts.optFloat(opts, "min",   adjustment.object.min);
		// adjustment.object.max   = Opts.optFloat(opts, "max",   adjustment.object.max);
		// adjustment.object.step  = Opts.optFloat(opts, "step",  adjustment.object.step);
		// adjustment.object.page  = Opts.optFloat(opts, "page",  adjustment.object.page);

		scroll = Opts.optFloat(opts, "scroll",  scroll);


		super.init(opts);


		// horizontal scrollbar
		horizontal = Opts.optBool(opts, "horizontal", horizontal);
		if(horizontal)
		rotation = -90;

		// Silently notify only when target is missing
		try {
			scrollee = Opts.classInstance(opts, "target", untyped [TextField, DisplayObject]);
		}
		catch(s:String) {
			trace(s);
			//~ var a = new haxegui.Alert();
			//~ a.init({label: this+"."+here.methodName+":\n\n\n"+s});
		}


		// frame
		frame = new ScrollBarFrame(this);
		frame.init({color: this.color});
		frame.focusRect = false;
		frame.tabEnabled = false;
		frame.description = null;
		frame.filters = [new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 8, 8, disabled ? .35 : .75, BitmapFilterQuality.HIGH, true, false, false)];


		// handle
		handle = new ScrollBarHandle(this);
		var _y = 20 + scroll * (box.height - 40 - 40) ;
		handle.init({y: _y, color: this.color, disabled: this.disabled, horizontal: this.horizontal , width: this.box.width, height : 40});
		handle.filters = [new DropShadowFilter (0, 0, DefaultStyle.DROPSHADOW, 0.75, horizontal ? 8 : 0, horizontal ? 0 : 8, disabled ? .35 : .75, BitmapFilterQuality.LOW, false, false, false)];


		// up button
		up = new ScrollBarUpButton(this);
		up.init({color: this.color, disabled: this.disabled});


		// down button
		down = new ScrollBarDownButton(this);
		down.init({color: this.color, disabled: this.disabled});
		down.move(0, box.height - 20);


		//
		frame.addEventListener(MoveEvent.MOVE, onFrameMoved, false, 0, true);
		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);


		addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 0, true);
	}
	//}}}


	//{{{ onFrameMoved
	private function onFrameMoved(e:MoveEvent) {
		move(frame.x, frame.y);
		e.target.removeEventListener(MoveEvent.MOVE, onFrameMoved);
		e.target.moveTo(0,0);
		e.target.addEventListener(MoveEvent.MOVE, onFrameMoved, false, 0, true);

	}
	//}}}


	//{{{ onParentResize
	/**
	* When parented to a [ScrollPane] scrollbars with stretch to fit.
	*/
	public function onParentResize(e:ResizeEvent) {
		if(!Std.is(parent, haxegui.containers.ScrollPane)) return;

		if(Std.is(parent, Component))
		if(horizontal) {
			box.height = parent.asComponent().box.width;
			this.y = parent.asComponent().box.height + 20;
		}
		else {
			box.height = parent.asComponent().box.height;
			this.x = parent.asComponent().box.width ;
		}


		down.y = Math.max( 20, box.height - 20);
		handle.y = Math.max( 20, Math.min( handle.y, this.box.height - handle.box.height - 20));


		dirty = true;
		frame.dirty = true;
		handle.dirty = true;
	}
	//}}}


	//{{{ onMouseWheel
	public override function onMouseWheel(e:MouseEvent)	{
		if(disabled) return;

		var self = this;
		var handleMotionTween = new Tween( 0, 1, 3000, feffects.easing.Expo.easeOut );
		var offset = e.delta * (horizontal ? 1 : -1)* adjustment.object.page;

		handle.updatePositionTween( handleMotionTween,  new Point(0, offset), function(v) { self.adjust(); } );

		super.onMouseWheel(e);
	}
	//}}}


	//{{{ onMouseMove
	public function onMouseMove(e:MouseEvent) {
		//~ if(e.buttonDown)
		adjust();
	}
	//}}}


	//{{{ adjust
	/**
	* Adjust the scroll on the bar.
	*/
	public function adjust(?v:Float) : Float {
		if(!scrollee) return scroll;

		if(v<0 || scroll<0 || handle.y < 20) {
			handle.updatePositionTween();
			handle.moveTo(0,20);
			adjustment.setValue(scroll=0);
			return scroll;
		}

		if(v>1 || scroll>1 || handle.y > (box.height - handle.box.height - 20)) {
			handle.updatePositionTween();
			handle.moveTo(0, box.height - handle.box.height - 20);
			adjustment.setValue(scroll=1);
			return scroll;
		}


		// handle textfields
		if(Std.is(scrollee, TextField))	{
			scroll = (handle.y-20) / (frame.box.height - handle.box.height + 2) ;
			scrollee.scrollH = (horizontal ? scrollee.maxScrollH : scrollee.maxScrollV) * scroll;
			return scroll;
		}


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

		return scroll;
	}
	//}}}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(ScrollBar);
	}
	//}}}
	//}}}
}
//}}}
