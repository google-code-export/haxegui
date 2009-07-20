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

package haxegui.windowClasses;

import flash.geom.Rectangle;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.FocusEvent;

import flash.ui.Mouse;
import flash.ui.Keyboard;

import haxegui.managers.CursorManager;
import haxegui.managers.MouseManager;
import haxegui.managers.StyleManager;
import haxegui.managers.WindowManager;
import haxegui.managers.DragManager;
import haxegui.managers.FocusManager;
import haxegui.managers.ScriptManager;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;

import haxegui.controls.Component;
import haxegui.controls.AbstractButton;
import haxegui.Opts;
import haxegui.windowClasses.TitleBar;
import haxegui.windowClasses.WindowFrame;


//~ enum ResizeDirection {
	//~ NESW;
	//~ NS;
	//~ NWSE;
	//~ WE;
//~ }

/**
*
* WidowFrame optionaly resizing window frame.
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class WindowFrame extends Component
{


	override public function init(?opts:Dynamic) {

		this.box = (cast parent).box.clone();
		
		super.init(opts);
		text = null;
		
		// Exclude modal windows from resizing
		if(!(cast parent).isModal())
		{
			this.setAction("mouseDown", 
			"
			this.updateColorTween( new feffects.Tween(0, 50, 150, feffects.easing.Linear.easeOut) );
			/* Remove corner detection */
			this.removeEventListener(flash.events.MouseEvent.MOUSE_MOVE, this.onMouseMove);
			/* Event for stopping the interval */
			this.stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, this.onStageMouseUp, false, 0, true);
			this.startInterval(12);
			CursorManager.getInstance().lock = true;

			var shadow = new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.4, 12, 12, 0.85, flash.filters.BitmapFilterQuality.LOW, false, false, false);
			this.filters = [shadow];		
			
			"
			);

			this.setAction("mouseUp", 
			"
			this.updateColorTween( new feffects.Tween(50, 0, 150, feffects.easing.Linear.easeOut) );
			/*this.stopInterval();*/
			/*this.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, this.onMouseMove, false, 0, true);*/
			var shadow = new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.9, 12, 12, 0.85, flash.filters.BitmapFilterQuality.HIGH, false, false, false);
			this.filters = [shadow];		
			"
			);
	
			this.setAction("interval", 
			"
				var d = -5;
			
					if(CursorManager.getInstance().cursor == Cursor.NS)
						/*this.parent.box.height = this.stage.mouseY - this.parent.y + d ;*/
						this.parent.box.height = this.stage.mouseY - this.parent.y + d + MouseManager.getInstance().delta.y;

					if(CursorManager.getInstance().cursor == Cursor.WE)
						{
						if(this.stage.mouseX > this.parent.x + .5*this.parent.box.width)
							/*this.parent.box.width = this.stage.mouseX - this.parent.x + d ;*/
							this.parent.box.width = this.stage.mouseX - this.parent.x + d + MouseManager.getInstance().delta.x;
						else
							{
								/*this.parent.box.width -= this.stage.mouseX - this.parent.x + d ;*/
								this.parent.box.width -= this.stage.mouseX - this.parent.x + d;
								this.parent.x = this.stage.mouseX + d ;
							}
						}
					
					if(CursorManager.getInstance().cursor == Cursor.NESW) {
						this.parent.box.width -=  this.stage.mouseX - this.parent.x + d ;
						this.parent.box.height = this.stage.mouseY - this.parent.y + d ;
						//~ this.parent.box.width += MouseManager.getInstance().delta.x;
						//~ this.parent.box.height += MouseManager.getInstance().delta.y;
						this.parent.x = this.stage.mouseX + d;
						}

					if(CursorManager.getInstance().cursor == Cursor.NWSE) {
						this.parent.box.height =  this.stage.mouseY - this.parent.y + d;
						this.parent.box.width = this.stage.mouseX - this.parent.x + d;
						//~ this.parent.box.width += MouseManager.getInstance().delta.x ;
						//~ this.parent.box.height += MouseManager.getInstance().delta.y ;
						}
						
				this.redraw();

		"
		);
		// listener for changing cursor icon, resizing direction.
		this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
		}
		
		var shadow = new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.9, 12, 12, 0.85, flash.filters.BitmapFilterQuality.HIGH, false, false, false);
		this.filters =[shadow];		
				
	}
	
	static function __init__() {
		haxegui.Haxegui.register(WindowFrame);
	}
	
	
	public function onMouseMove(e:MouseEvent) {
		
		if(e.buttonDown ) { 
			//~ this.redraw(); 
			return; 
			}
		
		var box = (cast this.parent).box;
		var d = 10;

		if(e.localX > d && e.localX < box.width -d)
			CursorManager.setCursor(Cursor.NS);

		if(e.localY > d && e.localY < box.height - d)
			CursorManager.setCursor(Cursor.WE);	

		if(e.localX < d && e.localY > box.height - d)
			CursorManager.setCursor(Cursor.NESW);

		if(e.localX > box.width - d && e.localY > box.height - d)
			CursorManager.setCursor(Cursor.NWSE);

		// top-right disabled coz of titlebar...
		//~ if(e.localX > this.box.width - d && e.localY < d)
			//~ CursorManager.setCursor(Cursor.NESW);

		//~ e.updateAfterEvent();
	}
	

	
	public function onStageMouseUp(e:MouseEvent) {
		//~ trace(e);
		CursorManager.getInstance().lock = false;
		this.stopInterval();
		stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		
		if(!this.hitTestObject( CursorManager.getInstance()._mc )) 
			CursorManager.setCursor(Cursor.ARROW);

		this.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, this.onMouseMove, false, 0, true);
			
		//~ e.updateAfterEvent();
	}
	
	public override function onRollOut(e:MouseEvent) {
		if(e.buttonDown ) return;
			CursorManager.setCursor(Cursor.ARROW);

		//~ e.updateAfterEvent();
	}
	

	override public function redraw(opts:Dynamic=null):Void {	
		parent.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
		ScriptManager.exec(this,"redraw", null);

	}
}
