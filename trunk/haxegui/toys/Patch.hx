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
package haxegui.toys;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.FocusEvent;

import haxegui.Haxegui;
import haxegui.events.MoveEvent;
import haxegui.managers.StyleManager;

import haxegui.controls.AbstractButton;
import haxegui.controls.Component;
import haxegui.containers.Container;
import haxegui.utils.Size;
import haxegui.utils.Color;

import aPath.Node;
import aPath.Engine;

using haxegui.utils.Color;

//}}}

/**
* Patch cable to visually connect signals and slots.<br/>
*
*
*
*/
class Patch extends AbstractButton
{
	/** **/
	public var container : Container;

	/** Signal emitting object **/
	public var source : Dynamic;

	/** Signal receiving object **/
	public var target : Dynamic;

	public var bitmap : Bitmap;

	/** the aPath engine **/
	public var engine : Engine;

	public var paths : Array<Array<Node>>;


	/** @see [Component.init] **/
	override public function init(?opts:Dynamic=null) {
		engine = new aPath.Engine();
		paths = [];

		super.init(opts);
		
		alpha = .5;
		color = Color.tint(Color.BLACK, .5);

		// this is turned back on onMouseUp
		mouseEnabled = false;


		//~ var p = new Point(source.x, source.y);
		//~ p = source.parent.localToGlobal(p);
		//~ p = p.add(new Point(9,9));

		//~ if(target!=null)
		//~ end = new Point(target.x, target.y);


		// add the drop-shadow filters
		filters = [new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 6, 6, 0.5, flash.filters.BitmapFilterQuality.LOW, false, false, false )];

		dirty = false;

	}

	public override function redraw(?opts:Dynamic=null) {
		if(paths==null || paths.length==0) return;
		// sort paths by length
		//~ paths.sort(function(p1,p2){return p2.length - p1.length;});
//~ var str="";
//~ for(i in paths) {
	//~ str += i.length + ", ";
	//~ if(i[i.length-1]==engine.endNode) {
		//~ paths.unshift(paths.pop());
		//~ break;
	//~ }
//~ }
//~ trace(str);
		var f = Haxegui.gridSpacing ;
		var fix = new Point(f,f);

		this.graphics.clear();

//~ for(i in paths) {
		var path = paths[paths.length-1];
		//~ var path = i;
		var node = engine.startNode;


		this.graphics.lineStyle(0,0,0);
		this.graphics.beginFill(this.color);
		this.graphics.drawCircle(node.x*Haxegui.gridSpacing+fix.x, node.y*Haxegui.gridSpacing+fix.y, 5);
		//~ this.graphics.drawCircle(container.x+source.x+source.slot.x, container.y+source.y+source.slot.y, 8);
		//~ node = engine.endNode;
		//~ this.graphics.drawCircle(node.x*Haxegui.gridSpacing+fix.x, node.y*Haxegui.gridSpacing+fix.y, 8);
		var p = stage.localToGlobal(new Point(container.mouseX-source.slot.x, container.mouseY-source.slot.y));
		//~ var bool = engine.endNode.parent!=null ;
		//~ for(o in container.getObjectsUnderPoint(p))
				//~ bool = bool || Std.is(o, Socket);

		//~ if(bool)
		this.graphics.drawCircle(p.x, p.y, 5);
		this.graphics.endFill();

		//~ node = path[path.length-1];
		node = path[path.length-1].parent.parent;
		this.graphics.lineStyle(4, this.color, 1);

		//~ var j=0;
		if(node==null) return;

			//~ if(bool) {
				this.graphics.moveTo(p.x, p.y);
				this.graphics.lineTo( node.x*Haxegui.gridSpacing+fix.x, node.y*Haxegui.gridSpacing+fix.y);
			//~ }

		while(node.parent!=null) {
			this.graphics.moveTo( node.x*Haxegui.gridSpacing+fix.x, node.y*Haxegui.gridSpacing+fix.y);
			node = node.parent;
			this.graphics.lineTo( node.x*Haxegui.gridSpacing+fix.x, node.y*Haxegui.gridSpacing+fix.y);
			//~ j++;
		}
		
		//~ super.redraw(opts);
	}
//~ }
	public function setupMap(w:Int, h:Int, s:Int) {

		//~ var w = Std.int(container.box.width/Haxegui.gridSpacing);
		//~ var h = Std.int(container.box.height/Haxegui.gridSpacing);
		//~ var dt = haxe.Timer.stamp();

		engine.generateMap(w,h);

		var o = null;
		var dt = haxe.Timer.stamp();
		for(i in 0...w)
		for(j in 0...h) {

			var samplePoints = [
			new flash.geom.Point((i*s)+s>>1, (j*s)+s>>1)
			//~ new flash.geom.Point( hs-1,-hs),
			//~ new flash.geom.Point(-hs+1, hs-1),
			//~ new flash.geom.Point( hs-1, hs-1)
			];

			for(k in samplePoints) {
				var o = container.getObjectsUnderPoint(new flash.geom.Point(k.x, k.y)).pop();
				if(o==null) continue;
				if(o!=container && (Std.is(o, Component) && !(cast o).disabled)) {

					// mark unwalkables
/*					
					container.graphics.beginFill(Color.CYAN, .5);
					container.graphics.drawRect(i*Haxegui.gridSpacing, j*Haxegui.gridSpacing,  Haxegui.gridSpacing,  Haxegui.gridSpacing);
					container.graphics.endFill();
*/					
					engine.map[i][j].close = true;
					//engine.map[i][j].type = Type.BREAK_NODE;

				}

			}
		}

		//~ trace('Mapping took: ~'+Std.string(haxe.Timer.stamp()-dt).substr(0,7)+'ms, Grid size: '+Lambda.count(engine.map)*Lambda.count(engine.map[0]));

	}


	/*
	public function setupMap(w:Int, h:Int, s:Int) {
	engine.generateMap(w,h);
	var bmpd = bitmap.bitmapData;
	var dt = haxe.Timer.stamp();
	for(i in 0...w)
	for(j in 0...h) {

	var samplePoints = [
	new Point(i*s-(i*s)%s+s>>1, j*s-(j*s)%s+s>>1)
	//~ new Point(i*s+s-1, j*s+s-1),
	//~ new Point(i*s-s+1, j*s-s+1)
	//~ new flash.geom.Point(-hs+1, hs-1),
	//~ new flash.geom.Point( hs-1, hs-1)
	];

	for(k in samplePoints) {
	var p = bmpd.getPixel32(Std.int(k.x), Std.int(k.y));
	var alpha = p >> 24 & 0xFF;
	if(alpha==0)
	{
	engine.map[i][j].close = true;
	engine.map[i][j].type = Type.BREAK_NODE;

	// mark unwalkables
	container.graphics.beginFill(Color.CYAN, .5);
	container.graphics.drawRect((i*s)-(i*s)%s, (j*s)-(j*s)%s,  s,  s);
	container.graphics.endFill();
	}
	}
	}
	trace('Mapping took: ~'+Std.string(haxe.Timer.stamp()-dt).substr(0,7)+'ms, Grid size: '+Lambda.count(engine.map)*Lambda.count(engine.map[0]));
	}
	*/


	/** Starting point for pathfinding **/
	public function setStartPoint()  {
		var s = Size.fromRect(container.box);
		s.scale(1/Haxegui.gridSpacing, 1/Haxegui.gridSpacing);
		
		var ix = Std.int(source.x/Haxegui.gridSpacing);
		var iy = Std.int(source.y/Haxegui.gridSpacing);

		if(ix>s.width-2 || ix<0 || iy>s.height || iy<0) return;
		var node = engine.map[ix][iy];

		engine.setStartNode(node);
	}


	public function setEndPoint(e:MouseEvent) {
		//~ if(e.target==null || e.target==source) return;
		
		var s = Size.fromRect(container.box);
		s.scale(1/Haxegui.gridSpacing, 1/Haxegui.gridSpacing);
		
		var mp = new Point(e.stageX, e.stageY);
		var o = stage.getObjectsUnderPoint(mp).pop();
		if(Std.is(o, Socket)) {
			color = Color.random();
			redraw();
			return;
		}	
				
		var p = container.globalToLocal(mp);
		p.subtract(new Point(source.x, source.y));
		
		var ix = Std.int(p.x/Haxegui.gridSpacing);
		var iy = Std.int(p.y/Haxegui.gridSpacing);
	
		//if(ix>w-2 || ix<0 || iy>h || iy<0) return;
		ix = Std.int(Math.max(0, Math.min(s.width-2, ix)));
		iy = Std.int(Math.max(0, Math.min(s.height-2, iy)));


		var node = engine.map[ix][iy];
		if(node==null) return;
		//~ trace(new Point(ix,iy)+",\tneigboors: "+node.getAdjacentNodes(engine.map).length);

		// mark the end node on the grid
/*		
		container.graphics.beginFill(Color.YELLOW, .5);
		container.graphics.drawRect(ix*Haxegui.gridSpacing, iy*Haxegui.gridSpacing, Haxegui.gridSpacing, Haxegui.gridSpacing);
		container.graphics.endFill();
*/

		//~ for(p in paths) 
			//~ for(n in p)
				//~ if(n==node) {
					//~ paths.unshift(p);
					//~ redraw();
					//~ return;
		//~ }
		if(engine.endNode==engine.map[ix][iy]) return;


		// set as endNode in the aPath engine
		engine.setEndNode(engine.map[ix][iy]);


		color = Color.BLACK.tint(.5);

			
		try {
			paths.push(engine.getPath());
		}
		catch(e:Dynamic) {
			//~ trace(e);
			//~ var s = Haxegui.gridSpacing;
			//~ Haxegui.gridSpacing = Haxegui.gridSpacing<<1;
			//~ setupMap(w>>1,h>>1, Haxegui.gridSpacing);
		
			if(!Std.is(o, haxegui.controls.IAdjustable) && !Std.is(o, haxegui.containers.IContainer)) {
			//~ dirty = true;
				redraw();
				return;
			}

			
			//~ engine.generateMap(s.width, s.height);
			//~ redraw();
			
			//~ dirty = true;
			//~ var self = this;
			//~ haxe.Timer.delay(function() { if(self!=null) self.setupMap(s.width, s.height, Haxegui.gridSpacing); }, 24);
			//~ haxe.Timer.delay(function() { if(self!=null) self.dirty=true; }, 4);
			setupMap(s.width, s.height, Haxegui.gridSpacing);
			//~ setupMap(s.width, s.height, Haxegui.gridSpacing<<1);
			
			//~ return;
			//~ setupMap(w,h);
			//~ Haxegui.gridSpacing = s;
			//~ return;
		}


		//~ var path = engine.getPath();
		//~ if(path==null || path.length==0) return;
		//~ trace("Path Length: "+path.length);

		// redraw the patch
		redraw();

		e.updateAfterEvent();
	}


	override public function onMouseUp(e:MouseEvent) {

		//~ trace(e.target);
		//~ if(!Std.is(e.target, Socket)) destroy();
		if(!Std.is(e.target, Socket)) { destroy(); return; }


		//~ stopInterval();
		mouseEnabled = true;
		stage.removeEventListener(flash.events.MouseEvent.MOUSE_MOVE, setEndPoint);
		stage.removeEventListener(flash.events.MouseEvent.MOUSE_UP, onMouseUp);
		
		var self = this;
		target = e.target.parent;
		
		trace(target);
		
		if(Std.is(self.target.getParentWindow(), haxegui.Node))
		target = e.target;

		var onSourceChange = function(e) {
			var ao = self.source.adjustment.object;
			if((Std.is(self.source, haxegui.toys.SevenSegment) || Std.is(self.source, haxegui.controls.Stepper))&& Std.is(self.target, haxegui.toys.Knob)) ao.value = -145 + ao.value*36;
			//~ if(Std.is(self.source, haxegui.toys.Knob) && ( Std.is(self.target, haxegui.controls.Stepper) || Std.is(self.target, haxegui.toys.SevenSegment))) ao.value = cast ao.value/27;
			if(Std.is(self.target.getParentWindow(), haxegui.Node)) {
				var text = self.target.prevSibling().input.tf.text;
				//~ text = Std.string(ao.value) + text;
				text = Std.string(ao.value) ;
				try {
					var out = self.target.nextSibling();

					var parser = new hscript.Parser();
					var program = parser.parseString( text );
					var interp = new hscript.Interp();

					interp.variables.set( "x", ao.value );
					haxegui.utils.ScriptStandardLibrary.set(interp);

					text = interp.execute(program);
					if(text!=null) 
						out.setText(text);
				}
				catch(e:Dynamic) {
					trace(e);
				}
				//~ trace(interp.execute(program));

				//~ trace(self.target.parent.adjustments);
				return;
			}

			self.target.adjustment.adjust(ao);
		}
		source.adjustment.addEventListener(Event.CHANGE, onSourceChange);

		super.onMouseUp(e);
	}

	override public function onMouseDoubleClick(e:MouseEvent) : Void {
		this.destroy();
	}

	override public function destroy() {
		root.stage.removeEventListener(flash.events.MouseEvent.MOUSE_MOVE, setEndPoint);
		root.stage.removeEventListener(flash.events.MouseEvent.MOUSE_UP, onMouseUp);
		super.destroy();
	}

	static function __init__() {
		haxegui.Haxegui.register(Patch);
	}
}
