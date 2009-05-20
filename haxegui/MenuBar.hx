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

package haxegui;

import flash.geom.Rectangle;

import flash.display.DisplayObjectContainer;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Graphics;
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

import haxegui.controls.AbstractButton;
import haxegui.controls.Label;
import haxegui.managers.FocusManager;
import haxegui.Opts;
import haxegui.managers.StyleManager;
import haxegui.Component;
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

	public var tf : TextField;

	override public function init(opts:Dynamic=null)
	{
		super.init(opts);

		var tf = new TextField();
		var tf = new TextField();
		tf.name = "tf";
		tf.text = this.name;
		tf.selectable = false;
		tf.mouseEnabled = false;
		tf.width = 38;
		tf.height = 18;
		tf.x = 2;
		tf.y = 4;
		tf.embedFonts = true;

		tf.tabEnabled = false;
		tf.focusRect = false;
		tf.mouseEnabled = false;


		tf.setTextFormat (DefaultStyle.getTextFormat(8, 10, flash.text.TextFormatAlign.CENTER ));
		this.addChild (tf);

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


	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float, ?width:Float)
	{
		super (parent, name, x, y);
		this.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

	}

	override public function init(opts : Dynamic=null)
	{
		if(Std.is(parent, Component))
			color = untyped parent.color;

		box = new Rectangle(0,0, untyped parent.box.width, 24);

		super.init(opts);

		redraw({box: this.box});

		//this.name = "MenuBar";
		buttonMode = false;
		tabEnabled = false;
		focusRect = false;
		mouseEnabled = false;

		_menu = 0;
		numMenus = 1+Math.round( Math.random() * 4 );


		for (i in 0...numMenus)
		{
			var menu = new MenuBarItem(this, "Menu"+(i+1), 40*i, 0);
			menu.init({color: this.color});

			menu.redraw({color: this.color});

			menu.addEventListener (MouseEvent.ROLL_OVER, onMenuRollOver, false, 0, true);
			menu.addEventListener (MouseEvent.ROLL_OUT, onMenuMouseOut, false, 0, true);
			menu.addEventListener (MouseEvent.MOUSE_MOVE, onMenuMouseMove, false, 0, true);
			menu.addEventListener (MouseEvent.MOUSE_DOWN, onMenuMouseDown, false, 0, true);
			menu.addEventListener (MouseEvent.MOUSE_UP, onMenuMouseUp, false, 0, true);


		}

		// inner-drop-shadow filter
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, 0x000000, 0.5,4, 4,0.75,BitmapFilterQuality.LOW,true,false,false);
		this.filters = [shadow];

		parent.addEventListener(ResizeEvent.RESIZE, onParentResize);

	}

	/**
	*
	*/
	public function onParentResize(e:ResizeEvent)
	{
		this.box = untyped parent.box.clone();

		this.box.width -= x;
		this.box.height -= y;

		var b = box.clone();
		b.height = box.height;
		b.x=b.y=0;
		this.scrollRect = b;

		dirty = true;

		e.updateAfterEvent();
	}




	function onMenuMouseOut (e:Event)
	{

	}

	function onMenuMouseUp (e:MouseEvent)
	{
	}

	function onMenuMouseDown (e:MouseEvent)
	{

		this.addEventListener (KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
		//~ onChanged();
		_menu = this.getChildIndex (e.target);
		openMenuAt (_menu);
	}//onMouseDown


	function onMenuMouseMove (e:MouseEvent)
	{
		//if(PopupMenu.getInstance().exists())
		//~ if (this.getChildIndex (e.target) != _menu)
		//~ if (this.hasFocus())
		//~ {
			//dispatchEvent(new Event("CLOSE_POPUP"));
			//~ _menu = this.getChildIndex (e.target);
			//~ onChanged();

			//~ openmenuByName (e.target.parent.name);
			//~ openMenuAt( _menu );
		//~ }
	}

	function onMenuRollOver (e:MouseEvent)
	{
		var oldmenu = _menu;
		_menu = this.getChildIndex (e.target);
		//~ onChanged (oldmenu);
	}

	function onPopupClosed (e:Event)
	{
		_menu = -1;
		//~ onChanged();
	}

	override public function onKeyDown (e:KeyboardEvent)
	{
	}



	/**
	*
	*/
	function openmenuByName (name:String)
	{
		openMenuAt (this.getChildIndex (this.getChildByName (name)));
	}

	/**
	*
	*/
	function openMenuAt (i:UInt)
	{
		var menu = this.getChildAt (i);
		var popup = PopupMenu.getInstance();
		popup.init ({parent:this.parent, x:menu.x, y:menu.y + 20});
		//register new popups for close
		popup.addEventListener (MenuEvent.MENU_HIDE, onPopupClosed);

	}

	static function __init__() {
		haxegui.Haxegui.register(MenuBar);
	}

}//MenuBar
