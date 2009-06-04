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
import haxegui.windowClasses.StatusBar;

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

	public var target : Component;
	
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
		var container = new Container(this, "Container", 10, 44);
		container.init({});
		
		//
		var scrollpane = new ScrollPane(container, "ScrollPane1", 210, 0);
		scrollpane.init({width: 400, fitH: false, fitV: false});
		scrollpane.removeChild(scrollpane.horz);

		//
		var scrollpane2 = new ScrollPane(container, "ScrollPane2", 0, 0);
		scrollpane2.init({width: 190, fitH: false, fitV: false});

		//
		tree = new Tree(scrollpane2);
		var o = { root : reflectDisplayObject(cast flash.Lib.current) };
		tree.data = o;
		tree.init({width: 250});
		
		
		//
		list1 = new UiList(scrollpane, "Properties", 210, 0);
		list1.init({text: "Property"});
		
		//
		list2 = new UiList(scrollpane, "Values", 350, 0);
		list2.init({text: "Value"});
		
		//
		var statusbar = new StatusBar(this, "StatusBar", 10, 360);
		statusbar.init();

	
	
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
		
		//~ FocusManager.getInstance().addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onFocusChanged);
		//~ this.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onFocusChanged);
		//~ onFocusChanged(this);
	}

	public function onFocusChanged(e:Dynamic)
	{
		if(e == this) return;
		if(!Std.is(e, flash.events.Event)) return;
		if(!Std.is(e.target, Component)) return;
		if(this.contains(e.target)) return;
		
		target = e.target;
		
		//~ var scrollpane = tree.parent;
		//~ scrollpane.removeChild(tree);
		//~ tree = new Tree(scrollpane, "Tree", 0, 0);
		//~ var o = { root : reflectDisplayObject(cast flash.Lib.current) };
		//~ tree.data = o;
		//~ tree.init({width: 250});
		//~ untyped tree.getChildAt(0).getChildAt(0).expanded = true;
		//~ 
		var self = this;
		
		var props = {
			name 					: "name",
			parent 					: "parent",
			x						: "x",
			y						: "y",
			width					: "width",
			height					: "height",
			visible					: "visible",
			alpha					: "alpha",
			//~ width					: function() { return (cast e.target).box.width; },
			//~ height					: function() { return (cast e.target).box.height; },
			//~ type 					: function() { return Type.typeof(e.target); },
			//~ globalX					: function(){ return e.target.localToGlobal(new flash.geom.Point(e.target.x, e.target.y)).x; },
			//~ globalY					: function(){ return e.target.localToGlobal(new flash.geom.Point(e.target.x, e.target.y)).y; },
			//~ init					: "init",
			//~ initOpts				: "initOpts",
			//~ focusable				: "focusable",
			//~ dirty					: "dirty",
			//~ id						: "id",
			//~ validate				: "validate"
			}
		if(Std.is(e.target, Component)) {
			Reflect.setField(props, "disabled", "disabled");
			Reflect.setField(props, "color", "color");
			Reflect.setField(props, "focusable", "focusable");
			Reflect.setField(props, "dirty", "dirty");
		}
		
		//~ if(Std.is(e.target, haxegui.controls.AbstractButton)) {
			//~ Reflect.setField(props, "autoRepeat", "autoRepeat");
			//~ Reflect.setField(props, "repeatWaitTime", "repeatWaitTime");
			//~ Reflect.setField(props, "repeatsPerSecond", "repeatsPerSecond");
		//~ }
		
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
				var value = Reflect.field( target, Reflect.field(props, key));
					list2.data.push( value );
				}
		}

		// redraw
		list1.redraw();
		list2.redraw();
			
			// place some icons
			//~ for(i in 1...list1.numChildren-1)	
			for(i in 0...Reflect.fields(props).length-1)	
				if(Std.is(list1.getChildAt(i), ListItem)) {

				// get a ListItem
				var item = cast(list1.getChildAt(i), ListItem);

				// icon
				if(item.numChildren>1)
					item.removeChild(item.getChildByName("icon"));
				var icon = new Image((cast item), "icon", 4, 4);
				var src = "assets/icons/types/type-undefined.png";

				switch( Type.typeof( list2.data[i]) ) {
					case TClass(c):
						if(Std.is(c, String)) {
						src = "assets/icons/types/type-string.png";
						var inpt = new Input(cast list2.getChildAt(i), "Input", 2, 2);
						inpt.init({width: 100, height: 16, text: list2.data[i], label: list2.data[i] });
						untyped list2.getChildAt(i).removeChild(list2.getChildAt(i).getChildAt(0));						
						untyped list2.getChildAt(i).setAction("mouseOver", "");
						untyped list2.getChildAt(i).setAction("mouseOut", "");
						untyped list2.getChildAt(i).setAction("mouseDown", "");
						untyped list2.getChildAt(i).setAction("mouseUp", "");
						}
					case TInt:
						src = "assets/icons/types/type-integer.png";
						var stp = new Stepper(cast list2.getChildAt(i), "Stepper", 2, 2);
						stp.init({height: 16, value: list2.data[i], max: Math.POSITIVE_INFINITY });
						untyped list2.getChildAt(i).removeChild(list2.getChildAt(i).getChildAt(0));
						untyped list2.getChildAt(i).setAction("mouseOver", "");
						untyped list2.getChildAt(i).setAction("mouseOut", "");
						untyped list2.getChildAt(i).setAction("mouseDown", "");
						untyped list2.getChildAt(i).setAction("mouseUp", "");
						var l = list1;
						stp.addEventListener(flash.events.Event.CHANGE, 
							function(e) {
								if(Reflect.hasField(self.target, l.data[i]))
									Reflect.setField(self.target, l.data[i], stp.value); 
								} );
					case TFloat:
						src = "assets/icons/types/type-float.png";
						var stp = new Stepper(cast list2.getChildAt(i), "Stepper", 2, 2);
						stp.init({height: 16, value: list2.data[i], max: Math.POSITIVE_INFINITY });
						untyped list2.getChildAt(i).removeChild(list2.getChildAt(i).getChildAt(0));
						untyped list2.getChildAt(i).setAction("mouseOver", "");
						untyped list2.getChildAt(i).setAction("mouseOut", "");
						untyped list2.getChildAt(i).setAction("mouseDown", "");
						untyped list2.getChildAt(i).setAction("mouseUp", "");
						var l = list1;
						stp.addEventListener(flash.events.Event.CHANGE, 
							function(e) {
								if(Reflect.hasField(self.target, l.data[i]))
									Reflect.setField(self.target, l.data[i], stp.value); 
								} );
					case TBool:
						src = "assets/icons/types/type-boolean.png";
						var chkbox = new CheckBox(cast list2.getChildAt(i), "CheckBox", 2, 2);
						chkbox.init({width: 16, height: 16, checked: list2.data[i], label: null });
						untyped list2.getChildAt(i).removeChild(list2.getChildAt(i).getChildAt(0));
						untyped list2.getChildAt(i).setAction("mouseOver", "");
						untyped list2.getChildAt(i).setAction("mouseOut", "");
						untyped list2.getChildAt(i).setAction("mouseDown", "");
						untyped list2.getChildAt(i).setAction("mouseUp", "");
						var l = list1;
						chkbox.addEventListener(flash.events.Event.CHANGE, 
							function(e) {
								if(Reflect.hasField(self.target, l.data[i]))
									Reflect.setField(self.target, l.data[i], chkbox.checked); 
								} );						
					case TFunction:
						src = "assets/icons/types/type-function.png";

					default:
						src = "assets/icons/types/type-undefined.png";
				}
				// icon
				icon.init({src: src});
				
				// text
				//~ var tf = cast(item.getChildAt(0), flash.text.TextField);
				//~ var fmt = DefaultStyle.getTextFormat();
				//~ fmt.leftMargin = 20;
				//~ tf.defaultTextFormat = fmt;
				//~ tf.setTextFormat(fmt);
				//~ tf.x = 20;
				item.label.moveTo(20,4);
			
				target.redraw();
			}
	}
	
	
	
	public override function onResize(e:ResizeEvent) {

		var container = cast this.getChildByName("Container");
		if(container!=null) {
			var scrollpane = cast container.getChildByName("ScrollPane1");
			if(scrollpane!=null) {
				scrollpane.box.height = this.box.height - 65;
				scrollpane.box.width = this.box.width - scrollpane.x - 30;
				}
			scrollpane = cast container.getChildByName("ScrollPane2");
			if(scrollpane!=null) 
				scrollpane.box.height = this.box.height - 85;
				
		}
		
		
		if(tree!=null) {
			tree.box.height = this.box.height - 85;
			//~ tree.box.height = 600;
			tree.dirty = true;
		}
		
		
		if(list1!=null) {

			list1.x = 0;
			list1.box.width = .5*(this.box.width - list1.parent.parent.x - 30) ;
			list1.box.height = tree.box.height + 20;
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
		super.onResize(e);
	}
	

	public override function destroy() {
		this.stage.removeEventListener(flash.events.MouseEvent.MOUSE_DOWN, onFocusChanged);
		super.destroy();
	}


	function reflectDisplayObject(d:DisplayObjectContainer) : Dynamic {
		if(d==null) return;
		var o = {};
		for(i in 0...d.numChildren) {
		var child = cast d.getChildAt(i);
		if(child==null) return;
		if(Std.is(child, flash.display.BitmapData)) return;
		if(Std.is(child, flash.display.Bitmap)) return;
		//~ if(!Std.is(child, flash.text.TextField)) {
		if(!Std.is(child, flash.text.TextField)) {
			//~ Reflect.setField( o, child.name, child );
			Reflect.setField( o, child.name, reflectDisplayObject(cast child) );
			}
		}
		return o;
	}
		
		
	
}
