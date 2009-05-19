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

import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilterQuality;
import haxegui.CursorManager;
import haxegui.Opts;
import haxegui.ScriptManager;
import haxegui.StyleManager;


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
class TitleBar extends Component
{

	public var title : TextField;
	public var closeButton : CloseButton;
	public var minimizeButton : MinimizeButton;
	public var maximizeButton : MaximizeButton;

	public function new (parent:DisplayObjectContainer=null, name:String=null, x:Float=0.0, y:Float=0.0)
	{
		super(parent, name, x, y);
	}

	override public function init(?opts:Dynamic) {
		super.init(opts);

		//
		//~ closeButton = new Component(this, "closeButton");
		closeButton = new CloseButton(this, "closeButton");
		closeButton.init({color: this.color });
		closeButton.moveTo(4,4);
		var shadow:DropShadowFilter = new DropShadowFilter (2, 45, DefaultStyle.DROPSHADOW, 0.5, 4, 4, 0.5, BitmapFilterQuality.HIGH, false, false, false );
		closeButton.filters = [shadow];

		//
		//~ minimizeButton = new MinimizeButton(this, "minimizeButton");
		minimizeButton = new MinimizeButton(this, "minimizeButton");
		minimizeButton.init({color: this.color });
		minimizeButton.moveTo(20,4);
		minimizeButton.filters = [shadow];

		//
		//~ minimizeButton = new MinimizeButton(this, "minimizeButton");
		maximizeButton = new MaximizeButton(this, "maximizeButton");
		maximizeButton.init({color: this.color });
		maximizeButton.moveTo(36,4);
		maximizeButton.filters = [shadow];

		//mc.x = box.width - 32;
		title = new TextField ();
		title.name = Opts.optString(opts,"title","");
		title.text = (opts.title==null)?this.name:opts.title;
		title.border = false;
		//~ title.textColor = 0x000000;
		title.x = 40;
		title.y = 1;
		//~ title.width = parent.width - 85;
		title.autoSize = flash.text.TextFieldAutoSize.LEFT;
		title.height = 18;
		title.selectable = false;
		title.mouseEnabled = false;
		title.tabEnabled = false;
		title.multiline = false;
		title.embedFonts = true;

		//~ title.antiAliasType = flash.text.AntiAliasType.NORMAL;
		//~ title.sharpness = 100;
		//~ this.quality = flash.display.StageQuality.LOW;

		title.setTextFormat (DefaultStyle.getTextFormat());

		this.addChild (title);
	}


	override public function redraw(opts:Dynamic=null):Void
	{
		var w = Opts.optFloat(opts, "width", title.width);
		title.x = Math.floor((w - title.width)/2);

		if(closeButton != null)
			closeButton.redraw(opts);
		if(minimizeButton != null)
			minimizeButton.redraw(opts);
		if(minimizeButton != null)
			maximizeButton.redraw(opts);

		title.setTextFormat (DefaultStyle.getTextFormat(8,DefaultStyle.LABEL_TEXT, flash.text.TextFormatAlign.CENTER));

		ScriptManager.exec(this,"redraw",
			{
				width : w,
				color: Opts.optInt(opts, "color", color),
			});

	}

	override public function onRollOver (e:MouseEvent)
	{
		CursorManager.setCursor(Cursor.HAND);
	}

	override public function onRollOut (e:MouseEvent)
	{
		CursorManager.setCursor(Cursor.ARROW);
	}

	override public function onMouseUp (e:MouseEvent)
	{
		CursorManager.setCursor(Cursor.ARROW);
	}

	static function __init__() {
		haxegui.Haxegui.register(TitleBar);
	}

}
