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

import haxegui.CursorManager;
import haxegui.StyleManager;

/**
*
* Titlebar class
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class TitleBar extends Component, implements Dynamic
{

	public var title : TextField;
	public var closeButton : CloseButton;
	public var minimizeButton : Component;

	public function new (parent:DisplayObjectContainer=null, name:String=null, x:Float=0.0, y:Float=0.0)
	{
		super(parent, name, x, y);
	}

	public function init(?initObj:Dynamic) {
		//
		this.graphics.beginFill (0x1A1A1A, 0.5);
		this.graphics.drawRoundRectComplex (0, 0, initObj.w, 32, 4, 4, 0, 0);
		this.graphics.drawRect (10, 20, initObj.w - 20, 12);
		this.graphics.endFill ();


		//
		//~ closeButton = new Component(this, "closeButton");
		closeButton = new CloseButton(this, "closeButton");
		closeButton.init({});
		closeButton.move(4,4);

		//
		minimizeButton = new Component(this, "minimizeButton");
		minimizeButton.move(20, 4);

		//mc.x = box.width - 32;
		title = new TextField ();
		title.name = "title";
		title.text = (initObj.title==null)?this.name:initObj.title;
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
		this.quality = flash.display.StageQuality.LOW;

		title.setTextFormat (StyleManager.getTextFormat());

		this.addChild (title);
	}




		/**
		*
		*
		*/
	public function redraw (? color : Int, ? w : Float):Void
	{
		title.x = Math.floor((w - title.width)/2);
		//~ title.width = Math.floor(w - 85);
		//~ title.y = 1;

		if(closeButton != null)
			closeButton.redraw(color, w);
// 		StyleManager.exec("redrawTitleBar", this, {w:w, color:color});
// 		StyleManager.exec("redrawCloseButton", closeButton, {color:color});
// 		StyleManager.exec("redrawMinimizeButton", minimizeButton, {color:color});

		title.setTextFormat (StyleManager.getTextFormat(8,DefaultStyle.LABEL_TEXT, flash.text.TextFormatAlign.CENTER));

	}

	public function onRollOver (e:MouseEvent)
	{
		CursorManager.setCursor(Cursor.HAND);
	}

	public function onRollOut (e:MouseEvent)
	{
		//~CursorManager.setCursor(Cursor.HAND);
	}

	public function onMouseUp (e:MouseEvent)
	{

	}


}