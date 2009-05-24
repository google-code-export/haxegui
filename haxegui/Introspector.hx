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

import flash.geom.Rectangle;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import haxegui.Window;
import haxegui.Component;
import haxegui.controls.Label;
import haxegui.controls.UiList;
import haxegui.controls.Tree;
import haxegui.Container;
import haxegui.ScrollPane;

import haxegui.events.ResizeEvent;

import haxegui.managers.FocusManager;
import flash.events.FocusEvent;



class Introspector extends Window
{

	public var o : Dynamic;
	public var tree : Tree;
	public var list1 : UiList;
	public var list2 : UiList;
	public var list3 : UiList;


	/**
	*
	*/
	public function new (?parent:DisplayObjectContainer, ?x:Float, ?y:Float)
	{
		super (parent, "Introspector", x, y);
	}

	public override function init(?opts:Dynamic)
	{
		//~ o = flash.Lib.current;

		super.init(opts);
		box = new Rectangle (0, 0, 640, 320);

			
		//
		var menubar = new MenuBar (this, "MenuBar", 10,20);
		menubar.init ();

		//
		var scrollpane = new ScrollPane(this, "ScrollPane", 10, 44);
		scrollpane.init({});
	
		//
		var container = new Container(scrollpane, "Container", 0, 0);
		container.init({});


		//
		tree = new Tree(container, "Tree", 0, 0);
		tree.init({width: 250});
		
		//
		list1 = new UiList(container, "Properties", 260, 0);
		list1.init({text: "Property"});
		
		//
		list2 = new UiList(container, "Values", 400, 0);
		list2.init({text: "Value"});
		
		//
		list3 = new UiList(container, "Types", 540, 0);
		list3.init({text: "Type"});
		
	
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
		
		//~ FocusManager.getInstance().addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onFocusChanged);
		this.stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, onFocusChanged);
	}

	public function onFocusChanged(e:Dynamic)
	{
		//~ trace(e);
		//~ this.o = e.target;
		//~ this.o = FocusManager.getInstance().getFocus();
		//~ if(!Std.is(e.target, DisplayObjectContainer)) return;
		if(!Std.is(e.target, Component)) return;
		var self = this;
		var props = {
			name : "name",
			type : function() { return Type.typeof(e.target); },
			color : "color",
			box	: "box",
			x	: "x",
			y	: "y",
			visible	: "visible",
			disabled	: "disabled",
			alpha	: "alpha",
			buttonMode	: "buttonMode",
			globalX	: function(){ return e.target.localToGlobal(new flash.geom.Point(e.target.x, e.target.y)).x; },
			globalY	: function(){ return e.target.localToGlobal(new flash.geom.Point(e.target.x, e.target.y)).y; }
			}
		
		this.o = this.stage.getObjectsUnderPoint( new flash.geom.Point( e.stageX, e.stageY )).pop();
		
		if(list1!=null) {


		//~ list1.data = [ "target", "object", "component", "component" ];
		list1.data = [];
		list2.data = [];
		list3.data = [];

		for(i in Reflect.fields(props))
				list1.data.push(i);
		list1.redraw();

		for(i in Reflect.fields(props))
			if(Std.is(Reflect.field(props, i), String))
				list2.data.push( Reflect.field( e.target, Reflect.field(props, i) )	);
			else
				list2.data.push( Reflect.callMethod(props, Reflect.field(props, i),[]) );
				
		list2.redraw();

		for(i in Reflect.fields(props))
			if(!Reflect.isFunction(Reflect.field(props, i)))
				list3.data.push( Type.typeof(Reflect.field( e.target, Reflect.field(props, i) ) ) );
				//~ list3.data.push( Type.typeof(Reflect.field(props, i) ) );
		list3.redraw();


		}
		
	
	}
	
	public override function onResize(e:ResizeEvent)
	{
		super.onResize(e);
	
	if(tree!=null) {
		tree.box.height = this.box.height - 100;
		tree.redraw();
	}
	
	
	if(list1!=null) {


		list1.box.width = .333*(this.box.width - list1.x - 30) ;
		list1.box.height = tree.box.height;

		list1.redraw();
	}

	if(list2!=null) {


		//~ list2.box.width = this.box.width - list2.x - 40 ;
		list2.x = list1.x + list1.box.width;
		list2.box.width = list1.box.width ;
		list2.box.height = list1.box.height ;
		list2.redraw();
	}

	if(list3!=null) {

		if( list3.box.height < this.box.height - list3.y - 60)
			for(i in 0...Std.int((this.box.height - list3.y - 60 - list3.box.height)/20))
			list3.data.push( "" );

		//~ list3.box.width = this.box.width - list3.x - 40 ;
		list3.x = list2.x + list2.box.width;
		list3.box.width = list1.box.width ;
		list3.box.height = list1.box.height ;
		list3.redraw();
	}

		//~ trace(e);
	}
	
	
}
