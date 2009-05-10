//

package haxegui;

import Type;

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
import flash.events.FocusEvent;

import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;

import flash.ui.Mouse;
import flash.ui.Keyboard;

import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.BevelFilter;


import haxegui.controls.Component;

import haxegui.WindowManager;
import haxegui.MouseManager;
import haxegui.CursorManager;
import haxegui.StyleManager;


class Toolbar extends Component, implements Dynamic
{

	public var color : UInt;
	public var handle : Sprite;
	
  public function new (? parent : DisplayObjectContainer, ? name : String,
		       ? x : Float, ? y : Float, ? width : Float, ? height : Float)
    {
	super (parent, name, x, y);
    }	

    /**
    * 
    * Initialize a new window
    * 
    * @param initObj Dynamic object containing attributes
    * 
    * 
    */
  public function init (? initObj : Dynamic)
  {
    
	box = new Rectangle(0,0,502,40);
	color = StyleManager.BACKGROUND;
	
	if (Reflect.isObject (initObj))
      {
	for (f in Reflect.fields (initObj))
	  if (Reflect.hasField (this, f))
	    if (f != "width" && f != "height")
	      Reflect.setField (this, f, Reflect.field (initObj, f));

	box.width = (Math.isNaN (initObj.width)) ? box.width : initObj.width;
	box.height = (Math.isNaN (initObj.height)) ? box.height : initObj.height;
	
	
      }
  
  
	handle = new Sprite();
	handle.name = "handle";
	handle.graphics.lineStyle(2, color - 0x202020);
	handle.graphics.beginFill(color, .5);
	handle.graphics.drawRoundRect(4, 8, 8, box.height - 16, 4, 4);
	handle.graphics.endFill();
	addChild(handle);
	
    // inner-drop-shadow filter
    var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.5,4, 4, 0.5, BitmapFilterQuality.LOW,true,false,false);
    this.filters = [shadow];

  
    parent.addEventListener (ResizeEvent.RESIZE, onResize);

  
	redraw();
  }
  

    /**
     * 
     * 
     * 
     */
    public function onResize(e:Dynamic)
    {

	if(Std.is(e, ResizeEvent))
	    {
	    var b = untyped parent.box.clone();
	    //~ box = untyped parent.box.clone();
	    //~ if(!Math.isNaN(e.oldWidth))
		//~ box.width = e.oldWidth;


	    box.width = b.width - x;
	    //~ box.height -= y;
	    
	    //~ var _m = new Shape();
	    //~ _m.graphics.beginFill(0xFF00FF);
	    //~ _m.graphics.drawRect(0,0,box.width,box.height);
	    //~ _m.graphics.endFill();
	    //~ mask = _m;
	    
	    scrollRect = box.clone();
	    
	    }
	
	redraw();
	
	if(Std.is(e, ResizeEvent))
	    e.updateAfterEvent();
    }
    
	
  /**
   * 
   * 
   */
  public function redraw (damage:Bool = true)
  {
    
    //~ var width = parent.getChildByName ("frame").width;
    //~ var width = untyped parent.box.width;

    this.graphics.clear ();
    //~ this.graphics.lineStyle (2, color - 0x1A1A1A);
    
		  //~ var colors = [ color - 0x141414, color | 0x323232 ];
		  var colors = [ color - 0x141414, color | 0x323232, color - 0x141414 ];
		  var alphas = [ 100, 100, 100 ];
		  var ratios = [ 0, 0x80, 0xFF ];
		  var matrix = new flash.geom.Matrix();
		  matrix.createGradientBox(box.width, box.height, Math.PI/2, 0, 0);
		  this.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );


    //~ this.graphics.beginFill (color);
    //~ this.graphics.drawRect (0, 0, width, 24);
    this.graphics.drawRect (0, 0, box.width, box.height);
    this.graphics.endFill ();



  }

  	
}
