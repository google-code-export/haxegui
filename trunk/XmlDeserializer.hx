//      XmlDeserializer.hx
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

import haxe.Serializer;
import haxe.Unserializer;


import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import StyleManager;
import CursorManager;

import hscript.Expr;

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
			return null;
		}
			

			
		//
		var resolved = Type.resolveClass(name);
		if(resolved == null) return null;
		
		//
		var v : Dynamic = {};	
		var args : Dynamic = {};
	
			//~ v = Type.createInstance( Type.resolveClass(name), [flash.Lib.current]);					
			v = Type.createInstance( Type.resolveClass(name), [parent]);					

		
		for(i in node.attributes())
			Reflect.setField(args, i, node.get(i) );


				if(node.firstChild()!=null)
					//~ if(node.firstChild().nodeType==Xml.PCData)
					if(Std.string(node.firstChild().nodeValue).charAt(0)!="\n")
					if(Std.string(node.firstChild().nodeValue).charAt(0)!="\t")
					{
						var str : String = node.firstChild().nodeValue;
						str = str.split("\t").join("");
						Reflect.setField(args, "innerData", str );
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
		
		if(node.get("type")!="text/hscript")
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
		interp.variables.set( "Event", Event );
		interp.variables.set( "MouseEvent", flash.events.MouseEvent );
		interp.variables.set( "StyleManager", StyleManager );
        interp.variables.set( "CursorManager", CursorManager );
        interp.variables.set( "Cursor", Cursor );
		
		interp.variables.set( "print_r", Utils.print_r );

		var ret = interp.execute(program); 
		trace(ret);
		
		//~ return ret;
		return ;
		
	}
	
	
	/**
	 * 
	 * 
	 * 
	 */
	public function deserialize()
	{
	
		for(i in  xml.firstElement().elements()) 
			getNode(i);
				
	
	}

	function createInstance( s : String, a : Array<Dynamic> )
	{
		return Type.createInstance( Type.resolveClass( s ), a );
	}

	function getClass( s : String )
	{
		return Type.resolveClass( s );
	}




}
