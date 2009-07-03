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

import haxegui.Component;
import haxegui.Opts;
import haxegui.controls.Expander;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;


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

	override public function init(opts:Dynamic=null)
	{
		box = new Rectangle(0,0,140,20);
		
		super.init(opts);

		expander = new Expander(this, name);
		expander.init();
		
	
		expander.setAction("mouseDown", "");
		expander.setAction("mouseUp", "");

		expander.setAction("mouseClick",
		"
		//~ var h = root.getBounds(this).height - 20;
		var h = this.getChildAt(1).numChildren * 20;

		for(i in parent.parent.getChildIndex(parent)+1...parent.parent.numChildren) {
			var child = parent.parent.getChildAt(i);
				var t = new feffects.Tween( 
				child.y, child.y + this.expanded ? h : -h, 1750,
				child, \"y\",
				feffects.easing.Expo.easeOut
				);
				t.start();
			}
		//~ var o = parent;
		//~ while(o!=null && Std.is(o, controls.TreeNode)) 
			//~ o = o.parent;

		"
		);


	}

	public override function onRollOver(e:MouseEvent) {
		//e.stopPropagation();
	}

	public override function onRollOut(e:MouseEvent) {
		//e.stopPropagation();
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
	
	public var data : Dynamic;
	
	override public function init(opts:Dynamic=null) {
		
		color = DefaultStyle.INPUT_BACK;
		box = new Rectangle(0,0,140,20);
		
		super.init(opts);

		
		var i = 0;
		for(key in Reflect.fields(data)) {

			var node = new TreeNode(this, key, 0, 20*i);
			node.init({width: this.box.width, color: this.color});

			if(Reflect.isObject(Reflect.field(data, key))) {
				
				var subtree = new Tree(node.expander);
				subtree.data = Reflect.field(data, key);
				subtree.init({width: this.box.width, visible: false});
				subtree.move(0, 16);
				
				for(i in 0...subtree.numChildren) 
					untyped subtree.getChildAt(i).getChildAt(0).x = 20;

				subtree.setAction("redraw", "");
			}
			
		i++;
		}


		
		this.setAction("redraw",
		"
			this.graphics.clear();
			this.graphics.lineStyle(1, Math.max(0, DefaultStyle.BACKGROUND - 0x141414), 1);
			this.graphics.beginFill(this.color);
			this.graphics.drawRect(0,0, this.box.width, this.box.height);
			this.graphics.endFill();
		"
		);

	}


	static function __init__() {
		haxegui.Haxegui.register(Tree);
	}


	public override function onRollOver(e:MouseEvent) {
		//e.stopPropagation();
	}

	public override function onRollOut(e:MouseEvent) {
		//e.stopPropagation();
	}

				
}

