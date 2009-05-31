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

import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.FocusEvent;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.BevelFilter;
import flash.geom.Rectangle;
import haxegui.Component;
import haxegui.managers.CursorManager;
import haxegui.managers.TooltipManager;
import haxegui.Opts;
import haxegui.managers.FocusManager;
import haxegui.managers.StyleManager;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;

class SliderHandle extends AbstractButton
{
	static function __init__() {
		haxegui.Haxegui.register(SliderHandle);
	}
}

class Slider extends Component
{
	public var handle : SliderHandle;
	//~ public var value : Float;
	public var min : Float;
	public var max : Float;
	public var step : Float;

	/** Number of ticks **/
	public var ticks : Int;
	
	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super(parent, name, x, y);
	}

	override public function init(opts:Dynamic=null)
	{
		max = Math.POSITIVE_INFINITY;
		box = new Rectangle(0,0,140,20);
		color = DefaultStyle.BACKGROUND;
		step = 5;
		ticks = 25;
		
		step = Opts.optFloat(opts,"step", step);
		max = Opts.optFloat(opts,"max", max);

		super.init(opts);

		handle = new SliderHandle(this);
		handle.init({color: this.color});
		handle.move(0,4);

		// add the drop-shadow filters
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, BitmapFilterQuality.HIGH, false, false, false );
		handle.filters = [shadow];


		addEventListener (MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 0, true);

		handle.addEventListener (MouseEvent.MOUSE_DOWN, onHandleMouseDown, false, 0, true);
		handle.addEventListener (MouseEvent.MOUSE_UP,   onMouseUp, false, 0, true);
		handle.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);

		this.addEventListener (Event.CHANGE, onChanged, false, 0, true);

	}


	public function onChanged(?e:Event)
	{
		//~ trace(e);
		//~ value = Math.max( min, Math.min( max, value ));
		if(handle.x < 0) handle.x = 0;
		if(handle.x > (box.width - handle.width) ) handle.x = box.width - handle.width;
	
	}


	public override function onMouseWheel(e:MouseEvent)	{
		handle.x += e.delta * step * ((rotation > 0) ? -1 : 1);
		dispatchEvent(new Event(Event.CHANGE));
		super.onMouseWheel(e);
	}

	function onHandleMouseDown (e:MouseEvent) : Void {
		CursorManager.setCursor (Cursor.DRAG);
		handle.startDrag(false,new Rectangle(0,e.target.y, box.width - handle.width ,0));
		e.target.stage.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
	}

	public function onMouseMove (e:MouseEvent)
	{
		TooltipManager.getInstance().create(this);
		dispatchEvent(new Event(Event.CHANGE));
		//~ onChanged();
		e.updateAfterEvent();
	}

	override public function onMouseUp (e:MouseEvent) : Void
	{
		if(hitTestObject( CursorManager.getInstance()._mc ))
			CursorManager.setCursor (Cursor.ARROW);

		handle.stopDrag();
		redraw(color);
	}

	static function __init__() {
		haxegui.Haxegui.register(Slider);
	}
	
	
	public override function destroy() {
		
		if(this.stage.hasEventListener (MouseEvent.MOUSE_MOVE))
			this.stage.removeEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
		
		super.destroy();
	}
	
	
	public override function onResize(e:ResizeEvent) {
		
		//~ handle.dirty = true;
		handle.redraw();
		handle.y = .5*( this.box.height - handle.height );
		
		super.onResize(e);
	}
	
}
