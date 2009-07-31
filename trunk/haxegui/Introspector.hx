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

//{{{ Imports
package haxegui;


import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import haxegui.Window;
import haxegui.controls.Component;
import haxegui.controls.Image;
import haxegui.controls.Label;
import haxegui.controls.UiList;
import haxegui.controls.CheckBox;
import haxegui.controls.Stepper;
import haxegui.controls.Input;
import haxegui.controls.Tree;
import haxegui.controls.MenuBar;
import haxegui.containers.Container;
import haxegui.containers.ScrollPane;

import haxegui.events.ResizeEvent;

import haxegui.managers.FocusManager;
import haxegui.managers.StyleManager;
import flash.events.FocusEvent;
import haxegui.windowClasses.StatusBar;
import haxegui.utils.Size;
//}}}

/**
*
* Introspector class
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.2
*/
class Introspector extends Window
{
	public var container : Container;
	public var scrollpane : ScrollPane;
	public var tree : Tree;
	public var list1 : UiList;
	public var list2 : UiList;

	public var target : Component;


	public override function init(?opts:Dynamic) {
		//~ o = flash.Lib.current;

		super.init(opts);
		box = new Size(640, 320).toRect();


		//
		var menubar = new MenuBar (this, "MenuBar", 10,20);
		menubar.init ();

		//
		container = new Container(this, "Container", 10, 44);
		container.init({});

		//
		scrollpane = new ScrollPane(container, "ScrollPane1", 210, 0);
		scrollpane.init({width: 400, fitH: false, fitV: false});
		scrollpane.removeChild(scrollpane.horz);

		//
		var scrollpane2 = new ScrollPane(container, "ScrollPane2", 0, 0);
		scrollpane2.init({width: 190, fitH: false, fitV: false});

		//
		tree = new Tree(scrollpane2);
		//tree.data = { root : reflectDisplayObjectContainer(cast flash.Lib.current) };
		tree.data = { root : reflectDisplayObjectContainer(cast flash.Lib.current) };
		tree.init({width: 250});


		//
		list1 = new UiList(scrollpane, "Properties", 210, 0);
		list1.init({text: null});

		//
		list2 = new UiList(scrollpane, "Values", 350, 0);
		list2.init();

		//
		var statusbar = new StatusBar(this, "StatusBar", 10, 360);
		statusbar.init();



		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));

		//FocusManager.getInstance().addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onFocusChanged, false, 0, true);
		this.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onFocusChanged, false, 0, true);

	}

	public function onFocusChanged(e:Dynamic) {
		if(e == this) return;
		if(!Std.is(e, flash.events.Event)) return;
		if(!Std.is(e.target, Component)) return;
		if(this.contains(e.target)) return;
		if(e.target==target) return;
		target = e.target;

		//~ var scrollpane = tree.parent;
		//~ scrollpane.removeChild(tree);
		//~ tree = new Tree(scrollpane, "Tree", 0, 0);
		//~ var o = { root : reflectComponent(cast flash.Lib.current) };
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
			type 					: function() { return Type.typeof(e.target); },
			globalX					: function(){ return e.target.localToGlobal(new flash.geom.Point(e.target.x, e.target.y)).x; },
			globalY					: function(){ return e.target.localToGlobal(new flash.geom.Point(e.target.x, e.target.y)).y; },
			//~ init					: "init",
			//~ initOpts				: "initOpts",
			//~ validate				: "validate"
			path					: function(){ var path = []; var p=e.target.parent; while(p!=null) untyped { path.push(p.name); p=p.parent; } path.pop();path.pop(); path.push("root"); path.reverse(); return path.join(".")+"."+e.target.name; },
			}
		if(Std.is(e.target, Component)) {
			Reflect.setField(props, "id", "id");
			Reflect.setField(props, "disabled", "disabled");
			Reflect.setField(props, "color",function() { return StringTools.hex(e.target.color); });
			Reflect.setField(props, "focusable", "focusable");
			Reflect.setField(props, "dirty", "dirty");
			Reflect.setField(props, "box", "box");
		}

		if(Std.is(e.target, UiList)) {
			Reflect.setField(props, "dataSource", "dataSource");
		}
		//~ if(Std.is(e.target, haxegui.controls.AbstractButton)) {
			//~ Reflect.setField(props, "autoRepeat", "autoRepeat");
			//~ Reflect.setField(props, "repeatWaitTime", "repeatWaitTime");
			//~ Reflect.setField(props, "repeatsPerSecond", "repeatsPerSecond");
		//~ }


		if(list1!=null)
			list1.destroy();
		if(list2!=null)
			list2.destroy();

		list1 = new UiList(scrollpane, "Properties", 210, 0);
		list2 = new UiList(scrollpane, "Values", 350, 0);
		list1.description = list2.description = null;

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

		list1.init({text: "Property"});
		list2.init({text: "Value"});
		for(item in list2.getElementsByClass(ListItem)) {
			item.label.tf.selectable = true;
			item.label.tf.mouseEnabled = true;
			}


		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));

	}



	public override function onResize(e:ResizeEvent) {

		var container = cast this.getChildByName("Container");
		if(container==null) return;

		var scrollpane = cast container.getChildByName("ScrollPane1");
		if(scrollpane!=null) {
			scrollpane.box.height = this.box.height - 65;
			scrollpane.box.width = this.box.width - scrollpane.x - 30;
			scrollpane.dirty = true;
			}
		scrollpane = cast container.getChildByName("ScrollPane2");
		if(scrollpane!=null)
			scrollpane.box.height = this.box.height - 85;


		if(tree!=null) {
			tree.box.height = this.box.height - 85;
			tree.dirty = true;
		}


		if(list1!=null) {
			list1.x = 0;
			list1.box.width = .5*(this.box.width - list1.parent.parent.x - 30) ;
			list1.box.height = tree.box.height + 20;
			list1.dirty = true;
		}

		if(list2!=null) {
			list2.x = list1.x + list1.box.width;
			list2.box.width = list1.box.width ;
			list2.box.height = list1.box.height ;
			list2.dirty = true;
		}

		super.onResize(e);
	}


	public override function destroy() {
		this.stage.removeEventListener(flash.events.MouseEvent.MOUSE_DOWN, onFocusChanged);
		super.destroy();
	}


	function reflectDisplayObjectContainer(d:DisplayObjectContainer) : Dynamic {
		if(d==null) return;
		var o = {};
		for(i in 0...d.numChildren) {
			var child = d.getChildAt(i);
			if(Std.is(child, flash.display.BitmapData)) return;
			if(Std.is(child, flash.display.Bitmap)) return;
			if(Std.is(child, flash.text.TextField)) return;
				Reflect.setField( o, child.name, reflectDisplayObjectContainer(cast child) );
		}
		return o;
	}



}
