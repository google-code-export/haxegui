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

import haxegui.managers.CursorManager;
import haxegui.managers.ScriptManager;
import haxegui.managers.MouseManager;
import haxegui.managers.StyleManager;
import haxegui.controls.AbstractButton;
import haxegui.controls.Component;
import haxegui.containers.IContainer;

import haxegui.utils.Opts;


class DividerHandleButton extends AbstractButton {

	override public function init(opts : Dynamic=null)
	{
		if(untyped parent.parent.horizontal)  
			box = new Rectangle(0,0,10,100);
		else
			box = new Rectangle(0,0,100,10);
			
		color = DefaultStyle.BACKGROUND;
		super.init(opts);
		
		var arrow = new haxegui.toys.Arrow(this);
		arrow.init({width: 6, height: 8, color: this.color});
		if(untyped parent.parent.horizontal)  {
			arrow.moveTo(5, .5*(this.box.height-8));
		}
		else {
			arrow.rotation = 90;
			arrow.moveTo(.5*(this.box.width-8), 5);
		}
				
	}

	static function __init__() {
		haxegui.Haxegui.register(DividerHandle);
	}
}


class DividerHandle extends AbstractButton {

	public var button : DividerHandleButton;
	
	override public function init(opts : Dynamic=null)
	{
		if((cast parent).horizontal)	
			box = new Rectangle(0,0,10,512);
		else
			box = new Rectangle(0,0,512,10);
		
		color = DefaultStyle.BACKGROUND;
		cursorOver = Cursor.NS;
		cursorPress = Cursor.DRAG;
			
		super.init(opts);

		button = new DividerHandleButton(this);
		button.init();
		if((cast parent).horizontal)	
			button.moveTo(0, .5*(512-100));
		else
			button.moveTo(.5*(512-100),0);
		
		var p = Component.getParentComponent(this);
		while(p!=null) {
			p.addEventListener(ResizeEvent.RESIZE, onParentResize);				
			p = Component.getParentComponent(p);
			}
	}


	public function onParentResize(e:ResizeEvent) {
		//box.width = (cast parent).box.width;
		var b = untyped parent.parent.parent.box;
		if((cast parent).horizontal) {
			box.height = b.height;
			button.moveTo(0, .5*(box.height-100));
		}
		else {
			box.width = b.width;
			button.moveTo(.5*(box.width-100),0);
		}
		
		//dirty = true;
		redraw();
	}
	
	static function __init__() {
		haxegui.Haxegui.register(DividerHandle);
	}
	
}


/**
* Divider is a split pane containers.
*
* @version 0.1
* @author Russell Weir <damonsbane@gmail.com>
* @author Omer Goshen <gershon@goosemoose.com>
*/
class Divider extends Container, implements IContainer
{
	
	var handle : DividerHandle;

	var horizontal : Bool;
	
	override public function init(opts : Dynamic=null)
	{
		horizontal = Opts.optBool(opts, "horizontal", false);

		super.init(opts);
		
		handle = new DividerHandle(this);
		handle.init();
		if(horizontal)
			handle.moveTo(250, 0);
		else
			handle.moveTo(0, 250);
		

		parent.addEventListener(ResizeEvent.RESIZE, onParentResize);

	}

	public override function addChild(o:DisplayObject) {
	/*
		if(handle!=null) {
				if(Std.is(o, Component)) {
				(cast o).box.height = handle.y - 1;
				(cast o).redraw();
				}
			}
	*/
		return super.addChild(o);
	}

	public override function onMouseDown(e:MouseEvent) {
		if(e.target==handle) {
			if(horizontal)
				e.target.startDrag(false, new Rectangle(-this.stage.stageWidth,0,2*this.stage.stageWidth,0));
			else
				e.target.startDrag(false, new Rectangle(0,-this.stage.stageHeight,0,2*this.stage.stageHeight));
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		super.onMouseDown(e);
	}

	public override function onMouseUp(e:MouseEvent) {
		handle.stopDrag();
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		super.onMouseUp(e);
	}

	static function __init__() {
		haxegui.Haxegui.register(Divider);
	}

	public function onMouseMove(e:MouseEvent) {
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
		//dirty = true;
		if(numChildren>0) {
		if(getChildAt(1)!=null)
			untyped	getChildAt(1).box.height = handle.y - 1;
		}
		//redraw();
	}


	private override function onParentResize(e:ResizeEvent) {
		if(Std.is(parent, Divider)) {
			if((cast parent).horizontal)
				box.width = (cast parent).handle.x;
			else
				box.height = (cast parent).handle.y;
		}
		if(handle!=null) {
			if(horizontal)
				handle.box.height = this.box.height;
			else
				handle.box.width = this.box.width;
			handle.dirty = true;
		}
		
		dirty = true;
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));	
	}
	
}
