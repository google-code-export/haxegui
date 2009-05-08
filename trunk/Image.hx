//
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

