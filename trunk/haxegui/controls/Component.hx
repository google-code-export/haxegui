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
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;

import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.FocusManager;
import haxegui.Haxegui;
import haxegui.Opts;
import haxegui.ScriptManager;

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
		this.addEventListener (MouseEvent.CLICK, onMouseClick, false, 0, true);
		this.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		this.addEventListener (MouseEvent.MOUSE_UP,   onMouseUp, false, 0, true);
		this.addEventListener (MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
		this.addEventListener (MouseEvent.ROLL_OUT,  onRollOut, false, 0, true);
		this.addEventListener (KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
		this.addEventListener (ResizeEvent.RESIZE, onResize, false, 0, true);
		this.addEventListener (Event.ADDED, onAdded, false, 0, true );
		this.addEventListener (FocusEvent.KEY_FOCUS_CHANGE, __focusHandler, false, 0, true);
		this.addEventListener (FocusEvent.MOUSE_FOCUS_CHANGE, __focusHandler, false, 0, true);
		this.addEventListener (FocusEvent.FOCUS_IN, onFocusIn, false, 0, true);
		this.addEventListener (FocusEvent.FOCUS_OUT, onFocusOut, false, 0, true);
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
		this.visible = Opts.optBool(opts, "visible", true);

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
	* Returns the code associated with the specified action. If this instance
	* does not have a script, the default from the style is returned.
	*
	* @param action Action name
	* @return String code
	**/
	public function getAction(action:String) : String {
		return try ScriptManager.getInstanceActionObject(this, name).code
		catch(e:Dynamic) null;
	}

	/**
	* Returns the code associated with this instance for the specified action.
	*
	* @param action Action name
	* @return String code
	**/
	public function getOwnAction(action:String) : String {
		return try ScriptManager.getInstanceOwnActionObject(this, name).code
		catch(e:Dynamic) null;
	}

	/**
	* Returns true if this component has an action
	* registered for the action type [name]. If this instance
	* does not have an override, the default from the style is
	* checked.
	*
	* @param name Action name
	* @return Bool true if an action exists
	**/
	public function hasAction(name:String) {
		var c = try ScriptManager.getInstanceActionObject(this, name) catch(e:Dynamic) null;
		return (c != null);
	}

	/**
	* Returns true if this component has an action registered
	* for the action type [name]. Only returns true if the
	* script is only for this instance.
	*
	* @param name Action name
	* @return Bool true if an action exists
	**/
	public function hasOwnAction(name:String) {
		return (ScriptManager.getInstanceOwnActionObject(this,name) != null);
	}

	/**
	* Excecute redrawing script
	**/
	public function redraw(opts:Dynamic=null) {
// 		trace(this.name + " redraw");
		ScriptManager.exec(this,"redraw", opts);
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

	/**
	* Sets the action code for the specified action name for this component.
	*
	* @param action Action name
	* @param code Action code
	**/
	public function setAction(action:String, code:String) : Void {
		ScriptManager.setInstanceScript(this, name, code);
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
	/** Triggered by addChild() or addChildAt() **/
	public function onAdded(e:Event) {
	}

	private function __focusHandler(e:FocusEvent) {
		var c : Component;
		// relatedObject is one gaining focus
		// target is object losing focus
		// currentTarget == this
// 		trace("------" + Std.string(this) + " __focusHandler");
// 		trace("__focusHandler " + (if(e.currentTarget != this) " ******* " + Std.string(e.currentTarget) else "") + " :  from " + Std.string(e.target) + " to " + Std.string(e.relatedObject));
		var o = e.target;

		// first event is fired to the target about to lose focus
		if(e.currentTarget == e.target && Std.is(e.currentTarget,Component)) {
			c = cast e.currentTarget;
			// see if current object will relinquish focus to gainer.
			if(!c.onLosingFocus(e.relatedObject)) {
				e.preventDefault();
				e.stopImmediatePropagation();
				c.stage.focus = c;
				return;
			}
		}

		// check if the object gaining focus rejects
		if(Std.is(e.relatedObject, Component)) {
			var c : Component = cast e.relatedObject;
			if(!c.onGainingFocus(e.relatedObject)) {
				e.preventDefault();
				e.stopImmediatePropagation();
				c.stage.focus = c;
				return;
			}
		}
	}

	/** Placeholder **/
	private function onClick(e:MouseEvent) {
		trace("Do not use onClick, use onMouseClick");
		onMouseClick(e);
	}

	/**
	* When a component is gaining focus, this event occurs twice.
	*
	* The first time, [focusFrom] is set to the object losing focus.
	*
	* The second time, [focusFrom == this] which shows that all parents
	* have been notified of the focus change.
	**/
	public function onFocusIn(e:FocusEvent) {
		// -- Fired twice: first time --
		// related == object losing focus
		// target == object gaining focus
		// currentTarget == this
		// -- second time --
		// related == null
		// target == currentTarget == this
// 		trace("++++ " + Std.string(this) + " onFocusIn");
// 		trace("onFocusIn relatedObject: " + Std.string(e.relatedObject));
// 		trace("onFocusIn currentTarget: " + Std.string(e.currentTarget));
// 		trace("onFocusIn target: " + Std.string(e.target));

		ScriptManager.exec(this, "focusIn", {focusFrom : e.target});
	}

	/**
	* When a component is losing focus, this event occurs
	*
	* [focusTo] is set to the object gaining focus.
	*
	**/
	private function onFocusOut(e:FocusEvent) : Void {
// 		trace("++++ " + Std.string(this) + " onFocusOut");
// 		trace("onFocusOut relatedObject: " + Std.string(e.relatedObject));
// 		trace("onFocusOut currentTarget: " + Std.string(e.currentTarget));
// 		trace("onFocusOut target: " + Std.string(e.target));
		// -- Fired twice : a real mess... we just need one
		if(e.relatedObject != null)
			ScriptManager.exec(this, "focusOut", {focusTo : e.relatedObject});
	}

	/**
	* If the component will not take focus, return false from this handler
	* which will cancel the focus transfer.
	**/
	public function onGainingFocus(from : flash.display.InteractiveObject) : Bool {
		var rv : Dynamic = ScriptManager.exec(this,"gainingFocus", {focusFrom : from});
		if(rv == null)
			return true;
		return cast rv;
	}

	/**
	* Dispatched to this object when it is about to lose focus
	*
	* @return true to allow change, false to prevent focus change
	**/
	public function onLosingFocus(losingTo : flash.display.InteractiveObject) : Bool {
		var rv : Dynamic = ScriptManager.exec(this,"losingFocus", {focusTo : losingTo});
		if(rv == null)
			return true;
		return cast rv;
	}

	/** onRollOver Event **/
	public function onRollOver(e:MouseEvent)
	{
		ScriptManager.exec(this,"mouseOver", {event : e});
	}

	/** onRollOut Event **/
	public function onRollOut(e:MouseEvent) : Void
	{
		ScriptManager.exec(this,"mouseOut", {event : e});
	}

	/** Mouse click **/
	public function onMouseClick(e:MouseEvent) : Void
	{
		trace("onMouseClick " + this.name + " " + hasOwnAction("mouseClick"));
		ScriptManager.exec(this,"mouseClick", {event : e});
	}

	public function onMouseDown(e:MouseEvent) : Void
	{
		FocusManager.getInstance().setFocus(this);
		ScriptManager.exec(this,"mouseDown", {event : e});
	}

	/**
	*/
	public function onMouseUp(e:MouseEvent) : Void
	{
		ScriptManager.exec(this,"mouseUp", {event : e});
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
	// redraw, mouseClick, mouseOver, mouseOut
	// mouseDown, mouseUp, validate, gainingFocus
	// losingFocus, focusIn, focusOut


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
