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
import haxegui.Haxegui;
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

	/** The color of this component, which has different meanings per component **/
	public var color:Int;

	/** Disabled \ Enabled **/
	public var disabled(__getDisabled, __setDisabled) : Bool;

	public var dirty(__getDirty,__setDirty) : Bool;

	/** Whether the component can gain focus **/
	public var focusable : Bool;

	/** Does object validate ? **/
	public var validate : Bool;

	/** Text for tooltip **/
	public var text : String;

//~ public var margin : Rectangle;
//~ public var padding : Array<Float>;
//~ public var getBox : Void -> Rectangle;

	/** Current color tween in effect **/
	private var colorTween : Tween;

	/** The initial opts **/
	private var initOpts : Dynamic;

	/**
	*
	**/
	public function new (parent:DisplayObjectContainer=null, name:String=null, ?x:Float, ?y:Float)
	{
		super ();
		color = 0xF00FFF;

		tabEnabled = mouseEnabled = true;
		buttonMode = false;
		focusable = true;

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
		this.name = Opts.optString(opts, "name", this.name);
		this.disabled = Opts.optBool(opts, "disabled", false);
		this.box.width = Opts.optFloat(opts, "width", this.box.width);
		this.box.height = Opts.optFloat(opts, "height", this.box.height);
		this.x = Opts.optFloat(opts, "x", this.x);
		this.y = Opts.optFloat(opts, "y", this.y);
		this.color = Opts.optInt(opts, "color", this.color);
		this.alpha = Opts.optFloat(opts, "alpha", this.alpha);
		this.buttonMode = Opts.optBool(opts, "buttonMode", false);

		this.initOpts = {};
		for(f in Reflect.fields(opts)) {
			Reflect.setField(initOpts, f, Reflect.field(opts,f));
		}
		this.dirty = true;
	}

	/**
	* Destroy this component and all children
	*/
	public function destroy() {
		for(i in 0...numChildren) {
			var c = getChildAt(i);
			if(Std.is(c,Component))
				(cast c).destroy();
		}
		for(i in 0...numChildren)
			removeChildAt(0);
		if(this.parent != null)
			this.parent.removeChild(this);
	}

	/**
	* Excecute redrawing script
	**/
	public function redraw(?opts:Dynamic) {
		StyleManager.exec(this,"redraw", opts);
	}

	/**
	* Move relative to current location.
	**/
	public function move(x : Float, y : Float) : Void
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
	* Move to specific location.
	**/
	public function moveTo(x : Float, y : Float) : Void
	{
		var event = new MoveEvent(MoveEvent.MOVE);
		event.oldX = this.x;
		event.oldY = this.y;
		this.x = x;
		this.y = y;
		box.x = x;
		box.y = y;
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

	override public function toString() : String
	{
		return this.name + "[" + Type.getClassName(Type.getClass(this)) + "]";
	}

	public function updateColorTween(t : Tween) {
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


	//////////////////////////////////////////////////
	////               Events                     ////
	//////////////////////////////////////////////////
	/** onRollOver Event **/
	public function onRollOver(e:MouseEvent)
	{
		StyleManager.exec(this,"mouseOver", {event : e});
	}

	/** onRollOut Event **/
	public function onRollOut(e:MouseEvent) : Void
	{
		StyleManager.exec(this,"mouseOut", {event : e});
	}

	public function onMouseDown(e:MouseEvent) : Void
	{
		FocusManager.getInstance().setFocus(this);
		StyleManager.exec(this,"mouseDown", {event : e});
	}

	/**
	*/
	public function onMouseUp(e:MouseEvent) : Void
	{
		StyleManager.exec(this,"mouseUp", {event : e});
	}

	public function onKeyDown(e:KeyboardEvent)
	{
	}

	public function onResize(e:ResizeEvent) : Void
	{
	}



	//////////////////////////////////////////////////
	////               Actions                    ////
	//////////////////////////////////////////////////
	/** The script that redraws the Component **/
	public var action_redraw(__getAction_redraw,__setAction_redraw) : String;
		function __getAction_redraw() {
			return try StyleManager.getInstanceActionObject(this, "redraw").code
			catch(e:Dynamic) null;
		}
		function __setAction_redraw(v:String) : String {
			return StyleManager.setInstanceScript(this, "redraw", v);
		}

	/** The script that is executed when the mouse over event occurs. **/
	public var action_mouseOver(__getAction_mouseOver,__setAction_mouseOver) : String;
		function __getAction_mouseOver() {
			return try StyleManager.getInstanceActionObject(this, "mouseOver").code
			catch(e:Dynamic) null;
		}
		function __setAction_mouseOver(v:String) : String {
			return StyleManager.setInstanceScript(this, "mouseOver", v);
		}

	/** The script that is executed when the mouse out event occurs. **/
	public var action_mouseOut(__getAction_mouseOut,__setAction_mouseOut) : String;
		function __getAction_mouseOut() {
			return try StyleManager.getInstanceActionObject(this, "mouseOut").code
			catch(e:Dynamic) null;
		}
		function __setAction_mouseOut(v:String) : String {
			return StyleManager.setInstanceScript(this, "mouseOut", v);
		}

	/** The script that is executed when the mouse down event occurs. **/
	public var action_mouseDown(__getAction_mouseDown,__setAction_mouseDown) : String;
		function __getAction_mouseDown() {
			return try StyleManager.getInstanceActionObject(this, "mouseDown").code
			catch(e:Dynamic) null;
		}
		function __setAction_mouseDown(v:String) : String {
			return StyleManager.setInstanceScript(this, "mouseDown", v);
		}

	/** The script that is executed when the mouse up event occurs. **/
	public var action_mouseUp(__getAction_mouseUp,__setAction_mouseUp) : String;
		function __getAction_mouseUp() {
			return try StyleManager.getInstanceActionObject(this, "mouseUp").code
			catch(e:Dynamic) null;
		}
		function __setAction_mouseUp(v:String) : String {
			return StyleManager.setInstanceScript(this, "mouseUp", v);
		}

	/** The script that is executed when the Component is validated **/
	public var action_validate(__getAction_validate,__setAction_validate) : String;
		function __getAction_validate() {
			return try StyleManager.getInstanceActionObject(this, "validate").code
			catch(e:Dynamic) null;
		}
		function __setAction_validate(v:String) : String {
			return StyleManager.setInstanceScript(this, "validate", v);
		}


	//////////////////////////////////////////////////
	////           Getters/Setters                ////
	//////////////////////////////////////////////////

	private function __getDirty() : Bool {
		return this.dirty;
	}

	private function __setDirty(v:Bool) : Bool {
		if(this.dirty == v) return v;
		this.dirty = v;
		if(v)
			Haxegui.setDirty(this);
		return v;
	}

	private function __getDisabled() : Bool {
		return this.disabled;
	}

	private function __setDisabled(v:Bool) : Bool {
		if(this.disabled == v) return v;
		this.disabled = v;
		this.dirty = true;
		for(i in 0...numChildren) {
			var c = getChildAt(i);
			if(Std.is(c,Component))
				(cast c).disabled = v;
		}
		return v;
	}


}
