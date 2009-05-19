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


import flash.Lib;

import flash.system.Capabilities;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.MovieClip;
import flash.display.Loader;
import flash.display.LoaderInfo;

import flash.display.Bitmap;

import flash.events.EventDispatcher;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;

import haxegui.events.MenuEvent;

import flash.net.URLLoader;
import flash.net.URLRequest;

import haxegui.WindowManager;
import haxegui.StyleManager;
import haxegui.ScriptManager;
import haxegui.FocusManager;
import haxegui.LayoutManager;
import haxegui.CursorManager;
import haxegui.MouseManager;
import haxegui.PopupMenu;

import haxegui.Console;
import haxegui.Container;
import haxegui.ScrollPane;
import haxegui.TabNavigator;
import haxegui.MenuBar;
import haxegui.Stats;
import haxegui.ToolBar;
import haxegui.ColorPicker;
import haxegui.Utils;


import haxegui.controls.Button;
import haxegui.controls.Label;
import haxegui.controls.Input;
import haxegui.controls.Slider;
import haxegui.controls.Stepper;
import haxegui.controls.RadioButton;
import haxegui.controls.CheckBox;
import haxegui.controls.ComboBox;
import haxegui.controls.UiList;
import haxegui.controls.Expander;

import feffects.Tween;



class Main extends Sprite, implements haxe.rtti.Infos
{

	static var log : haxe.Log;

	public static function main ()
	{
		// Setup Haxegui
		haxegui.Haxegui.init();

		// Set stage propeties
		var stage = flash.Lib.current.stage;
		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		stage.align = flash.display.StageAlign.TOP_LEFT;
		stage.stageFocusRect = true;

		// Assign a stage resize listener
		stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);

		// Desktop
		var desktop = new Sprite();
		desktop.name = "desktop";
		desktop.mouseEnabled = false;

		var colors = [ DefaultStyle.BACKGROUND, DefaultStyle.BACKGROUND - 0x4D4D4D ];
		var alphas = [ 100, 100 ];
		var ratios = [ 0, 0xFF ];
		var matrix = new flash.geom.Matrix();
		matrix.createGradientBox(stage.stageWidth, stage.stageHeight, Math.PI/2, 0, 0);
		desktop.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );
		desktop.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
		desktop.graphics.endFill();
		flash.Lib.current.addChild(desktop);



		// Console to show some debug
		var console = new Console (flash.Lib.current, 50, 50);
		console.init({color:0x2E2E2E, visible: false });
		haxe.Log.clear();
		setRedirection(console.log);

		trace("<FONT SIZE='24' FACE='_mono'>Hello and welcome.</FONT>");
		trace("<FONT SIZE='12' FACE='_mono'>"+flash.system.Capabilities.os+" "+flash.system.Capabilities.version+" "+flash.system.Capabilities.playerType+".</FONT>");

		stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e){ if(e.charCode=="`".code) console.visible = !console.visible; });


		// Statistics
		//~ var stats = new Stats (flash.Lib.current, 540, 80);
		//~ stats.init();

		// Color Picker
		//~ var colorpicker = new ColorPicker(100,100);
		//~ colorpicker.init();


/*
		/////////////////////////////////////////////////////////////////////////////
		// Widget Playground
		/////////////////////////////////////////////////////////////////////////////
			//
			var window = WindowManager.getInstance().addWindow (flash.Lib.current);
			window.init({name:"Widget Playground", x:120, y:10});

			//
			var menubar =  new MenuBar (window, "MenuBar", 10, 20);
			menubar.init();

			//
			var toolbar =  new ToolBar (window, "ToolBar", 10, 44);
			toolbar.init();

			//
			for(i in 0...10)
			{
			var btn = new Button(toolbar);
			btn.init({height: 24, width: 44, label: ""+i });
			btn.move(16+48*i, 8);
			btn.filters = null;
			}


			//
			var scrollpane = new ScrollPane(window, "scrollpane", 10, 84);
			scrollpane.init();

			//
			var container = new Container (scrollpane, "Container");
			container.init();

			//
			var label = new Label(container);
			label.text = "This window, all it's controls and events are hard-coded haxegui, play around.";
			label.init();
			label.move(20,10);

			//
			var btn = new Button(container);
			btn.init({label: "Button1"});
			btn.move(20, 40);

			//
			btn = new Button(container);
			btn.init({label: "Button2", color: 0x90EE90});
			btn.move(120, 40);

			btn = new Button(container);
			btn.init({label: "Button3", width: 100});
			btn.move(220, 40);
			btn.label.x += 8;
			var icon = flash.Lib.attach("Clear");
			icon.width = icon.height = 20;
			icon.x = icon.y = 4;
			btn.addChild(icon);

			//
			btn = new Button(container);
			btn.init({label:"1", x:330, y: 40, width: 70, height: 70, color: 0xE86B26});
			btn.label.x = btn.label.y = 4;

			btn.label.tf.multiline = true;
			btn.label.tf.wordWrap = true;
			btn.label.tf.width = 60;
			btn.label.tf.height = 60;
			btn.label.x = btn.label.y = 10;
			btn.label.tf.text = "Button4 Multi line label colored";
			btn.label.tf.setTextFormat(DefaultStyle.getTextFormat());


			//
			btn = new Button(container);
			btn.init({label: "Button5", x:20, y: 80, width: 70, disabled: true});

			//
			btn = new Button(container);
			btn.init({label: "Button #6 has a long label", x:100, y: 80, width: 220});

			//
			var chkbox = new CheckBox(container, "CheckBox1");
			chkbox.init();
			chkbox.move(20,120);

			//
			chkbox = new CheckBox(container, "CheckBox2");
			chkbox.init({checked: true});
			chkbox.move(160,120);

			//
			chkbox = new CheckBox(container, "CheckBox3");
			chkbox.init({disabled: true});
			chkbox.move(300,120);

			//
			var cmbbox = new ComboBox(container, "ComboBox1");
			cmbbox.init();
			cmbbox.move(20,150);

			//
			cmbbox = new ComboBox(container, "ComboBox2");
			cmbbox.init({editable: false});
			cmbbox.move(20,180);

			//
			cmbbox = new ComboBox(container, "ComboBox3");
			cmbbox.init({disabled:true});
			cmbbox.move(20,210);


			//
			for(i in 1...4)
			{
				var radio = new RadioButton(container, "RadioButton"+i);
				radio.init({disabled: i==3, selected: i==1 });
				radio.move(20,210+30*i);

				var slider = new Slider(container, "Slider"+i);
				slider.init();
				slider.move(200, 120+30*i);

				var stepper = new Stepper(container, "Stepper"+i);
					stepper.init({step: i, max: 128});
				//~ stepper.init();
				stepper.move(360, 120+30*i);

				slider.addEventListener(Event.CHANGE, function(e:Event) { stepper.value = e.target.handle.x; stepper.dispatchEvent(new Event(Event.CHANGE)); }, false, 0, true);
				stepper.addEventListener(Event.CHANGE, function(e:Event) { slider.handle.x = e.target.value;  }, false, 0, true);

			}

			for(i in 1...4)
			{
				var slider = new Slider(container, "Slider"+(4+i));
				slider.init({width: 200});
				slider.move(400+40*i, 40);
				slider.rotation = 90;
			}

			var input = new Input(container, "Input1", 200, 240);
			input.init();

			input = new Input(container, "Input2", 200, 270);
			input.init();

			input = new Input(container, "Input3", 200, 300);
			input.init({disabled: true});

			var list = new UiList(container, "List1", 400, 280);
			list.data = [ "A", "B", "C", "D" ];
			list.init();

			var list = new UiList(container, "List2", 550, 280);
			list.data = [ "1", "2", "3", "4" ];
			list.init();


			//
			var expand = new Expander(container, "Expander1", 550, 40);
			expand.init({ width: 200, height: 140 });

			//
			var scrollpane2 = new ScrollPane(expand, "ScrollPane2", 0, 20);
			scrollpane2.init();

			list = new UiList(scrollpane2, "List3", 0, -20);
			list.removeChild( list.header );
			for(i in 1...11) list.data.push("List Item "+i);
			list.init({width: 300});

			var tabnav = new TabNavigator(scrollpane, "TabNavigator1", 770, 40);
			tabnav.init();

			//
			window = WindowManager.getInstance().addWindow (scrollpane.content);
			window.init({name:"Nested Window", x:20, y:340, width: 200, height: 160, color: 0xA5DE33 });

			//
			container = new Container (window, "Container");
			container.init({ x: 10, y: 20, width: 190, height: 150, color: 0xA5DE33 });



*/
			//~ window.dispatchEvent(new haxegui.events.ResizeEvent(haxegui.events.ResizeEvent.RESIZE));

		/////////////////////////////////////////////////////////////////////////
		// Load XML
		/////////////////////////////////////////////////////////////////////////
		var loader:URLLoader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, loadXML, false, 0, true);
		loader.load(new URLRequest("samples/Example1.xml"));

//  try {
//      var l = flash.Lib.current.loaderInfo.parameters;
//  	trace(here.methodName + " " + Utils.print_r(l));
//  	loader.load(new URLRequest(Reflect.field(l, "layout")));
//      //~ for (f in Reflect.fields(l)) {
//          //~ trace("\t" + f + ":\t" + Reflect.field(l, f) + "\n");
//      //~ }
//  } catch (e:Dynamic) {
//      trace(here.methodName + " " + e);
//  }


		var a = new Array<String>();
		var keys : Iterator<String> = untyped ScriptManager.defaultActions.keys();
		for(k in keys)
			a.push( k.split('.').slice(-2,-1).join('.') + "." + k.split('.').pop() );
		a.sort(function(a,b) { if(a==b) return 0; if(a < b) return -1; return 1;});
		trace("Registered scripts: " + Std.string(a));
		//~ trace("Registered scripts: " + Utils.print_r(a));


	}//main



	/**
	* Loads the layout
	*/
	static function loadXML(e:Event) : Void
	{
		trace(here.methodName);
		var str = e.target.data;
		LayoutManager.loadLayouts(Xml.parse(str));
		for(k in LayoutManager.layouts.keys())
			trace("Loaded layout : " + k);
		//~ LayoutManager.setLayout("DemoLayout");
		LayoutManager.setLayout(Xml.parse(str).firstElement().get("name"));
	}


	/**
	*
	*
	*/
	public static function setRedirection(f:Dynamic) {
		haxe.Log.trace = f;
	}


	/**
	*
	*
	*/
	public static function onStageResize(e:Event)
	{

		var stage = e.target;

		var back = cast flash.Lib.current.getChildByName("desktop");
		back.graphics.clear();
		  var colors = [ DefaultStyle.BACKGROUND, DefaultStyle.BACKGROUND - 0x4D4D4D ];
		  var alphas = [ 100, 100 ];
		  var ratios = [ 0, 0xFF ];
		  var matrix = new flash.geom.Matrix();
		  matrix.createGradientBox(stage.stageWidth, stage.stageHeight, Math.PI/2, 0, 0);
		  back.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );

		back.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
		back.graphics.endFill();
	}

}//Main
