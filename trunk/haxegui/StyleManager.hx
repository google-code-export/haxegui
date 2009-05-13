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

import flash.display.DisplayObject;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import haxegui.CursorManager;

import hscript.Expr;
import hscript.Interp;


typedef ScriptObject = {
	var interp:Interp;
	var program: Expr;
	var setup : Interp->DisplayObject->Dynamic->Void;
}

class StyleManager implements Dynamic
{
	public static function commonInit(interp:Interp) : Void {
		StyleManager.setExports(interp);
	}

	public static function commonSetup(interp:Interp, obj:DisplayObject, opts:Dynamic) : Void {
		for(f in Reflect.fields(opts))
			interp.variables.set(f, Reflect.field(opts,f));
	}


// 	private static var _instance : StyleManager;
//
// 	public static function getInstance ():StyleManager
// 	{
// 		if (StyleManager._instance == null)
// 		{
// 			StyleManager._instance = new StyleManager();
// 			StyleManager._instance.init();
// 		}
// 		return StyleManager._instance;
// 	}

	public static function getTextFormat(?size:UInt, ?color:UInt, ?align:flash.text.TextFormatAlign) : TextFormat
	{
		var fmt = new TextFormat ();
		//~ fmt.align = flash.text.TextFormatAlign.CENTER;
		fmt.align = align;
		//~ fmt.font = "FFF_FORWARD";
		//~ fmt.font = "Impact";
		//~ fmt.font = "FFF_Manager_Bold";
		fmt.font = "FFF_Harmony";
		//~ fmt.font = "FFF_Freedom_Trial";
		//~ fmt.font = "FFF_Reaction_Trial";
		//~ fmt.font = "Amiga_Forever_Pro2";
		//~ fmt.font = "Silkscreen";
		//~ fmt.font = "04b25";
		//~ fmt.font = "Pixel_Classic";
		fmt.size = ( size == 0 ) ? 8 : size;
		fmt.align = ( align == null ) ? TextFormatAlign.LEFT : align;
		fmt.color = ( color == 0 ) ? DefaultStyle.LABEL_TEXT : color ;
		return fmt;
	}


	/**
	* Sets all the exported library methods to the given interpreter.
	* <ul>
	* <li>Math
	* <li>flash.display.GradientType
	* <li>flash.geom.Matrix
	* </ul>
	**/
	public static function setExports(interp:Interp) {
		interp.variables.set("Math",Math);
		interp.variables.set("feffects",
			{
				Tween : feffects.Tween,
				easing : {
					Back : feffects.easing.Back,
					Bounce : feffects.easing.Bounce,
					Circ : feffects.easing.Circ,
					Cubic : feffects.easing.Cubic,
					Sine : feffects.easing.Sine,
					Elastic : feffects.easing.Elastic,
					Expo : feffects.easing.Expo,
					Linear : feffects.easing.Linear,
					Quad : feffects.easing.Quad,
					Quart : feffects.easing.Quart,
					Quint : feffects.easing.Quint,
				},
			});
		interp.variables.set("flash",
			{
				display : {
					GradientType : {
						LINEAR: flash.display.GradientType.LINEAR,
						RADIAL: flash.display.GradientType.RADIAL,
					},
				},
				geom : {
					Matrix : flash.geom.Matrix,
				},
			});
		interp.variables.set("DefaultStyle", DefaultStyle);
		interp.variables.set("CursorManager", CursorManager);
		interp.variables.set("Cursor",{
				ARROW : Cursor.ARROW,
				HAND : Cursor.HAND,
				HAND2 : Cursor.HAND2,
				DRAG : Cursor.DRAG,
				IBEAM : Cursor.IBEAM,
				NE : Cursor.NE,
				NW : Cursor.NW,
				SIZE_ALL : Cursor.SIZE_ALL,
				CROSSHAIR : Cursor.CROSSHAIR,
			});
	}

	/**
	* Sets the hscript for a particular event. All events are the same names as the
	* public fields of the StyleManager instance.
	*
	* @param action An action name
	* @param code The code to execute.
	* @param init The initialization function for the interpreter, which is run once
	* @param setup The function called each time a display object needs to run the script
	* @throws String if action is invalid
	**/
	public static function setScript(
				classType : Class<Dynamic>,
				action:String,
				code:String,
				init:Interp->Void=null,
				setup:Interp->DisplayObject->Dynamic->Void=null)
	{
		var parser = new hscript.Parser();
		var program = parser.parseString((code==null) ? "" : code);
		var interp = new hscript.Interp();
		if(init != null)
			init(interp);
		else
			setExports(interp);
		if(setup == null)
			setup = commonSetup;

		actions.set(getActionKey(classType,action),{
				interp:interp,
				program: program,
				setup: setup,
			});
		return code;
	}

	public static function exec(classType:Class<Dynamic>, action:String, obj:DisplayObject, options:Dynamic) {
		try {
			doCall(getActionField(classType, action), obj, options);
		} catch(e:Dynamic) {
			if(e != "Not a valid action")
				trace(getActionKey(classType, action) + " script error : " + e);
		}
	}

	private static function doCall(so:ScriptObject,obj:DisplayObject,options:Dynamic) : Void
	{
		if(so == null)
			return;
		if(so.setup != null)
			so.setup(so.interp,obj,options);
		so.interp.variables.set("this",obj);
		so.interp.execute( so.program );
	}

	/**
	* Checks if the named action is valid, throwing an error if not
	*
	* @param action StyleManager action var name
	* @return Current value of the StyleManager instance field
	* @throws String on error
	**/
	private static function getActionField(classType:Class<Dynamic>, action:String) : Dynamic {
		var key = getActionKey(classType, action);
		if(!actions.exists(key) || actions.get(key) == null)
			throw "Not a valid action";
		return(actions.get(key));
	}

	private static function getActionKey(classType:Class<Dynamic>, action:String) : String
	{
		return Type.getClassName(classType) + "." + action;
	}

	static var actions : Hash<ScriptObject>;
	static var initialized : Bool;
	public static function initialize() {
		if(initialized) return;
		initialized = true;
		actions = new Hash<ScriptObject>();
	}
	static function __init__() : Void {
		initialize();
	}
}

class DefaultStyle {
	public static var BACKGROUND:UInt = 0xADD8E6;
	public static var BUTTON_FACE:UInt = 0xCFB675;
	public static var INPUT_BACK:UInt = 0xE5E5E5;
	public static var INPUT_TEXT:UInt = 0x333333;
	public static var LABEL_TEXT:UInt = 0x1A1A1A;
	public static var DROPSHADOW:UInt = 0x000000;
	public static var PANEL:UInt = 0xF3F3F3;
	public static var PROGRESS_BAR:UInt = 0xFFFFFF;

}
