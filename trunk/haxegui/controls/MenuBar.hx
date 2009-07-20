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

import flash.display.DisplayObjectContainer;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.Keyboard;


import haxegui.controls.Label;
import haxegui.managers.FocusManager;
import haxegui.Opts;
import haxegui.managers.StyleManager;
import haxegui.controls.AbstractButton;
import haxegui.controls.Component;
import haxegui.events.ResizeEvent;
import haxegui.events.MenuEvent;

/**
* MenuBarItem Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class MenuBarItem extends AbstractButton
{

	public var label : Label;

	override public function init(opts:Dynamic=null) {
		if(!Std.is(parent, MenuBar)) throw parent+" not a MenuBar";

		box = new Rectangle(0,0,40,24);
		
		super.init(opts);

		label = new Label(this);
		label.text = this.name;
		label.init();
		label.move(4,4);
		label.mouseEnabled = false;
		label.text = null;
		
	}

	public override function onMouseClick(e:MouseEvent) {
			var a = new haxegui.Alert();
			a.init({label: this+"."+here.methodName+":\n\n\n"+"Not implemented yet..."});
			
		super.onMouseClick(e);
	}

	static function __init__() {
		haxegui.Haxegui.register(MenuBarItem);
	}
}




/**
* MenuBar Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class MenuBar extends Component
{
	public var numMenus : Int;
	private var _menu:Int;


	override public function init(opts : Dynamic=null)
	{
		if(Std.is(parent, Component))
			color = untyped parent.color;

		// assuming parent is a window
		box = new Rectangle(0,0, untyped parent.box.width - 10, 24);

		super.init(opts);

		redraw({box: this.box});

		//this.name = "MenuBar";
		buttonMode = false;
		tabEnabled = false;
		focusRect = false;
		mouseEnabled = false;

		_menu = 0;
		numMenus = 1+Math.round( Math.random() * 4 );

		for (i in 0...numMenus) {
			var menu = new MenuBarItem(this, "Menu"+(i+1), 40*i, 0);
			menu.init({color: this.color});
		}

		// inner-drop-shadow filter
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5,4, 4,0.75,BitmapFilterQuality.LOW,true,false,false);
		this.filters = [shadow];

		parent.addEventListener(ResizeEvent.RESIZE, onParentResize);

	}

	/**
	*
	*/
	public function onParentResize(e:ResizeEvent) {
		box.width = untyped parent.box.width - 10;

		var b = box.clone();
		b.height = box.height;
		b.x = b.y =0;
		this.scrollRect = b;

		dirty = true;

		//e.updateAfterEvent();
	}


	override public function onKeyDown (e:KeyboardEvent)
	{
	}



	/**
	*
	*/
	function openMenuByName (name:String) {
		openMenuAt (this.getChildIndex (this.getChildByName (name)));
	}

	/**
	*
	*/
	function openMenuAt (i:UInt) {
		var menu = this.getChildAt (i);
		var popup = PopupMenu.getInstance();
		popup.init ({parent:this.parent, x:menu.x, y:menu.y + 20});
		//register new popups for close
	}

	static function __init__() {
		haxegui.Haxegui.register(MenuBar);
	}

}//MenuBar
