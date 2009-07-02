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

package haxegui.containers;

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

import haxegui.managers.ScriptManager;
import haxegui.managers.MouseManager;
import haxegui.managers.StyleManager;
import haxegui.Component;
import haxegui.IContainer;


class Container extends Component, implements IContainer
{
	private var _clip : Bool;

	public function new (?parent : flash.display.DisplayObjectContainer, ?name:String, ?x : Float, ?y: Float)
	{
		super (parent, name, x, y);
		this.color = DefaultStyle.BACKGROUND;
		this.buttonMode = false;
		this.mouseEnabled = false;
		this.tabEnabled = false;
	}

	public override function addChild(o : DisplayObject) : DisplayObject
	{
		dirty = true;
		return super.addChild(o);
	}


	override public function init(opts : Dynamic=null)
	{
		super.init(opts);
		text = null;
		
		parent.addEventListener(ResizeEvent.RESIZE, onParentResize);
		parent.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}


	public function onParentResize(e:ResizeEvent) {
		
		if(Std.is(parent, Component))
		{
			box = untyped parent.box.clone();
			box.width -= x;
			box.height -= y;
		}

		if(Std.is(parent.parent, ScrollPane)) {
			box = untyped parent.parent.box.clone();
		}

		for(i in 0...numChildren)
			if(Std.is( getChildAt(i), haxegui.controls.ScrollBar ))
			{
				this.box.width -= 20;
			}

		dirty = true;
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}

	static function __init__() {
		haxegui.Haxegui.register(Container);
	}
}
