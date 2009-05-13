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

package haxegui.controls;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;

import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.FocusManager;
import haxegui.Opts;
import haxegui.StyleManager;

import feffects.Tween;


/**
* Component Class
**/
class Component extends Sprite, implements haxegui.IMovable, implements haxegui.IToolTip, implements Dynamic
{

	/** Rectangular dimensions **/
	public var box : Rectangle;

	/** Disabled \ Enabled **/
	public var disabled(default, default) : Bool;

	/** Does object validate ? **/
	public var validate : Bool;

	/** Text for tooltip **/
	public var text : String;

//~ public var margin : Rectangle;
//~ public var padding : Array<Float>;
//~ public var getBox : Void -> Rectangle;

	/** Current color tween in effect **/
	private var colorTween : Tween;

	/**
	*
	**/
	public function new (parent:DisplayObjectContainer=null, name:String=null, ?x:Float, ?y:Float)
	{
		super ();

		tabEnabled = mouseEnabled = buttonMode = true;

		if(name!=null)
			this.name = name;
		else
			this.name = Type.getClassName(Type.getClass(this)).split(".").pop();


		if(parent!=null)
			parent.addChild(this);

		box = new Rectangle();

		text = name;
		disabled = false;

		move(x,y);

		//~ margin = new Rectangle();
		//~ trace("New " + this);

		// Listeners
		this.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		this.addEventListener (MouseEvent.MOUSE_UP,   onMouseUp, false, 0, true);
		this.addEventListener (MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
		this.addEventListener (MouseEvent.ROLL_OUT,  onRollOut, false, 0, true);
		this.addEventListener (KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
		this.addEventListener (ResizeEvent.RESIZE, onResize, false, 0, true);
	}

	public function init(opts:Dynamic=null) {
		if(opts == null) opts = {};
		name = Opts.optString(opts,"name",name);
		disabled = Opts.optBool(opts,"disabled",false);
	}

	public function redraw(?opts:Dynamic) {
	}

	/**
	* Move relative to current location.
	**/
	public function move (x : Float, y : Float) : Void
	{
		var event = new MoveEvent(MoveEvent.MOVE);
		event.oldX = this.x;
		event.oldY = this.y;
		this.x += x;
		this.y += y;
		box.offset(x,y);
		dispatchEvent(event);
	}

	/**
	*
	**/
	public function setBox(b:Rectangle) : Rectangle
	{
		var event = new ResizeEvent(ResizeEvent.RESIZE);
		event.oldWidth = box.width;
		event.oldHeight = box.height;
		box = b.clone();
		dispatchEvent(event);
		//~ trace(event);
		return box;
	}

	//TODO: recurse, that is check all children's children too..
	public function hasFocus ():Bool
	{
		if (FocusManager.getInstance ().getFocus () == this )
		return true;
		else
		return false;
	}

	/** Returns whether object validates **/
	public function isValid() : Bool
	{
		return true;
	}


	private function updateColorTween(t : Tween) {
		var me = this;
		var colorTrans: ColorTransform  = new ColorTransform();

		if(colorTween != null)
			colorTween.stop();
		colorTween = t;
		colorTween.setTweenHandlers(
				function(v) {
					colorTrans.redOffset = v;
					colorTrans.greenOffset = v;
					colorTrans.blueOffset = v;
					me.transform.colorTransform = colorTrans;
				},
				null);
		colorTween.start();
	}


	/** onRollOver Event **/
	public function onRollOver(e:MouseEvent)
	{
		StyleManager.exec(Type.getClass(this),"mouseOver", this, {event : e});
	}

	/** onRollOut Event **/
	public function onRollOut(e:MouseEvent) : Void
	{
		StyleManager.exec(Type.getClass(this),"mouseOut", this, {event : e});
	}

	public function onMouseDown(e:MouseEvent) : Void
	{
		StyleManager.exec(Type.getClass(this),"mouseDown", this, {event : e});
	}

	/**
	*/
	public function onMouseUp(e:MouseEvent) : Void
	{
		StyleManager.exec(Type.getClass(this),"mouseUp", this, {event : e});
	}

	public function onKeyDown(e:KeyboardEvent)
	{
	}

	public function onResize(e:ResizeEvent) : Void
	{
	}

	public var action_redraw(__getAction_redraw,__setAction_redraw) : String;
	 function __getAction_redraw() { return action_redraw; }
	 function __setAction_redraw(v:String) : String {
		return action_redraw = StyleManager.setScript(Type.getClass(this), "redraw", v);
	}
	public var action_mouseOver(__getAction_mouseOver,__setAction_mouseOver) : String;
	 function __getAction_mouseOver() { return action_mouseOver; }
	 function __setAction_mouseOver(v:String) : String {
		return action_mouseOver = StyleManager.setScript(Type.getClass(this), "mouseOver", v);
	}

	public var action_mouseOut(__getAction_mouseOut,__setAction_mouseOut) : String;
	 function __getAction_mouseOut() { return action_mouseOut; }
	 function __setAction_mouseOut(v:String) : String {
		return action_mouseOut = StyleManager.setScript(Type.getClass(this), "mouseOut", v);
	}

	public var action_mouseDown(__getAction_mouseDown,__setAction_mouseDown) : String;
	 function __getAction_mouseDown() { return action_mouseDown; }
	 function __setAction_mouseDown(v:String) : String {
		return action_mouseDown = StyleManager.setScript(Type.getClass(this), "mouseDown", v);
	}

	public var action_mouseUp(__getAction_mouseUp,__setAction_mouseUp) : String;
	 function __getAction_mouseUp() { return action_mouseUp; }
	 function __setAction_mouseUp(v:String) : String {
		return action_mouseUp = StyleManager.setScript(Type.getClass(this), "mouseUp", v);
	}

}
