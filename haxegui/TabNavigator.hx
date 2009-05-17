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

import haxegui.events.ResizeEvent;


import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;

import haxegui.StyleManager;
import haxegui.controls.Component;
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

	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super(parent, name, x, y);
	}

	override public function init(opts:Dynamic=null)
	{
		box = new Rectangle(0, 0, 40, 24);
		color = DefaultStyle.BACKGROUND;

		super.init(opts);

		active = Opts.optBool(opts, "active", active);


		label = new Label(this, "label");
		label.text = Opts.optString(opts, "label", name);
		label.init({text: name});

	}

	/** Mouse click **/
	public override function onMouseClick(e:MouseEvent) : Void
	{
		//~ StyleManager.exec(this,"mouseClick", {event : e});
		//~ this.active = true;
		//~ redraw();
		(cast this.parent).activeTab = this.parent.getChildIndex(this);
		parent.dispatchEvent(new Event(Event.CHANGE));

	}



	//////////////////////////////////////////////////
	////           Getters/Setters                ////
	//////////////////////////////////////////////////
	override private function __setDisabled(v:Bool) : Bool {
		super.__setDisabled(v);
		if(this.disabled) {
			mouseEnabled = false;
			buttonMode = false;
		}
		else {
			mouseEnabled = Opts.optBool(initOpts,"mouseEnabled",true);
			buttonMode = Opts.optBool(initOpts,"buttonMode",true);
		}
		return v;
	}


	//////////////////////////////////////////////////
	////           Initialization                 ////
	//////////////////////////////////////////////////
	static function __init__() {
		haxegui.Haxegui.register(Tab);
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


	override public function init(opts : Dynamic=null)
	{
		box = new Rectangle(0, 0, 200, 200);
		color = DefaultStyle.BACKGROUND;
		//~ tabs = new Array();
		//~ numTabs = 0;

		super.init(opts);


		for(i in 1...5)
			{
				var tab = new Tab(this, "Tab"+i, 44*(i-1), 0);
				tab.init({width: 40, color: this.color, active: i==1 });
				tab.redraw();
				//~ numTabs = tabs.push(tab);
			}


		// add the drop-shadow filter
		//~ var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 4, 4,0.75,BitmapFilterQuality.HIGH,true,false,false);
		//~ this.filters = [shadow];


		addEventListener(Event.CHANGE, onChanged, false, 0, true);

		//~ if(this.parent!=null)
		//~ parent.addEventListener(ResizeEvent.RESIZE, onParentResize);
		//~ parent.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));


	}

	public function onChanged(e:Event)
	{
		//~ (cast getChildAt(activeTab)).redraw();
		for(i in 0...numChildren)
			{
			var child = getChildAt(i);
			if(!Std.is(child, Tab)) return;
			untyped {
				child.active = i == activeTab;
				child.redraw();
				}
			}

	}

	static function __init__() {
		haxegui.Haxegui.register(TabNavigator);
	}
}
