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

import haxegui.CursorManager;
import haxegui.FocusManager;
import haxegui.Opts;
import haxegui.StyleManager;
import haxegui.controls.Component;
import haxegui.controls.AbstractButton;
import haxegui.events.MoveEvent;

class RadioButton extends AbstractButton, implements Dynamic
{

	//~ public var group : Array<RadioButton>
	public var selected(default, default) : Bool;
	public var label : Label;


	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super(parent, name, x, y);
	}


	override public function init(?opts:Dynamic)
	{
		box = new Rectangle(0,0,140,20);
		color = DefaultStyle.BACKGROUND;

		super.init(opts);

		selected = Opts.optBool(opts, "selected", selected);


		// drop-shadow filter
		//~ var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, BitmapFilterQuality.HIGH, false, false, false );
		//~ var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, BitmapFilterQuality.HIGH, true, false, false );
		//~ this.filters = [shadow];

		label = new Label(this, "label", 24, 2);
		label.init({innerData: name});

		// Listeners
		addEventListener (MouseEvent.MOUSE_DOWN, onBtnMouseDown,false,0,true);
		addEventListener (MouseEvent.MOUSE_UP,   onBtnMouseUp,false,0,true);
		//~ addEventListener (MouseEvent.ROLL_OVER, onBtnRollOver,false,0,true);
		//~ addEventListener (MouseEvent.ROLL_OUT,  onBtnRollOut,false,0,true);

		this.addEventListener (Event.ACTIVATE, onEnabled,false,0,true);
		this.addEventListener (Event.DEACTIVATE, onDisabled,false,0,true);

		if(disabled)
			dispatchEvent(new Event(Event.DEACTIVATE));


		redraw();

	}

	/**
	*
	*
	*/
	public function onDisabled(e:Event)
	{
		mouseEnabled = false;
		buttonMode = false;
		//~ tabEnabled = false;
		redraw();
	}

	/**
	*
	*/
	public function onEnabled(e:Event)
	{
		mouseEnabled = true;
		buttonMode = true;
		//~ tabEnabled = false;
		redraw();
	}




	override public function redraw (opts:Dynamic = null):Void
	{
		StyleManager.exec(this,"redraw",
			{
				color: Opts.optInt(opts, "color", color),
				selected: Opts.optBool(opts, "selected", selected),
			});
	}


	/**
	*
	*
	*/
	public  function onBtnMouseDown(e:MouseEvent) : Void
	{
		//~ if(disabled) return;

		//~ trace(Std.string(here)+Std.string(e));
		//~ if(!this.hasFocus())
		FocusManager.getInstance().setFocus(this);

		//~ redraw(DefaultStyle.BACKGROUND - 0x141414);

		for(i in 0...parent.numChildren)
			{
				var child = parent.getChildAt(i);
				if(Std.is(child, RadioButton))
					if(child!=this)
					//~ if(child!=this && untyped !child.disabled)
						{
						//~ trace(child);
						untyped
							{
							child.selected = false;
							child.redraw();
							}
						}
			}
	}

	/**
	*
	*
	*/
	public  function onBtnMouseUp(e:MouseEvent) {
		this.selected = !this.selected;

		//~ redraw(DefaultStyle.BACKGROUND);
		var color = selected ? DefaultStyle.BACKGROUND - 0x202020 : DefaultStyle.BACKGROUND;
		//~ redraw(color);
	}


	static function __init__() {
		haxegui.Haxegui.register(RadioButton,initialize);
	}
	static function initialize() {
		StyleManager.initialize();
		StyleManager.setDefaultScript(
			RadioButton,
			"redraw",
			haxe.Resource.getString("DefaultRadioButtonStyle")
		);
	}


}
