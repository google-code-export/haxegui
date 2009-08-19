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

//{{{ Imports
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.text.TextField;
import haxegui.Window;
import haxegui.containers.Container;
import haxegui.containers.Divider;
import haxegui.containers.ScrollPane;
import haxegui.containers.Grid;
import haxegui.controls.CheckBox;
import haxegui.controls.Component;
import haxegui.controls.Image;
import haxegui.controls.Input;
import haxegui.controls.Label;
import haxegui.controls.MenuBar;
import haxegui.controls.Stepper;
import haxegui.controls.Tree;
import haxegui.controls.UiList;
import haxegui.events.ResizeEvent;
import haxegui.managers.FocusManager;
import haxegui.managers.StyleManager;
import haxegui.utils.Color;
import haxegui.utils.Size;
import haxegui.windowClasses.StatusBar;
//}}}


using haxegui.controls.Component;
using haxegui.utils.Color;


/**
*
* Introspector class
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.2
*/
class Introspector extends Window {

	//{{{ Members
	public var container 	: Container;
	public var treePane 	: ScrollPane;
	public var listPane 	: ScrollPane;
	public var textPane 	: ScrollPane;
	public var hdivider 	: Divider;
	public var vdivider 	: Divider;
	public var hbox			: HBox;
	public var tree 		: Tree;
	public var list1 		: UiList;
	public var list2 		: UiList;

	public var tf			: TextField;

	/** the inspected component **/
	public var target : Component;

	public static var props = {
		alpha					: "alpha",
		box						: "box",
		description				: "description",
		filters					: "filters",
		initOpts				: "initOpts",
		height					: "height",
		name 					: "name",
		parent 					: "parent",
		visible					: "visible",
		width					: "width",
		x						: "x",
		y						: "y"
		// size					: function(o) { return new Size.fromRect(o.box); },
		// type 				: function() { return Type.typeof(e.target); },
		// globalX				: function(){ return e.target.localToGlobal(new flash.geom.Point(e.target.x, e.target.y)).x; },
		// globalY				: function(){ return e.target.localToGlobal(new flash.geom.Point(e.target.x, e.target.y)).y; },
		//~ init				: "init",
		//~ validate			: "validate"
		// path					: function(){ var path = []; var p=e.target.parent; while(p!=null) untyped { path.push(p.name); p=p.parent; } path.pop();path.pop(); path.push("root"); path.reverse(); return path.join(".")+"."+e.target.name; },
	}

	static var xml = Xml.parse('
	<haxegui:Layout name="Introspector">
	<haxegui:controls:MenuBar x="10" y="20"/>
	<haxegui:containers:HDivider name="HDivider" x="10" y="40">

	<haxegui:containers:VDivider name="VDivider">



	<haxegui:containers:ScrollPane>
	<haxegui:controls:Tree fitH="true"/>
	</haxegui:containers:ScrollPane>
<!--


	<haxegui:toys:Rectangle width="300" height="240">
	<haxegui:containers:HBox cellSpacing="0" width="300" fitV="true" fitH="true">
		<haxegui:controls:UiList/>
		<haxegui:controls:UiList/>
	</haxegui:containers:HBox>
	</haxegui:toys:Rectangle>
-->
	</haxegui:containers:VDivider>

	<haxegui:toys:Rectangle/>
	</haxegui:containers:HDivider>
	</haxegui:Layout>
	').firstElement();
	//}}}


	//{{{ Functions
	//{{{ init
	public override function init(?opts:Dynamic) {
		super.init(opts);


		box = new Size(640, 500).toRect();

		xml.set("name", name);

		XmlParser.apply(Introspector.xml, this);


		//
		hdivider = cast this.getChildByName("HDivider");

		//
		vdivider = cast hdivider.getChildByName("VDivider");

		/*
		//
		textPane = new ScrollPane(vdivider, "textPane");
		textPane.init();

		tf = new flash.text.TextField();
		tf.wordWrap = false;
		tf.multiline = true;
		tf.width = textPane.box.width;
		tf.height = textPane.box.height;
		tf.autoSize = flash.text.TextFieldAutoSize.NONE;
		tf.background = true;
		tf.backgroundColor = Color.WHITE;
		tf.text = haxegui.utils.Printing.print_r(this);
		textPane.addChild(tf);

		textPane.addEventListener(ResizeEvent.RESIZE, onTextPaneResized, false, 0, true);
*/

		//
		treePane = cast vdivider.firstChild();

		//
		tree = cast treePane.content.getChildAt(0);

		// var self = this;
		// treePane.addEventListener(ResizeEvent.RESIZE,
		// function(e) {
		// 	if(self.tree==null || self.treePane==null ) return;
		// self.tree.box = self.treePane.box.clone();
		// self.tree.redraw();
		// });

		var o = {};
		for(i in 0...(cast root).numChildren)
		if(Std.is((cast root).getChildAt(i), DisplayObjectContainer))
		Reflect.setField(o, (cast root).getChildAt(i).name,  reflectDisplayObjectContainer((cast root).getChildAt(i)));

		tree.process(o, tree.rootNode);
/*

		//
		listPane = new ScrollPane(hdivider, "listPane");
		listPane.init({});

		//
		hbox = new HBox(listPane, "HBox");
		hbox.init({});

		//
		list1 = new UiList(hbox, "Properties");
		list1.init();


		//
		list2 = new UiList(hbox, "Values");
		list2.init();


		//
		statusbar = new StatusBar(this, "StatusBar", 10, 360);
		statusbar.init();


		// treePane.addEventListener(ResizeEvent.RESIZE, onResize, false, 0, true);
		// listPane.addEventListener(ResizeEvent.RESIZE, onResize, false, 0, true);
		// textPane.addEventListener(ResizeEvent.RESIZE, onResize, false, 0, true);
		// treePane.addEventListener(ResizeEvent.RESIZE, tree.onParentResize, false, 0, true);

		*/
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));

		// this.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onFocusChanged, false, 0, true);
	}
	//}}}


	public function onTextPaneResized(e:ResizeEvent) {
		tf.width = textPane.box.width;
		tf.height = textPane.box.height;
	}


	//{{{ onFocusChanged
	public function onFocusChanged(e:Dynamic) {
		if(e == this) return;
		if(!Std.is(e, flash.events.Event)) return;
		if(!Std.is(e.target, Component)) return;
		if(this.contains(e.target)) return;
		if(e.target==target) return;
		target = e.target;

		var self = this;


		if(Std.is(e.target, Component)) {
			Reflect.setField(props, "id", "id");
			Reflect.setField(props, "disabled", "disabled");
			Reflect.setField(props, "color", function() { return "0x"+StringTools.hex(e.target.color,6); });
			Reflect.setField(props, "focusable", "focusable");
			Reflect.setField(props, "dirty", "dirty");
			Reflect.setField(props, "box", "box");
		}


		//{{{ Lists
		if(list1!=null) list1.destroy();
		if(list2!=null) list2.destroy();

		list1 = new UiList(hbox, "Properties");
		list2 = new UiList(hbox, "Values");
		// list2.header.destroy();

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

		list1.init();
		list2.init();

		//}}}


		tf.text = haxegui.utils.Printing.print_r(target);


		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));

	}
	//}}}


	//{{{ onResize
	public override function onResize(e:ResizeEvent) {

		super.onResize(e);
	} //}}}


	//{{{ destroy
	public override function destroy() {this.stage.removeEventListener(flash.events.MouseEvent.MOUSE_DOWN, onFocusChanged);

		this.stage.removeEventListener(flash.events.MouseEvent.MOUSE_DOWN, onFocusChanged);
		super.destroy();
	}
	//}}}


	//{{{ reflectDisplayObjectContainer
	public function reflectDisplayObjectContainer(d:DisplayObjectContainer) : Dynamic {
		if(d==null) return;
		var o = {};
		for(i in 0...d.numChildren) {
			var child = d.getChildAt(i);
			if(Std.is(child, flash.display.BitmapData)) return;
			if(Std.is(child, flash.display.Bitmap)) return;
			if(Std.is(child, flash.text.TextField)) return;
			if(Std.is(child, DisplayObjectContainer))
			Reflect.setField( o, child.name, reflectDisplayObjectContainer(cast child) );
		}
		return o;
	}
	//}}}
	//}}}
}
