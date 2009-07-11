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

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.FocusEvent;
import flash.geom.Rectangle;
import haxegui.Component;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;
import haxegui.managers.CursorManager;
import haxegui.managers.FocusManager;
import haxegui.managers.StyleManager;
import haxegui.managers.TooltipManager;
import haxegui.Opts;
import haxegui.IAdjustable;

/**
*
* Draggable handle to slide values.
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class SliderHandle extends AbstractButton
{
	static function __init__() {
		haxegui.Haxegui.register(SliderHandle);
	}
}

/**
*
* Slider Class
*
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class Slider extends Component, implements haxegui.IAdjustable
{
	/** Slider handle **/
	public var handle : SliderHandle;
	
	/** Adjustment object **/
	public var adjustment : Adjustment;

	/** Number of ticks **/
	public var ticks : Int;


	override public function init(opts:Dynamic=null) {
		adjustment = new Adjustment( 0, 0, 110, 5, 10 );
		box = new Rectangle(0, 0, 140, 20);
		color = DefaultStyle.BACKGROUND;
		ticks = 25;
		
		adjustment.value = Opts.optFloat(opts,"value", adjustment.value);
		adjustment.min = Opts.optFloat(opts,"min", adjustment.min);
		adjustment.max = Opts.optFloat(opts,"max", adjustment.max);
		adjustment.step = Opts.optFloat(opts,"step", adjustment.step);
		adjustment.page = Opts.optFloat(opts,"page", adjustment.page);

		super.init(opts);

		handle = new SliderHandle(this);
		handle.init({color: this.color, disabled: this.disabled });
		handle.move(0,4);

		// add the drop-shadow filters
		var shadow = new flash.filters.DropShadowFilter (disabled ? 1 : 2, 45, DefaultStyle.DROPSHADOW, disabled ? 0.25 : 0.5, 4, 4, disabled ?  0.25 : 0.5, flash.filters.BitmapFilterQuality.LOW, false, false, false );
		handle.filters = [shadow];


		//addEventListener (MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 0, true);

		handle.addEventListener (MouseEvent.MOUSE_DOWN, onHandleMouseDown, false, 0, true);
		handle.addEventListener (MouseEvent.MOUSE_UP,   onMouseUp, false, 0, true);
		handle.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);

		//~ this.addEventListener (Event.CHANGE, onChanged, false, 0, true);
		adjustment.addEventListener (Event.CHANGE, onChanged, false, 0, true);

	}

	public override function destroy() {
		handle.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		handle.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);

		if(this.stage.hasEventListener (MouseEvent.MOUSE_UP))
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);

		
		if(this.stage.hasEventListener (MouseEvent.MOUSE_MOVE))
			this.stage.removeEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
				
		super.destroy();
	}

	public function onChanged(e:Event) {
		handle.x = adjustment.value;
	}


	function onHandleMouseDown (e:MouseEvent) : Void {
		if(this.disabled) return;
		CursorManager.setCursor (Cursor.DRAG);
		CursorManager.getInstance().lock = true;
		handle.startDrag(false,new Rectangle(0, e.target.y, box.width - handle.width ,0));
		e.target.stage.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
	}

	override public function onMouseUp (e:MouseEvent) : Void {
		if(this.disabled) return;	

		e.target.removeEventListener (MouseEvent.MOUSE_UP, onMouseUp);

		if(this.stage.hasEventListener (MouseEvent.MOUSE_MOVE))
			e.target.stage.removeEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
		
		CursorManager.getInstance().lock = false;
		if(hitTestObject( CursorManager.getInstance()._mc ))
			CursorManager.setCursor (Cursor.ARROW);

		handle.stopDrag();
		
		super.onMouseUp(cast e.clone());
	}


	public function onMouseMove (e:MouseEvent) {
		adjustment.value = handle.x;
	}


	static function __init__() {
		haxegui.Haxegui.register(Slider);
	}

	
	public override function onResize(e:ResizeEvent) {
		
		//~ handle.dirty = true;
		handle.redraw();
		handle.y = .5*( this.box.height - handle.height );
		
		super.onResize(cast e.clone());
	}
	
}
