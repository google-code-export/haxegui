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
import haxegui.Opts;
import haxegui.StyleManager;
/**
*
* Close MinimizeButton Class
*
* @version 0.1
* @author Russell Weir <damonsbane@gmail.com>
*/
class MinimizeButton extends AbstractButton
{
	public function new(?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float) {
		super (parent, name, x, y);
		this.addEventListener(MouseEvent.CLICK,onMouseClick,false,0,true);
	}

	override public function redraw (opts:Dynamic = null):Void
	{
		StyleManager.exec(MinimizeButton,"redraw", this,
			{
				w : Opts.optInt(opts,"w",20),
				color: Opts.optInt(opts, "color", 0),
			});
	}

	override public function init(opts:Dynamic=null)
	{
		super.init(opts);

		action_redraw =
			"
				this.graphics.clear();
				this.graphics.lineStyle (2, color - 0x141414);
				//this.graphics.beginFill (color, 0.5);
				var grad = flash.display.GradientType.LINEAR;
				var colors = [ color | 0x323232, color - 0x141414 ];
				var alphas = [ 100, 0 ];
				var ratios = [ 0, 0xFF ];
				var matrix = new flash.geom.Matrix();
				matrix.createGradientBox(12, 12, Math.PI/2, 0, 0);

				this.graphics.beginGradientFill( grad, colors, alphas, ratios, matrix );
				this.graphics.drawRoundRect (0, 0, 12, 12, 4, 4);
				this.graphics.endFill ();
				this.graphics.moveTo(1,8);
				this.graphics.lineTo(11,8);
			";
	}

	/**
	*/
// 	override public function onMouseUp(e:MouseEvent) : Void
// 	{
// 		StyleManager.exec(MinimizeButton,"mouseUp", this, {event : e});
// 	}

	public function onMouseClick(e:MouseEvent) : Void
	{
		trace("Minimize clicked on " + parent.parent.toString());
	}
}