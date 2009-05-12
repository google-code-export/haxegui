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

package haxegui;

import Type;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.LineScaleMode;

import flash.text.TextField;
import flash.text.TextFormat;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import flash.events.EventDispatcher;

import flash.ui.Keyboard;

import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;
import haxegui.events.MenuEvent;

import flash.ui.Mouse;

import flash.Error;
import haxe.Timer;
//~ import flash.utils.Timer;

import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.BevelFilter;

import haxegui.StyleManager;
import haxegui.controls.Label;
import haxegui.controls.Stepper;
import haxegui.controls.UiList;


import feffects.Tween;
import feffects.easing.Quint;
import feffects.easing.Sine;
import feffects.easing.Back;
import feffects.easing.Bounce;
import feffects.easing.Circ;
import feffects.easing.Cubic;
import feffects.easing.Elastic;
import feffects.easing.Expo;
import feffects.easing.Linear;
import feffects.easing.Quad;
import feffects.easing.Quart;



/**
 *
 *
 *
 */
class Stats extends Window, implements Dynamic
{

  var list : UiList;

  var gridSpacing : UInt;
  var graph : Sprite;
  var grid : Sprite;
  var ploter : Sprite;


  var data : Array<Point>;
  var data2 : Array<Point>;
  var data3 : Array<Point>;

  public var interval : Int;

  var avgFPS : Array<Float>;

  var frameCounter : Int;
  var timer : Timer;
  var last : Float;
  var delta : Float;

  var maxFPS : Float;
  var minFPS : Float;



	/**
	 *
	 */
  public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
  {
    super (parent, name, x, y);
  }//end new


    /**
     *
     *
     *
     *
     *
     */
    public override function init(?initObj:Dynamic)
    {

        super.init({name:"Stats", x:x, y:y, width:width, height:height, sizeable: false, color: 0x2A7ACD});

        frameCounter = 0;
        delta = 0;
        maxFPS = Math.NEGATIVE_INFINITY;
        minFPS = Math.POSITIVE_INFINITY;
        avgFPS = [.0];
        interval = 500;
        gridSpacing = 20;

        data =
        data2 =
        data3 = [new Point(240, 140), new Point(240, 140)];

        timer = new haxe.Timer(interval);
        timer.run = update;



        box = new Rectangle (0, 0, 400, 160);

        //
        var container = new Container (this, "container", 10, 20);
        //~ container.init({color: 0x222222, alpha: .5});
        container.init({color: 0x2A7ACD});


        list = new UiList(container, "List");
        list.data=["FPS:", "minFPS:", "maxFPS:", "avgFPS:", "Mem:", "Uptime:"];
        list.init({color: 0xE5E5E5, width: 140});


        graph = new Sprite();
        grid = new Sprite();


        grid.graphics.lineStyle(0,0,0);
        grid.graphics.beginFill( 0xE5E5E5 );
        grid.graphics.drawRect(0,0,240+gridSpacing,140);
        grid.graphics.endFill();

        for(i in 0...Std.int(240/(gridSpacing-2)))
        {
        grid.graphics.lineStyle(1,0xCCCCCC);
        grid.graphics.moveTo(gridSpacing*i,0);
        grid.graphics.lineTo(gridSpacing*i,140);
        }

        for(i in 0...Std.int(140/gridSpacing))
        {
        grid.graphics.lineStyle(1,0xCCCCCC);
        grid.graphics.moveTo(0,gridSpacing*i);
        grid.graphics.lineTo(250,gridSpacing*i);
        }




        ploter = new Sprite();
        graph.addChild(grid);
        graph.addChild(ploter);

		//
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, BitmapFilterQuality.HIGH, true, false, false );
		graph.filters = [shadow];
        graph.x = 150;
        graph.scrollRect = new Rectangle(0,0,240,140);

        container.addChild(graph);


        var label = new Label(container, "Label", 160, 14);
        label.text = "Update Interval: ";
        label.init();

        var stepper = new Stepper(container, "Stepper", 250, 10);
        stepper.init({value: interval, step: 5, min: 20, max: 5000, color: 0x2A7ACD});
        var self = this;
		stepper.addEventListener(Event.CHANGE,
            function(e:Event) {
                self.frameCounter = 0;
                self.delta = 0;
                self.maxFPS = Math.NEGATIVE_INFINITY;
                self.minFPS = Math.POSITIVE_INFINITY;
                self.avgFPS = [.0];
                self.interval = e.target.value;

                self.list.data=["FPS:", "minFPS:", "maxFPS:", "avgFPS:", "Mem:", "Uptime:"];
                self.list.redraw();
                self.ploter.graphics.clear();
                self.ploter.x = 0;

                self.data = [new Point(240, 140), new Point(240, 140)];
                self.data2 = [new Point(240, 140), new Point(240, 140)];
                self.data3 = [new Point(240, 140), new Point(240, 140)];
                self.timer.stop();
                self.timer = new haxe.Timer(self.interval);
                self.timer.run = self.update;

                });


        if(isSizeable())
        {
          bl.y = frame.height - 32;
          br.x = frame.width - 32;
          br.y = frame.height - 32;
        }

          this.addEventListener (Event.ENTER_FRAME, onEnterFrame);


        //~ redraw(null);
        dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));


    }

    /**
     *
     *
     */
    public function update() {

        //~ stats.text = "FPS: " + Std.string(frameCounter*100*(haxe.Timer.stamp() - delta)).substr(0,5);
        //~ var fps = frameCounter/(haxe.Timer.stamp() - delta);
        var delta = haxe.Timer.stamp() - last;
        if(delta<=0) return;
        var fps = frameCounter/delta ;


        if(fps > maxFPS) maxFPS = fps;
        if(fps < minFPS) minFPS = fps;

        avgFPS.push(fps);
        var avg : Float = 0;
        for(i in avgFPS)
            avg += i;
        avg /= avgFPS.length;
        if(avgFPS.length > 10 ) avgFPS.shift();


        list.data[0] = "FPS: \t\t\t" + Std.string(fps).substr(0,5);
        list.data[1] = "minFPS: \t\t" + Std.string(minFPS).substr(0,5);
        list.data[2] = "maxFPS: \t\t" + Std.string(maxFPS).substr(0,5);
        list.data[3] = "avgFPS: \t\t" + Std.string(avg).substr(0,5);
        list.data[4] = "Mem(MB): \t\t" + Std.string(flash.system.System.totalMemory/Math.pow(10,6)).substr(0,5);
        list.data[5] = "Uptime: \t\t\t" + Std.string(haxe.Timer.stamp()).substr(0,5);


        list.redraw();


        var item = cast list.getChildAt(1);
		item.graphics.beginFill (0xFF9300);
		item.graphics.drawRect (0, 0, Std.int(fps), 20);
		item.graphics.endFill ();

        item = cast list.getChildAt(4);
		item.graphics.beginFill (0x9ADF00);
		item.graphics.drawRect (0, 0, Std.int(avg), 20);
		item.graphics.endFill ();

        item = cast list.getChildAt(5);
		item.graphics.beginFill (0xFF00A8);
		item.graphics.drawRect (0, 0, Std.int(flash.system.System.totalMemory/Math.pow(10,6)), 20);
		item.graphics.endFill ();


        //~ ploter.graphics.clear();

        data.push( new Point( 240-ploter.x, 140 - fps ) );
        data2.push( new Point( 240-ploter.x, 140 - flash.system.System.totalMemory/Math.pow(10,6) ) );
        data3.push( new Point( 240-ploter.x, 140 - avg ) );

        ploter.graphics.lineStyle(2,0xFF9300);
        ploter.graphics.moveTo( data[data.length-2].x+gridSpacing, data[data.length-2].y );
        ploter.graphics.lineTo( data[data.length-1].x+gridSpacing, data[data.length-1].y );

        ploter.graphics.lineStyle(2,0xFF00A8);
        ploter.graphics.moveTo( data2[data2.length-2].x+gridSpacing, data2[data2.length-2].y );
        ploter.graphics.lineTo( data2[data2.length-1].x+gridSpacing, data2[data2.length-1].y );

        ploter.graphics.lineStyle(2,0x9ADF00);
        ploter.graphics.moveTo( data3[data3.length-2].x+gridSpacing, data3[data3.length-2].y );
        ploter.graphics.lineTo( data3[data3.length-1].x+gridSpacing, data3[data3.length-1].y );



        if(data.length > 2) data.shift();
        if(data2.length > 2) data.shift();

        //~ ploter.x -= gridSpacing*delta;
        var p = new Tween(ploter.x, ploter.x-gridSpacing, interval, ploter, "x", Linear.easeNone );
        p.start();


        //~ grid.x -= gridSpacing*delta;
        var g = new Tween(0, -gridSpacing, interval, grid, "x", Linear.easeNone );
        g.start();

        //~ if(grid.x<-gridSpacing) grid.x=0;

        frameCounter = 0;
        last = haxe.Timer.stamp();



        //~ stats.setTextFormat( StyleManager.getTextFormat(8, 0xffffff) );

    }


  public function onEnterFrame(e:Event) : Void
  {

    frameCounter++;
  }











}
