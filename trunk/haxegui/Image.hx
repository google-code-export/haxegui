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

/**
*
* Image Class
*
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class Image extends Component
{
    public var src : String;
    public var loader : Loader;

    public var bitmap : Bitmap;

    public var aspect(default, null) : Float;
	
    override public function init(opts:Dynamic=null) : Void	{
	
	super.init(opts);
	
	src = Opts.optString(opts, "src", src);
	
	if(loader==null)
	    loader = new Loader();
	
	var urlReq:URLRequest = new URLRequest(this.src);
	
	loader.load(urlReq);
	loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);

    }
    
    function onComplete(e:Event) {
	bitmap = e.currentTarget.content ;
	aspect = bitmap.width / bitmap.height;
	addChild(bitmap);
	dispatchEvent(e);
    }

    static function __init__() {
	haxegui.Haxegui.register(Image);
    }
    

}

/**
*
* Icon Class
*
* Defines stock icons, used like this:
* 
* 	var icon = new Icon();
* 	icon.init({src: STOCK_NEW});
* 
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class Icon extends Image
{
    public static var iconDirectory : String = "/assets/icons/";
    
    public static var STOCK_NEW : String = iconDirectory+"document-new.png";
    public static var STOCK_OPEN : String = iconDirectory+"document-open.png";
    public static var STOCK_SAVE : String = iconDirectory+"document-save.png";

    public static var STOCK_COPY : String = iconDirectory+"edit-copy.png";
    public static var STOCK_CUT : String = iconDirectory+"edit-cut.png";
    public static var STOCK_PASTE : String = iconDirectory+"edit-paste.png";
    public static var STOCK_CLEAR : String = iconDirectory+"edit-clear.png";
    public static var STOCK_DELETE : String = iconDirectory+"edit-delete.png";

    public static var STOCK_FIND : String = iconDirectory+"edit-find.png";
    
    public static var DIALOG_ERROR : String = iconDirectory+"dialog-error.png";
    public static var DIALOG_WARNING : String = iconDirectory+"dialog-warning.png";
    
    static function __init__() {
	haxegui.Haxegui.register(Image);
    }  
}
