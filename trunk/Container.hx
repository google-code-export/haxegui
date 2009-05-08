//      Container.hx
//
//      Copyright 2009 gershon <gershon@yellow>
//
//      This program is free software; you can redistribute it and/or modify
//      it under the terms of the GNU General Public License as published by
//      the Free Software Foundation; either version 2 of the License, or
//      (at your option) any later version.
//
//      This program is distributed in the hope that it will be useful,
//      but WITHOUT ANY WARRANTY; without even the implied warranty of
//      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//      GNU General Public License for more details.
//
//      You should have received a copy of the GNU General Public License
//      along with this program; if not, write to the Free Software
//      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
//      MA 02110-1301, USA.

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Rectangle;

import flash.events.Event;
import flash.events.MouseEvent;

import events.ResizeEvent;


import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;


import controls.Component;

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
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.5,4, 4,0.75,BitmapFilterQuality.HIGH,true,false,false);
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
