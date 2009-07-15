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
import flash.geom.Transform;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.MovieClip;
import flash.display.Loader;
import flash.display.LoaderInfo;

import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.events.EventDispatcher;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import haxegui.events.MenuEvent;

import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.net.FileReferenceList;

import haxegui.managers.WindowManager;
import haxegui.managers.StyleManager;
import haxegui.managers.ScriptManager;
import haxegui.managers.FocusManager;
import haxegui.managers.LayoutManager;
import haxegui.managers.CursorManager;
import haxegui.managers.MouseManager;
import haxegui.PopupMenu;

import haxegui.Console;
import haxegui.TabNavigator;
import haxegui.MenuBar;
import haxegui.Stats;
import haxegui.ToolBar;
import haxegui.ColorPicker;
import haxegui.ColorPicker2;
import haxegui.RichTextEditor;
import haxegui.Haxegui;
import haxegui.Introspector;
import haxegui.Appearance;
import haxegui.Utils;
import haxegui.utils.Color;

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

import haxegui.containers.Container;
import haxegui.containers.Divider;
import haxegui.containers.ScrollPane;


/**
* Haxegui Demo Application
*
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.2
*/
class Main extends Sprite, implements haxe.rtti.Infos
{
	static var desktop : Sprite;
	static var root = flash.Lib.current;
	static var stage = root.stage;

	
	public static function main () {

		// Set stage propeties
		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		stage.align = flash.display.StageAlign.TOP_LEFT;
		stage.stageFocusRect = true;
        stage.frameRate = 120;

		// Assign a stage resize listener
		stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);

		// Desktop
		desktop = untyped flash.Lib.current.addChild(new Sprite());
		desktop.name = "desktop";
		desktop.mouseEnabled = false;

		var colors = [ DefaultStyle.BACKGROUND, Color.darken(DefaultStyle.BACKGROUND, 40) ];
		var alphas = [ 1, 1 ];
		var ratios = [ 0, 0xFF ];
		var matrix = new flash.geom.Matrix();
		matrix.createGradientBox(stage.stageWidth, stage.stageHeight, .5*Math.PI, 0, 0);
		desktop.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );
		desktop.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
		desktop.graphics.endFill();


		// Logos
/*		
		var logo = flash.Lib.current.addChild(flash.Lib.attach("Logo"));
		logo.name = "Logo";
		logo.x = cast (stage.stageWidth - logo.width) >> 1;
		logo.y = cast (stage.stageHeight - logo.height) >> 1;

		var t = new Tween(0,1,2000,feffects.easing.Bounce.easeOut);
		t.setTweenHandlers( function(v) {
			logo.alpha = v;
			var trans = new flash.geom.Matrix();
			trans.translate(cast (stage.stageWidth - logo.width) >> 1, cast (stage.stageHeight - logo.height) >> 1);
			trans.scale(v,v);
			logo.transform.matrix = trans;
		});		
		haxe.Timer.delay( t.start, 75);
		haxe.Timer.delay( init, 2200);
*/		
		haxe.Timer.delay( init, 50);
		
	}

	public static function init ()	{
		
		// Setup Haxegui
		haxegui.Haxegui.init();

		/*
		var t = new Tween(1,0,300,flash.Lib.current.getChildByName("Logo"),"alpha",feffects.easing.Linear.easeNone);
		t.setTweenHandlers(null,
		function(v) {
		flash.Lib.current.removeChild(flash.Lib.current.getChildByName("Logo"));	
		});
		t.start();
		*/
		
		var bootupMessages = new Array<{v:Dynamic, inf:haxe.PosInfos}>();
		var bootupHandler = function(v : Dynamic, ?inf:haxe.PosInfos) {
			bootupMessages.push({v:v, inf:inf});
		}
		setRedirection(bootupHandler);


		// Console to show some debug
		var console = new Console (flash.Lib.current, 50, 50);
		console.init({color:0x2E2E2E, visible: false });
		haxe.Log.clear();
		setRedirection(console.log);

		log = function(v:Dynamic) {
			console.log(v, null);
		}

		log("*** Bootup messages:");
		for(e in bootupMessages)
			console.log(e.v, e.inf);


		stage.addEventListener(KeyboardEvent.KEY_DOWN, 
			function(e){ 
				switch(e.charCode) {
					case "`".code:
						console.visible = !console.visible; 
						/*
						WindowManager.toFront(console);
						if(!console.visible) { 
							var t = new feffects.Tween( 0, 1, 1000, console, "alpha", feffects.easing.Linear.easeNone);
							var ty = new feffects.Tween( -console.height, console.y, 1000+Std.int(console.y*1.5), console, "y", feffects.easing.Back.easeOut);
							console.y = -console.height;
							console.visible = true; 
							t.start(); 
							ty.start(); 
							}
						else {
							var t = new feffects.Tween( 1, 0, 350, console, "alpha", feffects.easing.Linear.easeNone);
							t.start();
							t.setTweenHandlers(null, function(v){ console.visible = false; } );
							}
						*/
					}
				});


		// Statistics
		//var stats = new Stats (flash.Lib.current, 540, 80);
		//stats.init();

		// Color Picker
		//~ var colorpicker = new ColorPicker2(flash.Lib.current, 100,100);
		//~ colorpicker.init();
		




//~ var imageTypes:FileFilter = new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg; *.jpeg; *.gif; *.png");
//~ var textTypes:FileFilter = new FileFilter("Text Files (*.txt, *.rtf)", "*.txt; *.rtf");
//~ var allTypes = [imageTypes, textTypes];
//~ var fileRef:FileReference = new FileReference();
//~ fileRef.browse(allTypes);
//~ var xmlType = [new FileFilter("Xml Files (*.xml)", "*.xml;")];
//~ fileRef.browse(xmlType);


		/////////////////////////////////////////////////////////////////////////
		// Load XML
		/////////////////////////////////////////////////////////////////////////
		var loader:URLLoader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, loadXML, false, 0, true);
		//~ loader.load(new URLRequest("samples/Example1.xml"));

/////////////////////////////////////////////////////////////////////////
// Load XML, try by input flashvars first
/////////////////////////////////////////////////////////////////////////
  var layout = "";
  try {
    var l = flash.Lib.current.loaderInfo.parameters;
  	trace(here.methodName + " " + Utils.print_r(l));

  	var baseURL = Reflect.field(l, "baseURL");
	if(baseURL==null)  baseURL = "";
	haxegui.Haxegui.baseURL = baseURL;

  	layout = Reflect.field(l, "layout");
	if(layout==null) 
		layout="samples/Example7.xml";
		
      for (f in Reflect.fields(l)) {
          trace("\t" + f + ":\t" + Reflect.field(l, f) + "\n");
      }
  } catch (e:Dynamic) {
      trace(here.methodName + " " + e);
  }


		// rte
		//var rte = new RichTextEditor(flash.Lib.current, 120,120);
		//rte.init();
		

		// style
		//var appearance = new Appearance(flash.Lib.current, 180,180);
		//appearance.init();
			
		// debugger
		//var introspect = new Introspector(flash.Lib.current, 150,150);
		//introspect.init();
		
		// Analog Clock
		var clock = new haxegui.toys.AnalogClock(flash.Lib.current, 210,88);
		clock.init();
		
				
		loader.load(new URLRequest(Haxegui.baseURL+layout));

		//~ stage.addEventListener(MouseEvent.MOUSE_DOWN,
		//~ function(e)
		//~ {
		//~ var c = new haxegui.toys.Curvy(flash.Lib.current, "curvy"+haxe.Timer.stamp(), e.stageX, e.stageY);
		//~ c.init();
		//~ }
		//~ );

    //~ var URL = "http://localhost:2000/remoting.n";
    //~ var cnx = haxe.remoting.HttpAsyncConnection.urlConnect(URL);
    //~ cnx.setErrorHandler( function(err) trace("Error : "+Std.string(err)) );
	//~ 


	#if debug
		var a = new Array<String>();
		var keys : Iterator<String> = untyped ScriptManager.defaultActions.keys();
		for(k in keys)
			a.push( k.split('.').slice(-2,-1).join('.') + "." + k.split('.').pop() );
		a.sort(function(a,b) { if(a==b) return 0; if(a < b) return -1; return 1;});
		log("Registered scripts: " + Std.string(a));
	#end


	
 
	}//main



	/**
	* Loads the layout
	*/
	static function loadXML(e:Event) : Void
	{
		trace(here.methodName) ;
		var str = e.target.data;
		LayoutManager.loadLayouts(Xml.parse(str));
		for(k in LayoutManager.layouts.keys())
			trace("Loaded layout : " + k);
		LayoutManager.setLayout(Xml.parse(str).firstElement().get("name"));

//~ LayoutManager.fetchLayout("samples/Example6.xml");
//~ LayoutManager.setLayout("Example6");

	trace("Finished Initialization in "+ haxe.Timer.stamp() +" sec.");

		//~ var welcome = "\n<FONT SIZE='24'>Hello and welcome to <B>haxegui</B>.</FONT>\n";
		var welcome = "\n
	 _                       _ 
	| |_ ___ _ _ ___ ___ _ _|_|
	|   | .'|_'_| -_| . | | | |
	|_|_|__,|_,_|___|_  |___|_| Copyright (c) 2009 The haxegui developers
	                |___|\n\n\t";
		
		var info = "<FONT SIZE='8'>"+flash.system.Capabilities.os+" "+flash.system.Capabilities.version+" "+flash.system.Capabilities.playerType+" "+(flash.system.Capabilities.isDebugger ? "Debug" : "")+".</FONT>\n";
		info += "\n\t<U><A HREF=\"http://haxe.org/\">haXe</A></U> (pronounced as hex) is an open source programming language.\n";
		info += "\tHaxe Graphical User Interface for the flash9 platform, is a set of classes\n\tworking as widgets like flash/flex's components and windows.\n\n";
		info += "\tThis console can exeute hscript in the textfield below,\n\ttype <I>help</I> to display a list of a few special commands.\n\n";
		log(welcome+info);
		log("");
		
	}


	/**
	*
	*
	*/
	public static function setRedirection(f:Dynamic) {
		haxe.Log.trace = f;
		ScriptManager.redirectTraces(f);
	}


	/**
	*
	*
	*/
	public static function onStageResize(e:Event) {

	var stage = e.target;
	haxe.Timer.delay( function() {
	if(desktop!=null) {
		desktop.graphics.clear();
		  var colors = [ DefaultStyle.BACKGROUND, Color.darken(DefaultStyle.BACKGROUND,40) ];
		  var alphas = [ 1, 1 ];
		  var ratios = [ 0, 0xFF ];
		  var matrix = new flash.geom.Matrix();
		  matrix.createGradientBox(stage.stageWidth, stage.stageHeight, .5*Math.PI, 0, 0);
		  desktop.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );

		desktop.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
		desktop.graphics.endFill();
	}

		var logo = cast flash.Lib.current.getChildByName("Logo");
		logo.x = Std.int(stage.stageWidth - logo.width) >> 1;
		logo.y = Std.int(stage.stageHeight - logo.height) >> 1;
	},300);
	
	}

	public static dynamic function log(v:Dynamic) {
		trace(v, null);
	}
}//Main
