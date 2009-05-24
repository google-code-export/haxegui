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
import haxegui.Component;
import haxegui.Opts;
import haxegui.managers.CursorManager;
import haxegui.managers.StyleManager;
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
		haxegui.Haxegui.register(ComboBoxDropButton);
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
		haxegui.Haxegui.register(ComboBoxBackground);
	}

	override public function init(opts:Dynamic=null)
	{
		color = DefaultStyle.BACKGROUND;

		super.init(opts);

		
	}


}

/**
*
* ComboBox composited of a button for the pull-down menu, and an optional Input
* for custom values.
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class ComboBox extends Component
{
	public var background : ComboBoxBackground;
	public var dropButton : ComboBoxDropButton;
	public var input	  : Input;
	public var list 	  : UiList;

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
			input.init({width: this.box.width, text: this.name });
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
		dropButton.setAction("mouseClick",
		"
			if(parent.list==null) {
			parent.list = new haxegui.controls.UiList(root);
			var list = parent.list;
			list.color = this.color;
			for(i in 0...5) list.data.push(\"item\"+i);
			list.init();
			list.removeChild(list.header);
			list.box.width = this.parent.box.width - 20;
			for(i in 0...list.numChildren)
				{
					list.getChildAt(i).box.width = this.parent.box.width - 20;
					list.getChildAt(i).redraw();
					/*list.getChildAt(i).filters = null;*/
				}
		
		 	var p = new flash.geom.Point( parent.x, parent.y );
			p = this.parent.parent.localToGlobal(p);
			
			list.x = p.x;
			list.y = p.y;
			
			var shadow = new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, flash.filters.BitmapFilterQuality.HIGH, false, false, false );
			list.filters = [shadow];
			
			
			function down(e) { 
				trace(e); 
				if(list.stage.hasEventListener(flash.events.MouseEvent.MOUSE_DOWN))
					list.stage.removeEventListener(flash.events.MouseEvent.MOUSE_DOWN, down);
				list.parent.removeChild(list);
				parent.list = null;
				}

			list.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, down);
		
		}
		"
		);

	}

	static function __init__() {
		haxegui.Haxegui.register(ComboBox);
	}
}
