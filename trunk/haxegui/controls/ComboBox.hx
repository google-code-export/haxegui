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
		list = null;
		
		super.init(opts);

		editable = Opts.optBool(opts, "editable", editable);

		if(editable)
		{
			if(input != null && input.parent == this)
				removeChild(input);
			input = new Input(this, "input");
			input.init({width: this.box.width, text: this.name, disabled: this.disabled});
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
		if(!this.disabled) {
		  parent.list = new haxegui.controls.UiList(root, this.parent.name+\"List\");
		  parent.list.init();
		  parent.list.color = parent.color;
		  var p = new flash.geom.Point( parent.x, parent.y );		 	
		  p = parent.parent.localToGlobal(p);
		  parent.list.x = p.x + 1;
		  parent.list.y = p.y + 20;
		  parent.list.box.width = parent.box.width - 22;
		  parent.list.box.height = 200;
		  parent.list.removeChild(parent.list.header);
		  parent.list.data = [];
		  for(i in 1...10)
			parent.list.data.push(this.parent.name+\"_ListItem\"+i);
		  parent.list.redraw();
		  var shadow = new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, flash.filters.BitmapFilterQuality.HIGH, false, false, false );
		  parent.list.filters = [shadow];
		  function down(e) { 
			  trace(e); 
			  if(parent.list.stage.hasEventListener(flash.events.MouseEvent.MOUSE_DOWN))
				  parent.list.stage.removeEventListener(flash.events.MouseEvent.MOUSE_DOWN, down);
			  parent.list.parent.removeChild(parent.list);
			  parent.list = null;
			  }
		  parent.list.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, down);
		}
		"
		);

	}

	static function __init__() {
		haxegui.Haxegui.register(ComboBox);
	}
	/*
	public override function redraw(opts:Dynamic=null) {
		super.redraw(opts);
		if(this.input!=null) {
			if(this.disabled)
				input.redraw({color: DefaultStyle.BACKGROUND});
			}
		
	}
	*/
	

}
