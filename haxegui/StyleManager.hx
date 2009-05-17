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
import flash.utils.TypedDictionary;

import haxegui.CursorManager;
import haxegui.controls.Component;
import haxegui.utils.ScriptStandardLibrary;

import hscript.Expr;
import hscript.Interp;


typedef ScriptObject = {
	var interp:Interp;
	var program: Expr;
	var setup : Interp->DisplayObject->Dynamic->Void;
	var code : String;
}



/**
*
* StyleManager handles running scripts for styling controls
*
* @version 0.1
* @author <gershon@goosemoose.com>
* @author Russell Weir'
*
*/
class StyleManager implements Dynamic
{
	public static var styles : Hash<Xml>;
	static var defaultActions : Hash<ScriptObject>;
	static var instanceActions : TypedDictionary<Component,Hash<ScriptObject>>;
	static var initialized : Bool;

	public static function commonSetup(interp:Interp, obj:DisplayObject, opts:Dynamic) : Void {
		for(f in Reflect.fields(opts))
			interp.variables.set(f, Reflect.field(opts,f));
	}

	/**
	* Inlined method for exec, for readability. Returns result of executed code
	*/
	private static inline function doCall(inst:Component,so:ScriptObject,options:Dynamic) : Dynamic
	{
		var rv = null;
		if(so != null) {
			if(so.setup != null)
				so.setup(so.interp,inst,options);
			so.interp.variables.set("this",inst);
			rv = so.interp.execute( so.program );
		}
		return rv;
	}

	/**
	* Execute a script for a particular Component
	*
	* @param inst The component executing the script ("this")
	* @param action An action type
	* @param options Object with key->value mapping of vars to pass to script
	**/
	public static function exec(inst:Component, action:String, options:Dynamic) : Dynamic {
		try {
			return doCall(inst, getInstanceActionObject(inst, action), options);
		} catch(e:Dynamic) {
			if(e != "No default action.") {
				trace(inst.toString() + " " + action + " script error : " + e);
			}
		}
		return null;
	}

	/**
	* Returns the default ScriptObject for the classType, throwing an error
	* if it does not exist.
	*
	* @param classType
	* @param action StyleManager action var name
	* @return ScriptObject which is the default for the Component type
	* @throws String "No default action." if a default action does not exist
	**/
	private static function getDefaultActionObject(classType:Class<Dynamic>, action:String) : ScriptObject {
		var key = getDefaultActionKey(classType, action);
		if(!defaultActions.exists(key) || defaultActions.get(key) == null) {
			var sc = Type.getSuperClass(classType);
			if(sc == null)
				throw "No default action.";
			return getDefaultActionObject(sc, action);
		}
		return(defaultActions.get(key));
	}

	/**
	* Returns the key for the default action for the given Component instance
	*
	* @return String key used to index the defaultActions Hash
	**/
	private static inline function getDefaultActionKey(classType:Class<Dynamic>, action:String) : String
	{
		return Type.getClassName(classType) + "." + action;
	}

	/**
	* Finds the best script for a Component instance for a given action.
	* If the instance has it's own script, that is returned, otherwise
	* the default for the instance's class type is returned, if any.
	*
	* @param inst A Component
	* @param action Action type
	* @return ScriptObject, either the instance one, or the default for the class
	* @throws String on error
	**/
	public static function getInstanceActionObject(inst:Component, action:String) : ScriptObject
	{
		if(instanceActions.exists(inst)) {
			var so = instanceActions.get(inst).get(action);
			if(so != null)
				return so;
		}
		return getDefaultActionObject(Type.getClass(inst), action);
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
	public static function setDefaultScript(
				classType : Class<Dynamic>,
				action:String,
				code:String,
				init:Interp->Void=null,
				setup:Interp->DisplayObject->Dynamic->Void=null)
	{
		if(!initialized) initialize();
		var parser = new hscript.Parser();
		var program = parser.parseString((code==null) ? "" : code);
		var interp = new hscript.Interp();
		if(init != null)
			init(interp);
		else
			ScriptStandardLibrary.set(interp);
		if(setup == null)
			setup = commonSetup;

		defaultActions.set(
			getDefaultActionKey(classType,action),
			{
				interp:interp,
				program: program,
				setup: setup,
				code: code,
			});
		return code;
	}

	/**
	* Sets the hscript for a particular event. All events are the same names as the
	* public fields of the StyleManager instance.
	*
	* @param action An action name
	* @param code The code to execute.
	* @param init The initialization function for the interpreter, which is run once
	* @param setup The function called each time a display object needs to run the script
	* @return The code provided, for chaining in setters.
	* @throws String if action is invalid
	**/
	public static function setInstanceScript(
				inst : Component,
				action:String,
				code:String,
				init:Interp->Void=null,
				setup:Interp->DisplayObject->Dynamic->Void=null) : String
	{
		if(!initialized) initialize();
		var classType = Type.getClass(inst);
		var parser = new hscript.Parser();
		var program = parser.parseString((code==null) ? "" : code);
		var interp = new hscript.Interp();
		if(init != null)
			init(interp);
		else
			ScriptStandardLibrary.set(interp);
		if(setup == null)
			setup = commonSetup;

		if(!instanceActions.exists(inst))
			instanceActions.set(inst, new Hash<ScriptObject>());
		instanceActions.get(inst).set(action,
			{
				interp:interp,
				program: program,
				setup: setup,
				code: code,
			});
		return code;
	}

	/**
	* Loads all styles from the given Xml file.
	**/
	public static function loadStyles(xml:Xml) {
		for(elem in xml.elements()) {
			if(!XmlParser.isStyleNode(elem))
				continue;
			var name = XmlParser.getStyleName(elem);
			if(name == null)
				continue;
			styles.set(name, elem);
		}
	}

	public static function initialize() {
		if(initialized) return;
		initialized = true;
		styles = new Hash<Xml>();
		defaultActions = new Hash<ScriptObject>();
		// uses weak keys so when instance is gone, so is the script object.
		instanceActions = new TypedDictionary<Component,Hash<ScriptObject>>(true);
	}

	/**
	* Set the style to a loaded style by name. The style must have been
	* loaded with loadStyles, or compiled in as [default]. If the style
	* does not exist, then no change will occur.
	*
	* @param name Name of style
	**/
	public static function setStyle(name : String) : Void {
		if(!styles.exists(name))
			return;
		XmlParser.apply(styles.get(name));
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

	public static function getTextFormat(?size:Dynamic, ?color:UInt, ?align:flash.text.TextFormatAlign) : TextFormat
	{
		var fmt = new TextFormat ();
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
		fmt.size = ( size == null || size == 0 || Math.isNaN(size) ) ? 8 : size;
		fmt.align = ( align == null ) ? TextFormatAlign.LEFT : align;
		fmt.color = ( color == 0 ) ? DefaultStyle.LABEL_TEXT : color ;
		return fmt;
	}
}
