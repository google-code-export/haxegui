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

/**
*
* Options handler<br/>
* <p>
* Does type checking of fields in objects, and defaults to given values.
* Instead of sending unchecked annonymous objects to functions, a given name is checked for
* against the fields of the input object, and the default value will be used if it is not
* found, or is in an unexpected format. This not only allows better type-checking, values are also converted
* and safetly casted, so sending { bool1: true, bool2: "0", bool3: "true", int: "0xff", float: "0.123", ... } all work.
* </p>
* Usage example:
* <pre class="code haxe">
* var opts = { color1: "#FF0000", color2: "0xFF0000", color3: Color.RED };
* // will fail, and result in 0xFF00FF
* color = Opts.getInt(opts, "color1", Color.MAGENTA);
* // both will succeced, assigining red
* color = Opts.getInt(opts, "color2", Color.MAGENTA);
* color = Opts.getInt(opts, "color3", Color.MAGENTA);
* </pre>
*
* @version 0.2
* @author Russell Weir <damonsbane@gmail.com>
* @author Omer Goshen <gershon@goosemoose.com>
*
*/
class Opts {

	//{{{ string
	public static function string(opts:Dynamic, field:String) : String {
		var v = optString(opts, field, null);
		if(v == null) throw "Missing " + field;
		return v;
	}
	//}}}


	//{{{ clone
	/**
	* Clones a set of options, returning a new options object
	**/
	public static function clone(opts:Dynamic) : Dynamic {
		var rv = {};

		for(f in Reflect.fields(opts))
		Reflect.setField(rv, f, Reflect.field(opts,f));

		return rv;
	}
	//}}}


	//{{{ classInstance
	/**
	* Get an instance [field] from [opts] object, matching one from an array of class types.
	* @param classes Array of types like [Int, Float,...]
	* @throws String When input type does'nt match any in the array
	*/
	public static function classInstance(opts:Dynamic, field:String, classes:Array<Class<Dynamic>>) {
		var v =  getField(opts, field);
		if(v == null) throw "Missing " + field;
		if(classes == null || classes.length == 0)
		return v;
		var found = false;
		for(ct in classes) {
			if(Std.is(v, ct)) {
				found = true;
				break;
			}
		}
		if(!found)
		throw "Bad type for " + field;
		return v;
	}
	//}}}


	//{{{ hasOpt
	/**
	* @return [true] if [field] exists in [opts]
	*/
	public static function hasOpt(opts:Dynamic, field:String) : Bool {
		return (getField(opts, field) != null);
	}
	//}}}


	//{{{ optBool
	public static function optBool(opts:Dynamic,field:String,defaultValue:Bool) : Bool {
		var v = getField(opts,field);
		if(v == null) return defaultValue;
		if(Std.is(v,String)) {
			switch(v.toLowerCase()) {
				case "1", "true", "yes": return true;
				default: return false;
			}
		}
		return cast v;
	}
	//}}}


	//{{{ optFloat
	public static function optFloat(opts:Dynamic,field:String,defaultValue:Float) : Float {
		var v = getField(opts,field);

		if(v == null) return defaultValue;

		if(Std.is(v,Float) || Std.is(v, Int))
		return v;

		if(Std.is(v, String)) {
			v = Std.parseFloat(v);
			if(Math.isNaN(v))
			return defaultValue;
			return v;
		}
		if(v == null)
		return defaultValue;
		return v;
	}
	//}}}


	//{{{ optInt
	public static function optInt(opts:Dynamic,field:String,defaultValue:Int) : Int {
		var v = getField(opts, field);
		if(v == null) return defaultValue;

		if(Std.is(v, Int) || Std.is(v,Float))
		return Std.int(v);

		if(Std.is(v, String)) {
			v = Std.parseInt(v);
			if(v == null)
			return defaultValue;
			return v;
		}
		return defaultValue;
	}
	//}}}


	//{{{ optString
	public static function optString(opts:Dynamic,field:String,defaultValue:String) : String {
		var v = getField(opts,field);
		if(v == null) return defaultValue;
		return Std.string(v);
	}
	//}}}


	//{{{ getField
	/**
	* Internally used by the class.
	*
	* @param opts  Dynamic input object
	* @param field The field who's value to look for in the input
	* @return  	   [null] or the found value
	*/
	public static function getField(opts:Dynamic, field:String) : Dynamic {
		if(opts == null || field == null || field == "" || !Reflect.isObject(opts))
		return null;

		var idx = field.indexOf(".");

		if(idx < 0)
		return Reflect.field(opts, field);

		return getField(Reflect.field(opts, field.substr(0,idx)), field.substr(idx+1));
	}
	//}}}


	//{{{ removeFields
	/**
	* Takes the input opts and removes all the fields specified.
	*
	* @param opts Input opts to be modified
	* @param fields list of field names to remove
	**/
	public static function removeFields(opts:Dynamic, fields:Array<String>) : Void {
		for(f in fields) {
			Reflect.deleteField(opts, f);
		}
	}
	//}}}
}
