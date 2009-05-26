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
import flash.text.TextField;
import flash.text.TextFormat;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilterQuality;
import haxegui.events.ResizeEvent;
import haxegui.managers.CursorManager;
import haxegui.Opts;
import haxegui.managers.ScriptManager;
import haxegui.managers.StyleManager;
import haxegui.Component;
import haxegui.controls.AbstractButton;

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
	}

// 	override public function onMouseClick(e:MouseEvent) : Void	{
// 		trace("Close clicked on " + parent.parent.toString());
// 		//~ parent.dispatchEvent(new Event(Event.CLOSE));
// 	}

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

	public var title : TextField;
	public var closeButton 	  : CloseButton;
	public var minimizeButton : MinimizeButton;
	public var maximizeButton : MaximizeButton;

	public function new (parent:DisplayObjectContainer=null, name:String=null, x:Float=0.0, y:Float=0.0)
	{
		super(parent, name, x, y);
	}

	override public function init(?opts:Dynamic) {

		box = new flash.geom.Rectangle(0,0, (cast parent).box.width, 32);
		cursorOver = Cursor.SIZE_ALL;

		super.init(opts);

		closeButton = new CloseButton(this, "closeButton");
		closeButton.init({color: this.color });
		closeButton.moveTo(4,4);
		var shadow:DropShadowFilter = new DropShadowFilter (2, 45, DefaultStyle.DROPSHADOW, 0.5, 4, 4, 0.5, BitmapFilterQuality.HIGH, false, false, false );
		closeButton.filters = [shadow];
		closeButton.redraw();

		minimizeButton = new MinimizeButton(this, "minimizeButton");
		minimizeButton.init({color: this.color });
		minimizeButton.moveTo(20,4);
		minimizeButton.filters = [shadow];

		maximizeButton = new MaximizeButton(this, "maximizeButton");
		maximizeButton.init({color: this.color });
		maximizeButton.moveTo(36,4);
		maximizeButton.filters = [shadow];

		//closeButton.useHandCursors = minimizeButton.useHandCursors = maximizeButton.useHandCursors = true;



		title = new TextField ();
		title.name = Opts.optString(opts,"title","");
		title.text = (opts.title==null)?this.name:opts.title;
		title.border = false;
		title.x = 40;
		title.y = 1;
		title.autoSize = flash.text.TextFieldAutoSize.LEFT;
		title.height = 18;
		title.selectable = false;
		title.mouseEnabled = false;
		title.tabEnabled = false;
		title.multiline = false;
		title.embedFonts = true;

		//~ title.antiAliasType = flash.text.AntiAliasType.NORMAL;
		//~ title.sharpness = 100;
		//this.quality = flash.display.StageQuality.LOW;

		title.setTextFormat (DefaultStyle.getTextFormat());

		this.addChild (title);

		parent.addEventListener(ResizeEvent.RESIZE, onParentResize);
	}

	override public function redraw(opts:Dynamic=null):Void
	{
		this.box = (cast this.parent).box.clone();
		title.x = Math.floor((this.box.width - title.width)/2);

		title.setTextFormat (DefaultStyle.getTextFormat(8,DefaultStyle.LABEL_TEXT, flash.text.TextFormatAlign.CENTER));

		ScriptManager.exec(this,"redraw",
			{
				color: Opts.optInt(opts, "color", color),
			});
	}

	override public function onRollOver (e:MouseEvent)
	{
		CursorManager.setCursor(this.cursorOver);
	}

	override public function onRollOut (e:MouseEvent)
	{
		CursorManager.setCursor(Cursor.ARROW);
	}

	override public function onMouseDown (e:MouseEvent)
	{
		CursorManager.getInstance().lock = true;
		this.updateColorTween( new feffects.Tween(0, -50, 350, feffects.easing.Linear.easeOut) );
		var win = this.getParentWindow();
		if(win != null) {
			win.startDrag();
			win.addEventListener(flash.events.MouseEvent.MOUSE_UP, function(e){ win.stopDrag(); });
		}
		// dispatch(MoveEvent)
	}

	override public function onMouseUp (e:MouseEvent)
	{
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
	}

	static function __init__() {
		haxegui.Haxegui.register(TitleBar);
	}

	public function onParentResize(e:ResizeEvent)
	{
		redraw();
	}

}
