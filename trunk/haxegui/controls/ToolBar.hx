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
import flash.display.Graphics;
import flash.display.LineScaleMode;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import flash.ui.Mouse;
import haxegui.controls.AbstractButton;
import haxegui.controls.Component;
import haxegui.events.DragEvent;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.managers.CursorManager;
import haxegui.managers.MouseManager;
import haxegui.managers.StyleManager;
import haxegui.managers.WindowManager;
import haxegui.utils.Color;
import haxegui.utils.Size;
//}}}


//{{{ ToolBarHandle
/**
* Handle to detach the [ToolBar]<br/>
*/
class ToolBarHandle extends AbstractButton, implements IComposite
{
	//{{{ init
	override public function init (? opts : Dynamic) {
		super.init();
	}
	//}}}

	//{{{ onMouseDown
	override public function onMouseDown(e:MouseEvent) {
		untyped parent.startDrag();
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
	}
	//}}}

	//{{{ onMouseUp
	override public function onMouseUp(e:MouseEvent) {
		untyped parent.stopDrag();
		stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp, false);
	}
	//}}}

	//{{{
	static function __init__() {haxegui.Haxegui.register(ToolBarHandle);
		haxegui.Haxegui.register(ToolBarHandle);

	}
	//}}}
}
//}}}


//{{{ ToolBar
/**
* ToolBar for widgets.<br/>
*
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.2
*/
class ToolBar extends Component, implements IRubberBand
{
	public var handle 	  : ToolBarHandle;
	public var seperators : Array<Seperator>;

	//{{{ init
	override public function init (? opts : Dynamic) {
		color = DefaultStyle.BACKGROUND;
		box = new Size(502,40).toRect();

		super.init(opts);

		description = null;

		handle = new ToolBarHandle(this);
		handle.init();
		handle.move(8,8);

		// inner-drop-shadow filter
		this.filters = [new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5,4, 4, 0.5, flash.filters.BitmapFilterQuality.LOW,true,false,false)];

		parent.addEventListener (ResizeEvent.RESIZE, onParentResize);
	}
	//}}}



	//{{{ onParentResize
	public function onParentResize(e:ResizeEvent) {
		var b = untyped parent.box.clone();
		//~ box = untyped parent.box.clone();
		//~ if(!Math.isNaN(e.oldWidth))
		//~ box.width = e.oldWidth;


		box.width = b.width - x;
		//~ box.height -= y;

		//~ var _m = new Shape();
		//~ _m.graphics.beginFill(0xFF00FF);
		//~ _m.graphics.drawRect(0,0,box.width,box.height);
		//~ _m.graphics.endFill();
		//~ mask = _m;

		scrollRect = box.clone();

		redraw();
	}
	//}}}

	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(ToolBar);
	}
	//}}}

}
//}}}