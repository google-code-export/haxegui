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

import haxegui.controls.Component;

/**
*
* Style and Layout parser
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class XmlParser {
	private var isStyle : Bool;

	private function new(xml:Xml) {
		var typeParts = xml.nodeName.split(":");
		if(typeParts[0] != "haxegui")
			throw "Not a haxegui node";
		switch(typeParts[1].toLowerCase()) {
		case "layout":	isStyle = false;
		case "style":	isStyle = true;
		default:		throw "Unhandled xml type: " + typeParts[1];
		}

		trace("XmlParser: Setting " + typeParts[1].toLowerCase() + " to " + xml.get("name"));
		for(x in xml.elements())
			parseNode(x);
	}

	/**
	* Gets the name from a layout xml node.
	*
	* @return Null or layout name
	**/
	public static function getLayoutName(xml:Xml) : String {
		var typeParts = xml.nodeName.split(":");
		if(typeParts[0] != "haxegui")
			return null;
		switch(typeParts[1].toLowerCase()) {
		case "layout":
		default: return null;
		}
		return xml.get("name");
	}

	/**
	* Gets the name from a style xml node.
	*
	* @return Null or style name
	**/
	public static function getStyleName(xml:Xml) : String {
		var typeParts = xml.nodeName.split(":");
		if(typeParts[0] != "haxegui")
			return null;
		switch(typeParts[1].toLowerCase()) {
		case "style":
		default: return null;
		}
		return xml.get("name");
	}

	public static function isLayoutNode(xml:Xml) : Bool {
		var typeParts = xml.nodeName.split(":");
		if(typeParts[0] == "haxegui" && typeParts[1].toLowerCase() == "layout")
			return true;
		return false;
	}

	public static function isStyleNode(xml:Xml) : Bool {
		var typeParts = xml.nodeName.split(":");
		if(typeParts[0] == "haxegui" && typeParts[1].toLowerCase() == "style")
			return true;
		return false;
	}

	/**
	* Applies the given style or layout from the provided Xml node
	**/
	public static function apply(xml:Xml) {
		var xp = new XmlParser(xml);
	}

	function parseNode(node:Xml, ?parent:Dynamic) : Void {
		var className = node.nodeName.split(":").join(".");

		if(!isStyle) {
			if(Std.is(parent, List))
			{
				parent.add( node.firstChild().nodeValue );
				return;
			}

			if(Std.is(parent, Array))
			{
				parent.push( node.firstChild().nodeValue );
				Reflect.setField(flash.Lib.current, node.parent.get("name"), parent);
				// trace(Reflect.field(flash.Lib.current, "IntArray"));
				// trace(node.parent.get("name"));
				return;
			}
		}

		var resolvedClass = Type.resolveClass(className);
		if(resolvedClass == null) {
			trace("XmlParser : warning : Class " + className + " not resolved.");
			return;
		}

		var inst : Dynamic = null;
		var comp : Component = null;
		if(!isStyle) {
			var args : Dynamic = {};
			inst = Type.createInstance(resolvedClass, [parent]);
			if(Std.is(inst, Component)) {
				comp = cast inst;
			}

			for(attr in node.attributes())
			{
				var val = node.get(attr);
				if(val.charAt(0) == "@")
					Reflect.setField(args, attr, Reflect.field(flash.Lib.current, val.substr(1, val.length) ) );
				else
					Reflect.setField(args, attr, val );
			}

			if(node.firstChild() != null) {
				//~ if(node.firstChild().nodeType==Xml.PCData)
				if(Std.string(node.firstChild().nodeValue).charAt(0)!="\n") {
					if(Std.string(node.firstChild().nodeValue).charAt(0)!="\t") {
						var str : String = node.firstChild().nodeValue;
						str = str.split("\t").join("");
						Reflect.setField(args, "innerData", str );
					}
				}
			}

			// run the init script, if it's a Component or other
			// type with an Init field
			if(Reflect.hasField( inst, "init") )
				if(Reflect.isFunction( Reflect.field(inst, "init") ))
					Reflect.callMethod( inst, inst.init, [args] );
		}


		// parse event scripts
		for(evtSet in node.elementsNamed("events")) {
			for(x in evtSet.elements())
				parseScriptNode(className, x, inst, resolvedClass);
		}

		if(!isStyle) {
			if(node.elements().hasNext())
				for(i in node.elements())
					parseNode(i, inst);
			if(comp != null && comp.hasAction("onLoaded")) {
				trace("Executing onLoaded method for component "+ comp.name);
				try {
					StyleManager.exec(comp, "onLoaded", {});
				} catch(e:Dynamic) {
					trace("Error executing onLoaded method for component "+ comp.name);
				}
			}
		}
	}

	//<script type="text/hscript" action="redraw">
	function parseScriptNode(className:String, node:Xml, inst:Component, resolvedClass : Class<Dynamic>) {
		var location = " in "+className+"<events> section";
		if(node.nodeName != "script") {
			trace("XmlParser : warning : Unexpected node " + node.nodeName + location);
			return;
		}

		var type : String = node.get("type");
		var action : String = node.get("action");

		if(type != "text/hscript") {
			trace("XmlParser : error : Unhandled script type " + type + location);
			return;
		}

		if(action == null) {
			trace("XmlParser : warning : No action attribute " + node.nodeName + location);
			return;
		}

		var code : String = "";

		for(i in node) {
			if(i.nodeType == Xml.PCData) continue;
			if(i.nodeType == Xml.CData)
				code += i.nodeValue;
			else
				trace("XmlParser : warning : Bad node type " + node.firstChild().nodeType + location);
		}

		if(isStyle)
			StyleManager.setDefaultScript(resolvedClass,action,code);
		else
			StyleManager.setInstanceScript(inst,action,code);
	}

}