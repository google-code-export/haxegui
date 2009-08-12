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
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.managers.CursorManager;
import haxegui.managers.MouseManager;
import haxegui.managers.ScriptManager;
import haxegui.managers.StyleManager;
import haxegui.toys.Arrow;
import haxegui.utils.Opts;
import haxegui.utils.Size;
//}}}


using haxegui.controls.Component;


//{{{ DividerHandleButton
/**
* Button for the divider handle collapse\expand fully.<br/>
*/
class DividerHandleButton extends AbstractButton {

	public var arrow : Arrow;

	//{{{ init
	override public function init(opts : Dynamic=null) {
		if(untyped parent.parent.horizontal)
		box = new Rectangle(0,0,10,100);
		else
		box = new Rectangle(0,0,100,10);

		color = DefaultStyle.BACKGROUND;
		super.init(opts);

		arrow = new Arrow(this);
		arrow.init({width: 6, height: 8, color: this.color});
		arrow.mouseEnabled = false;
		if(untyped parent.parent.horizontal)  {
			arrow.moveTo(5, .5*(this.box.height-8));
		}
		else {
			arrow.rotation = 90;
			arrow.moveTo(.5*(this.box.width-8), 5);
		}

	}
	//}}}

	public override function onMouseClick(e:MouseEvent) {
		if((cast parent.parent).horizontal) {
			parent.asComponent().moveTo(parent.parent.asComponent().box.width-10, 0);
		}

		arrow.rotation += 180;

		(cast parent.parent).adjust();

		super.onMouseClick(e);
	}

	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(DividerHandle);
	}
	//}}}
}
//}}}


//{{{ DividerHandle
/**
* Handle to resize cells in the divider.<br/>
*/
class DividerHandle extends AbstractButton {

	public var button : DividerHandleButton;

	public var oldPos : Float;

	//{{{ init
	override public function init(opts : Dynamic=null) {
		box = new Size(10, (cast parent).box.height).toRect();
		if((cast parent).horizontal)
		box = new Size((cast parent).box.width,10).toRect();

		color = DefaultStyle.BACKGROUND;
		cursorOver = Cursor.NS;
		cursorPress = Cursor.DRAG;


		super.init(opts);


		button = new DividerHandleButton(this);
		button.init();
		if((cast parent).horizontal)
		button.moveTo(0, .5*(box.height-100));
		else
		button.moveTo(.5*(box.width-100),0);

		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);
	}
	//}}}


	//{{{ onMouseMove
	public function onMouseMove(e:MouseEvent) {}
	//}}}


	//{{{ onParentResize
	public function onParentResize(e:ResizeEvent) {

		if((cast parent).horizontal) {
			box = new Size(10, (cast parent).box.height).toRect();
			button.y = Std.int(box.height-100)>>1;
		}
		else {
			box = new Size((cast parent).box.width,10).toRect();
			button.x = Std.int(box.width-100)>>1;
		}

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

	public var handle : DividerHandle;

	public var horizontal : Bool;

	//{{{ init
	override public function init(opts : Dynamic=null) {
		box = parent.asComponent().box.clone();
		horizontal = true;


		super.init(opts);


		horizontal = Opts.optBool(opts, "horizontal", horizontal);

		handle = new DividerHandle(this);
		handle.init();
		if(horizontal)
		handle.moveTo(box.width/2, 0);
		else
		handle.moveTo(0, .5*box.height);


		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);
		parent.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
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
			if(this.horizontal)
			handle.startDrag(false, new Rectangle(-this.stage.stageWidth,0,2*this.stage.stageWidth,0));
			else
			handle.startDrag(false, new Rectangle(0,-this.stage.stageHeight,0,2*this.stage.stageHeight));
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
		adjust();

		handle.dispatchEvent(new MoveEvent(MoveEvent.MOVE));
		dispatchEvent(new Event(Event.CHANGE));
	}
	//}}}


	public function adjust() {
		if(handle==null) return;

		if(horizontal) {
			if(this.iterator().hasNext()) {
				firstChild().asComponent().box.width = handle.x - 1;
				if(Std.is(firstChild().asComponent(), ScrollPane))
				firstChild().asComponent().box.width -= 20;

				firstChild().asComponent().redraw();
				firstChild().dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
			}

			if(this.numChildren==3) {
				firstChild().asComponent().nextSibling().x = handle.x + 11;
				firstChild().asComponent().nextSibling().asComponent().box.width = this.box.width - handle.x - 11;
				firstChild().asComponent().nextSibling().asComponent().redraw();
				firstChild().asComponent().nextSibling().dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));

				if(firstChild().asComponent().nextSibling().asComponent().getElementsByClass(haxegui.controls.ScrollBar).hasNext())
				firstChild().asComponent().nextSibling().asComponent().box.width -= 20;
			}
		}
		else {
			if(firstChild()!=null) {
				firstChild().asComponent().box.height = handle.y - 1;
				firstChild().asComponent().redraw();
				firstChild().dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
			}

			if(this.numChildren==3) {
				firstChild().asComponent().nextSibling().y = handle.y + 11;
				firstChild().asComponent().nextSibling().asComponent().box.height = this.box.height - handle.y - 1;
				firstChild().asComponent().nextSibling().asComponent().redraw();
				firstChild().asComponent().nextSibling().dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
			}
		}
	}


	override function onResize(e:ResizeEvent) {
		if(handle!=null) {
		if(horizontal)
			handle.x = Math.min( handle.x, box.width-10 );
		else
			handle.y = Math.min( handle.y, box.height-10 );
		}

		super.onResize(e);
	}


	//{{{ onParentResize
	private override function onParentResize(e:ResizeEvent) {

		// box = parent.asComponent().box.clone();

		// // redraw();
		// if(handle!=null)
		// if(horizontal) {
		// 	handle.x = .5*box.width;
		// }
		// else
		// 	handle.y = .5*box.height;

		adjust();

		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}
	//}}}
}
//}}}