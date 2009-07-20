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

import haxegui.controls.Component;

import flash.display.Loader;
import flash.net.URLRequest;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.display.Bitmap;
import flash.display.BitmapData;

/**
*
* Component wrapper for bitmaps.
*
* used in xml like this:
* <pre class="code xml">
* <haxegui:Image src="http://www..."/>
* </pre>
* or in haxe:
* <pre class="code haxe">
* var img = new Image();
* image.init({src: "http://www..."});
* </pre>
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class Image extends Component
{
    /** url **/
    public var src : String;
    
    /** loader for the bitmap **/
    public var loader : Loader;

	/** the bitmap itself **/
    public var bitmap : Bitmap;

	/** aspect ratio **/
    public var aspect(default, null) : Float;
	
	override public function init(opts:Dynamic=null) : Void	{
	
		super.init(opts);
	
		src = Opts.optString(opts, "src", src);
	
		if(loader==null)
			loader = new Loader();
	
		var urlReq = new URLRequest(this.src);
	
		try {
			loader.load(urlReq);
		}
		catch(e:Dynamic) {
			trace(e);
		}

		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
    }
    
    function onComplete(e:Event) {
		bitmap = e.currentTarget.content ;
		aspect = bitmap.width / bitmap.height;
		addChild(bitmap);
		dispatchEvent(e);
    }

    function onError(e:IOErrorEvent) {
		trace(e);
    }
    
    static function __init__() {
		haxegui	.Haxegui.register(Image);
    }
    

}

/**
* Image helper class, defines stock icons.
*
* used in xml like this:
* <pre class="code xml">
* <haxegui:Icon src="STOCK_CLEAR"/>
* </pre>
* or in haxe:
* <pre class="code haxe">
* var icon = new Icon();
* icon.init({src: Icon.STOCK_NEW});
* </pre>
* 
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class Icon extends Image
{
	/** baseURL relative icon path **/
    public static var iconDirectory : String = "assets/icons/";
    
    //////////////////////////////////////////////////////////////////
    // 						Stock icons								//
    //////////////////////////////////////////////////////////////////
    public static var STOCK_NEW : String = "document-new.png";
    public static var STOCK_OPEN : String = "document-open.png";
    public static var STOCK_SAVE : String = "document-save.png";

    public static var STOCK_COPY : String = "edit-copy.png";
    public static var STOCK_CUT : String = "edit-cut.png";
    public static var STOCK_PASTE : String = "edit-paste.png";
    public static var STOCK_CLEAR : String = "edit-clear.png";
    public static var STOCK_DELETE : String = "edit-delete.png";

    public static var STOCK_FIND : String = "edit-find.png";
    
    public static var DIALOG_ERROR : String = "dialog-error.png";
    public static var DIALOG_WARNING : String = "dialog-warning.png";

    override public function init(opts:Dynamic=null) : Void {
		src = Opts.optString(opts, "src", src);
		src = Haxegui.baseURL + iconDirectory + src;
		super.init({src: src});
    }
    
    static function __init__() {
		haxegui.Haxegui.register(Image);
    }  
}
