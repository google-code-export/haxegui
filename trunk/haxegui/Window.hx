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

//{{{ Imports
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
import haxegui.utils.Opts;
import haxegui.windowClasses.TitleBar;
import haxegui.windowClasses.WindowFrame;
import haxegui.windowClasses.StatusBar;
import haxegui.utils.Color;
import haxegui.utils.Size;
//}}}


//{{{ WindowType
enum WindowType {
	NORMAL;
	MODAL;
	ALWAYS_ON_TOP;
}
//}}}


//{{{ Window
/**
* Dragable & Resizable window.<br/>
*
*
* @author <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class Window extends Component {
	//{{{ Members


	//{{{ Public
	public var titlebar 	: TitleBar;
	public var frame 		: WindowFrame;
	public var statusbar	: StatusBar;
	public var type			: WindowType;
	//}}}


	//{{{ Private
	private var sizeable(isSizeable, setSizeable) : Bool;
	//}}}


	//{{{ Static
	public static var lazyResize : Bool;
	//}}}

	//}}}


	//{{{ Constructor
	/**
	* Constructor
	*
	* @param parent  	The parent to hold the new window, will default to root.
	* @param name	 	Window's instance name on stage nad title.
	* @param x		 	Horizontal offset
	* @param y		 	Vertical offset
	* @param height  	Window's height, set to member box
	* @param width   	Window's width, set to member box
	* @param sizeable   True to make window sizeable
	*/
	public
	function new (
	? parent	: DisplayObjectContainer,
	? name   	: String,
	? x 	 	: Float,
	? y 	 	: Float,
	? width  	: Float,
	? height 	: Float,
	? sizeable  : Bool)	{


		super (parent, name, x, y);


		// register creation with window manager
		WindowManager.getInstance().windows.set( name, this );
	}
	//}}}


	//{{{ Functions
	//{{{ getClientRect
	/** @todo fix this*/
	public function getClientRect() : Rectangle {
		return new Rectangle();
	}
	//}}}


	//{{{ init
	override public function init(opts : Dynamic=null) {
		box = new Size (320, 240).toRect();
		color = DefaultStyle.BACKGROUND;
		description = null;


		type = Opts.getField(opts, "type");
		if(type==null) type = WindowType.NORMAL;


		super.init(opts);


		// options
		sizeable = Opts.optBool(opts, "sizeable", true);
		lazyResize = Opts.optBool(opts, "lazyResize", false);


		// frame
		frame = new WindowFrame(this, "frame");
		frame.init({color: this.color});


		// titlebar
		titlebar = new TitleBar(this, "titlebar");
		titlebar.init({title:this.name, color: this.color });

		// register events with window manager
		WindowManager.getInstance().register(this);
	}
	//}}}


	//{{{ setSizeable
	public function setSizeable(s:Bool):Bool {
		return sizeable = s;
	}
	//}}}


	//{{{ isSizeable
	public function isSizeable ():Bool	{
		return sizeable;
	} //}}}


	//{{{ isModal
	public function isModal() : Bool {
		return type == MODAL;
	}
	//}}}


	//{{{ destroy
	public override function destroy() {
		dispatchEvent(new WindowEvent(WindowEvent.CLOSE));
		super.destroy();
	}
	//}}}


	//{{{ onMouseDoubleClick
	/**
	* @todo window shading
	*/
	public override function onMouseDoubleClick(e:MouseEvent) : Void {
		super.onMouseDoubleClick(e);
	}
	//}}}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(Window);
	}
	//}}}

	//}}}
}
//}}}
