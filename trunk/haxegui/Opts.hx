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

/**
*
* Options handler
*
* @version 0.1
* @author Russell Weir'
*
*/
class Opts {
	public static function optBool(opts:Dynamic,field:String,defaultValue:Bool) : Bool
	{
		var v = getField(opts,field);
		if(v == null) return defaultValue;
		return cast field;
	}

	public static function optFloat(opts:Dynamic,field:String,defaultValue:Float) : Float
	{
		var v = getField(opts,field);
		if(v == null) return defaultValue;
		return Std.parseFloat(field);
	}

	public static function optInt(opts:Dynamic,field:String,defaultValue:Null<Int>) : Null<Int>
	{
		var v = getField(opts,field);
		if(v == null) return defaultValue;
		return Std.parseInt(field);
	}

	public static function optString(opts:Dynamic,field:String,defaultValue:String) : String
	{
		var v = getField(opts,field);
		if(v == null) return defaultValue;
		return new String(field);
	}

	public static function getField(opts:Dynamic,field:String) : Dynamic {
		if(opts == null || field == null || field == "") return null;
		var idx = field.indexOf(".");
		if(idx < 0) {
			return Reflect.field(opts, field);
		}
		return getField(Reflect.field(opts, field.substr(0,idx)), field.substr(idx+1));
	}
}