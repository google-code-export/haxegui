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
import haxegui.events.MoveEvent;


/**
* CheckBox class
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
**/
class CheckBox extends AbstractButton, implements Dynamic
{
	public var checked(__getChecked,__setChecked) : Bool;
	public var label : Label;


	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		label = new Label(this, "label", 24, 2);

		super(parent, name, x, y);
	}

	override public function init(opts:Dynamic=null)
	{
		box = new Rectangle(0, 0, 140, 20);
		color = DefaultStyle.BACKGROUND;

		super.init(opts);

		label.text = Opts.optString(opts, "label", name);
		label.init({text: name});

	}



	override public function onMouseClick(e:MouseEvent) {
		if(disabled) return;
		checked = !checked;
	}


	//////////////////////////////////////////////////
	////           Getters/Setters                ////
	//////////////////////////////////////////////////
	private function __getChecked() : Bool {
		return this.checked;
	}

	private function __setChecked(v:Bool) : Bool {
		if(v == this.checked) return v;
		this.checked = v;
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
		haxegui.Haxegui.register(CheckBox,initialize);
	}
	static function initialize() {
		StyleManager.setDefaultScript(
			CheckBox,
			"redraw",
			"
				this.graphics.clear();

     			this.filters = [];
				if( this.disabled )
				{
					var fmt = DefaultStyle.getTextFormat();
					fmt.color = this.color - 0x202020;
					this.label.tf.setTextFormat(fmt);

					var shadow = new flash.filters.DropShadowFilter(
							4, 45, DefaultStyle.DROPSHADOW,
							0.2, 4, 4, 0.65,
							flash.filters.BitmapFilterQuality.HIGH,
							true, false, false );
					this.filters = [shadow];
				}


				this.graphics.lineStyle (1,
					Math.max(0, Math.min(0xFFFFFF, this.color - 0x282828)),
					2, true, 
					flash.display.LineScaleMode.NONE,
					flash.display.CapsStyle.ROUND,
					flash.display.JointStyle.ROUND
					);
				if(this.checked)
				{
					var colors = [ this.color | 0x323232, this.color - 0x141414 ];
					var alphas = [ 100, 0 ];
					var ratios = [ 0, 0xFF ];
					var matrix = new flash.geom.Matrix();
					matrix.createGradientBox(20, 20, Math.PI/2, 0, 0);
					this.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );
					this.graphics.drawRoundRect (0, 0, 20, this.box.height, 8, 8 );

					this.graphics.lineStyle (4, this.color - 0x282828);
					this.graphics.moveTo (6, 6);
					this.graphics.lineTo (14, 14);
					this.graphics.moveTo (14, 6);
					this.graphics.lineTo (6, 14);

				}
				else
				{
					var colors = [ this.color - 0x141414, this.color | 0x323232 ];
					var alphas = [ 100, 0 ];
					var ratios = [ 0, 0xFF ];
					var matrix = new flash.geom.Matrix();
					matrix.createGradientBox(20, 20, Math.PI/2, 0, 0);
					this.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );

					this.graphics.drawRoundRect (0, 0, 20, this.box.height, 8, 8 );
				}

				this.graphics.endFill();
			"
		);

		StyleManager.setDefaultScript(
			CheckBox,
			"mouseOver",
			"
				if(!this.disabled) {
					CursorManager.setCursor(Cursor.HAND);
				}
			"
		);

		StyleManager.setDefaultScript(
			CheckBox,
			"mouseOut",
			"
				CursorManager.setCursor(Cursor.ARROW);
			"
		);
	}
}
