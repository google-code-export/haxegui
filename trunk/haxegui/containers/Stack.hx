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

import haxegui.managers.ScriptManager;
import haxegui.managers.MouseManager;
import haxegui.managers.StyleManager;
import haxegui.controls.Component;
import haxegui.containers.IContainer;

import haxegui.utils.Opts;


/**
* Stack container, a simple container for layering components, the active layer can be controled
* by a TabNavigator for ex.
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
**/
class Stack extends Component, implements IContainer
{
	public var selectedIndex : Int;

	public function new (?parent : flash.display.DisplayObjectContainer, ?name:String, ?x : Float, ?y: Float) {
		super (parent, name, x, y);
		this.color = DefaultStyle.BACKGROUND;
		this.buttonMode = false;
		this.mouseEnabled = false;
		this.tabEnabled = false;
	}


	override public function init(?opts:Dynamic=null) {
		super.init(opts);
		
		description = null;
		
		selectedIndex = Opts.optInt(opts, "selectedIndex", 0);
		
		if(Std.is(parent, haxegui.Window))
			if(x==0 && y==0)
				move(10,20);
		
		parent.addEventListener(ResizeEvent.RESIZE, onParentResize);
		parent.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}


	public function onParentResize(e:ResizeEvent) {
		
		//~ if(Std.is(parent, Component)) {
			//~ box = untyped parent.box.clone();
			//~ box.width -= x;
			//~ box.height -= y;
		//~ }
		//~ else
		//~ if(Std.is(parent, Divider)) untyped {
			//~ var b = parent.box.clone();
			//~ b.height = parent.handle.y;
			//~ box = b;
		//~ }
		//~ else
		//~ if(Std.is(parent.parent, ScrollPane)) {
			//~ box = untyped parent.parent.box.clone();
		//~ }

		dirty = true;
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	
	}

	static function __init__() {
		haxegui.Haxegui.register(Stack);
	}

	
}
