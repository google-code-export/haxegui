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

package haxegui.toys;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.FocusEvent;

import haxegui.managers.StyleManager;

import haxegui.utils.Color;

import haxegui.controls.Component;


class Curvy extends Line
{
	var points : Array<Point>;
	var cp : Array<Point>;

	var k : Float;
	var kmax : Int;
	var kTween : feffects.Tween;



	override public function init(?opts:Dynamic) {
		color = Color.random();
		super.init();

		//~ mouseEnabled = false;

		//~ kmax = 4;
		//~ k = .25*Math.PI;

		start = new Point(stage.mouseX, stage.mouseY);
		end = new Point(stage.mouseX, stage.mouseY);
		points = [start, end];
		cp = [Point.interpolate( start, end.add(new Point(0,50)), .5 )];



		setAction("redraw",
		"
		this.graphics.clear();
		var n = this.points.length;
		for(i in 0...n-1) {
			this.graphics.lineStyle(9,this.color);
			this.graphics.moveTo( this.points[i].x, this.points[i].y );
			this.graphics.curveTo(this.cp[i].x, this.cp[i].y, this.points[i+1].x, this.points[i+1].y);
			}
		"
		);

		this.filters = [new flash.filters.DropShadowFilter (8, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, flash.filters.BitmapFilterQuality.HIGH, false, false, false )];


		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
		stage.addEventListener(MouseEvent.MOUSE_UP, onRelease);



	}

	override function onMouseDown(e:MouseEvent) {
		for(i in getElementsByClass(Circle))
			i.visible = true;
		super.onMouseDown(e);
	}


	override function onMove(e) {

		var p1 = points[0];
		//var p2 = new Point(e.stageX-x, e.stageY-y);
		var p2 = new Point(e.stageX, e.stageY);

		points = [p1, p2];
		cp = [Point.interpolate( p1, p2.add(new Point(0,200)), .5 )];
		//~ cp = [new Point(2*p2.x - (p1.x+p2.x)/2 , 2*p2.y - (p1.y+p2.y)/2 )];

		var self = this;

		if(numChildren<1) {
			var c = new haxegui.toys.Circle(this);
			c.visible = false;
			c.moveTo(cp[0].x, cp[0].y);
			c.init({radius:10});
			c.addEventListener(MouseEvent.MOUSE_DOWN, function(e) {
				self.stage.addEventListener(MouseEvent.MOUSE_MOVE, self.updateControlPoints, false, 0, true);
				c.startDrag();
				self.updateControlPoints();
				self.stage.addEventListener(MouseEvent.MOUSE_UP, function(e) {
				c.stopDrag();
				self.stage.removeEventListener(MouseEvent.MOUSE_MOVE, self.updateControlPoints);
				self.updateControlPoints();
			}, false, 0, true);
			});

		}
		else
		(cast getChildAt(0)).moveTo(cp[0].x, cp[0].y);


			updateControlPoints();
				redraw();
	}

	function updateControlPoints(?e:Dynamic) {

		for(i in 0...cp.length)
			if(numChildren>i)
			if(this.getChildAt(i)!=null) {
				//~ cp[i] = new Point(this.getChildAt(i).x, this.getChildAt(i).y);
				//cp[i].add(cp[i]);
				//~ cp[i].x = 2*(this.mouseX) - (points[0].x+points[1].x)/2;
				//~ cp[i].y = 2*(this.mouseY) - (points[0].y+points[1].y)/2;
				cp = [Point.interpolate( start, new Point(stage.mouseX, stage.mouseY).add(new Point(0,200)), .5 )];

				}
	//~ dirty = true;
		redraw();

	}


	static function __init__() {
		haxegui.Haxegui.register(Curvy);
	}
}
