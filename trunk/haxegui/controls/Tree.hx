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

import flash.geom.Rectangle;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

import haxegui.managers.DragManager;
import haxegui.managers.CursorManager;
import haxegui.managers.StyleManager;
import haxegui.controls.Image;
import haxegui.controls.Component;
import haxegui.utils.Opts;
import haxegui.controls.Expander;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;
import haxegui.DataSource;
import haxegui.utils.Size;
import haxegui.utils.Color;

/**
*
* TreeLeaf class
* 
*
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class TreeLeaf extends Component
{
	var icon : Icon;
	var label : Label;
	
	override public function init(opts:Dynamic=null) {
		box = new Size(140,20).toRect();
		
		super.init(opts);

		label = new Label(this);
		label.init({text: this.name});
		label.move(24, 4);
		
		icon = new Icon(this);
		icon.init ({src: Icon.STOCK_DOCUMENT});
	
	}

	static function __init__() {
		haxegui.Haxegui.register(TreeLeaf);
	}
	
}



/**
* TreeNode class
* 
* @todo expand(), collapse()
*
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class TreeNode extends Component
{
	
	public var expander : Expander;
	public var depth : Int;

	public var expanded : Bool;
	public var selected : Bool;
	
	override public function init(opts:Dynamic=null) {
		color = DefaultStyle.INPUT_BACK;
		box = new Size(140, 24).toRect();
		depth = 0;

		depth = Opts.optInt(opts, "depth", depth);
						
		super.init(opts);

		expander = new Expander(this, name);
		expander.init();

		expander.setAction("mouseClick",
		"
		"
		);


	}
	
	
	public function expand() {
	
	}
	
	public function collapse() {
	
	}

	static function __init__() {
		haxegui.Haxegui.register(TreeNode);
	}
	
}



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

	public var selected : List<DisplayObject>;
	
	override public function init(opts:Dynamic=null) {
		
		color = DefaultStyle.INPUT_BACK;
		box = new Size(140,20).toRect();
	
	if(!Std.is(parent, Expander)) { 
		var o = { 
			node1: { 
				leaf1: "string",
				leaf2: "string"
				}
		};
		data = { node1: o, node2: o, node3: o};
		}

		super.init(opts);


		//process(data);
		for(i in 0...3) {
			var treenode = new TreeNode(this);
			treenode.init({width: box.width});
			addNode(treenode);
			for(j in 0...3) {

				var leaf = new TreeLeaf(treenode);
				leaf.init({width: box.width});
				addLeaf(leaf, treenode);
			}
		}
		
		this.setAction("redraw",
		"
			this.graphics.clear();
			this.graphics.lineStyle(1, Color.darken(DefaultStyle.BACKGROUND,10), 1);
			this.graphics.beginFill(this.color);
			this.graphics.drawRect(0,0, this.box.width, this.box.height);
			this.graphics.endFill();
		"
		);

	}

	public function process(o:Dynamic, ?node:Dynamic=null) {
		if(o==null) return;
		if(node==null) node=this;
		for(f in Reflect.fields(o)) {
				//var node = new TreeNode(this, key, 0, yOffset+d*yOffset);
				//node.init({depth: d++, width: this.box.width, color: this.color});				
				if(Reflect.isObject(Reflect.field(o, f))) {
					if(Std.is(Reflect.field(o, f), String))  {
						var leaf = new TreeLeaf(node, f);
						leaf.init({ width: this.box.width, visible: true});
						//addLeaf(leaf);
					}
					else {
						var treenode = new TreeNode(node, f);
						treenode.init({width: box.width});
						addNode(treenode);
						process(Reflect.field(o,f), treenode);
					}

				}
			
		}
	
	}
	
	public function addLeaf(leaf: TreeLeaf, node:TreeNode) {
		var n = 0;
		for(l in node)
			if(Std.is(l, TreeLeaf)) n++;
		leaf.move(16,24*n);
	}
	
	public function addNode(node: TreeNode) {
		var n = 0;
		for(t in this)
			if(Std.is(t, TreeNode)) {
				for(l in cast(t,Component))
					if(Std.is(l, TreeLeaf)) n++;
			n++;		
			}
		node.move(0,24*n);
	}

	static function __init__() {
		haxegui.Haxegui.register(Tree);
	}

}

