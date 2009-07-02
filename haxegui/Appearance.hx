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

import flash.geom.Rectangle;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import haxegui.Window;
import haxegui.Component;
import haxegui.Image;
import haxegui.containers.Container;
import haxegui.containers.ScrollPane;
import haxegui.controls.Label;
import haxegui.controls.UiList;
import haxegui.controls.CheckBox;
import haxegui.controls.Stepper;
import haxegui.controls.Input;
import haxegui.controls.Tree;
import haxegui.TabNavigator;

import haxegui.events.ResizeEvent;

import haxegui.managers.FocusManager;
import haxegui.managers.StyleManager;
import flash.events.FocusEvent;
import haxegui.windowClasses.StatusBar;

/**
*
* Appearance class
* 
*
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.2
*/
class Appearance extends Window
{

	/**
	*
	*/
	public function new (?parent:DisplayObjectContainer, ?x:Float, ?y:Float)
	{
		super (parent, "Appearance", x, y);
	}

	public override function init(?opts:Dynamic)
	{
		//~ o = flash.Lib.current;

		super.init(opts);
		box = new Rectangle (0, 0, 320, 480);

			
		//
		var menubar = new MenuBar (this, "MenuBar", 10,20);
		menubar.init ();

		//
		//~ var container = new Container(this, "Container", 10, 44);
		//~ container.init({});
		
		var tabnav = new TabNavigator(this, "TabNavigator", 10, 44);
		tabnav.init();
		
		var tab = cast tabnav.addChild(new Tab());
		tab.init();

		var rect = new haxegui.toys.Rectangle(this);
		rect.init({width: 300, height: 20});
		rect.color = 0xFFD69A;
		rect.roundness = 12;
		rect.move(15, 74);
		
		var icon = new haxegui.Image(rect);
		icon.init({src: "assets/icons/notice.png"});
		icon.move(8,2);
		
		var label = new haxegui.controls.Label(rect);
		label.init({innerData: "Some settings here will only affect new components."});
		label.move(24,2);


		label = new haxegui.controls.Label(this);
		label.init({innerData: "Default Font:"});
		label.move(20,104);
		
		var combo = new haxegui.controls.ComboBox(this);
		combo.init();
		combo.move(120,100);
		combo.input.tf.text = "FFF_Harmony";
		//cat library.xml  | grep 'font id=' | awk '{ print (substr($2,4)",") }'
		combo.dropButton.setAction("mouseClick",
		"
		if(!this.disabled) {
		  parent.list = new haxegui.controls.UiList(root);
		  parent.list.data = 
			[
			\"FFF_Forward\",
			\"FFF_Manager_Bold\",
			\"FFF_Harmony\",
			\"FFF_Freedom_Trial\",
			\"FFF_Reaction_Trial\",
			\"Amiga_Forever_Pro2\",
			\"Silkscreen\",
			\"04b25\",
			\"Pixel_Classic\"
			];		  
		  parent.list.init();
		  parent.list.color = parent.color;

		  var p = new flash.geom.Point( parent.x, parent.y );		 	
		  p = parent.parent.localToGlobal(p);

		  parent.list.x = p.x + 1;
		  parent.list.y = p.y + 20;
		  parent.list.box.width = parent.box.width - 22;
		  parent.list.box.height = 200;
		  parent.list.removeChild(parent.list.header);
		  
		  parent.list.redraw();
		  
		  function click(e) {
			parent.input.tf.text = e.target.getChildAt(0).tf.text;
			DefaultStyle.FONT = e.target.getChildAt(0).tf.text;
		  }
		  
		  for(i in 0...parent.list.numChildren)
			parent.list.getChildAt(i).addEventListener(flash.events.MouseEvent.MOUSE_DOWN, click);
		  
		  var shadow = new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, flash.filters.BitmapFilterQuality.HIGH, false, false, false );
		  parent.list.filters = [shadow];
		  
		  function down(e) { 
			  trace(e); 
			  if(parent.list.stage.hasEventListener(flash.events.MouseEvent.MOUSE_DOWN))
				  parent.list.stage.removeEventListener(flash.events.MouseEvent.MOUSE_DOWN, down);
			  parent.list.parent.removeChild(parent.list);
			  parent.list = null;
			  }
		  parent.list.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, down);
		}
		");


		var colors = {
		BACKGROUND 		: DefaultStyle.BACKGROUND,
		DROPSHADOW 		: DefaultStyle.DROPSHADOW,
		ACTIVE_TITLEBAR : DefaultStyle.ACTIVE_TITLEBAR,
		INPUT_BACK 		: DefaultStyle.INPUT_BACK,
		INPUT_TEXT 		: DefaultStyle.INPUT_TEXT,
		PROGRESS_BAR 	: DefaultStyle.PROGRESS_BAR,
		FOCUS	 		: DefaultStyle.FOCUS
		};
		
	for(i in 0...Reflect.fields(colors).length) {

		label = new haxegui.controls.Label(this);
		var capitalize = function(word) { return Std.string(word.charAt(0).toUpperCase()) + word.substr(1,word.length-1); }
		var str = Reflect.fields(colors)[i].toLowerCase();
		var words = Lambda.list(str.split("_"));
		str = words.map(capitalize).join(" ");
		
		str += ":";
		label.init({innerData: str });
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
				var container = c.getChildByName(\"Container\");
				var ok = container.getChildByName(\"Ok\");
				var cancel = container.getChildByName(\"Cancel\");
				
				cancel.setAction(\"mouseClick\",\"this.getParentWindow().destroy();\");
				ok.addEventListener(flash.events.MouseEvent.MOUSE_UP,
				function(e) {
					spr.graphics.clear();
					spr.graphics.lineStyle(1,0);
					spr.graphics.beginFill(c.currentColor);
					spr.graphics.drawRect(4,4,32,22);
					spr.graphics.endFill();
					DefaultStyle."+Reflect.fields(colors)[i]+" = c.currentColor;
					c.destroy();
					});
		
		");
		
		var sprite = cast btn.addChild(new flash.display.Sprite());
		sprite.graphics.lineStyle(1,0);
		sprite.graphics.beginFill(Reflect.field(colors, Reflect.fields(colors)[i]));
		sprite.graphics.drawRect(4,4,32,22);
		sprite.graphics.endFill();

		}
	}

	
}
