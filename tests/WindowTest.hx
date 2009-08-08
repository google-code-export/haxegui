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


// package haxegui.tests;


//{{{ Imports
import feffects.Tween;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import haxegui.Automator;
import haxegui.Haxegui;
import haxegui.Window;
import haxegui.events.DragEvent;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.utils.Color;
import haxegui.utils.Size;
import utest.Assert;
import utest.Runner;
import utest.ui.text.TraceReport;
import haxegui.managers.WindowManager;
//}}}


using haxegui.controls.Component;

class WindowDragTest extends haxe.unit.TestCase {

	public var win : Window;

	public function new(w:Window) {
		super();
		win = w;
	}

	public override function setup() {
	}


	public function testDrag1() {

		var p = new Point(100,10);
		var q = new Point(500,100);
		Automator.mouseToPoint(p);

		var o = win.titlebar;
		var w = win;
		var test = this;

		Automator.mouseDown(o);

		var t = new Tween(0,1,1000, feffects.easing.Quad.easeInOut);
		t.setTweenHandlers(function(v){
			var r = Point.interpolate(q, p, v);
			var e = Automator.mouseToPoint(r);
			w.moveTo(r.x-100, r.y);
		}, function(v) {
			Automator.mouseUp(o);
		} );

		t.start();

		var async = Assert.createAsync(
		function(){
			Assert.equals( 400, w.x);
			Assert.equals( 100, w.y);
		}, 1001);
		haxe.Timer.delay(async, 1000);
	}

	public function testDrag2() {
		Assert.isFalse( win==null );

		var p = new Point(200,200);
		var q = new Point(500,100);
		Automator.mouseToPoint(p);

		var o = win.titlebar;
		var w = win;
		var test = this;

		Automator.mouseDown(o);

		var t = new Tween(0,1,1000, feffects.easing.Quad.easeInOut);
		t.setTweenHandlers(function(v){
			var r = Point.interpolate(q, p, v);
			var e = Automator.mouseToPoint(r);
			w.moveTo(r.x-100, r.y);
		}, function(v) {
			Automator.mouseUp(o);
		} );

		t.start();

		var async = Assert.createAsync(
		function(){
			Assert.equals( 100, w.x);
			Assert.equals( 200, w.y);
		}, 1001);
		haxe.Timer.delay(async, 1000);
	}

}

class WindowMoveTest extends haxe.unit.TestCase {

	public var win : Window;

	public function new(w:Window) {
		super();
		win = w;
	}

	public override function setup() {
	}

	public function teardown() {
	}


	// public function testMove() {
	// 	win.moveTo(200,200);
	// 	Assert.equals( "200", Std.string(win.x) );
	// 	Assert.equals( "200", Std.string(win.y) );
	// }

	// public function testMoveTo() {
	// 	win.moveTo(300,300);
	// 	Assert.equals( "300", Std.string(win.x) );
	// 	Assert.equals( "300", Std.string(win.y) );
	// }

	public function testStress() {
		var t = 25;
		var r = 81;
		for(i in 1...r) {
			haxe.Timer.delay(function(){
				var w = new Window(flash.Lib.current, "Window"+i, Std.random(flash.Lib.current.stage.stageWidth), Std.random(flash.Lib.current.stage.stageHeight));
				w.init({width: 100, height: 100, color: Color.random()});
				haxe.Timer.delay(function(){ w.moveTo(100*((i-1)%10), 100*Std.int((i-1)/10)); }, i*t+t);
				haxe.Timer.delay(function(){ w.destroy(); }, 2*t*(r+1));
			}, i*t);
		}


		var async = Assert.createAsync(
		function(){
			Assert.equals( 81, flash.Lib.current.numChildren);
		}, 2*t*r);
		haxe.Timer.delay(async, 2*t*r);

		var root = flash.Lib.current;
		var clean = function() {
		for(i in 0...root.numChildren-1)
			if(Std.is(root.getChildAt(i), Window))
			root.removeChild(root.getChildAt(i));
		}
		haxe.Timer.delay(clean, 2*t*(r+1)+(t+1)*r);

	}

}

class WindowResizeTest extends haxe.unit.TestCase {

	public var win : Window;

	public function new(w:Window) {
		super();
		win = w;
	}

	public override function setup() {
	}

	public function testResize() {
		win.resize(new Size(400,400));
		Assert.equals( "400", Std.string(win.box.width) );
		Assert.equals( "400", Std.string(win.box.height) );
	}
}


class WindowTest {

	public static var win : Window;
	public static var stage = flash.Lib.current.stage;

	static function main(){

		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		stage.align = flash.display.StageAlign.TOP_LEFT;
		stage.stageFocusRect = true;
		stage.frameRate = 30;

		// flash.Lib.current.removeChildByName("notice");

		// Setup Haxegui
		haxegui.Haxegui.init();


		haxe.Log.clear();

		Automator.mouseToPoint(new Point(stage.stageWidth/2, stage.stageHeight/2));

		// win = new Window();
		// win.init({});

		var runner = new Runner();

		runner.addCase(new WindowMoveTest(win));
		// runner.addCase(new WindowResizeTest(win));
		// runner.addCase(new WindowDragTest(win));

		var report = new TraceReport(runner);
		runner.run();
	}




}
