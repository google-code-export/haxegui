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
import haxegui.Image;
import haxegui.controls.Label;
import haxegui.controls.UiList;
import haxegui.controls.Tree;
import haxegui.Container;
import haxegui.ScrollPane;

import haxegui.events.ResizeEvent;

import haxegui.managers.FocusManager;
import haxegui.managers.StyleManager;
import flash.events.FocusEvent;



class Introspector extends Window
{

	public var tree : Tree;
	public var list1 : UiList;
	public var list2 : UiList;


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
		tree.data = { 
			var1 : 1, 
			var2: 2, 
			str: "String", 
			bool: false, 
			array: [1,2], 
			obj2: { 
				var1: 1,
				var2: 2
				  },
			obj3: { 
				var1: 1,
				var2: 2,
				obj4: { 
					var1: 1,
					var2: 2
				      }
				  },
				obj5: { 
					var1: 1,
					var2: 2
				}
			};
		tree.init({width: 200});
		
		
		//
		list1 = new UiList(container, "Properties", 210, 0);
		list1.init({text: "Property"});
		
		//
		list2 = new UiList(container, "Values", 350, 0);
		list2.init({text: "Value"});
		

	
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
		
		//~ FocusManager.getInstance().addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onFocusChanged);
		this.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onFocusChanged);
		onFocusChanged(this);
	}

	public function onFocusChanged(e:Dynamic)
	{
		if(!Std.is(e, flash.events.Event)) return;
		if(!Std.is(e.target, Component)) return;
		
		
		var self = this;
		var props = {
			name 		: "name",
			//~ type 		: function() { return Type.typeof(e.target); },
			color 		: "color",
			box			: "box",
			//~ rect		: function(){ return e.target.getRect(e.target); },
			//~ bounds		: function(){ return e.target.getBounds(e.target); },
			x			: "x",
			y			: "y",
			visible		: "visible",
			disabled	: "disabled",
			alpha		: "alpha",
			buttonMode	: "buttonMode"
			//~ globalX		: function(){ return e.target.localToGlobal(new flash.geom.Point(e.target.x, e.target.y)).x; },
			//~ globalY		: function(){ return e.target.localToGlobal(new flash.geom.Point(e.target.x, e.target.y)).y; }
			}
		
		
	
		list1.data = [];
		list2.data = [];

		var src = "assets/icons/types/type-undefined.png";
		
		for(key in Reflect.fields(props)) {
				list1.data.push(key);
				var value = Reflect.field( e.target, Reflect.field(props, key));
				list2.data.push( value );
		}
		
		list1.redraw();
		list2.redraw();
		
			for(i in 1...list1.numChildren-1)
			{
				var item = (cast list1).getChildAt(i);
				var fmt = DefaultStyle.getTextFormat();
				fmt.leftMargin = 20;
				item.getChildAt(0).defaultTextFormat = fmt;
				var icon = new Image((cast item), "icon"+i, 4, 4);
					//~ src = "assets/icons/types/type-string.png";
					//~ src = "assets/icons/types/type-float.png";
					//~ src = "assets/icons/types/type-integer.png";
					//~ src = "assets/icons/types/type-boolean.png";
				
				icon.init({src: src});
			}
	}
	
	public override function onResize(e:ResizeEvent)
	{
		super.onResize(e);
	
	if(tree!=null) {
		tree.box.height = this.box.height - 70;
		//~ tree.box.height = 600;
		tree.dirty = true;
	}
	
	
	if(list1!=null) {

		list1.box.width = .5*(this.box.width - list1.x - 30) ;
		list1.box.height = tree.box.height;
		list1.dirty = true;
		//~ list1.redraw();
	}

	if(list2!=null) {

		//~ list2.box.width = this.box.width - list2.x - 40 ;
		list2.x = list1.x + list1.box.width;
		list2.box.width = list1.box.width ;
		list2.box.height = list1.box.height ;
		list2.dirty = true;
		//~ list2.redraw();
	}



		//~ trace(e);
	}
	
	
}
