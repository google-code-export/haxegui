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
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import haxegui.DataSource;
import haxegui.controls.AbstractButton;
import haxegui.controls.Component;
import haxegui.controls.Image;
import haxegui.controls.Label;
import haxegui.events.MenuEvent;
import haxegui.events.ResizeEvent;
import haxegui.managers.FocusManager;
import haxegui.managers.StyleManager;
import haxegui.utils.Color;
import haxegui.utils.Opts;
import haxegui.utils.Size;
//}}}


using haxegui.controls.Component;
using haxegui.utils.Color;

//{{{
class Spacer extends Component {
	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(Spacer);
	}
	//}}}
}
//}}}

//{{{ Menu
/**
* Menu Class
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.2
*/
class Menu extends AbstractButton, implements IAggregate, implements IData {

	public var label : Label;
	public var icon  : Icon;
	public var menu  : PopupMenu;
	public var data  : Dynamic;
	public var dataSource( default, __setDataSource ) : DataSource;


	//{{{ init
	/**
	* @throws String when not parented to a [MenuBar]
	*/
	override public function init(opts:Dynamic=null) {
		if(!Std.is(parent, MenuBar)) throw parent+" not a MenuBar";
		box = new Size(40,24).toRect();
		// menu = new PopupMenu();


		super.init(opts);


		label = new Label(this);
		label.init({text: name});
		label.move(4,4);
		label.mouseEnabled = false;

		box.width = label.width;
		// dirty = false;
	}
	//}}}


	//{{{ onMouseClick
	public override function onMouseClick(e:MouseEvent) {
		var p = parent.localToGlobal(new flash.geom.Point(x, y));

		if(menu!=null)
		menu.destroy();
		menu = new PopupMenu(flash.Lib.current);
		menu.dataSource = this.dataSource;
		menu.init ({color: this.color});

		menu.toFront();

		menu.x = p.x;
		menu.y = p.y + 20;

		var self = this;
		var r = new Rectangle();
		r.width = menu.box.width;
		menu.scrollRect = r;
		var t = new feffects.Tween(0, menu.data.length*24, 250, r, "height", feffects.easing.Linear.easeOut);
		t.setTweenHandlers(
		function(v){
			self.menu.scrollRect = r.clone();
		}
		);
		t.start();

		// for(i in menu)
			// (cast i).setAction("mouseDown", "var a = new haxegui.Alert(); a.init(); a.label.setText(this.label.getText());");

		super.onMouseClick(e);
	}
	//}}}


	//{{{ __setDataSource
	public function __setDataSource(d:DataSource) : DataSource {
		dataSource = d;

		#if debug
		trace(this.dataSource+" => "+this);
		trace(this.dataSource+": "+dataSource.data);
		#end

		return dataSource;
	}
	//}}}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(Menu);
	}
	//}}}
}
//}}}


//{{{ MenuBar
/**
* MenuBar Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class MenuBar extends Component, implements IRubberBand {
	//{{{ Members
	public var items : Array<Menu>;

	public var numMenus : Int;

	private var _menu:Int;
	//}}} Members


	//{{{ init
	override public function init(opts : Dynamic=null) {
		// assuming parent is a window
		box = new Size(parent.asComponent().box.width - 10, 24).toRect();

		color = (cast parent).color;
		items = [];


		super.init(opts);


		redraw({box: this.box});

		buttonMode = false;
		tabEnabled = false;
		focusRect = false;
		mouseEnabled = false;


		// inner-drop-shadow filter
		this.filters = [new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5,4, 4,0.75,BitmapFilterQuality.LOW,true,false,false)];

		parent.addEventListener(ResizeEvent.RESIZE, onParentResize);

	}
	//}}}


	//{{{ addChild
	override function addChild(child : flash.display.DisplayObject) : flash.display.DisplayObject {
		var child = super.addChild(child);
		if(Std.is(child, Menu))
		items.push(cast child);
		// child.x = 40*getChildIndex(child);
		var w = .0;
		for(i in this) w += (getChildIndex(child)==0?0:4) + (Std.is(i, Component)?(cast i).box.width:i.width);
		child.x = w;
		return child;
	}
	//}}}


	//{{{ onParentResize
	public function onParentResize(e:ResizeEvent) {
		box.width = untyped parent.box.width - 10;

		var b = box.clone();
		b.height = box.height;
		b.x = b.y =0;
		this.scrollRect = b;

		dirty = true;

		//e.updateAfterEvent();
	}
	//}}}


	//{{{ onKeyDown
	override public function onKeyDown (e:KeyboardEvent) {}

	//}}}


	//{{{ openMenuByName

	/**
	*
	*/
	function openMenuByName (name:String) {
		openMenuAt (this.getChildIndex (this.getChildByName (name)));
	}

	//}}}


	//{{{ openMenuAt
	/**
	*
	*/
	function openMenuAt (i:UInt) {
		var menu = this.getChildAt (i);
		//~ var popup = PopupMenu.getInstance();
		//~ popup.init ({parent:this.parent, x:menu.x, y:menu.y + 20});
		//register new popups for close
	}
	//}}}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(MenuBar);
	}
	//}}}
}
//}}}
