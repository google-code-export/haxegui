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
import haxegui.controls.ScrollBar;
import haxegui.containers.Container;
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



class BarsTest extends haxe.unit.TestCase {

	public var win : Window;
	public var cnt : Container;
	public var bars : Array<Dynamic>;

	public function new(w:Window) {
		super();
		win = w;
		cnt = win.getElementsByClass(Container).next();
		bars = cnt.getElementsByClassArray(ScrollBar);
	}

	public override function setup() {
	}

	public function testCreation() {
		Assert.equals( 7, Lambda.count(bars));
	}


	public function testManualHandleMovment() {
		for(i in 0...7) {
			bars[i].handle.move(0, 180*i/7);
			trace(bars[i].adjustment.getValue());
		}
		// Assert.equals( 7, Lambda.count(bars));
	}
}


class ScrollBarTest {

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

		win = new Window();
		win.init({});
		win.moveTo( Std.int(stage.stageWidth - win.box.width)>>1, Std.int(stage.stageHeight - win.box.height)>>1);

		var cnt = new Container(win);
		cnt.init();

		var txt = new flash.text.TextField();
		cnt.addChild(txt);

		for(i in 0...7) {
			var sb = new ScrollBar(cnt, 20+40*i, 20);
			sb.init({target: txt, height: 180});
		}

		var runner = new Runner();

		runner.addCase(new BarsTest(win));

		var report = new TraceReport(runner);
		runner.run();
	}




}
