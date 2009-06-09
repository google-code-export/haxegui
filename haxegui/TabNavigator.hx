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

package haxegui;

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.geom.Rectangle;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.FocusEvent;

import haxegui.events.ResizeEvent;


import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;

import haxegui.managers.StyleManager;
import haxegui.Component;
import haxegui.controls.AbstractButton;
import haxegui.controls.Label;


/**
*
* Tab Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*
*/
class Tab extends AbstractButton
{
	public var label : Label;
	public var active : Bool;


	override public function init(opts:Dynamic=null) {
		box = new Rectangle(0, 0, 40, 24);
		color = DefaultStyle.BACKGROUND;
		active = false;

		super.init(opts);

		active = Opts.optBool(opts, "active", active);

		label = new Label(this, "label");
		label.text = Opts.optString(opts, "label", name);
		label.init({text: name});

		parent.dispatchEvent(new Event(Event.CHANGE));
		
		//~ addEventListener(FocusEvent.FOCUS_IN, (cast parent).onChanged, false, 0, true);

	}

	/** Mouse click **/
	public override function onMouseClick(e:MouseEvent) : Void
	{
		(cast this.parent).activeTab = this.parent.getChildIndex(this);
		parent.dispatchEvent(new Event(Event.CHANGE));

		super.onMouseClick(e);
	}

	public override function onMouseDown(e:MouseEvent) : Void {
	
		this.startDrag(false, new Rectangle(0,0,untyped parent.box.width,0));		

		super.onMouseDown(e);
	}

	public override function onMouseUp(e:MouseEvent) : Void {
	
		this.stopDrag();		

		super.onMouseUp(e);
	}


	static function __init__() {
		haxegui.Haxegui.register(Tab);
	}
}



/**
*
* TabChild Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*
*/
class TabChild extends Component
{
	var _tabNav : Dynamic;
	
	override public function init(opts : Dynamic=null) {
		_tabNav = parent;
		
		super.init(opts);
	
		while(_tabNav!=null && !Std.is(_tabNav,TabNavigator))
			_tabNav =  cast _tabNav.parent;

		_tabNav.addEventListener(Event.CHANGE, onTabChanged, false, 0, true);
	
		
	}
	
	public function onTabChanged(e:Event) {
		for(i in 0..._tabNav.numChildren) 
			if(Std.is(_tabNav.getChildAt(i), TabChild))
				_tabNav.getChildAt(i).visible = false; 
		this.visible = true;
	}
	
	
}



/**
*
* TabNavigator class
*
*
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class TabNavigator extends Component
{

	//~ public var tabs : Array<Tab> ;
	//~ public var numTabs : Int;
	public var activeTab : Int;

	public override function addChild(o : DisplayObject) : DisplayObject
	{
		//if(Std.is(o, Tab)) for(i in 0...numChildren) if(Std.is(getChildAt(i), Tab)) getChildAt(i).active = false;
		this.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
		return super.addChild(o);
	}


	override public function init(opts : Dynamic=null)
	{
		box = new Rectangle(0, 0, 200, 200);
		color = DefaultStyle.BACKGROUND;
		text = null;
		//~ tabs = new Array();
		//~ numTabs = 0;

		super.init(opts);
/*

		for(i in 1...5)
			{
				var tab = new Tab(this);
				tab.init({width: 60, color: this.color, active: i==1 });
				tab.redraw();
				tab.move(60*(i-1), 0);
				//~ numTabs = tabs.push(tab);
			}
*/

		// add the drop-shadow filters
		var shadow1:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 4, 4,0.75,BitmapFilterQuality.HIGH,true,false,false);
		var shadow2:DropShadowFilter = new DropShadowFilter (4, 235, DefaultStyle.DROPSHADOW, 0.5, 4, 4,0.5,BitmapFilterQuality.HIGH,true,false,false);
		this.filters = [shadow1,shadow2];


		addEventListener(Event.CHANGE, onChanged, false, 0, true);
		parent.addEventListener(ResizeEvent.RESIZE, onParentResize);

		//~ if(this.parent!=null)
		//~ parent.addEventListener(ResizeEvent.RESIZE, onParentResize);
		//~ parent.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));


	}


	public function onChanged(e:Event)
	{
		
		for(i in 0...numChildren) {
			var child = getChildAt(i);
			if(Std.is(child, Tab)) untyped {
				child.active = ( i == activeTab );
				child.redraw();
				}
			//~ if(Std.is(child, TabChild)) untyped {
				//~ child.visible = i == activeTab;
				//~ child.redraw();
				//~ }				
		}

	}

	static function __init__() {
		haxegui.Haxegui.register(TabNavigator);
	}
	
	

	public function onParentResize(e:ResizeEvent) {
		
		if(Std.is(parent, Component)) {
			box = untyped parent.box.clone();
			box.width -= x + 2;
			box.height -= y + 2;
		}

		if(Std.is(parent, Window)) {
			//box.inflate(-20,-30);
			box.inflate(0,-10);
		}

		if(Std.is(parent.parent, ScrollPane)) {
			box = untyped parent.parent.box.clone();
			//~ box.inflate(-5,0);		
		}

		//~ for(i in 0...numChildren)
			//~ if(Std.is( getChildAt(i), haxegui.controls.ScrollBar ))
			//~ {
				//~ this.box.width -= 20;
			//~ }

		dirty = true;
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}	
}
