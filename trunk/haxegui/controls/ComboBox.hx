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

//{{{ Imports
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import haxegui.DataSource;
import haxegui.controls.Button;
import haxegui.controls.Component;
import haxegui.controls.IAdjustable;
import haxegui.controls.PopupMenu;
import haxegui.events.MenuEvent;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.managers.CursorManager;
import haxegui.managers.StyleManager;
import haxegui.toys.Arrow;
import haxegui.toys.Socket;
import haxegui.utils.Color;
import haxegui.utils.Opts;
import haxegui.utils.Size;
//}}}


using haxegui.controls.Component;


//{{{ ComboBoxDropButton
/**
*
* The pulldown button for a ComboBox.<br/>
* <p>
* This is a child of the ComboBox, so any calculations regarding the
* box should refer to parent.box
* </p>
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class ComboBoxDropButton extends PushButton, implements IComposite
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

		// menu.data = (cast parent).data;
		menu.dataSource = (cast parent).dataSource;
		menu.data = (cast parent).dataSource.data;

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
		moveTo(parent.asComponent().box.width - box.width, -1);
		box  = parent.asComponent().box.clone();
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
//}}}


//{{{ ComboBoxBackground
/**
* The background for a non-editable ComboBox.<br/>
* <p>
* This is a child of the ComboBox, so any calculations regarding the
* box should refer to parent.box
* </p>
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
**/
class ComboBoxBackground extends Component, implements IComposite
{
	public var label : Label;


	//{{{ init
	override public function init(?opts:Dynamic=null) {
		color = DefaultStyle.BACKGROUND;


		super.init(opts);


		label = new Label(this);
		label.init({text: Opts.optString(opts, "label", name), disabled: this.disabled});
		label.move(4,4);
	}
	//}}}


	//{{{ onAdded
	public override function onAdded(e:Event) {
		//if(.hasNext())
		for(child in parent.asComponent().getElementsByClass(ComboBoxBackground))
		if(child!=null && child!=this)
			throw "ComboBoxBackground is composited, and should be singular";
	}
	//}}}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(ComboBoxBackground);
	}
	//}}}
}
//}}}


//{{{ ComboBox
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
	//{{{ Members

	//{{{ Public
	public var adjustment : Adjustment;

	public var background : ComboBoxBackground;

	public var data : Dynamic;

	public var dataSource( default, __setDataSource ) : DataSource;

	public var dropButton : ComboBoxDropButton;

	public var input	  : Input;

	public var menu 	  : PopupMenu;

	public var slot : Socket;
	//}}}


	//{{{ Private
	private var editable : Bool;
	//}}}

	//}}}


	//{{{ Functions
	//{{{ init
	public override function init(?opts:Dynamic) {
		adjustment = new Adjustment({ value: 0, min: 0, max: 1, step:null, page: null});
		box = new Size(140,20).toRect();
		color = DefaultStyle.BACKGROUND;
		menu = new PopupMenu();


		super.init(opts);


		editable = Opts.optBool(opts, "editable", true);

		mouseEnabled = true;
		focusRect = false;
		tabEnabled = false;
		tabChildren = true;


		// Input \ Background
		if(editable) {
			input = new Input(this);
			input.init({width: this.box.width, height: this.box.height, text: Opts.optString(opts, "text", this.name), disabled: this.disabled});
			input.redraw();
		}
		else {
			background = new ComboBoxBackground(this);
			background.init({width: box.width, height: box.height, color:this.color, label: Opts.optString(opts, "text", this.name), disabled: this.disabled});
		}


		// Drop Button
		dropButton = new ComboBoxDropButton(this);
		var bOpts = Opts.clone(opts);
		Opts.removeFields(bOpts, ["x", "y"]);
		dropButton.init(bOpts);
		dropButton.box = new Size(20,20).toRect();
		dropButton.moveTo(box.width-box.height,-1);


		// Slot
		slot = new haxegui.toys.Socket(this);
		slot.init({visible: false});
		slot.moveTo(-14,Std.int(this.box.height)>>1);
		slot.color = Color.tint(slot.color, .5);


		//
		if(input==null) return;
		input.addEventListener(MoveEvent.MOVE, onInputMoved, false, 0, true);
		input.addEventListener(ResizeEvent.RESIZE, onInputResized, false, 0, true);
		input.addEventListener(Event.CHANGE, onInputChanged, false, 0, true);
	}
	//}}}


	//{{{ onInputChanged
	public function onInputChanged(e:Event) {
		dispatchEvent(e);
	}
	//}}}


	//{{{ onMenuItemSelected
	public function onMenuItemSelected(e:MouseEvent) {
		if(input!=null)
		input.setText(e.target.getChildAt(0).tf.text);
		if(background!=null)
		background.label.setText(e.target.getChildAt(0).tf.text);
	}
	//}}}


	//{{{ onMenuShow
	public function onMenuShow(e:MenuEvent) {
		menu.addEventListener(MouseEvent.MOUSE_DOWN, onMenuItemSelected, false, 0, true);
	}
	//}}}


	//{{{ onInputMoved
	private function onInputMoved(e:MoveEvent) {
		if(input==null) return;
		move(input.x, input.y);
		e.target.removeEventListener(MoveEvent.MOVE, onInputMoved);
		e.target.moveTo(0,0);
		e.target.addEventListener(MoveEvent.MOVE, onInputMoved, false, 0, true);
	}
	//}}}


	//{{{ onInputResized
	private function onInputResized(e:ResizeEvent) {
		if(input==null) return;
		this.box = input.box.clone();
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}
	//}}}


	//{{{ __setDataSource
	public function __setDataSource(d:DataSource) : DataSource {
		dataSource = d;
		//dataSource.addEventListener(Event.CHANGE, onData, false, 0, true);
		//~ trace(this.dataSource+" => "+this);
		//~ trace(dataSource.data);
		return dataSource;
	}
	//}}}


	//{{{ onResize
	public override function onResize(e:ResizeEvent) {
		if(input==null) return;

		if(box.width<input.tf.width) return;
		super.onResize(e);
	}
	//}}}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(ComboBox);
	}
	//}}}
	//}}}
}
//}}}


//{{{ DropDown
/**
* Alias for a non-editable [ComboBox]
*/
class DropDown extends ComboBox {
	public override function init(?opts:Dynamic) {
		if(opts==null) opts = {};
		Reflect.setField(opts, "editable", false);
		super.init(opts);
	}

	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(DropDown);
	}
	//}}}
}
//}}}