//      PopupMenu.hx
//      
//      Copyright 2009 gershon <gershon@yellow>
//      
//      This program is free software; you can redistribute it and/or modify
//      it under the terms of the GNU General Public License as published by
//      the Free Software Foundation; either version 2 of the License, or
//      (at your option) any later version.
//      
//      This program is distributed in the hope that it will be useful,
//      but WITHOUT ANY WARRANTY; without even the implied warranty of
//      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//      GNU General Public License for more details.
//      
//      You should have received a copy of the GNU General Public License
//      along with this program; if not, write to the Free Software
//      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
//      MA 02110-1301, USA.

import flash.geom.Rectangle;

import flash.display.DisplayObjectContainer;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

import flash.text.TextField;
import flash.text.TextFormat;


import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import events.MenuEvent;

import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;



import controls.Component;

class PopupMenu extends Component
{

  private var items : UInt;
  private var _item : UInt;
  
  public var color : UInt;

  private static var _instance:PopupMenu = null;


  private function new() 
  {
      super();
  }
  
  public static function getInstance ():PopupMenu
  {
    if (PopupMenu._instance == null)
      {
	PopupMenu._instance = new PopupMenu ();
      }
    return PopupMenu._instance;
  }


  


  public function init (parent:DisplayObjectContainer, x:Float, y:Float) : Void
  {
    
    close();
    
    
    parent.addChild (this);

    color = (cast parent).color;

    this.mouseEnabled = false;
    this.tabEnabled = false;
    
    //~ this.alpha = 0;
    //~ Tweener.addTween(this, { alpha:1, time: .75, transition:"linear" });


    this.name = "PopupMenu";

    items = 1 + Math.round( Math.random()*19 );
    

    for (i in 0...items)
      {
	var item = new Sprite();
	item.name = "Item" + (i+1);
	item.graphics.lineStyle(2, color - 0x323232);
	item.graphics.beginFill (color, .8);
	item.graphics.drawRect (0, 0, 100, 20);
	item.graphics.endFill ();
		
		var myPath = new Array<Dynamic>();
		
		myPath.push ({x:0, y: Math.exp(2)*2*i});
		//~ myPath.push ({x:0});
		//~ myPath.push ({x:2*i*Math.cos(i)});
		//~ myPath.push ({x:0});
		//~ item.alpha = 0;
		var p = new flash.geom.Point(x,y);
		p = localToGlobal( p );
		
		//~ item.alpha = 0;
		item.x = 100 + (flash.Lib.current.stage.stageWidth - p.x);
		item.y = -p.y  - 20*i ;
	//~ Tweener.addTween( item, {   
				//~ y: 20 * i,
				//~ x: 0,
				//~ alpha: 1,
				//~ _bezier:myPath,
				//~ time: .75+i/items,
//~ 
				//~ transition: "easeInOutBack",
//~ 
				//~ });

	item.buttonMode = true;

	item.addEventListener (MouseEvent.ROLL_OVER, onMouseOver);
	item.addEventListener (MouseEvent.ROLL_OUT, onMouseOut);
	item.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown);

	var tf = new TextField ();
	tf.name = "tf";
	tf.text = item.name;
	tf.selectable = false;
	tf.width = 40;
	tf.height = 20;
	tf.embedFonts = true;
    
	tf.mouseEnabled = false;

	tf.setTextFormat (StyleManager.getTextFormat());

	item.addChild (tf);
	this.addChild (item);
	//~ this.addChild (cast(item,Component));
	//addChildAt(item, i-1);

    // add the drop-shadow filter
    var shadow:DropShadowFilter = new DropShadowFilter (4, 45, 0x000000, 0.8,
							4, 4,
							0.65,
							BitmapFilterQuality.HIGH,
							false,
							false,
							false);
    var af:Array < Dynamic > = new Array ();
    af.push (shadow);
    item.filters = af;


      }
    
    // position
    this.x = x;
    this.y = y;


    
    //
    this.addEventListener (MouseEvent.ROLL_OUT, onMouseOut);
    this.addEventListener (KeyboardEvent.KEY_DOWN, onKeyDown);
    
    
    // shutdown event
    this.addEventListener (MenuEvent.MENU_HIDE, close);

    //
    dispatchEvent (new MenuEvent(MenuEvent.MENU_SHOW, false, false, parent, this ));
    
  }

  public function draw() : Void {
    if(numChildren>2)
    //~ if(!Tweener.isTweening(this.getChildAt(numChildren-2))){
    this.graphics.lineStyle (2, 0x1A1A1A, 0.9);
    //this.graphics.beginFill (0x595959, .8);
    //this.graphics.drawRect (0, 0, 100, 20 * (items - 1));
    this.graphics.drawRect (0, 0, 100, 20 * (numChildren - 1));
    //this.graphics.endFill ();

    // add the drop-shadow filter
    var shadow:DropShadowFilter = new DropShadowFilter (4, 45, 0x000000, 0.8,
							4, 4,
							0.65,
							BitmapFilterQuality.HIGH,
							false,
							false,
							false);
    var af:Array < Dynamic > = new Array ();
    af.push (shadow);
    this.filters = af;
    
    
    //~ }
  }//draw
  
  public function close (e:Event=null)
  {


    while(numChildren>0)
    this.removeChildAt(numChildren-1);

    items = _item = 0;
    this.graphics.clear();
    this.filters = null;
    
    
    if(this.hasEventListener(KeyboardEvent.KEY_DOWN))
	this.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);    

    // remove  
    if (this.parent != null)
      if (this.parent.contains (this))
	this.parent.removeChild (this);
    
    
  }



  function onMouseOut (e:MouseEvent)  {
    }
    

  function onMouseOver (e:MouseEvent)
  {

    _item = this.getChildIndex(e.target);
    onChanged();
    /*
    e.target.graphics.clear ();
    //e.target.graphics.lineStyle(2, 0x5D5D5D);
    e.target.graphics.beginFill (0xf5f5f5);
    e.target.graphics.drawRect (0, 0, 100, 20);
    e.target.graphics.endFill ();
    */
    //~ if(!Tweener.isTweening(e.target))
	//~ Tweener.addTween( e.target, { x: 0, _bezier:{ x: -10 }, time: .75, transition: "easeOutElastic" });
  }

  /**
   * 
   */
  public function onMouseDown(e:MouseEvent) {
	//~ dispatchEvent(new MenuEvent(MenuEvent.ITEM_CLICK, false, false, this, e.target.parent));
	dispatchEvent(new MenuEvent(MenuEvent.ITEM_CLICK, false, false));
        trace(Std.string(here)+Std.string(e));

    }
  
  
  public function onKeyDown (e:KeyboardEvent) {
      /*
    var item = cast (this.getChildAt (_item), Sprite);
    item.graphics.clear ();
    item.graphics.beginFill (0x595959);
    item.graphics.drawRect (0, 0, 100, 20);
    item.graphics.endFill ();

    switch (e.keyCode)
      {
      case flash.ui.Keyboard.UP:
	if (_item > 0)
	  _item--;
      case flash.ui.Keyboard.DOWN:
	if (_item < this.numChildren - 1)
	  _item++;
      }
        */
  }//end onKeyDown
  
    public function numItems() {
	return items;
    }
    
    public function nextItem() {
    _item++;
    if(_item>numChildren-1) _item=1;
    onChanged();
    }
      
    public function prevItem() {
    _item--;
    if(_item<=0) _item=numChildren-1;
    onChanged();
    }

    public function getItem() {
    trace(this.getChildAt(_item).name);
    }

    public function onChanged() {
	//trace(_item);
	//for(i in 0...items) {
	for(i in 0...numChildren) 
	{
	    var item = cast(this.getChildAt(i), Sprite);
	    //~ var color = (i==_item) ? color + 0x333333 : color;
	    var color = (i==_item) ? color + 0x202020 : color;
	    item.graphics.clear ();
	    item.graphics.lineStyle(2, color - 0x323232);
	    item.graphics.beginFill (color, .8);
	    item.graphics.drawRect (0, 0, 100, 20);
	    //item.graphics.endFill ();
	    
	    var tf : TextField = cast item.getChildByName("tf");
	    var fmt = new TextFormat ();
	    fmt.color = StyleManager.LABEL_TEXT ;
	    tf.setTextFormat (fmt);
	    
	}
    var item = cast(this.getChildAt(_item), Sprite);
    
	//~ if(!Tweener.isTweening(item)) 
	    //~ Tweener.addTween( item, { x: 0,  alpha:1, _bezier:{ x: 8, alpha:.5}, time: .175, transition: "easeOutCubic" });
	
	
    }
    
    
}
