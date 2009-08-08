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
import feffects.Tween;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import haxegui.DataSource;
import haxegui.controls.AbstractButton;
import haxegui.controls.Component;
import haxegui.controls.Label;
import haxegui.controls.UiList;
import haxegui.events.MenuEvent;
import haxegui.managers.CursorManager;
import haxegui.managers.StyleManager;
import haxegui.utils.Color;
import haxegui.utils.Opts;
import haxegui.utils.Size;
//}}}

/**
* Popup Menu<br/>
*
*
*/
class PopupMenu extends Component, implements IData {
	//{{{ Members
	public var items 						: List<ListItem>;

	public var data 						: Dynamic;
	public var dataSource(default, default) : DataSource;
	//}}}

	//{{{ Functions
	//{{{ init
	override public function init(?opts:Dynamic=null) {
		box = new Size(100,20).toRect();
		color = DefaultStyle.BACKGROUND;
		if(data==null) data = [""];


		super.init(opts);


		mouseEnabled = false;
		tabEnabled = false;


		// data
		if(dataSource!=null) {
			if(Std.is(dataSource.data, Array)) {
				data = cast(dataSource.data, Array<Dynamic>);
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
			if(Std.is(dataSource.data, List)) {
				var j=0;
				data = cast(dataSource.data, List<Dynamic>);
				var items : Iterator<Dynamic> = data.iterator();
				for(i in items) {
					var item = new ListItem(this);
					item.init({ color: this.color,
						label: i
					});
					//item.label.mouseEnabled = false;
					item.move(0,20*j+1);
					j++;
				}
			}
		}
		// position
		x = Opts.optFloat(opts,"x",0) + 10;
		y = Opts.optFloat(opts,"y",0) + 20;

		// add the drop-shadow filter
		filters = [new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8,4, 4,0.65,flash.filters.BitmapFilterQuality.HIGH,false,false,false)];


		if(stage!=null)
		stage.addEventListener(MouseEvent.MOUSE_DOWN, shutDown, false, 0, true);


		dispatchEvent (new MenuEvent(MenuEvent.MENU_SHOW, false, false));
		dispatchEvent (new MenuEvent(MenuEvent.CHANGE, false, false));

		// for(i in this) (cast i).redraw();
	}
	//}}}


	//{{{ shutDown
	public function shutDown(e:MouseEvent) {
		//~ dispatchEvent (new MenuEvent(MenuEvent.MENU_HIDE));
		destroy();
	}
	//}}}


	//{{{ onAdded
	public override function onAdded(e:Event) {
		dispatchEvent (new MenuEvent(MenuEvent.MENU_SHOW));
	}
	//}}}


	//{{{ onKeyDown
	override public function onKeyDown (e:KeyboardEvent) {
	}
	//}}}


	//{{{ numItems
	public function numItems() {
		return items.length;
	}
	//}}}


	//{{{ onChanged
	public function onChanged() {
	}
	//}}}


	//{{{ destroy
	public override function destroy() {
		dispatchEvent(new MenuEvent(MenuEvent.MENU_HIDE));
		super.destroy();
	}
	//}}}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(PopupMenu);
	}
	//}}}
	//}}}
}

