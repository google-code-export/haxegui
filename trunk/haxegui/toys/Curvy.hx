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


import haxegui.Component;


class Curvy extends Component
{
	var points : Array<Point>;
	var k : Float;
	var kmax : Int;
	var kTween : feffects.Tween;
	
	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super(parent, name, x, y);
	}

	override public function init(?opts:Dynamic)
	{
		super.init();
		this.color = cast Math.random() * 0xFFFFFF;
		mouseEnabled = false;

		kmax = 4;
		k = .25*Math.PI;

		points = [new Point(x,y)];
		x=0;
		y=0;
	
		setAction("interval",
		"
		this.graphics.clear();
		var n = this.points.length;
		for(i in 0...n-1) {
			var mid = flash.geom.Point.interpolate(this.points[i], this.points[i+1], .5);			

			this.graphics.lineStyle(9,this.color);
			this.graphics.moveTo( this.points[i].x, this.points[i].y );
			this.graphics.curveTo(mid.x, mid.y, this.points[i+1].x, this.points[i+1].y);
			}
		"
		);
	

		var shadow = new flash.filters.DropShadowFilter (8, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, flash.filters.BitmapFilterQuality.HIGH, false, false, false );
		this.filters = [shadow];
			
			
	this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
	this.stage.addEventListener(MouseEvent.MOUSE_UP, onRelease);
	//~ this.stage.addEventListener(Event.ENTER_FRAME, redraw);
	this.startInterval(25);

	
	}


	function onMove(e) {
				var p1 = points[0];
				points = [p1];
				
				var p2 = new Point(e.stageX, e.stageY);
				p2.y = Math.max( p1.y, p2.y )*2 + 20;
				//~ points.push( flash.geom.Point.interpolate( p1, p2, .5 ));
				//~ for(i in 1...4)	 
					//~ points.push( flash.geom.Point.interpolate( p1, p2, 1/i ) );
				p2 = new Point(e.stageX, e.stageY);
				points.push( p2 );
	}
	
	function onRelease(e)
	{
	this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
	haxe.Timer.delay( stopInterval, 5000 );
	var t = new feffects.Tween( k, 0, 2500, this, "k", feffects.easing.Linear.easeNone );
	t.start();
	}


	static function __init__() {
		haxegui.Haxegui.register(Curvy);
	}
}
