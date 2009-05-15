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
			haxe.Resource.getString("DefaultComboBoxDropButton")
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
			haxe.Resource.getString("DefaultComboBoxBackground")
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
			input.init({text: this.name });
			input.redraw();
		}
		else
		{
			if(background != null && background.parent == this)
				removeChild(background);
			background = new ComboBoxBackground(this, "background");
			background.init(opts);
		}

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

				if(this.input != null)
					{
					this.input.redraw();
					this.input.tf.setTextFormat( DefaultStyle.getTextFormat( 8, this.disabled ? DefaultStyle.BACKGROUND - 0x141414 : DefaultStyle.INPUT_TEXT ));
					}

				if(this.background!=null)
					this.background.redraw();
				
				this.dropButton.redraw();
				this.setChildIndex(this.dropButton, this.numChildren - 1);
			"
		);
	}

}