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

//{{{ Imports
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.geom.Point;
import haxegui.Window;
import haxegui.XmlParser;
import haxegui.controls.AbstractButton;
import haxegui.controls.Component;
import haxegui.controls.Image;
import haxegui.controls.Label;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.managers.CursorManager;
import haxegui.managers.ScriptManager;
import haxegui.managers.StyleManager;
import haxegui.utils.Color;
import haxegui.utils.Opts;
import haxegui.utils.Size;
//}}}

//{{{ CloseButton
/**
*
* Close CloseButton Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class CloseButton extends AbstractButton {
	//{{{ Constructor
	public function new(?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float) {
		super (parent, name, x, y);
		description = "Close Window";
	}
	//}}}

	///{{{ Functions
	//{{{ onMouseClick
	override public function onMouseClick(e:MouseEvent) : Void	{
		trace("Close clicked on " + parent.parent.toString());
		this.getParentWindow().destroy();
	}
	//}}}

	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(CloseButton);
	}
	//}}}
	//}}}
}
//}}}

//{{{ MinimizeButton
/**
* A TitleBar Button to minimize the window
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class MinimizeButton extends AbstractButton {

	//{{{ Constructor
	public function new(?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float) {
		super (parent, name, x, y);
		description = "Minimize Window";
	}
	//}}}


	//{{{ onMouseClick
	override public function onMouseClick(e:MouseEvent) : Void	{
		trace("Minimized clicked on " + parent.parent.toString());
		//~ parent.dispatchEvent(new Event(Event.CLOSE));
	}
	//}}}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(MinimizeButton);
	}
	//}}}
}
//}}}

//{{{ MaximizeButton
/**
*
* MaximizeButton Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class MaximizeButton extends AbstractButton {

	//{{{ Constructor
	public function new(?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float) {
		super (parent, name, x, y);
		description = "Maximize Window";
	}
	//}}}

	//{{{ Functions
	//{{{ onMouseClick
	override public function onMouseClick(e:MouseEvent) : Void {
		trace("Maximize clicked on " + parent.parent.toString());
		//~ parent.dispatchEvent(new Event(Event.CLOSE));
	}
	//}}}

	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(MaximizeButton);
	}
	//}}}
	//}}}
}
//}}}

//{{{ Titlebar
/**
*
* Titlebar class
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class TitleBar extends AbstractButton {

	//{{{ Members
	//{{{ Static
	/** Title offset from center titlebar **/
	static inline var titleOffset : Point = new Point(0,-4);

	static var xml = Xml.parse(	'
	<haxegui:Layout name="TitleBar">
	<haxegui:windowClasses:CloseButton x="4" y="4"/>
	<haxegui:windowClasses:MinimizeButton x="20" y="4"/>
	<haxegui:windowClasses:MaximizeButton x="36" y="4"/>
	<haxegui:controls:Label/>
	<haxegui:controls:Icon src="applications-system.png"/>
	</haxegui:Layout>
	').firstElement();
	//}}}
	//}}}


	//{{{ Functions
	//{{{ init
	/**
	* @throws String warning when not attached to a window
	*/
	override public function init(?opts:Dynamic) {
		if(!Std.is(parent, Window)) throw parent+" not a Window";


		box = new flash.geom.Rectangle(0,0, (cast parent).box.width, 32);
		color = (cast parent).color;
		// cursorOver = Cursor.SIZE_ALL;


		super.init(opts);

		xml.set("name", name);

		XmlParser.apply(TitleBar.xml, this);

/*
		// closeButton
		closeButton = new CloseButton(this, "closeButton");
		closeButton.init({color: this.color });
		closeButton.moveTo(4,4);
		closeButton.redraw();


		// minimizeButton
		minimizeButton = new MinimizeButton(this, "minimizeButton");
		minimizeButton.init({color: this.color });
		minimizeButton.moveTo(20,4);


		// maximizeButton
		maximizeButton = new MaximizeButton(this, "maximizeButton");
		maximizeButton.init({color: this.color });
		maximizeButton.moveTo(36,4);


		// filters
		closeButton.filters = minimizeButton.filters = maximizeButton.filters = [new flash.filters.DropShadowFilter (1, 45, DefaultStyle.DROPSHADOW, 0.5, 2, 2, 0.5, flash.filters.BitmapFilterQuality.LOW, true, false, false )];
		//closeButton.useHandCursors = minimizeButton.useHandCursors = maximizeButton.useHandCursors = true;


		// title
		title = new Label(this);
		title.init({text: Opts.optString(opts,"title", name)});
		title.mouseEnabled = false;
		title.tabEnabled = false;
		title.center();
		title.movePoint(titleOffset);
*/

		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);
	}
	//}}}

	//{{{ onRollOver
	override public function onRollOver (e:MouseEvent) {
		CursorManager.setCursor(this.cursorOver);
		super.onRollOver(e);
	}
	//}}}

	//{{{ onRollOut
	override public function onRollOut (e:MouseEvent) {
		CursorManager.setCursor(Cursor.ARROW);
		super.onRollOut(e);
	}
	//}}}

	//{{{ onMouseDown
	override public function onMouseDown (e:MouseEvent)	{
		#if debug
		trace(e);
		#end

		CursorManager.getInstance().lock = true;


		this.updateColorTween( new feffects.Tween(0, -50, 350, feffects.easing.Linear.easeOut) );


		var win = this.getParentWindow();
		if(win==null) return;


		win.startDrag();
		win.addEventListener(MouseEvent.MOUSE_UP, onStopDrag, false, 0, true);
		win.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);


		super.onMouseDown(e);
	}
	//}}}


	//{{{ onMouseMove
	public function onMouseMove(e:MouseEvent) {
		var win = this.getParentWindow();
		if(win==null) return;
		win.dispatchEvent(new MoveEvent(MoveEvent.MOVE));
	}
	//}}}


	//{{{ onStopDrag
	public function onStopDrag(e:MouseEvent) {
		var win = this.getParentWindow();
		if(win==null) return;

		win.stopDrag();
	}
	//}}}


	//{{{ onMouseUp
	override public function onMouseUp (e:MouseEvent) {
		#if debug
		trace(e);
		#end

		CursorManager.getInstance().lock = false;


		this.updateColorTween( new feffects.Tween(-50, 0, 120, feffects.easing.Linear.easeNone) );


		var win = this.getParentWindow();
		if(win== null) return;


		win.stopDrag();
		win.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		win.removeEventListener(MouseEvent.MOUSE_UP, onStopDrag);


		if(this.hitTestObject( CursorManager.getInstance()._mc ))
		CursorManager.setCursor(this.cursorOver);
		else
		CursorManager.setCursor(Cursor.ARROW);


		super.onMouseUp(e);
	}
	//}}}


	//{{{ onMouseDoubleClick
	/**
	* @todo window shading
	*/
	public override function onMouseDoubleClick(e:MouseEvent) : Void {
		super.onMouseDoubleClick(e);
	}
	//}}}


	//{{{ onParentResize
	public function onParentResize(e:ResizeEvent) {
		box = new Size((cast parent).box.width, 32).toRect();
		redraw();

		var icon = this.getElementsByClass(Icon).next();
		if(icon==null) return;
		icon.moveTo((cast parent).box.width-12, 2);

		var title = this.getElementsByClass(Label).next();
		if(title==null) return;
		title.center();
		title.movePoint(titleOffset);
	}
	//}}}

	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(TitleBar);
	}
	//}}}
	//}}}
}
//}}}

