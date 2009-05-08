// 
// The MIT License
// 
// Copyright (c) 2004 - 2006 Paul D Turner & The CEGUI Development Team
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



import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;


import controls.Component;

import flash.display.Loader;
import flash.net.URLRequest;
import flash.events.Event;
import flash.display.Bitmap;


class Image extends Component
{

	public function new(?parent : DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super(parent, name, x, y);
	}

	public function init(initObj:Dynamic) : Void
	{
		if(Reflect.isObject(initObj))
		{
			//~ trace(Std.string(initObj));
		for (f in Reflect.fields (initObj))
		  if (Reflect.hasField (this, f))
		    if (f != "width" && f != "height")
		      Reflect.setField (this, f, Reflect.field (initObj, f));

		    var pictLdr:Loader = new Loader();
		    //var pictURLReq:URLRequest = new URLRequest("./assets/banners/banner$
		    var pictURLReq:URLRequest = new URLRequest(initObj.src);
		    pictLdr.load(pictURLReq);
		    pictLdr.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
		}

	}

	function onComplete(e:Event)
	{
	    var bmp:Bitmap = e.currentTarget.content ;
    	addChild(bmp);
	}

}

