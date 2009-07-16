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
import haxegui.Image;
import haxegui.Component;
import haxegui.Opts;
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
		label.init({innerData: this.name});
		label.move(24, 4);
		
		icon = new Icon(this);
		icon.init ({src: Icon.STOCK_NEW});
	
	}

	static function __init__() {
		haxegui.Haxegui.register(TreeLeaf);
	}
	
}



/**
*
* TreeNode class
* 
*
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class TreeNode extends Component
{
	
	public var expander : Expander;

	override public function init(opts:Dynamic=null) {
		box = new Size(140,20).toRect();
		
		super.init(opts);

		expander = new Expander(this, name);
		expander.init();

		expander.setAction("mouseClick",
		"
		for(i in parent.getChildIndex(parent)+1...parent.numChildren) {
			var node = tree.getChildAt(i);
			node.y += 20*(this.expanded?1:-1);				
		}
		

		"
		);


	}
	static function __init__() {
		haxegui.Haxegui.register(TreeNode);
	}
	
}



/**
*
* Tree Class
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*
*/
class Tree extends Component {
	
	public var dataSource : DataSource;
	public var data : Dynamic;
	
	override public function init(opts:Dynamic=null) {
		
		color = DefaultStyle.INPUT_BACK;
		box = new Size(140,20).toRect();

	if(!Std.is(parent, Expander)) { 
		var o = { lvl1_1: { lvl1_2: { lvl1_3_1: "string", lvl1_3_2: "string", lvl1_3_3: "string"}}};
		data = { lvl0_1: o, lvl0_2: o, lvl0_3: o};
		}

				
		super.init(opts);

		for(key in Reflect.fields(data)) {

			var yOffset = 20;
			var node = new TreeNode(this, key, 0, yOffset);
			node.init({width: this.box.width, color: this.color});				

			if(Reflect.isObject(Reflect.field(data, key))) {
				if(Std.is(Reflect.field(data, key), String)) {
					var leaf = new TreeLeaf(node.expander);
					leaf.init({ width: this.box.width, visible: true });
					leaf.move(16,yOffset);
				}
				else {
					var subtree = new Tree(node.expander);
					subtree.data = Reflect.field(data, key);
					subtree.init({width: this.box.width, visible: true});
					subtree.move(16,0);

					subtree.setAction("redraw", "");
				}
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


	static function __init__() {
		haxegui.Haxegui.register(Tree);
	}

}

