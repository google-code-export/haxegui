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

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import haxegui.events.MenuEvent;

import haxegui.controls.Component;
import haxegui.controls.AbstractButton;
import haxegui.controls.Label;
import haxegui.controls.UiList;
import haxegui.managers.CursorManager;
import haxegui.managers.StyleManager;

import feffects.Tween;

import haxegui.utils.Size;
import haxegui.utils.Color;
import haxegui.utils.Opts;

import haxegui.DataSource;



/**
*
* Popup Menu managers 
*
*
*/
class PopupMenu extends Component, implements IData
{
	public var items : List<ListItem>;
	
	public var data : Dynamic;
	public var dataSource( default, default ) : DataSource;


	override public function init(?opts:Dynamic=null) {
		//~ close();
		color = DefaultStyle.BACKGROUND;
		if(data==null) data = [""];
			
		super.init(opts);

		var px = Opts.optFloat(opts,"x",0);
		var py = Opts.optFloat(opts,"y",0);
		this.mouseEnabled = false;
		this.tabEnabled = false;


		if(Std.is(data, Array)) {
			data = cast(data, Array<Dynamic>);
			for (i in 0...data.length) {
				var item = new ListItem(this);
				item.init({ width: this.box.width,
							color: this.color,
							label: data[i]
							});
				//item.label.mouseEnabled = false;
				item.move(0,20*i+1);
				}
		}
		else
		if(Std.is(data, List)) {
			var j=0;
			data = cast(data, List<Dynamic>);
			var items : Iterator<Dynamic> = data.iterator();
			for(i in items) {
				var item = new ListItem(this);
				item.init({ color: this.color,
							label: i
							});
				//item.label.mouseEnabled = false;
				item.move(0,0*j+1);			
				j++;
			}
		}

		// position
		this.x = px + 10;
		this.y = py + 20;

		// add the drop-shadow filter
		filters = [new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8,4, 4,0.65,flash.filters.BitmapFilterQuality.HIGH,false,false,false)];

		// shutdown event
		//~ addEventListener (MenuEvent.MENU_HIDE, close, false, 0, true);

		// 
		//~ dispatchEvent (new MenuEvent(MenuEvent.MENU_SHOW, false, false, parent, this ));
		dispatchEvent (new MenuEvent(MenuEvent.MENU_SHOW, false, false));
		dispatchEvent (new MenuEvent(MenuEvent.CHANGE, false, false));

		//~ dispatchEvent (new MenuEvent(MenuEvent.MENU_SHOW));

		stage.addEventListener(MouseEvent.MOUSE_DOWN, shutDown, false, 0, true);
	}
	
	public function shutDown(e:MouseEvent) {
		//~ dispatchEvent (new MenuEvent(MenuEvent.MENU_HIDE));
		
		destroy();
	}
	

	public override function onAdded(e:Event) {
		dispatchEvent (new MenuEvent(MenuEvent.MENU_SHOW));
		super.onAdded(e);
	}

	override public function onKeyDown (e:KeyboardEvent) {
		/*
		var item = cast (this.getChildAt (_item), Sprite);
		item.graphics.clear ();
		item.graphics.beginFill (0x595959);
		item.graphics.drawRect (0, 0, 100, 20);
		item.graphics.endFill ();

		switch (e.keyCode)
		{
		case flash.ui.Keyboard.UP:
		if (_item > 0)
		_item--;
		case flash.ui.Keyboard.DOWN:
		if (_item < this.numChildren - 1)
		_item++;
		}
			*/
	}//end onKeyDown

	public function numItems() {
		return items.length;
	}


	public function onChanged() {
		//trace(_item);
		//for(i in 0..._items) {
		//~ for(i in 0...numChildren)
		//~ {
			//~ var item = cast(this.getChildAt(i), Sprite);
			//var color = (i==_item) ? color + 0x333333 : color;
			//~ var color = (i==_item) ? this.color | 0x202020 : this.color;
			//~ item.graphics.clear ();
			//~ item.graphics.lineStyle(2, color - 0x323232);
			//~ item.graphics.beginFill (color, .8);
			//~ item.graphics.drawRect (0, 0, 100, 20);
			//~ //item.graphics.endFill ();
//~
			//~ var tf : TextField = cast item.getChildByName("tf");
			//~ var fmt = new TextFormat ();
			//~ fmt.color = DefaultStyle.LABEL_TEXT ;
			//~ tf.setTextFormat (fmt);
//~
		//~ }

	}
	
	public override function destroy() {
		dispatchEvent(new MenuEvent(MenuEvent.MENU_HIDE));
		super.destroy();
	}
	

	static function __init__() {
		haxegui.Haxegui.register(PopupMenu);
	}

}
