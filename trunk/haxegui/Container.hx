// 
// The MIT License
// 
// Copyright (c) 2004 - 2006 Paul D Turner & The CEGUI Development Team
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

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Rectangle;

import flash.events.Event;
import flash.events.MouseEvent;

import haxegui.events.ResizeEvent;


import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;


import haxegui.controls.Component;
import haxegui.controls.Scrollbar;


class Container extends Component, implements IContainer, implements Dynamic
//~ , implements IChildList
{

	public var color : UInt;

	private var _clip : Bool;


	public function new (?parent : flash.display.DisplayObjectContainer, ?name:String, ?x : Float, ?y: Float)
	{
		super (parent, name, x, y);
	}

	public override function addChild(o : DisplayObject) : DisplayObject
	{
		//~ box = transform.pixelBounds.clone();
		//~ onResize(new ResizeEvent(ResizeEvent.RESIZE));
		//~ box = box.union(o.getBounds(this));
		this.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
		return super.addChild(o);
	}
	

	public function init(?initObj : Dynamic)
	{

		color = StyleManager.BACKGROUND;
		//~ color = 0xff00ff;

		if(Reflect.isObject(initObj))
		{
			for(f in Reflect.fields(initObj))
				if(Reflect.hasField(this, f))
					if(f!="width" && f!="height")
						Reflect.setField(this, f, Reflect.field(initObj, f));
			
			
			//~ name = ( initObj.name == null) ? "container" : name;
			box.width = ( Math.isNaN(initObj.width) ) ? box.width : initObj.width;
			box.height = ( Math.isNaN(initObj.height) ) ? box.height : initObj.height;
			//~ move(initObj.x, initObj.y);
			//~ color = (initObj.color==null) ? color : initObj.color;

		}		

		this.buttonMode = false;
		this.mouseEnabled = false;
		this.tabEnabled = false;

		//~ this.graphics.lineStyle (2, color - 0x141414, flash.display.LineScaleMode.NONE);
		//~ this.graphics.beginFill (color - 0x0A0A0A);
		//~ this.graphics.drawRect (0, 0, box.width, box.height );
		//~ this.graphics.endFill ();

		// add the drop-shadow filter
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.5, 4, 4,0.75,BitmapFilterQuality.HIGH,true,false,false);
		this.filters = [shadow];
		
		//~ this.cacheAsBitmap = true;
		
		//~ if(this.parent!=null)
		parent.addEventListener(ResizeEvent.RESIZE, onResize);
		
		//~ this.addEventListener(ResizeEvent.RESIZE, onResize);
		//~ dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
		parent.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
		
		redraw();
		
	}


	/**
	*
	*
	*/
	public function onResize(e:Dynamic) {

	if(Std.is(e, ResizeEvent))
		if(Std.is(parent, Component))
		{
			box = untyped parent.box.clone();
				box.width -= x;
				box.height -= y;
		}

	if(Std.is(parent.parent, ScrollPane))
		box = untyped parent.parent.box.clone();
		//~ box.union(untyped parent.parent.box.clone());

		//~ if(!this.box.containsRect(this.getBounds(flash.Lib.current)))
			//~ box.union(this.getBounds(flash.Lib.current));
//~ 
	//~ for(i in 0...numChildren-1)
		//~ {
			//~ box = box.union( getChildAt(i).getBounds(flash.Lib.current) );
			//~ box.width -= x;
			//~ box.height -= y;
		//~ }


			
		redraw(null);
		
		//
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));

		if(Std.is(e, ResizeEvent))
			e.updateAfterEvent();

	}


	/**
	*
	*
	*/
	public function redraw(?e:Dynamic) 
	{
		this.graphics.clear();
		//~ this.graphics.lineStyle (2, color - 0x141414, flash.display.LineScaleMode.NONE);
		this.graphics.beginFill (color);
		this.graphics.drawRect (0, 0, box.width, box.height );
		this.graphics.endFill ();


	}





}
