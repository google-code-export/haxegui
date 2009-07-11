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

import flash.geom.Rectangle;

import flash.display.Sprite;
import flash.display.MovieClip;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;

import haxegui.Component;
import haxegui.Opts;
import haxegui.managers.CursorManager;
import haxegui.managers.StyleManager;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;

import haxegui.DataSource;


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

	public var arrow : haxegui.toys.Arrow;
	
	public override function init(opts:Dynamic=null) {
		if(!Std.is(parent, ComboBox)) throw parent+" not a ComboBox";
		
		mouseChildren = false;
		
		super.init(opts);
		
		arrow = new haxegui.toys.Arrow(this);
		arrow.init({ width: 8, height: 8, color: haxegui.utils.Color.darken(this.color, 10)});
		arrow.rotation = 90;
		arrow.move(6,7);
		arrow.mouseEnabled = false;
		
		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);
	}

	public function onParentResize(e:ResizeEvent) {
		untyped moveTo(parent.box.width - box.width, -1);
		untyped box  = parent.box.clone();
		box.width = box.height;
		dirty = true;
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}

	public override function onResize(e:ResizeEvent) {
		arrow.box = box.clone();
		arrow.box.inflate(-6,-6);
		arrow.moveTo(.5*box.width, .5*box.height+1);
		arrow.dirty = true;
		super.onResize(e);
	}
	
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
	
	public var  dataSource( default, __setDataSource ) : DataSource;

	private var editable : Bool;

	public override function init(?opts:Dynamic) {
		color = DefaultStyle.BACKGROUND;
		box = new Rectangle(0,0,140,20);
		editable = true;
		list = null;
		
		super.init(opts);

		editable = Opts.optBool(opts, "editable", editable);
		
		this.mouseEnabled = true;
		this.focusRect = false;
		this.tabEnabled = false;
		this.tabChildren = true;
		
		if(editable) {
			if(input != null && input.parent == this)
				removeChild(input);
			input = new Input(this);
			input.init({width: this.box.width, text: this.name, disabled: this.disabled});
			input.redraw();
		}
		else {
			if(background != null && background.parent == this)
				removeChild(background);
			background = new ComboBoxBackground(this);
			background.init(opts);
		}

		dropButton = new ComboBoxDropButton(this);
		var bOpts = Opts.clone(opts);
		Opts.removeFields(bOpts, ["x", "y"]);
		dropButton.init(bOpts);
		dropButton.box = new Rectangle(0,0,20,20);
		dropButton.moveTo(box.width-box.height,-1);


		input.addEventListener(MoveEvent.MOVE, onInputMoved, false, 0, true);
		input.addEventListener(ResizeEvent.RESIZE, onInputResized, false, 0, true);

	}

	static function __init__() {
		haxegui.Haxegui.register(ComboBox);
	}

	public function onInputMoved(e:MoveEvent) {
		this.move(input.x, input.y);
		e.target.removeEventListener(MoveEvent.MOVE, onInputMoved);
		e.target.moveTo(0,0);
		e.target.addEventListener(MoveEvent.MOVE, onInputMoved, false, 0, true);		
	}

	public function onInputResized(e:ResizeEvent) {
		this.box = input.box.clone();
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}
	

	public function __setDataSource(d:DataSource) : DataSource {
		dataSource = d;
		//dataSource.addEventListener(Event.CHANGE, onData, false, 0, true);
		//~ trace(this.dataSource+" => "+this);
		//~ trace(dataSource.data);
		return dataSource;
	}	

	public override function onResize(e:ResizeEvent) {
		if(box.width<input.tf.width) return;
		super.onResize(e);
	}
	
}
