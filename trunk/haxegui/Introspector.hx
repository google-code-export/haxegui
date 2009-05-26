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
import haxegui.controls.CheckBox;
import haxegui.controls.Stepper;
import haxegui.controls.Input;
import haxegui.controls.Tree;
import haxegui.Container;
import haxegui.ScrollPane;

import haxegui.events.ResizeEvent;

import haxegui.managers.FocusManager;
import haxegui.managers.StyleManager;
import flash.events.FocusEvent;


/**
*
* Introspector class
* 
*
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.2
*/
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
		if(untyped this.getChildByName("ScrollPane").contains(e.target)) return;
		
		
		var self = this;
		var props = {
			parent 		: "parent",
			name 		: "name",
			x			: "x",
			y			: "y",
			box			: "box",
			color 		: "color",
			type 		: function() { return Type.typeof(e.target); },
			//~ rect		: function(e){ return e.target.getRect(e.target); },
			//~ bounds		: function(e){ return e.target.getBounds(e.target); },
			//~ globalX		: function(){ return e.target.localToGlobal(new flash.geom.Point(e.target.x, e.target.y)).x; },
			//~ globalY		: function(){ return e.target.localToGlobal(new flash.geom.Point(e.target.x, e.target.y)).y; }
			init				: "init",
			initOpts			: "initOpts",
			visible				: "visible",
			disabled			: "disabled",
			alpha				: "alpha",
			buttonMode			: "buttonMode",
			focusable			: "focusable",
			dirty				: "dirty",
			id					: "id",
			validate			: "validate",
			}
		
		if(Std.is(e.target, haxegui.controls.AbstractButton)) {
			Reflect.setField(props, "autoRepeat", "autoRepeat");
			Reflect.setField(props, "repeatWaitTime", "repeatWaitTime");
			Reflect.setField(props, "repeatsPerSecond", "repeatsPerSecond");
		}
		
	
		list1.data = [];
		list2.data = [];

		
		// fill the lists
		for(key in Reflect.fields(props)) {
				
				//
				list1.data.push(key);

				//
				if(Reflect.isFunction(Reflect.field(props, key)))
					list2.data.push( Reflect.callMethod(props, Reflect.field(props, key), []) );
				
				else {
				var value = Reflect.field( e.target, Reflect.field(props, key));
				list2.data.push( value );
				}
					//~ list2.data.push("");
					//~ list2.data.push( Reflect.field(props, key) );
				//~ else
				//~ if(Reflect.isObject(Reflect.field(props, key)))
					//~ list2.data.push( Std.string( Reflect.field( e.target, Reflect.field(props, key)) ));
				//~ else
					//~ list2.data.push( Reflect.field( e.target, Reflect.field(props, key)));
		}

		// redraw
		list1.redraw();
		list2.redraw();
			
			// place some icons
			for(i in 1...list1.numChildren)	
				if(Std.is(list1.getChildAt(i), ListItem)) {

				// get a ListItem
				var item = cast(list1.getChildAt(i), ListItem);
				// text
				var tf = cast(item.getChildAt(0), flash.text.TextField);
				var fmt = DefaultStyle.getTextFormat();
				fmt.leftMargin = 20;
				tf.defaultTextFormat = fmt;
				tf.setTextFormat(fmt);
				
			
				// icon
				if(item.numChildren>1)
					item.removeChild(item.getChildByName("icon"));
				var icon = new Image((cast item), "icon", 4, 4);
				var src = "assets/icons/types/type-undefined.png";
/*				
				switch( Type.typeof( list2.data[i]) ) {
					case TClass(c):
						if(Std.is(c, String))
						src = "assets/icons/types/type-string.png";
					case TInt:
						src = "assets/icons/types/type-integer.png";

					case TFloat:
						src = "assets/icons/types/type-float.png";

					case TBool:
						src = "assets/icons/types/type-boolean.png";

					case TFunction:
						src = "assets/icons/types/type-function.png";

					default:
						src = "assets/icons/types/type-undefined.png";
				}
*/
				if(Std.is(list2.data[i], Component))
					src = "assets/icons/types/type-class.png";
				else
				if(Std.is(list2.data[i], String)) {
					src = "assets/icons/types/type-string.png";
					var inpt = new Input(cast list2.getChildAt(i), "Input", 2, 2);
					inpt.init({width: 16, height: 16, checked: list2.data[i], label: list2.data[i] });
					untyped list2.getChildAt(i).removeChild(list2.getChildAt(i).getChildAt(0));
					}
				else
				if(Std.is( list2.data[i], Bool )) {
					src = "assets/icons/types/type-boolean.png";
					var chkbox = new CheckBox(cast list2.getChildAt(i), "CheckBox", 2, 2);
					chkbox.init({width: 16, height: 16, checked: list2.data[i], label: null });
					untyped list2.getChildAt(i).removeChild(list2.getChildAt(i).getChildAt(0));
					untyped list2.getChildAt(i).setAction("mouseOver", "");
					untyped list2.getChildAt(i).setAction("mouseOut", "");
					untyped list2.getChildAt(i).setAction("mouseDown", "");
					untyped list2.getChildAt(i).setAction("mouseUp", "");
					}
				else
				if(Std.is( list2.data[i], Int ) || Std.is( list2.data[i], UInt ) ) {
					src = "assets/icons/types/type-integer.png";
					var stp = new Stepper(cast list2.getChildAt(i), "Stepper", 2, 2);
					stp.init({height: 16, value: list2.data[i], label: list2.data[i] });
					untyped list2.getChildAt(i).removeChild(list2.getChildAt(i).getChildAt(0));
					untyped list2.getChildAt(i).setAction("mouseOver", "");
					untyped list2.getChildAt(i).setAction("mouseOut", "");
					untyped list2.getChildAt(i).setAction("mouseDown", "");
					untyped list2.getChildAt(i).setAction("mouseUp", "");
					}
				else
				if(Std.is( list2.data[i], Float ))
					src = "assets/icons/types/type-float.png";
				else
				if(Reflect.isFunction( list2.data[i] )) 
					src = "assets/icons/types/type-function.png";

				icon.init({src: src});
			}
	}
	
	
	
	public override function onResize(e:ResizeEvent) {
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
