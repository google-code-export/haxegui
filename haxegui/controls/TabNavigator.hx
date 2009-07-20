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
import haxegui.controls.Component;
import haxegui.controls.AbstractButton;
import haxegui.controls.Label;

import haxegui.Opts;

import haxegui.utils.Color;
import haxegui.utils.Size;

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
		if(!Std.is(parent, TabNavigator)) throw parent+" not a TabNavigator";
		
		box = new Size(40, 24).toRect();
		color = DefaultStyle.BACKGROUND;
		active = false;

		super.init(opts);

		active = Opts.optBool(opts, "active", active);

		label = new Label(this, "label");
		label.text = Opts.optString(opts, "label", name);
		label.init({text: name});
		label.mouseEnabled = false;

		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);
		//~ parent.dispatchEvent(new Event(Event.CHANGE));
		//~ addEventListener(FocusEvent.FOCUS_IN, (cast parent).onChanged, false, 0, true);

	}

	/** Mouse click **/
	public override function onMouseClick(e:MouseEvent) : Void
	{
		var tabnav = cast(parent, TabNavigator);
		tabnav.activeTab = tabnav.getChildIndex(this);
		//parent.dispatchEvent(new Event(Event.CHANGE));
		super.onMouseClick(e);
	}
/*
	public override function onMouseDown(e:MouseEvent) : Void {
	
		this.startDrag(false, new Rectangle(0,0,untyped parent.box.width,0));		

		super.onMouseDown(e);
	}

	public override function onMouseUp(e:MouseEvent) : Void {
	
		this.stopDrag();		

		super.onMouseUp(e);
	}
*/
	public function onParentResize(e:ResizeEvent) {
		moveTo(x, (cast parent).box.height-box.height);
	}

	static function __init__() {
		haxegui.Haxegui.register(Tab);
	}
}



enum TabPosition {
	TOP;
	BOTTOM;
	LEFT;
	RIGHT;
}


/**
* Tab Navigator bar for switching visible content.<br>
* Add child Tabs to the bar, and connect it to a [Stack] container like this:
* <pre class="code haxe">
* // add a tabnav with 2 tabs
* var tabnav = new TabNavigator();
* tabnav.init();
* 
* var tab = new Tab(tabnav);
* tab.init();
* 
* // 40 is the default tab width, and is passed as horizotal offset
* tab = new Tab(tabnav, 40);
* tab.init();
*
* // prepare a stack container
* var stack = getChildByName("Stack");
* var onTabChanged = function(e:Event) { stack.getChildAt(tabnav.activeTab).toFront(); }
*
* // connect to the stack container
* tabnav.addEventListener(Event.CHANGE, onTabChanged, false, 0, true);
* </pre>
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class TabNavigator extends Component
{
	/** Tab position **/
	public var tabPosition : TabPosition;

	/** The index of the selected tab **/
	public var activeTab(default, __setActive) : Int;

	public override function addChild(o : DisplayObject) : DisplayObject {
		//if(Std.is(o, Tab)) for(i in 0...numChildren) if(Std.is(getChildAt(i), Tab)) getChildAt(i).active = false;
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
		return super.addChild(o);
	}


	override public function init(opts : Dynamic=null) {
		box = new Size(200, 24).toRect();
		color = DefaultStyle.BACKGROUND;
		text = null;
		tabPosition = TabPosition.TOP;

		super.init(opts);

		// add the drop-shadow filters
		//~ var shadow2:DropShadowFilter = new DropShadowFilter (4, 235, DefaultStyle.DROPSHADOW, 0.45, 4, 4,0.35,BitmapFilterQuality.HIGH,true,false,false);
		//~ this.filters = [shadow1,shadow2];
		this.filters = [new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 4, 4,0.5,BitmapFilterQuality.HIGH,true,false,false)];

		addEventListener(Event.CHANGE, onChanged, false, 0, true);
		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);

		//~ if(this.parent!=null)
		//~ parent.addEventListener(ResizeEvent.RESIZE, onParentResize);
		//~ parent.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));


	}
	
	/** Setter for the active tab **/
	public function __setActive(v:Int) : Int {
		activeTab = v;
        dispatchEvent(new Event(Event.CHANGE));
		return activeTab;	
	}

	/** Callback for a tab change, updates all child Tabs **/
	public function onChanged(e:Event) {
		#if debug
			trace(this+" tab changed: "+activeTab);
		#end
		for(tab in getElementsByClass(Tab)) {
				tab.active = ( getChildIndex(cast tab) == activeTab );
				tab.redraw();
				}
	}

	static function __init__() {
		haxegui.Haxegui.register(TabNavigator);
	}

	public function onParentResize(e:ResizeEvent) {
		
		if(Std.is(parent, Component)) {
			box.width = untyped parent.box.width - x;
		}

		if(Std.is(parent.parent, haxegui.containers.ScrollPane)) {
			box.width = untyped parent.parent.box.width;
		}

		dirty = true;
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}	
}
