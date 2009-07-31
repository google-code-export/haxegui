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

package haxegui.windowClasses;

import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.managers.CursorManager;
import haxegui.managers.ScriptManager;
import haxegui.managers.StyleManager;
import haxegui.controls.Component;
import haxegui.controls.AbstractButton;
import haxegui.controls.Image;
import haxegui.controls.Label;
import haxegui.Window;

import haxegui.utils.Size;
import haxegui.utils.Color;
import haxegui.utils.Opts;

/**
*
* Close CloseButton Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class CloseButton extends AbstractButton
{
	public function new(?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float) {
		super (parent, name, x, y);
		description = "Close Window";
	}

 	override public function onMouseClick(e:MouseEvent) : Void	{
 		trace("Close clicked on " + parent.parent.toString());
		this.getParentWindow().destroy();
 	}

	static function __init__() {
		haxegui.Haxegui.register(CloseButton);
	}
}



/**
*
* MinimizeButton Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class MinimizeButton extends AbstractButton
{
	public function new(?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float) {
		super (parent, name, x, y);
		description = "Minimize Window";
	}

	override public function onMouseClick(e:MouseEvent) : Void
	{
		trace("Minimized clicked on " + parent.parent.toString());
		//~ parent.dispatchEvent(new Event(Event.CLOSE));
	}

	static function __init__() {
		haxegui.Haxegui.register(MinimizeButton);
	}
}




/**
*
* MaximizeButton Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class MaximizeButton extends AbstractButton
{
	public function new(?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float) {
		super (parent, name, x, y);
		description = "Maximize Window";
	}

	override public function onMouseClick(e:MouseEvent) : Void
	{
		trace("Maximize clicked on " + parent.parent.toString());
		//~ parent.dispatchEvent(new Event(Event.CLOSE));
	}

	static function __init__() {
		haxegui.Haxegui.register(MaximizeButton);
	}
}


/**
*
* Titlebar class
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class TitleBar extends AbstractButton
{
	public var title 		  : Label;
	public var closeButton 	  : CloseButton;
	public var minimizeButton : MinimizeButton;
	public var maximizeButton : MaximizeButton;
	public var icon			  : Icon;
	
	static inline var titleOffset : Int = -4;
	
	override public function init(?opts:Dynamic) {
		if(!Std.is(parent, Window)) throw parent+" not a Window";
	
		box = new flash.geom.Rectangle(0,0, (cast parent).box.width, 32);
		cursorOver = Cursor.SIZE_ALL;

		super.init(opts);

		closeButton = new CloseButton(this, "closeButton");
		closeButton.init({color: this.color });
		closeButton.moveTo(4,4);
		closeButton.filters = [new flash.filters.DropShadowFilter (1, 45, DefaultStyle.DROPSHADOW, 0.5, 2, 2, 0.5, flash.filters.BitmapFilterQuality.LOW, true, false, false )];
		closeButton.redraw();

		minimizeButton = new MinimizeButton(this, "minimizeButton");
		minimizeButton.init({color: this.color });
		minimizeButton.moveTo(20,4);
		minimizeButton.filters = [new flash.filters.DropShadowFilter (1, 45, DefaultStyle.DROPSHADOW, 0.5, 2, 2, 0.5, flash.filters.BitmapFilterQuality.LOW, true, false, false )];

		maximizeButton = new MaximizeButton(this, "maximizeButton");
		maximizeButton.init({color: this.color });
		maximizeButton.moveTo(36,4);
		maximizeButton.filters = [new flash.filters.DropShadowFilter (1, 45, DefaultStyle.DROPSHADOW, 0.5, 2, 2, 0.5, flash.filters.BitmapFilterQuality.LOW, true, false, false )];

		//closeButton.useHandCursors = minimizeButton.useHandCursors = maximizeButton.useHandCursors = true;

		title = new Label(this);
		title.init({text: Opts.optString(opts,"title", name)});
		title.mouseEnabled = false;
		title.tabEnabled = false;
		title.center();
		title.move(0, titleOffset);
		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);
	}

	override public function onRollOver (e:MouseEvent) {
		CursorManager.setCursor(this.cursorOver);
		super.onRollOver(e);
	}

	override public function onRollOut (e:MouseEvent) {
		CursorManager.setCursor(Cursor.ARROW);
		super.onRollOut(e);
	}

	override public function onMouseDown (e:MouseEvent)	{
		CursorManager.getInstance().lock = true;
		this.updateColorTween( new feffects.Tween(0, -50, 350, feffects.easing.Linear.easeOut) );
		var win = this.getParentWindow();
		if(win != null) {
			win.startDrag();
			win.addEventListener(flash.events.MouseEvent.MOUSE_UP, function(e){ win.stopDrag(); });
			win.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, function(e){ win.dispatchEvent(new MoveEvent(MoveEvent.MOVE)); });
		}
		// dispatch(MoveEvent)
		super.onMouseDown(e);
	}

	override public function onMouseUp (e:MouseEvent) {
		CursorManager.getInstance().lock = false;
		this.updateColorTween( new feffects.Tween(-50, 0, 120, feffects.easing.Linear.easeNone) );

		var win = this.getParentWindow();
		if(win != null) {
			win.stopDrag();
		}

		if(this.hitTestObject( CursorManager.getInstance()._mc ))
			CursorManager.setCursor(this.cursorOver);
		else
			CursorManager.setCursor(Cursor.ARROW);

		super.onMouseUp(e);
	}

	public function onParentResize(e:ResizeEvent) {
		box = new Size((cast parent).box.width, 32).toRect();
		redraw();
		title.center();
		title.move(0, titleOffset);
	}

	static function __init__() {
		haxegui.Haxegui.register(TitleBar);
	}
}
