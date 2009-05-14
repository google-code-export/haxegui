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
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.Keyboard;

import haxegui.FocusManager;
import haxegui.Opts;
import haxegui.StyleManager;
import haxegui.controls.Component;
import haxegui.events.ResizeEvent;
import haxegui.events.MenuEvent;

/**
*
*
*
*/
class Menubar extends Component, implements Dynamic
{
	public var numMenus : Int;
	private var _menu:Int;


	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float, ?width:Float)
	{
		super (parent, name, x, y);
		this.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

	}

	override public function init(opts : Dynamic=null)
	{
		if(Std.is(parent, Component))
			color = (cast parent).color;

		super.init(opts);

		//this.name = "Menubar";
		buttonMode = false;
		tabEnabled = false;
		focusRect = false;
		mouseEnabled = false;

		_menu = 0;
		numMenus = 1+Math.round( Math.random() * 4 );

		//~ this.graphics.lineStyle (2, color - 0x1A1A1A);
		//~ this.graphics.beginFill (color);
		//~ this.graphics.drawRect (0, 0, width, 24);
		//~ this.graphics.endFill();


		for (i in 0...numMenus)
		{
			var menu = new Sprite();
			menu.name = "Menu" + (i+1);
			//menu.graphics.lineStyle(2, 0x5D5D5D);


			var colors = [ color - 0x141414, color | 0x323232 ];
			var alphas = [ 100, 100 ];
			var ratios = [ 0, 0xFF ];
			//~ var matrix = { a:200, b:0, c:0, d:0, e:200, f:0, g:200, h:200, i:1 };
			var matrix = new flash.geom.Matrix();
			matrix.createGradientBox(40, 24, Math.PI/2, 0, 0);
			menu.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );


			//~ menu.graphics.beginFill (color);
			menu.graphics.drawRect (0, 0, 40, 24);
			menu.graphics.endFill();
			//~ menu.y = 20;
			menu.x = Std.int(40 * i);

			menu.buttonMode = true;
			menu.tabEnabled = true;
			menu.focusRect = true;
			menu.mouseEnabled = true;

			menu.addEventListener (MouseEvent.ROLL_OVER, onMenuRollOver, false, 0, true);
			menu.addEventListener (MouseEvent.ROLL_OUT, onMenuMouseOut, false, 0, true);
			menu.addEventListener (MouseEvent.MOUSE_MOVE, onMenuMouseMove, false, 0, true);
			menu.addEventListener (MouseEvent.MOUSE_DOWN, onMenuMouseDown, false, 0, true);
			menu.addEventListener (MouseEvent.MOUSE_UP, onMenuMouseUp, false, 0, true);



			var tf = new TextField();
			tf.name = "tf";
			tf.text = menu.name;
			tf.selectable = false;
			tf.mouseEnabled = false;
			tf.width = 38;
			tf.height = 18;
			tf.x = 2;
			tf.y = 4;
			tf.embedFonts = true;

			tf.tabEnabled = false;
			tf.focusRect = false;
			tf.mouseEnabled = false;


			tf.setTextFormat (DefaultStyle.getTextFormat(8, 10, flash.text.TextFormatAlign.CENTER ));


			menu.addChild (tf);
			this.addChild (menu);
		}

		// inner-drop-shadow filter
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, 0x000000, 0.5,4, 4,0.75,BitmapFilterQuality.LOW,true,false,false);
		this.filters = [shadow];


		//parent.addChild(this);
		//parent.addEventListener(Event.CHANGE, this.redraw);
		//getParent().addEventListener(Event.CHANGE, this.redraw);
		//~ this.addEventListener (KeyboardEvent.KEY_DOWN, onKeyDown);
		//PopupMenu.getInstance().addEventListener(Event.CLOSE, onFocusChanged);
		//~ addEventListener (ResizeEvent.RESIZE, this.redraw);


		//~ parent.addEventListener (ResizeEvent.RESIZE, this.redraw);
		parent.addEventListener(ResizeEvent.RESIZE, onParentResize);

	}


	/**
	*
	*/
	public function onParentResize(e:ResizeEvent)
	{
		box = untyped parent.box.clone();
		//~ if(!Math.isNaN(e.oldWidth))
		//~ box.width = e.oldWidth;

		box.width -= x;
		box.height -= y;

		var b = box.clone();
		b.height = box.height;
		b.x=b.y=0;
		scrollRect = b;

		redraw();

		e.updateAfterEvent();
	}


	override public function redraw(opts:Dynamic=null)
	{

		//~ var width = parent.getChildByName ("frame").width;
		//~ var width = untyped parent.box.width;

		this.graphics.clear();
		//~ this.graphics.lineStyle (2, color - 0x1A1A1A);

		var colors = [ color - 0x141414, color | 0x323232 ];
		var alphas = [ 100, 100 ];
		var ratios = [ 0, 0xFF ];
		var matrix = new flash.geom.Matrix();
		matrix.createGradientBox(box.width, 24, Math.PI/2, 0, 0);
		this.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );


		//~ this.graphics.beginFill (color);
		//~ this.graphics.drawRect (0, 0, width, 24);
		this.graphics.drawRect (0, 0, box.width, 24);
		this.graphics.endFill();

	}


	function onMenuMouseOut (e:Event)
	{
		e.target.graphics.clear();
		//e.target.graphics.lineStyle(2, 0x5D5D5D);
		//~ e.target.graphics.beginFill (color);


		var colors = [ color - 0x141414, color | 0x323232 ];
		var alphas = [ 100, 100 ];
		var ratios = [ 0, 0xFF ];
		//~ var matrix = { a:200, b:0, c:0, d:0, e:200, f:0, g:200, h:200, i:1 };
		var matrix = new flash.geom.Matrix();
		matrix.createGradientBox(40, 24, Math.PI/2, 0, 0);
		e.target.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );


		e.target.graphics.drawRect (0, 0, 40, 24);
		e.target.graphics.endFill();


		var tf : TextField = cast e.target.getChildByName("tf");
		var fmt = new TextFormat();
		fmt.color = DefaultStyle.LABEL_TEXT  ;
		tf.setTextFormat (fmt);
		//dispatchEvent(new Event("CLOSE_POPUP"));
	}

	function onMenuMouseUp (e:MouseEvent)
	{
		//~ PopupMenu.getInstance().dispatchEvent (new Event (MenuEvent.MENU_HIDE));
	}

	function onMenuMouseDown (e:MouseEvent)
	{

		this.addEventListener (KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);

		//~ if(FocusManager.getInstance().getFocus()!=this)
		//~ if (Type.getClass (e.target.parent) == Sprite)
		//if(this.getChildIndex(e.target.parent)==_menu)
		//~ if (this.hasFocus())
		//~ PopupMenu.getInstance().dispatchEvent (new Event (MenuEvent.MENU_HIDE));
		//~ else
		//~ if(!this.hasFocus())
		//~ FocusManager.getInstance().setFocus(this);
		//~ FocusManager.getInstance().setFocus(e.target.parent);
		//~ PopupMenu.getInstance().dispatchEvent (new Event (MenuEvent.MENU_HIDE));


		onChanged();
		_menu = this.getChildIndex (e.target);
		openMenuAt (_menu);
		//~ openmenuByName (e.target.parent.name);
	}//onMouseDown


	function onMenuMouseMove (e:MouseEvent)
	{
		//if(PopupMenu.getInstance().exists())
		if (this.getChildIndex (e.target) != _menu)
		//~ if (this.hasFocus())
		{
			//dispatchEvent(new Event("CLOSE_POPUP"));
			_menu = this.getChildIndex (e.target);
			onChanged();

			//~ openmenuByName (e.target.parent.name);
			openMenuAt( _menu );
		}
	}

	function onMenuRollOver (e:MouseEvent)
	{
		var oldmenu = _menu;
		_menu = this.getChildIndex (e.target);
		onChanged (oldmenu);
	}

	function onPopupClosed (e:Event)
	{
		_menu = -1;
		onChanged();
	}

	override public function onKeyDown (e:KeyboardEvent)
	{
		trace(e);

		var popmenu:UInt;

		var menu = cast (this.getChildAt (_menu), Sprite);
		menu.graphics.clear();
		//~ menu.graphics.beginFill (color);

				var colors = [ color | 0x323232, color - 0x4D4D4D ];
			var alphas = [ 100, 100 ];
			var ratios = [ 0, 0xFF ];
			//~ var matrix = { a:200, b:0, c:0, d:0, e:200, f:0, g:200, h:200, i:1 };
			var matrix = new flash.geom.Matrix();
			matrix.createGradientBox(40, 24, Math.PI/2, 0, 20);
			menu.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );


		menu.graphics.drawRect (0, 0, 40, 20);
		menu.graphics.endFill();

		switch (e.keyCode)
		{
		case Keyboard.LEFT:
			if (_menu > 0)
				_menu--;
			else
				_menu = this.numChildren - 1;
		case Keyboard.RIGHT:
			if (_menu < this.numChildren - 1)
				_menu++;
			else
				_menu = 0;
		}

		menu = cast (this.getChildAt (_menu), Sprite);

		if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.RIGHT)
		{
			var popup = PopupMenu.getInstance();
			popup.init ({parent:this.parent, x:menu.x, y:menu.y + 20});
		}

		if (e.keyCode == Keyboard.DOWN)
			PopupMenu.getInstance().nextmenu();

		if (e.keyCode == Keyboard.UP)
			PopupMenu.getInstance().prevmenu();

		menu.graphics.clear();
		menu.graphics.beginFill(color);
		menu.graphics.drawRect(0, 0, 40, 20);
		menu.graphics.endFill();
	}


	public function onChanged (?oldmenu:Int)
	{

		//~ for (i in 0...numChildren)
		//~ if(Std.is(this.getChildAt(i), Sprite))
		//~ {
		//~ var menu = cast(this.getChildAt(i), Sprite);
		//~ var color = (i == _menu) ? 0xf5f5f5 : 0x595959;
		//~ menu.graphics.clear();
		//~ menu.graphics.beginFill (color);
		//~ menu.graphics.drawRect (0, 0, 40, 20);
		//~ menu.graphics.endFill();
		//~ }
		if( Math.isNaN(_menu) || _menu<0 || !this.contains(this.getChildAt(_menu)))
		return;

		var menu = cast(this.getChildAt(_menu), Sprite);
		//~ var color = this.color | 0x323232;
		menu.graphics.clear();

				//~ var colors = [ color | 0x323232, color - 0x141414 ];
				var colors = [ color, 0xFFFFFF ];
			var alphas = [ 100, 100 ];
			var ratios = [ 0, 0xFF ];
			//~ var matrix = { a:200, b:0, c:0, d:0, e:200, f:0, g:200, h:200, i:1 };
			var matrix = new flash.geom.Matrix();
			matrix.createGradientBox(40, 24, Math.PI/2, 0, 0);
			menu.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );



		//~ menu.graphics.beginFill (color);
		menu.graphics.drawRect (0, 0, 40, 24);
		menu.graphics.endFill();

		var tf : TextField = cast menu.getChildByName("tf");
		var fmt = new TextFormat();
		fmt.color = DefaultStyle.LABEL_TEXT ;
		tf.setTextFormat (fmt);

	}


	/**
	*
	*/
	function openmenuByName (name:String)
	{
		openMenuAt (this.getChildIndex (this.getChildByName (name)));
	}

	/**
	*
	*/
	function openMenuAt (i:UInt)
	{
		var menu = this.getChildAt (i);
		var popup = PopupMenu.getInstance();
		popup.init ({parent:this.parent, x:menu.x, y:menu.y + 20});
		//register new popups for close
		popup.addEventListener (MenuEvent.MENU_HIDE, onPopupClosed);

	}

	static function __init__() {
		haxegui.Haxegui.register(Menubar,initialize);
	}
	static function initialize() {
	}
}//Menubar
