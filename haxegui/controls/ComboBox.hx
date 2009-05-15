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

import haxegui.Opts;
import haxegui.CursorManager;
import haxegui.StyleManager;
import haxegui.events.MoveEvent;

/**
*
* The pulldown button for a ComboBox.
*
* This is a child of the ComboBox, so any calculations regarding the
* box should refer to parent.box
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class ComboBoxDropButton extends AbstractButton {

	static function __init__() {
		haxegui.Haxegui.register(ComboBoxDropButton,initialize);
	}
	


	static function initialize() {
		StyleManager.setDefaultScript(
			ComboBoxDropButton,
			"redraw",
			"
				var h = this.parent.box.height;
				var w = h;
				this.graphics.clear();
				var colors = [ this.color | 0x323232, this.color - 0x141414 ];
				var alphas = [ 100, 100 ];
				var ratios = [ 0, 0xFF ];
				var matrix = new flash.geom.Matrix();
				matrix.createGradientBox(w, h, Math.PI/2, 0, 0);
				this.graphics.lineStyle (1,
					Math.max(0, Math.min(0xFFFFFF, DefaultStyle.BACKGROUND - 0x282828)),
					1, true, 
					flash.display.LineScaleMode.NONE,
					flash.display.CapsStyle.ROUND,
					flash.display.JointStyle.ROUND
					);
				this.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );
				this.graphics.drawRoundRectComplex(0, 0, w, h, 0, 4, 0, 4 );
				this.graphics.endFill ();
				this.graphics.lineStyle (1, this.color - 0x333333 );
				colors = [ this.color - 0x141414,  this.color - 0x333333 ];
				matrix.createGradientBox(w/2, h/2, Math.PI/2, 7.5, 7.5);
				this.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, [0, 0x66], matrix );
				this.graphics.moveTo(7.5,7.5);
				this.graphics.lineTo(w-7.5, 7.5);
				this.graphics.lineTo(w/2, h-7.5);
				this.graphics.endFill ();

				if(this.filters == null || this.filters.length == 0) {
					var shadow = new flash.filters.DropShadowFilter(
							2, 45, DefaultStyle.DROPSHADOW,
							0.5, 4, 4, 0.5,
							flash.filters.BitmapFilterQuality.HIGH,
							false, false, false );
					this.filters = [shadow];
				}
				this.x = this.parent.box.width - w;
			"
		);
	}
}

/**
* The background of a ComboBox.
*
* This is a child of the ComboBox, so any calculations regarding the
* box should refer to parent.box
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
**/
class ComboBoxBackground extends Component
{
	static function __init__() {
		haxegui.Haxegui.register(ComboBoxBackground,initialize);
	}
	
	override public function init(opts:Dynamic=null)
	{
		color = DefaultStyle.BACKGROUND;

		super.init(opts);
	
	}
		
	static function initialize() {
		StyleManager.setDefaultScript(
			ComboBoxBackground,
			"redraw",
			"
				var h = this.parent.box.height;
				//~ var d = this.parent.dropButton.box.width;
				var d = 20;
				var w = this.parent.box.width - d - 1;
				
				var colors = [ this.color | 0x323232, this.color - 0x141414 ];
				var alphas = [ 100, 100 ];
				var ratios = [ 0, 0xFF ];
				var matrix = new flash.geom.Matrix();
				matrix.createGradientBox(w, h*2, Math.PI/2, 0, 0);
				this.graphics.lineStyle (1,
					Math.max(0, Math.min(0xFFFFFF, DefaultStyle.BACKGROUND - 0x282828)),
					1, true, 
					flash.display.LineScaleMode.NONE,
					flash.display.CapsStyle.ROUND,
					flash.display.JointStyle.ROUND
					);
				this.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, [0, 0x66], matrix );
				this.graphics.drawRoundRectComplex(0, 0, w, h, 4, 0, 4, 0 );
				this.graphics.endFill();

				if(this.filters == null || this.filters.length == 0) {
					var shadow = new flash.filters.DropShadowFilter(
							2, 45, DefaultStyle.DROPSHADOW,
							0.5, 4, 4, 0.5,
							flash.filters.BitmapFilterQuality.HIGH,
							false, false, false );
					this.filters = [shadow];
				}
			"
		);
	}
}

/**
*
* ComboBox Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class ComboBox extends Component, implements Dynamic
{
	public var background : ComboBoxBackground;
	public var dropButton : ComboBoxDropButton;
	public var input : Input;

	private var editable : Bool;
	
	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		background = new ComboBoxBackground(this, "background");
		dropButton = new ComboBoxDropButton(this, "button");

		super(parent, name, x, y);
	}

	override public function init(?opts:Dynamic)
	{
		color = DefaultStyle.BACKGROUND;
		box = new Rectangle(0,0,140,20);
		editable = true;

		super.init(opts);

		editable = Opts.optBool(opts, "editable", editable);
		
		if(editable)
		{
			if(input != null && input.parent == this)
				removeChild(input);
			input = new Input(this, "input");
			input.init(opts);
			input.redraw(opts);
		}
		else
		{
			if(background != null && background.parent == this)
				removeChild(background);
			background = new ComboBoxBackground(this, "background");
			background.init(opts);
		}

		background.init(opts);



		dropButton.init(opts);
	}

	static function __init__() {
		haxegui.Haxegui.register(ComboBox,initialize);
	}
	static function initialize() {
		StyleManager.setDefaultScript(
			ComboBox,
			"redraw",
			"
				if(this.color==0 || Math.isNaN(this.color))
					this.color = DefaultStyle.BACKGROUND;

				//~ if( this.disabled ) {
					//~ this.color = DefaultStyle.BACKGROUND;
					//~ var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.2, 4, 4, 0.65, BitmapFilterQuality.HIGH, true, false, false );
					//~ this.filters = [shadow];
					//~ this.input.backgroundColor = DefaultStyle.BACKGROUND + 0x141414;
				//~ }


				if(this.input != null)
					this.input.tf.setTextFormat( DefaultStyle.getTextFormat( 8, this.disabled ? DefaultStyle.BACKGROUND - 0x141414 : DefaultStyle.INPUT_TEXT ));

				if(this.background!=null)
					this.background.redraw();
				
				this.dropButton.redraw();
			"
		);
	}

}
