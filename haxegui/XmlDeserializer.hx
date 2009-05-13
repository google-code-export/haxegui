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

import haxe.Serializer;
import haxe.Unserializer;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

import flash.text.TextField;

import flash.events.Event;
import flash.events.MouseEvent;

import hscript.Expr;

import haxegui.CursorManager;

class XmlDeserializer extends Unserializer
{

	public var xml : Xml;


	public function new(?xml:Xml)
	{
		buf = "";
		super(buf);
		this.xml = xml;
	}


	public function getNode( node:Xml, ?parent:Dynamic ) : Dynamic
	{
		//
		var name = node.nodeName;
		name = name.split(':').join('.');


		if(name=="script")
		{
			getScript(node);
			return;
		}


		if(Std.is(parent, List))
		{
			parent.add( node.firstChild().nodeValue );
			//~ trace(parent);
			return;
		}

		if(Std.is(parent, Array))
		{

			//~ parent[parent.length] = node.firstChild().nodeValue ;
			parent.push( node.firstChild().nodeValue );
			//~ trace(parent);
			Reflect.setField(flash.Lib.current, node.parent.get("name"), parent);
			//~ trace(Reflect.field(flash.Lib.current, "IntArray"));
			//~ trace(node.parent.get("name"));

			return;
		}

		//
		var resolved = Type.resolveClass(name);
		if(resolved == null) return null;
		//~ trace(resolved);


		//
		var v : Dynamic = {};
		var args : Dynamic = {};

		//~ v = Type.createInstance( Type.resolveClass(name), [flash.Lib.current]);
		v = Type.createInstance( resolved, [parent]);

		for(attr in node.attributes())
		{
			var val = node.get(attr);
			if(val.charAt(0) == "@")
				Reflect.setField(args, attr, Reflect.field(flash.Lib.current, val.substr(1, val.length) ) );
			else
				Reflect.setField(args, attr, val );
		}

		if(node.firstChild()!=null) {
			//~ if(node.firstChild().nodeType==Xml.PCData)
			if(Std.string(node.firstChild().nodeValue).charAt(0)!="\n") {
				if(Std.string(node.firstChild().nodeValue).charAt(0)!="\t") {
					var str : String = node.firstChild().nodeValue;
					str = str.split("\t").join("");
					Reflect.setField(args, "innerData", str );
				}
			}
		}
		//~ trace(Std.string(node.firstChild().nodeType)+" "+Std.string(node.firstChild().nodeValue));

		if(Reflect.hasField( v, "init") )
			if(Reflect.isFunction( Reflect.field(v, "init") ))
				Reflect.callMethod( v, v.init, [args] );

		// recurse
		if(node.elements().hasNext())
			for(i in node.elements())
				getNode(i, v);

		return v;

	}


	public function getScript(node:Xml) : Dynamic
	{

		if(node.get("type") != "text/hscript")
			return new flash.Error("Not of type hscript");


		var script : String = node.firstChild().nodeValue;
		script = script.split("\n").join("");
		script = script.split("\t").join("");
		script = script.split(";").join("; ");
		//~ trace(script);

		var parser = new hscript.Parser();
		var program = parser.parseString(script);

		var interp = new hscript.Interp();

		interp.variables.set( "root", flash.Lib.current );
		//~ //interp.variables.set( "this", ? );

		interp.variables.set( "new", createInstance );
		interp.variables.set( "class", getClass );

		interp.variables.set( "Std", Std );
		interp.variables.set( "Math", Math );
		interp.variables.set( "Type", Type );
		interp.variables.set( "Reflect", Reflect );
		interp.variables.set( "Timer", haxe.Timer );

		interp.variables.set( "Sprite", Sprite );
		interp.variables.set( "TextField", TextField );

		interp.variables.set( "Event", Event );
		interp.variables.set( "MouseEvent", flash.events.MouseEvent );

		interp.variables.set( "StyleManager", StyleManager );
		interp.variables.set( "CursorManager", CursorManager );
		interp.variables.set( "Cursor", Cursor );

		interp.variables.set( "print_r", haxegui.Utils.print_r );

		try {
			var ret = interp.execute(program);
			trace(ret);
		} catch(e:Dynamic) {
			trace("XmlDeserializer script error parsing "+node.nodeName+": "+e);
		}


		//~ return ret;
		return ;

	}


	/**
	*
	*/
	public function deserialize()
	{
		for(i in  xml.firstElement().elements())
			getNode(i);
	}


	/**
	*  10x to filt3rek:
	*
	*  http://filt3r.free.fr/index.php/2008/07/23/59-hscript
	*
	*/
	function createInstance( s : String, a : Array<Dynamic> )
	{
		return Type.createInstance( Type.resolveClass( s ), a );
	}

	function getClass( s : String )
	{
		return Type.resolveClass( s );
	}

}

