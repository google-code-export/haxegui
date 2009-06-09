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

import Type;
import Reflect;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.text.TextField;

class Utils
{

	/**
	*
	*
	*/
	public static function print_r(obj:Dynamic, ?indent:String="\t") : String
	{
		return Std.is(obj, DisplayObjectContainer) ? print_mc(obj, indent) : print_a(obj, indent);
	}

	/**
	*
	*
	*/
	public static function print_a(obj:Dynamic, ?indent:String="\t") : String
	{
		//
		var type = obj.constructor;
		var str : String = "\n"+indent + type;

		// Make sure its an object, and not a of class String
		if(!Reflect.isObject(obj) || Std.is(obj, String) )
			return Std.string(obj) + " " + type;

		for (i in Reflect.fields(obj))
		{
			str += "\n"+indent;
			var field = Reflect.field(obj, i) ;
			//~ type = field.constructor;

			if(Reflect.isObject(field))
			//~ if(Reflect.isObject(field) || Std.is(field, Array) )
			{
					str += indent + "[" + i  + "]" + " => " ;
					str += print_r(field, indent+indent) ;

			}
			else
			{
				str += indent + "["+i+"] => "+field+" "+type;
			}
		}

		return str;
	}

	/**
	*
	*
	*/
	//~ public static function print_mc(obj:DisplayObjectContainer, ?indent:String="\t") : String
	public static function print_mc(obj:DisplayObjectContainer, ?indent:String) : String
	{
		if (indent == null) { indent = "\t"; } else { indent += "\t"; }

		//
		var str : String = "\n";
		for (i in 0...obj.numChildren)
		{
			var child = obj.getChildAt(i);
			if(Std.is(child, DisplayObjectContainer))
			{
				str += indent + "[" + child.name  + "]" + " => " + child;
				str += indent + print_r(cast child, indent);
			}
			else
			{
				if(Std.is(child,Sprite) || Std.is(child,TextField))
					str += indent + "[" + child.name + "] => " + child + "\n";
			}
		}
		return str;
	}
	

	public static inline function darken(color:UInt, v:UInt ) : UInt {
		return clamp(color - grayHex(v));
	}
	
		
	public static inline function grayHex( v:UInt ) : UInt {
		return ( v << 16 | v << 8 | v );
	}
	
	
	public static inline function clamp( color:UInt ) : UInt {
		return cast Math.max(0, Math.min(0xFFFFFF, color));
	}
	
	
	public static inline function tint( color:UInt, tint:Float ) : UInt	{

	var r = color >> 16 ;
	var g = color >> 8 & 0xFF ;
	var b = color & 0xFF ;
			
	tint = 1 - tint;

	r = Math.round( r + ( ( 255 - r ) * tint ) );
	g = Math.round( g + ( ( 255 - g ) * tint ) );
	b = Math.round( b + ( ( 255 - b ) * tint ) );

	return clamp(( r << 16 ) | ( g << 8 ) | b);
	}
		
}
