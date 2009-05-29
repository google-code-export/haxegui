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

package haxegui.managers;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.text.TextField;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.FocusEvent;
import flash.geom.Rectangle;

import haxegui.Component;
import haxegui.managers.StyleManager;

import feffects.Tween;


class Tooltip extends Component {
	var target  : Component;
	var tf 		: TextField;
	var t		: Tween;
	

	public function new (target:Component)
	{
	
	//~ super (parent, "Tooltip", x, y);
	super (flash.Lib.current, "Tooltip",  flash.Lib.current.stage.mouseX, flash.Lib.current.stage.mouseY - 20);

	alpha = 0;
	
	mouseEnabled = false;
	buttonMode = false;
	
	tf = new TextField();
	tf.embedFonts = true;
	tf.x = 4;
	tf.y = 4;
	//~ tf.autoSize = flash.text.TextFieldAutoSize.LEFT;
	tf.defaultTextFormat = DefaultStyle.getTextFormat();
	tf.setTextFormat( DefaultStyle.getTextFormat() );
	this.addChild(tf);		

	t = new feffects.Tween(0, .8, 500, this, "alpha", feffects.easing.Linear.easeNone);
	

			this.graphics.lineStyle(1, DefaultStyle.TOOLTIP - 0x141414);
			this.graphics.beginFill(DefaultStyle.TOOLTIP);
			//~ sprite.graphics.drawRect(0,0,tf.width+8, tf.height+8 );
			this.graphics.drawRect(0,0, tf.width, 20);
			this.graphics.endFill();

			var shadow = new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, flash.filters.BitmapFilterQuality.HIGH, false, false, false );
			this.filters = [shadow];  
	
			tf.text = target.text == null ? target.name : target.text;
			//~ t.start();
			haxe.Timer.delay( t.start, 750 );
			

		if (this.parent != null)
			if (this.parent.contains (this))
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);

  }



	

	
	public function onMove(e:MouseEvent) {
		this.x = e.stageX + 4;
		this.y = e.stageY - 24;

		if (this.parent != null)
			if (this.parent.contains (this))
				this.parent.setChildIndex(this, this.parent.numChildren-1);
				
//~ trace(target.hitTestPoint(x,y));
//~ if(target.hitTestPoint(x,y)) destroy();
	}
	

	public override function destroy() {
		if(this.filters!=null)
			this.filters = null;
		if(this.tf!=null)
			if (this.contains (tf))	
				this.removeChild(tf);
		if(this.stage!=null)
			if(this.stage.hasEventListener(MouseEvent.MOUSE_MOVE))
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
		if (this.parent != null)
			if (this.parent.contains (this))
				this.parent.removeChild (this);		
		
		super.destroy();
				
	}

	
	static function __init__() {
		haxegui.Haxegui.register(Tooltip);
	}
		


}

class TooltipManager extends EventDispatcher
{
	
  private static var _instance : TooltipManager = null;

  var tt : Tooltip;


  public static function getInstance ():TooltipManager
  {
    if (TooltipManager._instance == null)
      {
        TooltipManager._instance = new TooltipManager ();
      }
    return TooltipManager._instance;
  }


  public function new ()
  {
    super ();
  }		


	public function create(target:Component) {
	
		if(tt!=null) tt.destroy();
		tt = new Tooltip(target);
		
	}
	
	public function destroy() {
	
		tt.destroy();
	}
	

}
