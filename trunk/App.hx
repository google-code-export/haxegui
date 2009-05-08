//	  App.hx
//
//	  Copyright 2009 gershon <gershon@yellow>
//
//	  This program is free software; you can redistribute it and/or modify
//	  it under the terms of the GNU General Public License as published by
//	  the Free Software Foundation; either version 2 of the License, or
//	  (at your option) any later version.
//
//	  This program is distributed in the hope that it will be useful,
//	  but WITHOUT ANY WARRANTY; without even the implied warranty of
//	  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	  GNU General Public License for more details.
//
//	  You should have received a copy of the GNU General Public License
//	  along with this program; if not, write to the Free Software
//	  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
//	  MA 02110-1301, USA.

import flash.system.Capabilities;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.MovieClip;
import flash.display.Loader;

import flash.display.Bitmap;

import flash.events.EventDispatcher;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;

import events.MenuEvent;

import flash.net.URLLoader;
import flash.net.URLRequest;

import Reflect;
import Type;
import Xml;

import XmlDeserializer;
import haxe.Unserializer;

import haxe.Log;

//~ import controls.Component;
import controls.Button;
import controls.CheckBox;
import controls.ComboBox;
import controls.RadioButton;
import controls.Slider;
import controls.Stepper;
import controls.UiList;


import Window;
import WindowManager;
import Container;
import Image;



/*
 * Demo Application
 * 
 * 
 * 
 * 
 * 
 */
class App extends Sprite, implements haxe.rtti.Infos
{


	static var log:Log;

	public static function main ()
	{
	
		// Set stage propeties
		var stage = flash.Lib.current.stage;
		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		stage.align = flash.display.StageAlign.TOP_LEFT;
		stage.stageFocusRect = true;
		
		// Assign a stage resize listener
		stage.addEventListener(Event.RESIZE, onStageResize);
		
		// Start Tweener
		//~ ColorShortcuts.init ();
		//~ DisplayShortcuts.init ();
		//~ CurveModifiers.init ();

		// Setup mouse and cursor
		MouseManager.getInstance().init();
		CursorManager.getInstance().init();

		// Desktop
		var desktop = new Sprite();
		desktop.name = "desktop";
		desktop.mouseEnabled = false;
		
		  var colors = [ StyleManager.BACKGROUND, StyleManager.BACKGROUND - 0x4D4D4D ];
		  var alphas = [ 100, 100 ];
		  var ratios = [ 0, 0xFF ];
		  var matrix = new flash.geom.Matrix();
		  matrix.createGradientBox(stage.stageWidth, stage.stageHeight, Math.PI/2, 0, 0);
		  desktop.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );
//~ 
		desktop.graphics.drawRect( 0, 0, flash.Lib.current.stage.stageWidth, flash.Lib.current.stage.stageHeight );
		desktop.graphics.endFill();
		flash.Lib.current.addChild(desktop);



/*
 * 
 * CONSOLE!
 */


		// Console to show some debug
		var console = new Console (flash.Lib.current);
		console.init();
		console.move (120, 300);
		Log.clear();
		setRedirection(console.log);


		//~ trace("Application starting...");
	
		trace("<FONT SIZE='24' FACE='_mono'>Hello and welcome.</FONT>");
		trace("<FONT SIZE='12' FACE='_mono'>"+flash.system.Capabilities.os+" "+flash.system.Capabilities.version+" "+flash.system.Capabilities.playerType+".</FONT>");



		// Statistics
		var stats = new Stats (flash.Lib.current);
		stats.init();
		stats.move (750, 50);



		/////////////////////////////////////////////////////////////////////////////
		// Widget Playground
		/////////////////////////////////////////////////////////////////////////////
			//
			var window = WindowManager.getInstance().addWindow (flash.Lib.current);
			window.init({name:"Widget Playground", x:100, y:60});
			
			//
			var menubar =  new Menubar (window, "Menubar", 10, 20);
			menubar.init();

			//
			var scrollPane = new ScrollPane(window, "ScrollPane", 10, 44);
			scrollPane.init();

			//
			var container = new Container (scrollPane, "Container");
			container.init();

			//
			var label = new Label(container);
			label.text = "This window, all it's controls and events are hard-coded with haxe, play around.";
			label.init();
			label.move(20,10);
			
			//
			var btn = new Button(container);
			btn.init({label: "Button1"});
			btn.move(20, 40);
			if(btn==null)
				trace(new flash.Error());
			
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
			btn.init({label:"1", x:330, y: 40, width: 70, height: 70});
			btn.label.x = btn.label.y = 4;
			
			btn.label.tf.multiline = true;
			btn.label.tf.wordWrap = true;
			btn.label.tf.width = 60;
			btn.label.tf.height = 60;
			btn.label.x = btn.label.y = 10;
			btn.label.tf.text = "Button4, with Multi line label ";
			//~ btn.label.text = "Button4 Multi line label ";
			btn.label.tf.setTextFormat(StyleManager.getTextFormat());

	
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
			cmbbox.move(20,160);

			//
			cmbbox = new ComboBox(container, "ComboBox2");
			cmbbox.init();
			cmbbox.move(20,200);
			
			//
			cmbbox = new ComboBox(container, "ComboBox2");
			cmbbox.init({disabled:true});
			cmbbox.move(20,240);


			//
			for(i in 1...4)
			{
				var radio = new RadioButton(container, "RadioButton"+i);
				radio.init({disabled: (i==3) });
				radio.move(20,240+40*i);

				var slider = new Slider(container, "Slider"+i);
				slider.init();
				slider.move(200, 120+40*i);
				
				var stepper = new Stepper(container, "Stepper"+i);
					stepper.init({step: i, max: 128});
				//~ stepper.init();
				stepper.move(360, 120+40*i);
							
				slider.addEventListener(Event.CHANGE, function(e:Event) { stepper.value=e.target.handle.x; stepper.dispatchEvent(new Event(Event.CHANGE)); });
				stepper.addEventListener(Event.CHANGE, function(e:Event) { slider.handle.x = e.target.value;  });
				
			}

			for(i in 1...4)
			{
				var slider = new Slider(container, "Slider"+(4+i));
				slider.init();
				slider.move(420+40*i, 270);
				slider.rotation = -90;
			}
			
			
			var list = new UiList(container, "List1", 200, 280);
			list.data = [ "A", "B", "C", "D" ];
			list.init();
			
			var list = new UiList(container, "List2", 350, 280);
			list.data = [ "1", "2", "3", "4" ];
			list.init();
			
			
			
			window.dispatchEvent(new events.ResizeEvent(events.ResizeEvent.RESIZE));
		

			
		//~ var c:Int = Math.round (Math.random () * 0xFFFFFF);
		//~ var t:String = "easeOutElastic";
		//~ 
		//~ var red = c >> 16 & 0x44;
		//~ var green = c >> 8 & 0x44;
		//~ var blue = c & 0x44;
		//~ 
		//~ var toColor = { redMultiplier: 1, greenMultiplier: 1, blueMultiplier: 1, alphaMultiplier:1,
		//~ redOffset: red, greenOffset: green, blueOffset: blue, alphaOffset:0
		//~ };
		//~ 
		//~ window.move(0,flash.Lib.current.stage.stageHeight) ;
		//~ 
		//~ Tweener.addTween (window,
		//~ {
		//~ y: 100 + 50 * i,
		//~ _colorTransform: toColor,
		//~ time: 2 + Math.random () * 3,
		//~ transition:t,
		//~ onUpdate: function(){ window.box.y = window.y; },
		//~ });

			
			
		
	/////////////////////////////////////////////////////////////////////////////////
	// Scroll test window
	/////////////////////////////////////////////////////////////////////////////////
/*	
		window = new Window("Scrolling picture window");
		window.init();
		window.color = 0xBB9F6B;
		window.move(200,200);

		var menubar =  cast window.addChild(new Menubar ());
		menubar.init();
		var scrollPane = cast window.addChild(new ScrollPane(12,46));
		scrollPane.init();

		var pictLdr:Loader = new Loader();
		var pictURLReq:URLRequest = new URLRequest("./assets/palm.jpg");
		pictLdr.load(pictURLReq);
		pictLdr.contentLoaderInfo.addEventListener(Event.COMPLETE,  
			function(e:Event) { scrollPane.addChild(e.currentTarget.content); });
*/



	/////////////////////////////////////////////////////////////////////////////////
	// Load XML
	/////////////////////////////////////////////////////////////////////////////////
		var loader:URLLoader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, loadXML);
		loader.load(new URLRequest("config.xml"));
		//
		flash.Lib.current.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown);
		FocusManager.getInstance ().addEventListener (FocusEvent.MOUSE_FOCUS_CHANGE, onFocusChanged);
		



 
/*
 * DEBUG
 *

		trace("---------------------------------------------------------------------");
		for(i in 0...flash.Lib.current.numChildren) 
			{
				trace("<FONT SIZE=\"14\" FACE=\"_mono\" >print_mc(<B>"+flash.Lib.current.getChildAt(i).name+"</B>):</FONT>");
				var child : Dynamic = cast flash.Lib.current.getChildAt(i) ;
				//
				if(!Std.is(child, flash.text.TextField))
					trace(Utils.print_mc(child));

				//~ // trace everything
				//~ var str : String = "\n";
				//~ var p = Type.getInstanceFields(Type.getClass(child));
				//~ for(j in p) {
					//~ var field = Reflect.field(child,j);
					//~ if(Reflect.isFunction(field))
						//~ {}
					//~ else
						//~ {
							//~ str += "\t" + j + " => ";							
							//~ str += field + "\n";
						//~ }
				//~ }
				//~ trace(str);		
			}//endfor
		trace("---------------------------------------------------------------------");
*/

/*
 * rtti experiments....
 * 
		var rtti : String = untyped App.__rtti;
		var x = Xml.parse(rtti).firstElement();
        var infos = new haxe.rtti.XmlParser().processElement(x);
        trace(Utils.print_r(infos));		
		trace(Utils.print_r(Type.enumConstructor(infos)));
*/	
		
	}//main

	static public function onFocusChanged (e:FocusEvent)
	{
		//~ trace(e.target+"::"+e);
		//~ trace( FocusManager.getInstance().getFocus() );
	}

	static public function onMouseDown (e:MouseEvent)
	{
		var popup = PopupMenu.getInstance ();
		if(popup.numItems() > 0)
		popup.dispatchEvent (new Event (MenuEvent.MENU_HIDE));


	}


	/**
	*
	*/
	static function loadXML(e:Event) : Void
	{
		trace(e);
		
		var str = e.target.data;
		//~ str = str.split('\n').join('');
		//~ str = str.split('\t').join('');
		var xml = Xml.parse(str);

		//~ var xml = Xml.parse(e.target.data);

		var xmlds : XmlDeserializer = new XmlDeserializer(xml);
		
		xmlds.deserialize();

	}//loadXML

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
		//~ back.graphics.beginFill(StyleManager.BACKGROUND,1);
		  var colors = [ StyleManager.BACKGROUND, StyleManager.BACKGROUND - 0x4D4D4D ];
		  var alphas = [ 100, 100 ];
		  var ratios = [ 0, 0xFF ];
		  var matrix = new flash.geom.Matrix();
		  matrix.createGradientBox(stage.stageWidth, stage.stageHeight, Math.PI/2, 0, 0);
		  back.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );
		  
		back.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
		back.graphics.endFill();
	}

}//App
