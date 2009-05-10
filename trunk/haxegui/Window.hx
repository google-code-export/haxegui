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



package haxegui;


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

import haxegui.WindowManager;
import haxegui.MouseManager;
import haxegui.CursorManager;
import haxegui.StyleManager;

import haxegui.controls.Component;




enum WindowType
{
  NORMAL;
  MODAL;
  ALWAYS_ON_TOP;
}

/**
 * 
 * Titlebar class
 * 
 * @author <gershon@goosemoose.com>
 * @version 0.1
 */
class Titlebar extends Sprite, implements Dynamic
{

  public var title : TextField;
  public var closeButton : Component;
  public var minimizeButton : Component;

  public function new (? w : Float)
  {
    super ();

    this.name = "titlebar";

    //
    this.graphics.beginFill (0x1A1A1A, 0.5);
    this.graphics.drawRoundRectComplex (0, 0, w, 32, 4, 4, 0, 0);
    this.graphics.drawRect (10, 20, w - 20, 12);
    this.graphics.endFill ();


    //
    //~ closeButton = new Component(this, "closeButton");
    closeButton = new Component (this, "closeButton");
    closeButton.graphics.lineStyle (2, StyleManager.BACKGROUND - 0x141414);
    closeButton.graphics.beginFill (StyleManager.BACKGROUND, 0.5);
    closeButton.graphics.drawRoundRect (0, 0, 12, 12, 4, 4);
    closeButton.graphics.endFill ();
    closeButton.move (4, 4);
    closeButton.addEventListener (MouseEvent.ROLL_OVER, onRollOver);
    closeButton.addEventListener (MouseEvent.ROLL_OUT, onRollOut);
    closeButton.addEventListener (MouseEvent.MOUSE_UP, onMouseUp);

    //
    minimizeButton = new Component (this, "minimizeButton");
    minimizeButton.graphics.lineStyle (2, StyleManager.BACKGROUND - 0x141414);
    minimizeButton.graphics.beginFill (StyleManager.BACKGROUND, 0.5);
    minimizeButton.graphics.drawRoundRect (0, 0, 12, 12, 4, 4);
    minimizeButton.graphics.endFill ();
    minimizeButton.move (20, 4);
    minimizeButton.addEventListener (MouseEvent.ROLL_OVER, onRollOver);
    minimizeButton.addEventListener (MouseEvent.ROLL_OUT, onRollOut);
    minimizeButton.addEventListener (MouseEvent.MOUSE_UP, onMouseUp);

    //mc.x = box.width - 32;
    title = new TextField ();
    title.name = "title";
    title.text = this.name;
    title.border = false;
    //~ title.textColor = 0x000000;
    title.x = 40;
    title.y = 1;
    //~ title.width = parent.width - 85;
    title.autoSize = flash.text.TextFieldAutoSize.LEFT;
    title.height = 18;
    title.selectable = false;
    title.mouseEnabled = false;
    title.tabEnabled = false;
    title.multiline = false;
    title.embedFonts = true;

    //~ title.antiAliasType = flash.text.AntiAliasType.NORMAL;
    //~ title.sharpness = 100;
    this.quality = flash.display.StageQuality.LOW;

    title.setTextFormat (StyleManager.getTextFormat());

    this.addChild (title);


  }
  

	

    /**
     * 
     * 
     */
  public function redraw (? color : Int, ? w : Float):Void
  {
    title.x = Math.floor((w - title.width)/2);
    //~ title.width = Math.floor(w - 85);
    //~ title.y = 1;

    var parser = new hscript.Parser();

    var interp = new hscript.Interp();

    interp.variables.set("Math",Math);
    interp.variables.set("this", this);
    interp.variables.set("flash.geom.Matrix", flash.geom.Matrix); 
    interp.variables.set("grad", flash.display.GradientType.LINEAR); 
    interp.variables.set("w", w); 
    interp.variables.set("color", color); 


    var script = "
	this.graphics.clear ();
	//~ var colors = [ color | 0x323232, color - 0x4D4D4D ];
	var colors = [ color | 0x323232, color - 0x141414 ];
	var alphas = [ 100, 0 ];
	var ratios = [ 0, 0xFF ];
	var matrix = new flash.geom.Matrix();
	matrix.createGradientBox(w, 32, Math.PI/2, 0, 0);
	this.graphics.beginGradientFill( grad, colors, alphas, ratios, matrix );    
	this.graphics.drawRoundRectComplex (0, 0, w, 32, 4, 4, 0, 0);
	this.graphics.drawRect (10, 20, w - 20, 12);
	this.graphics.endFill ();
    ";

    var program = parser.parseString(script);

    interp.execute(program) ; 




    //~ this.graphics.clear ();
    //~ 
    		  //~ var colors = [ color | 0x323232, color - 0x4D4D4D ];
		  //~ var alphas = [ 100, 0 ];
		  //~ var ratios = [ 0, 0xFF ];
		  //~ var matrix = new flash.geom.Matrix();
		  //~ matrix.createGradientBox(w, 32, Math.PI/2, 0, 0);
		  //~ this.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );
//~ 
//~ 
    //~ this.graphics.drawRoundRectComplex (0, 0, w, 32, 4, 4, 0, 0);
    //~ this.graphics.drawRect (10, 20, w - 20, 12);
    //~ this.graphics.endFill ();

    closeButton.graphics.lineStyle (2, color - 0x141414);
    //closeButton.graphics.beginFill (color, 0.5);
	var grad = flash.display.GradientType.LINEAR;
	var colors = [ color | 0x323232, color - 0x141414 ];
	var alphas = [ 100, 0 ];
	var ratios = [ 0, 0xFF ];
	var matrix = new flash.geom.Matrix();
	matrix.createGradientBox(12, 12, Math.PI/2, 0, 0);
	closeButton.graphics.beginGradientFill( grad, colors, alphas, ratios, matrix );    
    closeButton.graphics.drawRoundRect (0, 0, 12, 12, 4, 4);
    closeButton.graphics.endFill ();

    minimizeButton.graphics.lineStyle (2, color - 0x141414);
    //minimizeButton.graphics.beginFill (color, 0.5);
	var grad = flash.display.GradientType.LINEAR;
	var colors = [ color | 0x323232, color - 0x141414 ];
	var alphas = [ 100, 0 ];
	var ratios = [ 0, 0xFF ];
	var matrix = new flash.geom.Matrix();
	matrix.createGradientBox(12, 12, Math.PI/2, 0, 0);

	minimizeButton.graphics.beginGradientFill( grad, colors, alphas, ratios, matrix );    
    minimizeButton.graphics.drawRoundRect (0, 0, 12, 12, 4, 4);
    minimizeButton.graphics.endFill ();

    title.setTextFormat (StyleManager.getTextFormat(8,StyleManager.LABEL_TEXT, flash.text.TextFormatAlign.CENTER));

  }				

    public function onRollOver (e:MouseEvent)
    {
		CursorManager.getInstance().setCursor(Cursor.HAND);
    }

    public function onRollOut (e:MouseEvent)
    {
		//~CursorManager.getInstance().setCursor(Cursor.HAND);
    }

    public function onMouseUp (e:MouseEvent)
    {
	
    }				


}

/*
 * Window Class
 * 
 * A movable, resizeable window.
 * 
 * 
 * 
 * 
 */
class Window extends haxegui.controls.Component, implements Dynamic
{
  public var titlebar:Titlebar;

  public var frame:Sprite;
  public var br:Sprite;
  public var bl:Sprite;


  public var color:UInt;
  public var type:WindowType;

  private var sizeable:Bool;
  //~ private var _mask:Sprite;

  public function new (? parent : DisplayObjectContainer, ? name : String,
		       ? x : Float, ? y : Float, ? width : Float,
		       ? height : Float, ? sizeable : Bool)
    {

	if (parent == null || !Std.is (parent, DisplayObjectContainer))
	  parent = flash.Lib.current;

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
    
    type = WindowType.NORMAL;
    sizeable = true ;
    box = new Rectangle (0, 0, 512, 512);
    color = StyleManager.BACKGROUND;
    text = "Window";

    if (Reflect.isObject (initObj))
      {
	for (f in Reflect.fields (initObj))
	  if (Reflect.hasField (this, f))
	    if (f != "width" && f != "height")
	      Reflect.setField (this, f, Reflect.field (initObj, f));

	//~ name = (initObj.name == null) ? name : initObj.name;
	//~ move(initObj.x, initObj.y);
	box.width = (Math.isNaN (initObj.width)) ? box.width : initObj.width;
	box.height = (Math.isNaN (initObj.height)) ? box.height : initObj.height;
	//~ color = (initObj.color==null) ? color : initObj.color;
	//~ sizeable = ( initObj.sizeable == null ) ? true : initObj.sizeable;

	//~ trace(Std.string(initObj));
      }



    this.buttonMode = false;
    this.mouseEnabled = false;
    this.tabEnabled = false;


    //
    draw ();

    // add a titlebar
    titlebar = cast this.addChild (new Titlebar ());
    titlebar.title.text = this.name;
    titlebar.redraw ();

    titlebar.addEventListener (MouseEvent.ROLL_OVER, onRollOver);
    titlebar.addEventListener (MouseEvent.ROLL_OUT, onRollOut);
    titlebar.addEventListener (DragEvent.DRAG_START, DragManager.getInstance ().onStartDrag);
    titlebar.addEventListener (DragEvent.DRAG_COMPLETE, DragManager.getInstance ().onStopDrag);

    // add mouse event listeners
    //~ this.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown);
    this.addEventListener (MouseEvent.MOUSE_DOWN, onRaise);
    this.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown, false);
    this.addEventListener (MouseEvent.MOUSE_UP, onMouseUp);


    // register with focus manager
    FocusManager.getInstance ().addEventListener (FocusEvent.MOUSE_FOCUS_CHANGE, redraw);

    // register resize event
    //~ this.addEventListener (ResizeEvent.RESIZE, redraw);
    this.addEventListener (ResizeEvent.RESIZE, onResize);


    // add to stage
    //~ flash.Lib.current.addChild (this);
    parent.addChild (this);


    this.dispatchEvent (new ResizeEvent (ResizeEvent.RESIZE));


    redraw (null);

    //~ return this;
  }


  public function isSizeable ():Bool
  {
    return sizeable;
  }



  public function onMove (e:MoveEvent)
  {
    //trace(e);
  }


    /**
     * 
     * 
     * 
     * 
     */
    public function draw ()
    {

    // frame
    frame = new Sprite ();
    frame.name = "frame";
    frame.buttonMode = false;

    var shadow:DropShadowFilter =
      new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.9, 8, 8, 0.85,
			    BitmapFilterQuality.HIGH, false, false, false);

    //~ var bevel:BevelFilter = new BevelFilter( 4, 45 ,color | 0x323232 ,1 ,0x000000, .5, 4, 4, 2, BitmapFilterQuality.HIGH , flash.filters.BitmapFilterType.INNER, false );
    //~ frame.filters = [shadow, bevel];
    frame.filters = [shadow];

    this.addChild (frame);

	// corners
	if (isSizeable ())
	{
	    br = new Sprite ();
	    br.name = "br";
	    br.graphics.beginFill (StyleManager.BACKGROUND + 0x202020, 0.5);
	    br.graphics.drawRoundRectComplex (0, 0, 32, 32, 0, 0, 0, 4);
	    br.graphics.drawRect (0, 0, 22, 22);
	    br.graphics.endFill ();
	    br.x = box.width - 22;
	    br.y = box.height - 22;

	    br.buttonMode = true;
	    br.focusRect = false;
	    br.tabEnabled = false;

	    br.addEventListener (MouseEvent.ROLL_OVER, onRollOver);
	    br.addEventListener (MouseEvent.ROLL_OUT, onRollOut);
	    br.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown);
	    br.addEventListener (DragEvent.DRAG_START, DragManager.getInstance ().onStartDrag);
	    br.addEventListener (DragEvent.DRAG_COMPLETE, DragManager.getInstance ().onStopDrag);

	    this.addChild (br);

	    //
	    bl = new Sprite ();
	    bl.name = "bl";
	    bl.graphics.beginFill (0x1A1A1A, 0.5);
	    bl.graphics.drawRoundRectComplex (0, 0, 32, 32, 0, 0, 4, 0);
	    bl.graphics.drawRect (10, 0, 22, 22);
	    bl.graphics.endFill ();
	    bl.y = box.height - 22;

	    bl.buttonMode = true;
	    bl.focusRect = false;
	    bl.tabEnabled = false;

	    bl.addEventListener (MouseEvent.ROLL_OVER, onRollOver);
	    bl.addEventListener (MouseEvent.ROLL_OUT, onRollOut);
	    bl.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown);
	    bl.addEventListener (DragEvent.DRAG_START,
				 DragManager.getInstance ().onStartDrag);
	    bl.addEventListener (DragEvent.DRAG_COMPLETE,
				 DragManager.getInstance ().onStopDrag);

	    this.addChild (bl);

	}

    }




    /**
     * 
     * 
     */
    public function onRollOut (e:MouseEvent):Void
    {
	if (this.hasFocus ())
	  redraw ( {damaged: true, fill: 0x4D4D4D, color:0xBFBFBF} );
	else
	  redraw (null);
	//
	//~CursorManager.getInstance ().setCursor (Cursor.ARROW);
    }



    /**
     * 
     * 
     */
    public function onRollOver (e:MouseEvent)
    {
    //~ redraw (true, 0x595959, 0x737373);
	//
	CursorManager.getInstance ().setCursor (Cursor.HAND);
    }


    /**
     * 
     * 
     * 
     */
    public function onMouseMove (e:MouseEvent)
    {
    //
    CursorManager.getInstance ().inject (e.stageX, e.stageY);
    e.stopImmediatePropagation ();
    //
    var damaged:Bool = true;
    if (e.buttonDown)
      {

	var resizeEvent = new ResizeEvent (ResizeEvent.RESIZE);
	resizeEvent.oldWidth = box.width;
	resizeEvent.oldHeight = box.height;

	switch (e.target)
	  {
	  case titlebar:
	    this.move (e.target.x, e.target.y);
	    e.target.x = e.target.y = 0;
	    damaged = false;
	  case br:
	    bl.y = e.target.y;
	    box.width = e.target.x + 22;
	    box.height = e.target.y + 22;
	  case bl:
	    br.y = e.target.y;
	    box.width -= e.target.x;
	    box.height = e.target.y + 22;
	    move (e.target.x, 0);
	    e.target.x = 0;
	    br.x = box.width - 22;
	  //~ case "frame":
	    //~ move (e.target.x, e.target.y);
	    //~ e.target.x = e.target.y = 0;
	    //~ damaged = false;
	  }


	if (damaged)
	  {
	    this.dispatchEvent (resizeEvent);
	    //~ redraw(null);
	  }

	e.updateAfterEvent ();
      }				//buttonDown
  }				// onMouseMove


    /**
     * Resize listener to position corners and redraw frame
     * 
     * 
     */
  public function onResize (e:ResizeEvent)
  {
    //~ trace(e);
    if (sizeable)
      {
	bl.y = box.height - 22;
	br.y = box.height - 22;
	br.x = box.width - 22;
      }
    redraw (null);
    //~ e.updateAfterEvent();
  }



  /**
   *
   */
  public function onMouseDown (e:MouseEvent):Void
  {
    if (!Std.is (e.target, Sprite))
      return;

    //
    FocusManager.getInstance ().setFocus (this);

    // raise window
    parent.setChildIndex (this, parent.numChildren - 1);

	
    if (e.target == titlebar || e.target.name == "br"	|| e.target.name == "bl")
      {


	e.target.dispatchEvent (new DragEvent (DragEvent.DRAG_START));
	e.target.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
	//~ flash.Lib.current.stage.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
	//~ this.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
	//~ flash.Lib.current.addEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);
	
	
	// raise target
	e.target.parent.setChildIndex (e.target, e.target.parent.numChildren - 1);
      }

    switch (e.target)
      {
      case titlebar:
	CursorManager.getInstance ().setCursor (Cursor.SIZE_ALL);
      case bl:
	CursorManager.getInstance ().setCursor (Cursor.NE);
      case br:
	CursorManager.getInstance ().setCursor (Cursor.NW);
      }


  }				//onMouseDown


  /**
   * 
   * 
   * 
   */
  public function onMouseUp (e:MouseEvent):Void
  {
    //~ if(!Std.is(e.target, Sprite)) return;

    e.target.dispatchEvent (new DragEvent (DragEvent.DRAG_COMPLETE));
    e.target.removeEventListener (MouseEvent.MOUSE_MOVE, onMouseMove);


    //~ if (this.hasFocus())
    //~ redraw ({damaged:true, fill:0x4D4D4D, color:0xBFBFBF});
    //~ else
    //~ redraw ({target: e.target});

    this.dispatchEvent (new ResizeEvent (ResizeEvent.RESIZE));

    //~ redraw (false);
    e.updateAfterEvent ();
  }


    /**
     * Redraw just frame
     * 
     */
  public function redrawFrame (fill:UInt, color:UInt)
  {
    frame.graphics.clear ();
    frame.graphics.beginFill (fill, 0.5);
    frame.graphics.lineStyle (2, color);
    frame.graphics.drawRoundRect (0, 0, box.width + 10, box.height + 10, 8, 8);
    frame.graphics.drawRect (10, 20, box.width - 10, box.height - 20);
    //~ frame.graphics.endFill ();
    //~ frame.graphics.beginFill (0x8C8C8C, 0.5);
    //~ frame.graphics.drawRect (10, 20, box.width - 20, box.height - 30);
    frame.graphics.endFill ();
  }


/**
 * Redraw entire window
 *
 */
//~ public function redraw (?damaged : Bool = true, ?color : UInt, ?fill : Int) : Void
  public function redraw (e:Dynamic):Void
  {

    var color:UInt = this.color - 0x141414;
    var fill:UInt = this.color;
    var damaged:Bool = true;

    if (e != null && Reflect.isObject (e))
      if (!Std.is (e, ResizeEvent))
      if (!Std.is (e, FocusEvent))
	{
	  color = (e.color == null) ? color : e.color;
	  fill = (e.fill == null) ? fill : e.fill;
	  damaged = (e.damaged == null) ? damaged : e.damaged;
	}


    if (!damaged)
      return;



    if (this.hasFocus ())
      {
	color = this.color | 0x141414;
	fill = this.color | 0x191919;
      }

    // frame
    redrawFrame (fill, color);

    // titlebar
    titlebar.redraw (fill, box.width+10);

    // corners
    if (isSizeable ())
      {
	//
	bl.graphics.clear ();
	bl.graphics.beginFill (fill, 0.5);
	bl.graphics.drawRoundRectComplex (0, 0, 32, 32, 0, 0, 4, 0);
	bl.graphics.drawRect (10, 0, 22, 22);

	//
	br.graphics.clear ();
	br.graphics.beginFill (fill, 0.5);
	br.graphics.drawRoundRectComplex (0, 0, 32, 32, 0, 0, 0, 4);
	br.graphics.drawRect (0, 0, 22, 22);
	br.graphics.endFill ();
      }

    if (Std.is (e, ResizeEvent))
      e.updateAfterEvent ();

  }				//redraw



    public function onRaise(e:Event)
    {
	parent.setChildIndex (this, parent.numChildren - 1);
    }
    

}
