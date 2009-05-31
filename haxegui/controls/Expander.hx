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
import flash.display.MovieClip;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;

import haxegui.managers.CursorManager;
import haxegui.managers.FocusManager;
import haxegui.Opts;
import haxegui.managers.StyleManager;
import haxegui.events.MoveEvent;


/**
* Expander class, may be expanded or collapsed by the user to reveal or hide child
* widgets.
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
**/
class Expander extends AbstractButton
{
	public var expanded(__getExpanded,__setExpanded) : Bool;
	public var label : Label;


	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super(parent, name, x, y);
	}

	override public function init(opts:Dynamic=null)
	{
		box = new Rectangle(0, 0, 15, 15);
		color = cast Math.max(0, DefaultStyle.BACKGROUND - 0x202020);
		expanded = false;

		expanded = Opts.optBool(opts, "expanded", expanded);

		label = new Label(this, "label", 20, 0);
		//~ label.text = Opts.optString(opts, "label", name);
		label.init({innerData: this.name});


		super.init(opts);

	}



	override public function onMouseClick(e:MouseEvent) {
		if(disabled) return;
		
		e.stopImmediatePropagation();
		
		expanded = !expanded;
		
		dirty = true;
		dispatchEvent(new Event(Event.CHANGE));
		
		super.onMouseClick(e);
	}


	//////////////////////////////////////////////////
	////           Getters/Setters                ////
	//////////////////////////////////////////////////
	private function __getExpanded() : Bool {
		return this.expanded;
	}

	private function __setExpanded(v:Bool) : Bool {
		if(v == this.expanded) return v;
		this.expanded = v;
		this.dirty = true;
		return v;
	}

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
		haxegui.Haxegui.register(Expander);
	}

}
