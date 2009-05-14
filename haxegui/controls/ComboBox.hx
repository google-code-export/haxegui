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

import haxegui.Opts;
import haxegui.CursorManager;
import haxegui.StyleManager;
import haxegui.events.MoveEvent;

/**
*
* ComboBoxDropButton Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class ComboBoxDropButton extends AbstractButton {

	override public function init(opts:Dynamic=null)
	{

		super.init(opts);


		// add the drop-shadow filter
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 4, 4, 0.5, BitmapFilterQuality.HIGH, false, false, false );
		this.filters = [shadow];

		redraw();

	}

	static var initialized : Bool;
	static function __init__() {
		initialize();
	}
	static function initialize() {
		if(initialized) return;
		initialized = true;

		StyleManager.setDefaultScript(
			ComboBoxDropButton,
			"redraw",
			"
				this.graphics.clear();
				var colors = [ this.color | 0x323232, this.color - 0x141414 ];
				var alphas = [ 100, 100 ];
				var ratios = [ 0, 0xFF ];
				var matrix = new flash.geom.Matrix();
				matrix.createGradientBox(this.box.width, this.box.height, Math.PI/2, 0, 0);
				this.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );
				this.graphics.drawRoundRectComplex (0, 0, this.box.width, this.box.height, 0, 4, 0, 4 );
				this.graphics.endFill ();
				this.graphics.lineStyle (1, this.color - 0x333333 );
				this.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, [0, 0x66], matrix );
				this.graphics.moveTo(5,5);
				this.graphics.lineTo(15,5);
				this.graphics.lineTo(10,15);
				this.graphics.endFill ();
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
	public var back : Sprite;
	public var dropButton : ComboBoxDropButton;
	public var tf : TextField;

	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super(parent, name, x, y);
	}

	override public function init(?opts:Dynamic)
	{
		color = DefaultStyle.BACKGROUND;
		box = new Rectangle(0,0,140,20);

		super.init(opts);


		back = new Sprite();
		back.name = "back";
		back.graphics.lineStyle (2, DefaultStyle.BACKGROUND - 0x202020);
		back.graphics.beginFill (DefaultStyle.INPUT_BACK);
		back.graphics.drawRoundRectComplex (0, 0, box.width - 20 , box.height, 4, 0, 4, 0 );
		back.graphics.endFill ();
		addChild(back);
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, BitmapFilterQuality.HIGH, true, false, false );
		back.filters = [shadow];

		if(tf != null && tf.parent == this)
			removeChild(tf);
		tf = new TextField();
		tf.name = "tf";
		tf.type = flash.text.TextFieldType.INPUT;
		tf.text = name;
		//~ tf.background = true;
		//~ tf.border = true;
		//~ tf.borderColor = color - 0x202020;
		tf.embedFonts = true;

		tf.height = box.height - 4;
		tf.x = tf.y = 4;

		tf.setTextFormat(DefaultStyle.getTextFormat());
		this.addChild(tf);

		if(dropButton != null && dropButton.parent == this)
			removeChild(dropButton);
		dropButton = new ComboBoxDropButton(this, "button");
		dropButton.init({x: box.width - 20, width: 20, height: 20});

		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.2, 4, 4, 0.65, BitmapFilterQuality.HIGH, false, false, false );
		dropButton.filters = [shadow];

		this.addEventListener (Event.ACTIVATE, onEnabled, false, 0, true);
		this.addEventListener (Event.DEACTIVATE, onDisabled, false, 0, true);
	}

	public function onEnabled(e:Event)
	{
	}

	public function onDisabled(e:Event)
	{
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
				var txt = this.tf;
				if(txt != null)
					txt.setTextFormat( DefaultStyle.getTextFormat( 8, DefaultStyle.LABEL_TEXT ));

				if( this.disabled ) {
					this.dropButton.disabled = this.disabled;
					//~ this.color = DefaultStyle.BACKGROUND - 0x141414;
					this.color = DefaultStyle.BACKGROUND;
					//~ var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.2, 4, 4, 0.65, BitmapFilterQuality.HIGH, true, false, false );
					//~ this.filters = [shadow];
					//~ this.tf.backgroundColor = DefaultStyle.BACKGROUND + 0x141414;
					if(txt != null)
						txt.setTextFormat( DefaultStyle.getTextFormat( 8, DefaultStyle.BACKGROUND - 0x141414 ));
				}

				this.back.graphics.lineStyle(2, DefaultStyle.BACKGROUND - 0x202020);
				//~ back.graphics.beginFill (this.color);
				this.back.graphics.beginFill( this.disabled ? DefaultStyle.BACKGROUND : DefaultStyle.INPUT_BACK );
				this.back.graphics.drawRoundRectComplex(0, 0, this.box.width - 20 , this.box.height, 4, 0, 4, 0 );
				this.back.graphics.endFill();
				this.dropButton.redraw();
			"
		);
	}

}
