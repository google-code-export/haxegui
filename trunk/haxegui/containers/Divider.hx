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

package haxegui.containers;


//{{{ Imports
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;
import haxegui.containers.IContainer;
import haxegui.controls.AbstractButton;
import haxegui.controls.Component;
import haxegui.events.ResizeEvent;
import haxegui.managers.CursorManager;
import haxegui.managers.MouseManager;
import haxegui.managers.ScriptManager;
import haxegui.managers.StyleManager;
import haxegui.utils.Opts;
import haxegui.utils.Size;
//}}}


using haxegui.controls.Component;


//{{{ DividerHandleButton
/**
* Button for the divider handle collapse\expand fully.<br/>
*/
class DividerHandleButton extends AbstractButton {

	override public function init(opts : Dynamic=null)
	{
		if(untyped parent.parent.horizontal)
		box = new Rectangle(0,0,10,100);
		else
		box = new Rectangle(0,0,100,10);

		color = DefaultStyle.BACKGROUND;
		super.init(opts);

		var arrow = new haxegui.toys.Arrow(this);
		arrow.init({width: 6, height: 8, color: this.color});
		if(untyped parent.parent.horizontal)  {
			arrow.moveTo(5, .5*(this.box.height-8));
		}
		else {
			arrow.rotation = 90;
			arrow.moveTo(.5*(this.box.width-8), 5);
		}

	}

	static function __init__() {
		haxegui.Haxegui.register(DividerHandle);
	}
}
//}}}


//{{{ DividerHandle
/**
* Handle to resize cells in the divider.<br/>
*/
class DividerHandle extends AbstractButton {

	public var button : DividerHandleButton;

	override public function init(opts : Dynamic=null) {
		if((cast parent).horizontal)
		box = new Rectangle(0,0,10,512);
		else
		box = new Rectangle(0,0,512,10);

		color = DefaultStyle.BACKGROUND;
		cursorOver = Cursor.NS;
		cursorPress = Cursor.DRAG;


		super.init(opts);


		button = new DividerHandleButton(this);
		button.init();
		if((cast parent).horizontal)
		button.moveTo(0, .5*(512-100));
		else
		button.moveTo(.5*(512-100),0);

	}

	//{{{ onMouseMove
	public function onMouseMove(e:MouseEvent) {}
	//}}}


	//{{{ onParentResize
	public function onParentResize(e:ResizeEvent) {
		redraw();
	}
	//}}}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(DividerHandle);
	}
	//}}}

}
//}}}


//{{{ Divider
/**
* Divider is a split pane containers.<br/>
*
* @todo the whole thing
*
* @version 0.1
* @author Russell Weir <damonsbane@gmail.com>
* @author Omer Goshen <gershon@goosemoose.com>
*/
class Divider extends Container {

	var handle : DividerHandle;

	var horizontal : Bool;

	//{{{ init
	override public function init(opts : Dynamic=null) {
		box = parent.asComponent().box.clone();
		horizontal = Opts.optBool(opts, "horizontal", false);


		super.init(opts);


		handle = new DividerHandle(this);
		handle.init();
		if(horizontal)
		handle.moveTo(250, 0);
		else
		handle.moveTo(0, 250);


		parent.addEventListener(ResizeEvent.RESIZE, onParentResize);
	}
	//}}}


	//{{{ addChild
	public override function addChild(o:DisplayObject) {
		if(handle==null) return super.addChild(o);
		var r = super.addChild(o);
		handle.toFront();
		return r;
	}
	//}}}


	//{{{ onMouseDown
	public override function onMouseDown(e:MouseEvent) {
		if(e.target==handle) {
			if(horizontal)
			e.target.startDrag(false, new Rectangle(-this.stage.stageWidth,0,2*this.stage.stageWidth,0));
			else
			e.target.startDrag(false, new Rectangle(0,-this.stage.stageHeight,0,2*this.stage.stageHeight));
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		super.onMouseDown(e);
	}
	//}}}


	//{{{ onMouseUp
	public override function onMouseUp(e:MouseEvent) {
		handle.stopDrag();
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		super.onMouseUp(e);
	}
	//}}}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(Divider);
	}
	//}}}


	//{{{ onMouseMove
	public function onMouseMove(e:MouseEvent) {
		firstChild().asComponent().box.width = handle.x - 1;
		firstChild().asComponent().redraw();

		firstChild().asComponent().nextSibling().x = handle.x - 1;
		// firstChild().nextSibling().asComponent().redraw();
	}
	//}}}


	//{{{ onParentResize
	private override function onParentResize(e:ResizeEvent) {
		// var size = new Size(parent.width - x, parent.height - y);

		// if(Std.is(parent, Component))
		// size = untyped new Size(parent.box.width - x, parent.box.height - y);

		// box = size.toRect();

		box = parent.asComponent().box.clone();

		if(handle!=null) {
			if(horizontal)
			handle.box.height = box.height;
			else
			handle.box.width = box.width;
			// handle.dirty = true;
			handle.redraw();
		}


		redraw();

		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}
	//}}}
}
//}}}