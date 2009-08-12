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

package haxegui.controls;

//{{{ Imports
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import haxegui.DataSource;
import haxegui.controls.Component;
import haxegui.controls.Expander;
import haxegui.controls.Image;
import haxegui.events.DragEvent;
import haxegui.events.ResizeEvent;
import haxegui.managers.CursorManager;
import haxegui.managers.DragManager;
import haxegui.managers.StyleManager;
import haxegui.utils.Color;
import haxegui.utils.Opts;
import haxegui.utils.Size;
//}}}


using haxegui.controls.Component;


//{{{ Tree Leaf
/**
*
* TreeLeaf class
*
*
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class TreeLeaf extends AbstractButton, implements IAggregate {
	/** Optional icon **/
	var icon : Icon;
	/** Default to the name property **/
	var label : Label;

	//{{{ init
	override public function init(opts:Dynamic=null) {
		box = new Size(140,24).toRect();
		icon = null;

		super.init(opts);

		label = new Label(this);
		label.init({text: this.name});
		label.move(48, 4);

		icon = new Icon(this, 24, 4);
		icon.init ({src: Icon.STOCK_DOCUMENT});

	}
	//}}}

	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(TreeLeaf);
	}
	//}}}

}
//}}}


//{{{ TreeNode
/**
* Expandable tree node<br/>
*
* @todo expand(), collapse()
*
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class TreeNode extends AbstractButton, implements IAggregate {

	public var expander : Expander;

	public var depth : Int;

	public var expanded : Bool;
	public var selected : Bool;

	//{{{ init
	override public function init(opts:Dynamic=null) {
		color = DefaultStyle.INPUT_BACK;
		box = new Size(140, 24).toRect();
		depth = Opts.optInt(opts, "depth", 0);


		super.init(opts);

		expander = new Expander(this, name);
		expander.init({style: "arrow_and_icon", expanded: false});
		// expander.init({style: ExpanderStyle.ARROW_AND_BOX, expanded: false});
		//expander.setAction("mouseClick", "");
		expander.label.x += 24;

		expander.mouseEnabled = false;
		expander.removeEventListener(MouseEvent.CLICK, expander.onMouseClick);

	}
	//}}}

	public function empty() {
		return expander.numChildren<=2;
	}


	//{{{ addChild
	public override function addChild(o:DisplayObject) : DisplayObject {
		if(expander==null) return super.addChild(o);
		return expander.addChild(o);
	}
	//}}}


	//{{{ getChildIndex
	public override function getChildIndex(o:DisplayObject) : Int {
		if(expander==null) return super.getChildIndex(o);
		return expander.getChildIndex(o);
		// return super.addChild(o);
	}
	//}}}


	//{{{ onMouseClick
	public override function onMouseClick(e:MouseEvent) {


		if(empty() || disabled) return;

			expander.expanded = !expander.expanded;

			if(expander.expanded)
			expand();
			else
			collapse();

			for(i in 2...expander.numChildren)
			expander.getChildAt(i).visible = expander.expanded;



		e.stopImmediatePropagation();

		super.onMouseClick(e);
	}
	//}}}


	//{{{ expand
	public function expand() {
		var h = 24*(this.expander.numChildren-2);
		var i = parent.getChildIndex(this) + 1;
		for(j in i...parent.numChildren)
		parent.getChildAt(j).y += h;


		// if((cast a).numChildren!=0)
		// for(j in a.asComponent())
		// j.y += h;

	}
	//}}}


	//{{{ collapse
	public function collapse() {
		var i = parent.getChildIndex(this) + 1;
		for(j in i...parent.numChildren)
		parent.getChildAt(j).y = 24*j - 24;


	}
	//}}}

	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(TreeNode);
	}
	//}}}
}
//}}}


//{{{ Tree
/**
*
* Tree Class
*
* @todo all
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*
*/
class Tree extends Component, implements IData {
	public var dataSource : DataSource;
	public var data : Dynamic;
	/** A list of selected items on the tree **/
	public var selected : List<DisplayObject>;
	public var rootNode : TreeNode;

	public var showRoot : Bool;
	//{{{ Functions
	//{{{ init
	override public function init(opts:Dynamic=null) {
		box = new Size(140,24).toRect();
		color = DefaultStyle.INPUT_BACK;


		super.init(opts);


		rootNode = new TreeNode(this, "rootNode");
		rootNode.init({x: 12, width: box.width, color: this.color });



		// var o = {};
		// var root = flash.Lib.current;
		// for(i in 0...root.numChildren) {
		// 	var child = cast root.getChildAt(i);
		// 	Reflect.setField(o, child.name, child);
		// }

		// process(o, rootNode);
		var self = this;
		addEventListener(ResizeEvent.RESIZE, function(e){ trace(e); self.redraw(); });
	}
	//}}}

	public function count() : Int {
		return 0;
	}

	//{{{ redraw
	public override function redraw(opts:Dynamic=null) {
		// background
		this.graphics.clear();
		for(i in 0...Std.int(this.box.height/24)+1) {
			this.graphics.beginFill( (i%2==0?Color.darken(this.color,10):this.color) );
			this.graphics.drawRect(0, 24*i, this.box.width, 24);
			this.graphics.endFill();
		}

		// var o = this;
		// var draw = function(x:Float,y:Float) {
		// 	var h = 24;
		// 	o.graphics.lineStyle(1, Color.darken(DefaultStyle.BACKGROUND,30), 1);
		// 	o.graphics.moveTo(12+x, h+24*y);
		// 	o.graphics.lineTo(12+x, 12+h+24*y);
		// 	o.graphics.lineTo(12+x, 12+h+24*y);
		// 	o.graphics.lineTo(24+x, 12+h+24*y);
		// }

		this.graphics.lineStyle(1, Color.darken(DefaultStyle.BACKGROUND,30), 1);
		this.graphics.moveTo(24, 12);
		this.graphics.lineTo(24, 24*this.rootNode.expander.numChildren);


		// var node = this.asComponent();
		for(i in 0...this.rootNode.expander.numChildren) {
			this.graphics.moveTo(24, 24*i-12);
			this.graphics.lineTo(48, 24*i-12);

		}



		super.redraw(opts);
	}
	//}}}


	//{{{ process
	public function process(o:Dynamic, ?node:Dynamic=null) {
		if(o==null) return;
		if(node==null) node=this;
		for(f in Reflect.fields(o)) {
			if(Reflect.isObject(Reflect.field(o, f))) {
				if(Std.is(Reflect.field(o, f), String) || Reflect.fields(Reflect.field(o,f)).length==0 )  {
					var leaf = new TreeLeaf(node, f);
					leaf.init({x: x+24, y: 24*(node.getChildIndex(leaf)-1), width: this.box.width, visible: false});
				}
				else {
					var treenode = new TreeNode(node, f);
					treenode.init({x: x+24, y: 24*(node.getChildIndex(treenode)-1), width: box.width, visible: false });
					process(Reflect.field(o,f), treenode);
				}
			}
		}
	}
	//}}}

	public function onParentResize(e:ResizeEvent) : Void {
		box = parent.asComponent().box.clone();
		redraw();
	}

	public override function onResize(e:ResizeEvent) : Void {
		redraw();
	}


	public function visibleRowCount() : Int {
		// var count = function(o) { if(o==null) return; var i=o.numChildren; for(j in o) i+=count(j); return i; };
		return 0;
	}

	public function totalRowCount() : Int {
		// return 0;
		return countNode(rootNode);
	}

	public function countNode(n:TreeNode) : Int {
		if(n==null) return 0;
		var i = n.expander.numChildren;
		for(c in n.expander)
			if(Std.is(c, TreeNode)) i+=countNode(cast c);
			return i;
	}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(Tree);
	}
	//}}}
	//}}}
}
//}}}

