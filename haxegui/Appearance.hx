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

package haxegui;

//{{{ Imports
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import haxegui.Window;
import haxegui.containers.Container;
import haxegui.containers.ScrollPane;
import haxegui.controls.CheckBox;
import haxegui.controls.Component;
import haxegui.controls.Image;
import haxegui.controls.Image;
import haxegui.controls.Input;
import haxegui.controls.Label;
import haxegui.controls.MenuBar;
import haxegui.controls.Stepper;
import haxegui.controls.Tree;
import haxegui.controls.UiList;
import haxegui.events.MenuEvent;
import haxegui.events.ResizeEvent;
import haxegui.managers.FocusManager;
import haxegui.managers.StyleManager;
import haxegui.utils.Color;
import haxegui.utils.Opts;
import haxegui.utils.Size;
import haxegui.windowClasses.StatusBar;
//}}}

using haxegui.utils.Color;

/**
*
* Appearance is a modal dialog, for changing the common look&feel
*
*
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.2
*/
class Appearance extends Window
{
	//{{{ Members
	public static var colorTheme : ColorTheme = {
		ACTIVE_TITLEBAR : DefaultStyle.ACTIVE_TITLEBAR,
		BACKGROUND 		: DefaultStyle.BACKGROUND,
		DROPSHADOW 		: DefaultStyle.DROPSHADOW,
		FOCUS	 		: DefaultStyle.FOCUS,
		INPUT_BACK 		: DefaultStyle.INPUT_BACK,
		INPUT_TEXT 		: DefaultStyle.INPUT_TEXT,
		LABEL_TEXT		: DefaultStyle.LABEL_TEXT,
		PROGRESS_BAR 	: DefaultStyle.PROGRESS_BAR,
		TOOLTIP			: DefaultStyle.TOOLTIP
	}

	public static var fonts = [
	"FFF_Forward",
	"FFF_Manager_Bold",
	"FFF_Harmony",
	"FFF_Freedom_Trial",
	"FFF_Reaction_Trial",
	"Amiga_Forever_Pro2",
	"Silkscreen",
	"04b25",
	"Pixel_Classic"
	];

	//{{{ Constructor
	public function new (?parent:DisplayObjectContainer, ?x:Float, ?y:Float) {
		super (parent, "Appearance", x, y);
	}
	//}}}

	//{{{ init
	public override function init(?opts:Dynamic) {
		super.init(opts);
		box = new Size(320, 480).toRect();

		//
		var menubar = new MenuBar (this, "MenuBar", 10,20);
		menubar.init ();

		//
		var container = new Container(this, "Container", 10, 44);
		container.init({});

		makeNoticeLabel();

		var label = new Label(this);
		label.init({text: "Default Font:"});
		label.move(20,104);

		var combo = new haxegui.controls.ComboBox(this);
		combo.init();
		combo.move(120,100);
		combo.input.tf.text = "FFF_Harmony";
		//cat library.xml  | grep 'font id=' | awk '{ print (substr($2,4)",") }'
		combo.data = fonts;

		var onFontSelected = function(e) {
			combo.input.tf.text = e.target.getChildAt(0).tf.text;
			DefaultStyle.FONT = e.target.getChildAt(0).tf.text;
		}
		combo.addEventListener(MenuEvent.MENU_SHOW, onFontSelected);

		var onFontMenu = function(e) { combo.menu.addEventListener(MouseEvent.MOUSE_DOWN, onFontSelected); }

		combo.addEventListener(MenuEvent.MENU_SHOW, onFontMenu);


		var capitalize = function(word) { return Std.string(word.charAt(0).toUpperCase()) + word.substr(1,word.length-1); }

		for(i in 0...Reflect.fields(colorTheme).length) {
			label = new Label(this);
			var str = Reflect.fields(colorTheme)[i].toLowerCase();
			var words = Lambda.list(str.split("_"));
			str = words.map(capitalize).join(" ");

			str += ":";
			label.init({text: str });
			label.move(20,144+30*i);

			var btn = new haxegui.controls.Button(this);
			btn.init({width: 40, label: null});
			btn.move(120, 134+30*i);
			btn.setAction("mouseClick",
			"
			var spr = this.getChildAt(0);

			var c = new haxegui.ColorPicker();
			c.currentColor = DefaultStyle.BACKGROUND;
			c.init();
			var container = c.getChildByName('Container');
			var ok = container.getChildByName('Ok');
			var cancel = container.getChildByName('Cancel');

			cancel.setAction('mouseClick', 'this.getParentWindow().destroy();');
			ok.addEventListener(flash.events.MouseEvent.MOUSE_UP,
			function(e) {
				spr.graphics.clear();
				spr.graphics.lineStyle(1,Color.darken(this.color, 40));
				spr.graphics.beginFill(c.currentColor);
				spr.graphics.drawRect(4,4,32,22);
				spr.graphics.endFill();
				DefaultStyle."+Reflect.fields(colorTheme)[i]+" = c.currentColor;
				c.destroy();
			});
			");

			//
			var swatch = cast btn.addChild(new flash.display.Sprite());
			swatch.graphics.lineStyle(1, this.color.darken(40));
			swatch.graphics.beginFill(Reflect.field(colorTheme, Reflect.fields(colorTheme)[i]));
			swatch.graphics.drawRect(4,4,32,22);
			swatch.graphics.endFill();
			swatch.mouseEnabled = false;
			swatch.filters = [new flash.filters.DropShadowFilter (2, 45, DefaultStyle.DROPSHADOW, 0.5, 4, 4,0.5,flash.filters.BitmapFilterQuality.HIGH,true,false,false)];

		}
	}
	//}}}

	//{{{ makeNoticeLabel
	private function makeNoticeLabel() {
		// background
		var rect = new haxegui.toys.Rectangle(this);
		rect.init({width: 300, height: 20});
		rect.color = 0xFFD69A;
		rect.roundness = 12;
		rect.move(15, 74);

		// icon
		var icon = new Icon(rect);
		icon.init({src: "notice.png"});
		icon.move(8,2);

		// label
		var label = new haxegui.controls.Label(rect);
		label.init({text: "Some settings here will only affect new components."});
		label.move(24,2);
	}
	//}}}
}
