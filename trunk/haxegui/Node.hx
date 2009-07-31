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

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;


import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import flash.events.EventDispatcher;

import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;
import haxegui.managers.StyleManager;
import haxegui.Window;

import haxegui.containers.Container;
import haxegui.controls.Component;
import haxegui.controls.ComboBox;
import haxegui.controls.Label;
import haxegui.controls.Input;
import haxegui.controls.IAdjustable;
import haxegui.utils.Color;
import haxegui.utils.Size;
import haxegui.utils.Opts;

import haxegui.toys.Socket;
import haxegui.toys.Patch;

using haxegui.utils.Color;
//}}}

/**
* Signal\Slot Matrix node.<br/>
*
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class Node extends Window
{
	public var combos : Array<ComboBox>;
	public var inputs : Array<Input>;
	public var sockets : Array<Socket>;
	public var adjustments : Array<Adjustment>;

	var container : Container;

	var _current : Dynamic ;

	var holders : Array<Component>;
	public override function init(opts:Dynamic=null) {
		super.init(opts);

		color = Color.random().tint(.5);
		box = new Size(240,80).toRect();
		type = WindowType.MODAL;

		moveTo(.5*(this.stage.stageWidth-box.width), .5*(this.stage.stageHeight-box.height));

		container = new Container(this, 10, 21);
		container.init({color: Color.WHITE});

		combos = [];
		inputs = [];
		sockets = [];
		holders = [];
		adjustments = [];
		for(i in 0...2) {
			adjustments.push(new Adjustment({ value: .0, min: Math.NEGATIVE_INFINITY, max: Math.POSITIVE_INFINITY, step: 5., page: 10.}));

			var j = combos.push(new ComboBox(container));
			combos[j-1].init({color: this.color, text: "", x: 20, y:10+28*i, width: 90});
			combos[j-1].data = ["Expression", "AND", "OR", "XOR", "NOR", "NAND", "XNOR"];

			var j = inputs.push(new Input(container));
			inputs[j-1].init({text: "", x: 120, y:10+28*i, width: 90});
			inputs[j-1].tf.multiline = false;
			inputs[j-1].tf.autoSize = flash.text.TextFieldAutoSize.NONE;
			inputs[j-1].tf.width = 80;


			j = sockets.push(new Socket(container));
			sockets[j-1].init({x: 220, y:20+28*i});

			sockets[i].removeEventListener(MouseEvent.MOUSE_DOWN, sockets[i].onMouseDown);
			sockets[j-1].removeEventListener(MouseEvent.MOUSE_DOWN, sockets[i].onMouseDown);
		}

		titlebar.color = this.color;
		titlebar.dirty = true;
		titlebar.minimizeButton.destroy();
		titlebar.maximizeButton.destroy();
		titlebar.closeButton.destroy();
		titlebar.setAction("redraw",
		"
		this.graphics.clear();
		var grad = flash.display.GradientType.LINEAR;
		var colors = [ Color.tint(this.color, .85), this.color ];
		var alphas = [ 1, 1 ];
		var ratios = [ 0, 0xFF ];
		var matrix = new flash.geom.Matrix();
		matrix.createGradientBox(this.parent.box.width, 20, .5*Math.PI, 0, 0);
		this.graphics.lineStyle(1, Color.darken(this.color, 50), 1, true, flash.display.LineScaleMode.NONE);
		this.graphics.beginGradientFill( grad, colors, alphas, ratios, matrix );
		this.graphics.drawRoundRectComplex (0, 0, this.parent.box.width + 10, 20, 4, 4, 0, 0);
		this.graphics.endFill ();
		");

		frame.removeEventListener(MouseEvent.MOUSE_MOVE, frame.onMouseMove);
		frame.color = this.color;
		frame.setAction("redraw",
		"
		this.graphics.clear ();

		this.graphics.lineStyle (2,
					 Color.darken(this.color, 50),
					1, true, flash.display.LineScaleMode.NONE,
					 flash.display.CapsStyle.NONE,
					 flash.display.JointStyle.ROUND);

		this.graphics.beginFill (Color.WHITE);
		this.graphics.drawRoundRect (2, 2, this.parent.box.width + 8, this.parent.box.height + 8, 8, 8);
		this.graphics.endFill ();
		");
	}


	public function onMouseMove(e:MouseEvent) {
		var patchLayer = cast flash.Lib.current.getChildByName('patchLayer');
		patchLayer.getChildAt(patchLayer.numChildren-1).end = new Point(e.stageX, e.stageY);
		patchLayer.getChildAt(patchLayer.numChildren-1).redraw();
	}

	public override function onMouseUp(e:MouseEvent) {
		if(_current==null) return;
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		var oa = stage.getObjectsUnderPoint(new Point(e.stageX, e.stageY));
		oa.reverse();
		var c = false;
		var self = this;
		for(o in oa)
			if(Std.is(o, Socket)) {
			if(Std.is(o.parent, IAdjustable)) {
			trace(_current+"\t"+o.parent);
			_current.addEventListener(Event.CHANGE, function(e) {
				var ao = (cast o.parent).adjustment;
				ao.setValue(Std.parseFloat(self._current.tf.text));
			}, false, 0, false);
			//~ }, false, 0, true);
			c = true;
			}
			else
			if(Std.is((cast o).getParentWindow(), Node)) {
				_current.addEventListener(Event.CHANGE, function(e) {
				var i = (cast o).prevSibling();
				//i.tf.text = self._current.tf.text;
				}, false, 0, false);
			}
		}

		super.onMouseUp(e);
	}

	public override function onMouseDown(e:MouseEvent) {
		if(Std.is(e.target, Socket)) {
			e.preventDefault();
			var patchLayer = cast flash.Lib.current.getChildByName('patchLayer');
			var patch = new haxegui.toys.Curvy(patchLayer);
			patch.init({thickness: 9, color: Color.random()});
			patch.start = new Point(e.stageX, e.stageY);
			patch.setAction("mouseDoubleClick", "this.destroy();");

			_current = e.target.prevSibling();

			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			return;
		}

		super.onMouseDown(e);
	}

	public override function destroy() {
		super.destroy();
	}
}
