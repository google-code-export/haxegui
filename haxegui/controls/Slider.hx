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
import haxegui.controls.Component;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;
import haxegui.managers.CursorManager;
import haxegui.managers.FocusManager;
import haxegui.managers.StyleManager;
import haxegui.managers.TooltipManager;
import haxegui.controls.IAdjustable;
import haxegui.controls.Component;
import haxegui.toys.Socket;
import haxegui.utils.Size;
import haxegui.utils.Color;
import haxegui.utils.Opts;

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
	override public function init(opts:Dynamic=null) {
		box = new Rectangle(0, 0, 24, 10);
		super.init(opts);		
	}
	
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
class Slider extends Component, implements IAdjustable
{
	/** Slider handle **/
	public var handle : SliderHandle;
	
	/** Adjustment object **/
	public var adjustment : Adjustment;

	/** Number of ticks **/
	public var ticks : Int;

	/** slot **/
	public var slot : Socket;

	/** true to show value in tooltip while dragging the handle **/
	public var showToolTip: Bool;
	
	override public function init(opts:Dynamic=null) {
		//adjustment = new Adjustment( 0, 0, Math.POSITIVE_INFINITY, 5, 10 );
		adjustment = new Adjustment({ value: .0, min: Math.NEGATIVE_INFINITY, max: Math.POSITIVE_INFINITY, step: 5., page: 10.});
		box = new Size(140, 20).toRect();
		color = DefaultStyle.BACKGROUND;
		ticks = 25;
		description = null;
		showToolTip = true;
		
		adjustment.object.value = Opts.optFloat(opts,"value", adjustment.object.value);
		adjustment.object.min = Opts.optFloat(opts,"min", adjustment.object.min);
		adjustment.object.max = Opts.optFloat(opts,"max", adjustment.object.max);
		adjustment.object.step = Opts.optFloat(opts,"step", adjustment.object.step);
		adjustment.object.page = Opts.optFloat(opts,"page", adjustment.object.page);
		
		showToolTip = Opts.optBool(opts,"showToolTip", showToolTip);
		
		super.init(opts);

		handle = new SliderHandle(this);
		handle.init({color: this.color, disabled: this.disabled });
		handle.move(0,4);

		// add the drop-shadow filters
		var shadow = new flash.filters.DropShadowFilter (disabled ? 1 : 2, 45, DefaultStyle.DROPSHADOW, disabled ? 0.25 : 0.5, 4, 4, disabled ?  0.25 : 0.5, flash.filters.BitmapFilterQuality.LOW, false, false, false );
		handle.filters = [shadow];

		if(!disabled) {
			slot = new haxegui.toys.Socket(this);
			slot.init();
			slot.moveTo(-14,Std.int(this.box.height)>>1);
	
			slot.color = Color.tint(slot.color, .5);
		}
		
		//addEventListener (MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 0, true);

		handle.addEventListener (MouseEvent.MOUSE_DOWN, onHandleMouseDown, false, 0, true);
		//~ handle.addEventListener (MouseEvent.MOUSE_UP,   onMouseUp, false, 0, true);
		//~ handle.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);

		//~ this.addEventListener (Event.CHANGE, onChanged, false, 0, true);
		adjustment.addEventListener (Event.CHANGE, onChanged, false, 0, true);

	}
	



	public override function destroy() {
	/*		
		handle.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		handle.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);

		if(handle.stage.hasEventListener (MouseEvent.MOUSE_UP))
			handle.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);

		if(handle.stage.hasEventListener (MouseEvent.MOUSE_MOVE))
			handle.stage.removeEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
	*/					
		super.destroy();
	}

	public function onChanged(e:Event) {
		handle.x = Math.max(0, Math.min( box.width- handle.box.width, adjustment.getValue()));
	}

	function onHandleMouseDown (e:MouseEvent) : Void {
		if(this.disabled) return;
		if(e.target!=handle) return;
		CursorManager.setCursor (Cursor.DRAG);
		CursorManager.getInstance().lock = true;
		handle.startDrag(false,new Rectangle(0, e.target.y, box.width - handle.box.width ,0));
		e.target.stage.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);	

		handle.addEventListener (MouseEvent.MOUSE_UP,   onMouseUp, false, 0, true);
		handle.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);

		if(!showToolTip) return;
		tooltip = new Tooltip(handle);
		tooltip.label.setText(adjustment.valueAsString().substr(0,5));	
		tooltip.balloon.box.width = tooltip.label.width + 24;
		tooltip.label.move(4,0);
		tooltip.balloon.redraw();
		tooltip.alpha=.8;
		tooltip.fadeTween.stop();
		tooltip.visible = true;
		tooltip.alpha = 1;
		tooltip.redraw();
	}


	override public function onMouseUp (e:MouseEvent) : Void {
		if(this.disabled) return;	

		if(e.target.stage.hasEventListener (MouseEvent.MOUSE_UP))
			e.target.removeEventListener (MouseEvent.MOUSE_UP, onMouseUp);

		if(e.target.stage.hasEventListener (MouseEvent.MOUSE_MOVE))
			e.target.stage.removeEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
		
		CursorManager.getInstance().lock = false;
		if(hitTestObject( CursorManager.getInstance()._mc ))
			CursorManager.setCursor (Cursor.ARROW);

		handle.stopDrag();
		
		if(tooltip!=null)
			tooltip.destroy();
		
		super.onMouseUp(e);
	}

	public function onMouseMove (e:MouseEvent) {
		adjustment.object.value = handle.x;
		adjustment.adjust(adjustment.object);
		if(tooltip!=null) {
			tooltip.label.setText(adjustment.valueAsString());	
			tooltip.box.width = tooltip.label.width + 8;
			tooltip.redraw();
		}
	}
	
	public override function onResize(e:ResizeEvent) {
		
		//~ handle.dirty = true;
		handle.box.height = Std.int(box.height)>>1;
		
		handle.redraw();
		
		handle.y = Std.int( this.box.height - handle.height )>>1;
		handle.x = Math.max(0, Math.min( box.width - handle.box.width, handle.x ));
		
		if(slot!=null)
			slot.y = Std.int( this.box.height - slot.box.height )>>1;
		super.onResize(e);
	}

	static function __init__() {
		haxegui.Haxegui.register(Slider);
	}
}
