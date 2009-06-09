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

package haxegui.managers;

import flash.display.DisplayObject;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.TypedDictionary;

import haxegui.XmlParser;
import haxegui.managers.CursorManager;
import haxegui.Component;
import haxegui.utils.ScriptStandardLibrary;

import hscript.Expr;
import hscript.Interp;


/**
*
* StyleManager handles running scripts for styling controls
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class StyleManager implements Dynamic
{
	public static var styles : Hash<Xml> = new Hash<Xml>();

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
}

class DefaultStyle {
	public static var BACKGROUND 		: UInt   = 0xADD8E6;
	public static var ACTIVE_TITLEBAR 	: UInt   = 0xB3EEFF;
	//~ public static var BACKGROUND		: UInt   = 0x5E5E5E;
	//~ public static var ACTIVE_TITLEBAR 	: UInt   = 0xBFBFBF;
	public static var TOOLTIP			: UInt 	 = 0xe5baac;
	public static var FOCUS				: UInt   = 0xd7ace5;
	public static var INPUT_BACK		: UInt   = 0xF5F5F5;
	public static var INPUT_TEXT		: UInt   = 0x333333;
	public static var LABEL_TEXT		: UInt   = 0x1A1A1A;
	public static var DROPSHADOW		: UInt   = 0x000000;
	public static var PANEL		    	: UInt 	 = 0xF3F3F3;
	public static var PROGRESS_BAR  	: UInt	 = 0xace5b5;

	public static var FONT				:	String = "FFF_Harmony";
	public static function getTextFormat(?size:Dynamic, ?color:UInt, ?align:flash.text.TextFormatAlign) : TextFormat
	{
		var fmt = new TextFormat ();
		fmt.align = align;
		//~ fmt.font = "FFF_FORWARD";
		//~ fmt.font = "Impact";
		//~ fmt.font = "FFF_Manager_Bold";
		//~ fmt.font = "FFF_Harmony";
		//~ fmt.font = "FFF_Freedom_Trial";
		//~ fmt.font = "FFF_Reaction_Trial";
		//~ fmt.font = "Amiga_Forever_Pro2";
		//~ fmt.font = "Silkscreen";
		//~ fmt.font = "04b25";
		//~ fmt.font = "Pixel_Classic";
		fmt.font = DefaultStyle.FONT;
		fmt.size = ( size == null || size == 0 || Math.isNaN(size) ) ? 8 : size;
		fmt.align = ( align == null || !Std.is(align, flash.text.TextFormatAlign) ) ? TextFormatAlign.LEFT : align;
		fmt.color = ( color == 0 ) ? DefaultStyle.LABEL_TEXT : color ;
		return fmt;
	}
}
