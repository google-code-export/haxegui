//      Utils.hx
//      
//      Copyright 2009 gershon <gershon@yellow>
//      
//      This program is free software; you can redistribute it and/or modify
//      it under the terms of the GNU General Public License as published by
//      the Free Software Foundation; either version 2 of the License, or
//      (at your option) any later version.
//      
//      This program is distributed in the hope that it will be useful,
//      but WITHOUT ANY WARRANTY; without even the implied warranty of
//      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//      GNU General Public License for more details.
//      
//      You should have received a copy of the GNU General Public License
//      along with this program; if not, write to the Free Software
//      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
//      MA 02110-1301, USA.

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

	return Std.is(obj, DisplayObjectContainer) ? print_mc(obj, indent) : print_r(obj, indent);
	
	}

	/**
	 * 
	 * 
	 */
	public static function print_a(obj:Dynamic, ?indent:String="\t") : String
	{
		//
		var type = obj.constructor;
		//~ var type = Type.typeof(obj.constructor);
		//~ var str : String = Std.string(obj) + " " + type;
		var str : String = "\n"+indent + type;
		
		// Make sure its an object, and not a of class String
		//~ if(!Reflect.isObject(obj) || Std.is(type, TClass(String)) ) 
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
				//~ str += print_mc(cast child, indent+indent);
				//~ str += indent + print_r(cast child, indent+indent);
				//~ str += indent + print_r(cast child, indent+indent);	
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
}
