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

import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;

import haxegui.CursorManager;
import haxegui.StyleManager;
/**
*
* Close CloseButton Class
*
* @version 0.1
* @author Russell Weir <damonsbane@gmail.com>
*/
class CloseButton extends Component
{
	public function new(?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float) {
		super (parent, name, x, y);
	}

	override public function redraw (opts:Dynamic = null):Void
	{
		StyleManager.exec(CloseButton,"redraw", this,
			{
				w : Opts.optInt(opts,"w",20),
				color: Opts.optInt(opts, "color", 0),
			});
	}

	override public function init(opts:Dynamic=null)
	{
		action_redraw =
			"
				this.graphics.clear();
				var grad = flash.display.GradientType.LINEAR;
				var colors = [ color | 0x323232, color - 0x141414 ];
				var alphas = [ 100, 0 ];
				var ratios = [ 0, 0xFF ];
				var matrix = new flash.geom.Matrix();
				matrix.createGradientBox(12, 12, Math.PI/2, 0, 0);
				this.graphics.lineStyle (2, color - 0x141414);
				this.graphics.beginGradientFill( grad, colors, alphas, ratios, matrix );
				this.graphics.drawRoundRect (0, 0, 12, 12, 4, 4);
				this.graphics.endFill ();
				this.graphics.moveTo(0,0);
				this.graphics.lineTo(12,12);
				this.graphics.moveTo(12,0);
				this.graphics.lineTo(0,12);
			";
		action_mouseOver =
			"
				if(this.disabled) return;
				this.updateColorTween( new feffects.Tween(0, 50, 275, feffects.easing.Expo.easeOut ) );
				CursorManager.setCursor(Cursor.ARROW);
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
				CursorManager.setCursor(Cursor.ARROW);
			";
		action_mouseUp =
			"
				if(this.disabled) return;
				this.redraw();
				if(this.hitTestObject( CursorManager.getInstance()._mc )) {
					this.updateColorTween( new feffects.Tween(-50, 50, 150, feffects.easing.Linear.easeNone) );
					CursorManager.setCursor(Cursor.ARROW);
				}
				else {
					this.updateColorTween( new feffects.Tween(-50, 0, 120, feffects.easing.Linear.easeNone) );
				}
			";

		this.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		this.addEventListener (MouseEvent.MOUSE_UP,   onMouseUp, false, 0, true);
		this.addEventListener (MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
		this.addEventListener (MouseEvent.ROLL_OUT,  onRollOut, false, 0, true);
		this.addEventListener (MouseEvent.CLICK, onMouseClick, false, 0, true);
	}

	/** onRollOver Event **/
	override public function onRollOver(e:MouseEvent)
	{
		StyleManager.exec(CloseButton,"mouseOver", this, {event : e});
	}

	/** onRollOut Event **/
	override public function onRollOut(e:MouseEvent) : Void
	{
		StyleManager.exec(CloseButton,"mouseOut", this, {event : e});
	}

	override public function onMouseDown(e:MouseEvent) : Void
	{
		StyleManager.exec(CloseButton,"mouseDown", this, {event : e});
	}

	/**
	*/
	override public function onMouseUp(e:MouseEvent) : Void
	{
		StyleManager.exec(CloseButton,"mouseUp", this, {event : e});
	}

	public function onMouseClick(e:MouseEvent) : Void
	{
	}
}