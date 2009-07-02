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

import haxegui.Component;

import flash.display.Loader;
import flash.net.URLRequest;
import flash.events.Event;
import flash.display.Bitmap;
import flash.display.BitmapData;

class Image extends Component
{
	public var src : String;
	public var bitmap : Bitmap;
	public var loader : Loader;

	override public function init(opts:Dynamic=null) : Void	{
	    
	    super.init(opts);
	    
	    src = Opts.optString(opts, "src", src);
	    
	    if(loader==null)
		loader = new Loader();
	    
	    var urlReq:URLRequest = new URLRequest(this.src);
	    
	    loader.load(urlReq);
	    loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);

	}
	

	function onComplete(e:Event)
	{
	    bitmap = e.currentTarget.content ;
	    addChild(bitmap);
	    dispatchEvent(e);
	}

	static function __init__() {
	    haxegui.Haxegui.register(Image);
	}
	

}

