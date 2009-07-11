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
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.FocusEvent;
import flash.geom.Rectangle;

import haxegui.Component;
import haxegui.managers.StyleManager;
import haxegui.controls.Label;

import feffects.Tween;

/**
*
* Tooltip Class
*
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class Tooltip extends Component {
	
	var target  : Component;
	var label 	: Label;
	var t		: Tween;
	

	public function new (target:Component) {
		//
		super (flash.Lib.current, "Tooltip",  flash.Lib.current.stage.mouseX - 15, flash.Lib.current.stage.mouseY - 30);

	
		mouseEnabled = false;
		buttonMode = false;
		visible = false;
		alpha = 0;
						
	
		label = new Label(this);		
		label.init({ innerData: target.text == null ? target.name : target.text });
		label.move(4,4);
		label.mouseEnabled = false;
		label.tf.selectable = false;
		label.tf.autoSize = flash.text.TextFieldAutoSize.LEFT;
	
		box = new Rectangle(0,0, label.tf.width+8, label.tf.height+8);

		var shadow = new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, flash.filters.BitmapFilterQuality.HIGH, false, false, false );
		this.filters = [shadow];  
			

		if (this.parent != null)
			if (this.parent.contains (this))
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);

		dirty = false;
		var tween = new feffects.Tween(0, .8, 350, this, "alpha", feffects.easing.Expo.easeOut);
		var self = this;
		var t = tween;
		haxe.Timer.delay( function(){ self.dirty=true; self.visible=true; t.start(); }, 750 );
				
	}

	
	public function onMove(e:MouseEvent) {
			this.x = e.stageX - 15;
			this.y = e.stageY - 30;

			if (this.parent != null)
				if (this.parent.contains (this))
					this.parent.setChildIndex(this, this.parent.numChildren-1);
	}
	
	
	

	public override function destroy() {
		if(this.filters!=null)
			this.filters = null;
		if(this.label!=null)
			if (this.contains (label))	
				this.removeChild(label);
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

/**
*
* TooltipManager Class
*
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class TooltipManager extends EventDispatcher
{
	
  private static var _instance : TooltipManager = null;

  var tt : Tooltip;

	public static function getInstance ():TooltipManager
	{
	if (TooltipManager._instance == null) 
		TooltipManager._instance = new TooltipManager ();
	return TooltipManager._instance;
	}


	public function create(target:Component) {
		if(tt!=null)
			tt.destroy();
		tt = new Tooltip(target);
		tt.init();
	}
	
	public function destroy() {
		if(tt==null) return;
		tt.destroy();
	}
	

}
