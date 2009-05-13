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

import feffects.Tween;
import feffects.easing.Quint;
import feffects.easing.Sine;
import feffects.easing.Back;
import feffects.easing.Bounce;
import feffects.easing.Circ;
import feffects.easing.Cubic;
import feffects.easing.Elastic;
import feffects.easing.Expo;
import feffects.easing.Linear;
import feffects.easing.Quad;
import feffects.easing.Quart;

import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilterQuality;
import flash.geom.Rectangle;
import flash.text.TextFormat;

import haxegui.CursorManager;
import haxegui.Opts;
import haxegui.StyleManager;
import haxegui.events.MoveEvent;

/**
*
* Button Class
*
* @version 0.1
* @author <gershon@goosemoose.com>
* @author Russell Weir'
*
*/
class Button extends Component, implements Dynamic
{
	/** Sets whether mouse events in buttons use hand cursors **/
	public static var useHandCursors(default,__setHandCursors) : Bool;
	/** The cursor to use when the mouse is over buttons **/
	public static var defaultCursorOver : Cursor;
	/** The cursor to use when a button is pressed **/
	public static var defaultCursorPress : Cursor;

	static function __setHandCursors(v:Bool) : Bool
	{
		if(v == useHandCursors)
			return v;
		if(v) {
			defaultCursorOver = Cursor.HAND;
			defaultCursorPress = Cursor.HAND2;
		} else {
			defaultCursorOver = Cursor.ARROW;
			defaultCursorPress = Cursor.ARROW;
		}
		return v;
	}

	/**
	*  @see Label
	*/
	public var label :Label;
	public var fmt : TextFormat;

	/** The cursor to use when the mouse is over this button **/
	public var cursorOver : Cursor;
	/** The cursor to use when this button is pressed **/
	public var cursorPress : Cursor;

	/**
	*
	* @param parent  Parent object
	* @param name    Name of new instance
	* @param x       Horizontal location
	* @param y       Vertical location
	*/
	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super (parent, name, x, y);
		cursorOver = defaultCursorOver;
		cursorPress = defaultCursorPress;
	}


	override public function init(opts:Dynamic=null)
	{
		color = DefaultStyle.BACKGROUND;
		if(box.isEmpty())
			box = new Rectangle(0,0,90,30);

		super.init(opts);

		useHandCursors = false;
		action_mouseOver =
			"
				if(this.disabled) return;
				this.updateColorTween( new feffects.Tween(0, 50, 275, feffects.easing.Expo.easeOut ) );
				CursorManager.setCursor(this.cursorOver);
			";
		action_mouseOut =
			"
				if(this.disabled) return;
				this.updateColorTween( new feffects.Tween(event.buttonDown ? -50 : 50, 0, 350, feffects.easing.Linear.easeOut ) );
				CursorManager.setCursor(Cursor.ARROW);
			";
		action_mouseDown =
			"
				if(this.disabled) return;
				this.updateColorTween( new feffects.Tween(50, -50, 350, feffects.easing.Linear.easeOut) );
				CursorManager.setCursor(this.cursorPress);
			";
		action_mouseUp =
			"
				if(this.disabled) return;
				this.redraw();
				if(this.hitTestObject( CursorManager.getInstance()._mc )) {
					this.updateColorTween( new feffects.Tween(-50, 50, 150, feffects.easing.Linear.easeNone) );
					CursorManager.setCursor(this.cursorOver);
				}
				else {
					this.updateColorTween( new feffects.Tween(-50, 0, 120, feffects.easing.Linear.easeNone) );
				}
			";

		label = new Label();
		label.init();
		label.text = Opts.optString(opts,"label",name);

		label.move( Math.floor(.5*(this.box.width - label.width)), Math.floor(.5*(this.box.height - label.height)) );
		this.addChild(label);

		buttonMode = true;
		tabEnabled = true;
		mouseEnabled = true;
		focusRect = true;


		//~ else
		//~ if(Math.isNaN(box.width))
			//~ box.width = 90;
		//~ else
		//~ if(Math.isNaN(box.height))
			//~ box.height = 30;

		// add the drop-shadow filter
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 4, 4, 0.5, BitmapFilterQuality.HIGH, false, false, false );
		//~ var bevel:BevelFilter = new BevelFilter( 4, 45 ,color | 0x323232 ,1 ,0x000000, .25, 2, 2, 1, BitmapFilterQuality.LOW , flash.filters.BitmapFilterType.INNER, false );
		this.filters = [shadow];
		//~ this.filters = [shadow, bevel];

		// register with focus manager
		//~ FocusManager.getInstance().addEventListener (FocusEvent.MOUSE_FOCUS_CHANGE, onFocusChanged);

	}

	/**
	*
	* @param e
	*
	*/
	public function onFocusChanged (e:FocusEvent)
	{
		//~ var color = this.hasFocus ()? DefaultStyle.BACKGROUND | 0x141414: DefaultStyle.BACKGROUND;
		redraw ();
	}


	override public function redraw(opts:Dynamic=null) : Void
	{
		//~ if(color == 0 || Math.isNaN(color))
		//~ color = DefaultStyle.BACKGROUND;

		this.graphics.clear();
		this.graphics.lineStyle (2, color - 0x141414 );

		if( disabled )
		{
			//~ color = DefaultStyle.BACKGROUND - 0x141414;
			this.graphics.lineStyle (2, color);

			fmt = StyleManager.getTextFormat();
			fmt.color = color - 0x202020;
			fmt.align = flash.text.TextFormatAlign.CENTER;
			label.tf.setTextFormat(fmt);

			var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.2, 4, 4, 0.65, BitmapFilterQuality.HIGH, false, false, false );
			//~ var bevel:BevelFilter = new BevelFilter( 4, 45 ,color | 0x202020 ,1 ,0x000000, .15, 2, 2, 1, BitmapFilterQuality.LOW , flash.filters.BitmapFilterType.INNER, false );
			//~ this.filters = [shadow, bevel];
			this.filters = [shadow];
		}


		//~ this.graphics.beginFill (color);

		//~ var colors = [ color | 0x1A1A1A, color - 0x1A1A1A ];
		//~ var colors = [ color | 0x323232, color - 0x333333 ];
		var colors = [ color | 0x323232, color - 0x141414 ];


		var alphas = [ 100, 100 ];
		var ratios = [ 0, 0xFF ];
		var matrix = new flash.geom.Matrix();
		matrix.createGradientBox(box.width, box.height, Math.PI/2, 0, 0);
		this.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );

		this.graphics.drawRoundRect (0, 0, box.width, box.height, 8, 8 );
		this.graphics.endFill ();
	}
}

