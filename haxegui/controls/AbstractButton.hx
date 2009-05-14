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

// import flash.display.Sprite;
// import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
// import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import flash.filters.DropShadowFilter;
// import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
// import flash.filters.BevelFilter;
import flash.geom.Rectangle;
// import flash.geom.Transform;
// import flash.text.TextField;
import flash.text.TextFormat;

import haxegui.StyleManager;
import haxegui.CursorManager;
import haxegui.events.MoveEvent;
import haxegui.Opts;

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



/**
*
* Abstract Button Class
*
* @version 0.1
* @author <gershon@goosemoose.com>
* @author Russell Weir'
*
*/
class AbstractButton extends Component
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
		//~ useHandCursors = false;
		useHandCursors = true;
	}

	/**
	* Init Function
	*
	*
	* @param opts Dynamic object
	*
	*/
	override public function init(?opts:Dynamic)
	{
		color = DefaultStyle.BACKGROUND;
		if(box.isEmpty())
			box = new Rectangle(0,0,90,30);

		super.init(opts);


		buttonMode = true;
		tabEnabled = true;
		mouseEnabled = true;
		focusRect = true;
	}

	static function __init__()
	{
		untyped StyleManager.initialize();
		StyleManager.setDefaultScript(
			AbstractButton,
			"mouseOver",
			"
				if(this.disabled) return;
				this.updateColorTween( new feffects.Tween(0, 50, 275, feffects.easing.Expo.easeOut ) );
				CursorManager.setCursor(this.cursorOver);
			"
		);
		StyleManager.setDefaultScript(
			AbstractButton,
			"mouseOut",
			"
				if(this.disabled) return;
				this.updateColorTween( new feffects.Tween(event.buttonDown ? -50 : 50, 0, 350, feffects.easing.Linear.easeOut ) );
				CursorManager.setCursor(Cursor.ARROW);
			"
		);
		StyleManager.setDefaultScript(
			AbstractButton,
			"mouseDown",
			"
				if(this.disabled) return;
				this.updateColorTween( new feffects.Tween(50, -50, 350, feffects.easing.Linear.easeOut) );
				CursorManager.setCursor(this.cursorPress);
   			"
		);
		StyleManager.setDefaultScript(
			AbstractButton,
			"mouseUp",
			"
				if(this.disabled) return;
				//~ this.redraw();
				if(this.hitTestObject( CursorManager.getInstance()._mc )) {
					this.updateColorTween( new feffects.Tween(-50, 50, 150, feffects.easing.Linear.easeNone) );
					CursorManager.setCursor(this.cursorOver);
				}
				else {
					this.updateColorTween( new feffects.Tween(-50, 0, 120, feffects.easing.Linear.easeNone) );
				}
   			"
		);
	}
}

