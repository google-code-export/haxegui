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
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import haxegui.controls.Component;
import haxegui.controls.IAdjustable;
import haxegui.controls.Button;
import haxegui.controls.PopupMenu;
import haxegui.utils.Opts;
import haxegui.managers.CursorManager;
import haxegui.managers.StyleManager;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.MenuEvent;

import haxegui.toys.Socket;
import haxegui.toys.Arrow;

import haxegui.utils.Size;
import haxegui.utils.Color;

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
class ComboBoxDropButton extends PushButton
{    
	public var arrow : Arrow;
	
	public override function init(opts:Dynamic=null) {
		if(!Std.is(parent, ComboBox)) throw parent+" not a ComboBox";
		selected = false;
		mouseChildren = false;
		
		super.init(opts);
		
		arrow = new haxegui.toys.Arrow(this);
		arrow.init({ width: 8, height: 8, color: haxegui.utils.Color.darken(this.color, 10)});
		arrow.rotation = 90;
		arrow.move(6,7);
		arrow.mouseEnabled = false;
		
		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);
		
	}
	

	public override function onMouseClick(e:MouseEvent) {
		if(this.disabled) return;
		
		var p = new flash.geom.Point( parent.x, parent.y );		 	
		p = parent.parent.localToGlobal(p);


		(cast parent).menu = new PopupMenu();

		var menu = (cast parent).menu;
		
		menu.data = (cast parent).data;
		menu.addEventListener(MenuEvent.MENU_SHOW, (cast parent).onMenuShow, false, 0, true);
		menu.addEventListener(MenuEvent.MENU_HIDE, onMenuHide, false, 0, true);
				
		menu.init({color: DefaultStyle.INPUT_BACK});
		
		menu.x = p.x + 1;
		menu.y = p.y + 20;
		menu.box.width = (cast parent).box.width - 22;
		//parent.list.box.height = 200;
		//parent.list.. = [];

		//menu.__setDataSource( parent.dataSource );
		//for(i in 1...10)
		//parent.list.data.push("List Item "+i);
		//parent.list.data = parent.data;

		//~ menu.dispatchEvent(new MenuEvent(MenuEvent.MENU_SHOW));

		super.onMouseClick(e);
	}
	
	public function onMenuShow(e:MenuEvent) {
		parent.dispatchEvent(e);
//		(cast parent).menu.addEventListener(MenuEvent.MENU_HIDE, onMenuHide, false, 0, true);
	}

	public function onMenuHide(e:MenuEvent) {
		selected = false;
		//dirty = true;	
		redraw();	
		//trace(selected);
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
		arrow.center();
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
class ComboBoxBackground extends AbstractButton
{
	public var label : Label;
	
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
* ComboBox is composited of a button for the pull-down menu, and an optional Input for custom values.
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class ComboBox extends Component, implements IData, implements IAdjustable
{
	public var background : ComboBoxBackground;
	public var dropButton : ComboBoxDropButton;
	
	public var input	  : Input;
	
	public var menu 	  : PopupMenu;
	
	public var dataSource( default, __setDataSource ) : DataSource;

	public var data : Dynamic;

	private var editable : Bool;

	public var slot : Socket;
	public var adjustment : Adjustment;


	public override function init(?opts:Dynamic) {
		color = DefaultStyle.BACKGROUND;
		//box = new Rectangle(0,0,140,20);
		box = new Size(140,20).toRect();
		editable = true;
		//~ menu = null;
		adjustment = new Adjustment({ value: 0, min: 0, max: 1, step:null, page: null});
		menu = new PopupMenu();
		

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
			input.init({width: this.box.width, text: Opts.optString(opts, "text", this.name), disabled: this.disabled});
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
		dropButton.box = new Size(20,20).toRect();
		dropButton.moveTo(box.width-box.height,-1);

		
		if(!disabled) {
			slot = new haxegui.toys.Socket(this);
			slot.init();
			slot.moveTo(-14,Std.int(this.box.height)>>1);
	
			slot.color = Color.tint(slot.color, .5);
		}	
		
		input.addEventListener(MoveEvent.MOVE, onInputMoved, false, 0, true);
		input.addEventListener(ResizeEvent.RESIZE, onInputResized, false, 0, true);
		input.addEventListener(Event.CHANGE, onInputChanged, false, 0, true);		
	}
	
	public function onInputChanged(e:Event) {
		dispatchEvent(e);
	}
	
	public function onMenuItemSelected(e:MouseEvent) {
		input.setText(e.target.getChildAt(0).tf.text);
	}
	
	public function onMenuShow(e:MenuEvent) {
		menu.addEventListener(MouseEvent.MOUSE_DOWN, onMenuItemSelected, false, 0, true);
	}
		
	
	private function onInputMoved(e:MoveEvent) {
		move(input.x, input.y);
		e.target.removeEventListener(MoveEvent.MOVE, onInputMoved);
		e.target.moveTo(0,0);
		e.target.addEventListener(MoveEvent.MOVE, onInputMoved, false, 0, true);		
	}

	private function onInputResized(e:ResizeEvent) {
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

	static function __init__() {
		haxegui.Haxegui.register(ComboBox);
	}
	
}
