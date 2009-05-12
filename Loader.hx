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

import flash.events.Event;
import flash.events.ProgressEvent;

import flash.display.Sprite;

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.net.URLLoader;
import flash.net.URLRequest;

import flash.Error;

import haxegui.StyleManager;


class Loader extends Sprite
{

    static var xmlLoader:URLLoader;
    static var loader: flash.display.Loader;


	public static function main()
	{

		var stage = flash.Lib.current.stage;
/*
        stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
        stage.align = flash.display.StageAlign.TOP_LEFT;
        stage.stageFocusRect = true;
*/


        // Desktop
        var desktop = new Sprite();
        desktop.name = "desktop";
        desktop.mouseEnabled = false;

          var colors = [ DefaultStyle.BACKGROUND, DefaultStyle.BACKGROUND - 0x4d4d4d ];
          var alphas = [ 100, 100 ];
          var ratios = [ 0, 0xFF ];
          var matrix = new flash.geom.Matrix();

          matrix.createGradientBox(stage.stageWidth, stage.stageHeight, Math.PI/2, 0, 0);
          desktop.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );

        desktop.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight);
        desktop.graphics.endFill();
        flash.Lib.current.addChild(desktop);




            xmlLoader = new URLLoader();
            xmlLoader.addEventListener(Event.COMPLETE, onComplete);
            xmlLoader.load(new URLRequest("loader.xml"));


	}


	public static function onComplete(e:Event)
	{
//	trace(Std.string(e));
			try
			{
                var xml:Xml = Xml.parse(e.target.data);
//				trace(xml);

//loader.dataFormat = flash.net.URLLoaderDataFormat.BINARY;
//loader.addEventListener(Event.COMPLETE, loadComplete);

loader = new flash.display.Loader();

			var url = xml.firstElement().firstElement().get("src");
			loader.load( new URLRequest(url) );

loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, onComplete);
loader.contentLoaderInfo.addEventListener(flash.events.ProgressEvent.PROGRESS, loadProgress);
/*
				for(i in xml.firstElement().elements())
				{
				var url = i.get("src");
				loader.load( new URLRequest(url) );
				}
*/

            } catch (e:Error)
            {
                //Could not convert the data, probably because
                //because is not formated correctly

                trace("Could not parse the XML");
                trace(e.message);
            }


	}

public static function loadProgress(event:ProgressEvent):Void {
	var percentLoaded:Float = event.bytesLoaded/event.bytesTotal;
	percentLoaded = Math.round(percentLoaded * 100);
	trace("Loading: "+percentLoaded+"%");
}

	public static function loadComplete(e:Event):Void
	{
		trace("Complete");

	trace(loader.content);
	flash.Lib.current.addChild(loader.content);

	}

}
