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
	

	public function new (target:Component) {
		//
		super (flash.Lib.current, "Tooltip",  flash.Lib.current.stage.mouseX - 15, flash.Lib.current.stage.mouseY - 30);
		
		mouseEnabled = false;
		buttonMode = false;
		alpha = 0;
		
		tf = cast this.addChild(new TextField());		
		tf.text = target.text == null ? target.name : target.text;
		tf.embedFonts = true;
		tf.x = 4;
		tf.y = 4;
		tf.selectable = false;
		tf.mouseEnabled = false;
		tf.autoSize = flash.text.TextFieldAutoSize.LEFT;
		tf.defaultTextFormat = DefaultStyle.getTextFormat();
		tf.setTextFormat( DefaultStyle.getTextFormat() );
		
		this.box = new Rectangle(0,0, tf.width+8, tf.height+8);

		var shadow = new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.8, 4, 4, 0.65, flash.filters.BitmapFilterQuality.HIGH, false, false, false );
		this.filters = [shadow];  

		t = new feffects.Tween(0, .8, 500, this, "alpha", feffects.easing.Linear.easeNone);
		haxe.Timer.delay( t.start, 750 );

		if (this.parent != null)
			if (this.parent.contains (this))
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);

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
