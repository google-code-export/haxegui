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

import flash.geom.Rectangle;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.FocusEvent;
import flash.ui.Mouse;
import flash.ui.Keyboard;
import haxegui.controls.Component;
import haxegui.controls.AbstractButton;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.WindowEvent;
import haxegui.events.DragEvent;
import haxegui.managers.CursorManager;
import haxegui.managers.MouseManager;
import haxegui.managers.StyleManager;
import haxegui.managers.WindowManager;
import haxegui.managers.DragManager;
import haxegui.managers.FocusManager;
import haxegui.managers.ScriptManager;
import haxegui.Opts;
import haxegui.windowClasses.TitleBar;
import haxegui.windowClasses.WindowFrame;
import haxegui.windowClasses.StatusBar;
import haxegui.utils.Color;
import haxegui.utils.Size;


enum WindowType
{
	NORMAL;
	MODAL;
	ALWAYS_ON_TOP;
}


/**
* Dragable & Resizable window.
*
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class Window extends Component
{
	
	////////////////////////////////////////////////////////////////////////////
	// Composition
	////////////////////////////////////////////////////////////////////////////
	public var titlebar 	: TitleBar;
	public var frame 		: WindowFrame;
	public var statusbar	: StatusBar;
	public var type			: WindowType;

	
	
	////////////////////////////////////////////////////////////////////////////
	// Privates
	////////////////////////////////////////////////////////////////////////////
	private var lazyResize:Bool;
	private var sizeable(isSizeable, setSizeable):Bool;
	
	/** 
	 * Constructor
	 * 
	 * @param parent The parent to hold the new window, will default to root.
	 * @param name	 Window's instance name on stage nad title.
	 * @param x		 Horizontal offset
	 * @param y		 Vertical offset
	 * @param height Window's height, set to member box
	 * @param width  Window's width, set to member box
	 * @param sizeable
	 * 
	 */
	public function new (
				? parent : DisplayObjectContainer, 
				? name   	: String,
				? x 	 	: Float, 
				? y 	 	: Float, 
				? width  	: Float,
				? height 	: Float, 
				? sizeable  : Bool
				) {
						
		/** Default new windows to be children of root **/
		if (parent == null || !Std.is (parent, DisplayObjectContainer))
			parent = flash.Lib.current;
		
		/** Check name with WindowManager **/
		if( WindowManager.getInstance().windows.exists( name ) )
			this.name += Std.string(haxe.Timer.stamp()*1000).substr(0,2);

		super (parent, name, x, y);

		WindowManager.getInstance().windows.set( name, this );
		
	}

	public function getClientRect() : Rectangle {
		return new Rectangle();
	}

	override public function init(opts : Dynamic=null) {
		
		box = new Size (320, 240).toRect();
		color = DefaultStyle.BACKGROUND;
		text = null;
		
		type = Opts.getField(opts, "type");
		if(type==null) type = WindowType.NORMAL;

		super.init(opts);

		
		// options
		sizeable = Opts.optBool(opts, "sizeable", true);
		lazyResize = Opts.optBool(opts, "lazyResize", false);

		// frame
		frame = new WindowFrame(this, "frame");
		frame.init({color: this.color});
		
		// add a titlebar
		titlebar = new TitleBar(this, "titlebar");
		titlebar.init({title:this.name, color: this.color });

		// register with focus manager
		//~ FocusManager.getInstance ().addEventListener (FocusEvent.MOUSE_FOCUS_CHANGE, redraw, false, 0, true);

		// register with WindowManager
		//~ this.addEventListener( ResizeEvent.RESIZE, WindowManager.getInstance().proxy );
		//~ this.addEventListener( MoveEvent.MOVE,  WindowManager.getInstance().proxy );
		WindowManager.getInstance().register(this);


	}

	public function setSizeable(s:Bool):Bool {
		return sizeable = s;
	}

	public function isSizeable ():Bool	{
		return sizeable;
	}


	/**
	* Returns true if the window is modal
	**/
	public function isModal() : Bool {
		return switch(type) {
		case MODAL: true;
		default : false;
		}
	}

	static function __init__() {
		haxegui.Haxegui.register(Window,initialize);
	}

	static function initialize() {
	}


	override public function destroy() {
	
		//var t = new feffects.Tween(1, 0, 750, this, "alpha", feffects.easing.Linear.easeNone);
		//t.start();
		
		var self = this;
		/*
		haxe.Timer.delay(
		function()
		{
		*/
		var idx : Int = 0;
		for(i in 0...self.numChildren) {
			var c = self.getChildAt(idx);
			if(Std.is(c,Component))
				(cast c).destroy();
			else
				idx++;
		}
		for(i in 0...self.numChildren)
			self.removeChildAt(0);
		if(self.parent != null)
			self.parent.removeChild(self);
		//}, 750 );
		
	}
	
	public override function onMouseDoubleClick(e:MouseEvent) : Void {
		/*
		var self = this;
		var t = new feffects.Tween(this.box.height, 40, 1500, feffects.easing.Back.easeInOut);
		t.setTweenHandlers( function(v) {
			self.box.height = v;
			self.redraw();
			} );
		t.start();
			
		var self = this;
		haxe.Timer.delay( function() {
			for(i in 0...self.numChildren)
			if(self.getChildAt(i)!=self.frame && 
			self.getChildAt(i)!=self.titlebar && 
			self.getChildAt(i)!=self.statusbar )
			self.getChildAt(i).visible = false;
			
			}, 1500 );
		dispatchEvent(new WindowEvent(WindowEvent.ROLLED));
		*/
		super.onMouseDoubleClick(e);
	}
	

	
}
