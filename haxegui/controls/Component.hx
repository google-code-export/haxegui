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
	/** The script that redraws the Component **/
	public var action_redraw(__getAction_redraw,__setAction_redraw) : String;
		function __getAction_redraw() {
			return try ScriptManager.getInstanceActionObject(this, "redraw").code
			catch(e:Dynamic) null;
		}
		function __setAction_redraw(v:String) : String {
			return ScriptManager.setInstanceScript(this, "redraw", v);
		}

	/** The script that is executed when the mouse click event occurs. **/
	public var action_mouseClick(__getAction_mouseClick,__setAction_mouseClick) : String;
		function __getAction_mouseClick() {
			return try ScriptManager.getInstanceActionObject(this, "mouseClick").code
			catch(e:Dynamic) null;
		}
		function __setAction_mouseClick(v:String) : String {
			return ScriptManager.setInstanceScript(this, "mouseClick", v);
		}

	/** The script that is executed when the mouse over event occurs. **/
	public var action_mouseOver(__getAction_mouseOver,__setAction_mouseOver) : String;
		function __getAction_mouseOver() {
			return try ScriptManager.getInstanceActionObject(this, "mouseOver").code
			catch(e:Dynamic) null;
		}
		function __setAction_mouseOver(v:String) : String {
			return ScriptManager.setInstanceScript(this, "mouseOver", v);
		}

	/** The script that is executed when the mouse out event occurs. **/
	public var action_mouseOut(__getAction_mouseOut,__setAction_mouseOut) : String;
		function __getAction_mouseOut() {
			return try ScriptManager.getInstanceActionObject(this, "mouseOut").code
			catch(e:Dynamic) null;
		}
		function __setAction_mouseOut(v:String) : String {
			return ScriptManager.setInstanceScript(this, "mouseOut", v);
		}

	/** The script that is executed when the mouse down event occurs. **/
	public var action_mouseDown(__getAction_mouseDown,__setAction_mouseDown) : String;
		function __getAction_mouseDown() {
			return try ScriptManager.getInstanceActionObject(this, "mouseDown").code
			catch(e:Dynamic) null;
		}
		function __setAction_mouseDown(v:String) : String {
			return ScriptManager.setInstanceScript(this, "mouseDown", v);
		}

	/** The script that is executed when the mouse up event occurs. **/
	public var action_mouseUp(__getAction_mouseUp,__setAction_mouseUp) : String;
		function __getAction_mouseUp() {
			return try ScriptManager.getInstanceActionObject(this, "mouseUp").code
			catch(e:Dynamic) null;
		}
		function __setAction_mouseUp(v:String) : String {
			return ScriptManager.setInstanceScript(this, "mouseUp", v);
		}

	/** The script that is executed when the Component is validated **/
	public var action_validate(__getAction_validate,__setAction_validate) : String;
		function __getAction_validate() {
			return try ScriptManager.getInstanceActionObject(this, "validate").code
			catch(e:Dynamic) null;
		}
		function __setAction_validate(v:String) : String {
			return ScriptManager.setInstanceScript(this, "validate", v);
		}

	//////////////////////////////////////////////////
	////            Focus Actions                 ////
	//////////////////////////////////////////////////
	/** The script that is executed when the Component is gaining focus, which must return false to cancel the action, or true to approve. It is passed the one var [focusFrom] **/
	public var action_gainingFocus(__getAction_gainingFocus,__setAction_gainingFocus) : String;
		function __getAction_gainingFocus() {
			return try ScriptManager.getInstanceActionObject(this, "gainingFocus").code
			catch(e:Dynamic) null;
		}
		function __setAction_gainingFocus(v:String) : String {
			return ScriptManager.setInstanceScript(this, "gainingFocus", v);
		}

	/** The script that is executed when the Component is losingFocus, which must return false to cancel the action, or true to approve. It is passed the one var [focusTo] **/
	public var action_losingFocus(__getAction_losingFocus,__setAction_losingFocus) : String;
		function __getAction_losingFocus() {
			return try ScriptManager.getInstanceActionObject(this, "losingFocus").code
			catch(e:Dynamic) null;
		}
		function __setAction_losingFocus(v:String) : String {
			return ScriptManager.setInstanceScript(this, "losingFocus", v);
		}

	/**
	* When a component is gaining focus, this script executes twice.
	*
	* The first time, [focusFrom] is set to the object losing focus.
	*
	* The second time, [focusFrom == this] which shows that all parents
	* have been notified of the focus change.
	**/
	public var action_focusIn(__getAction_focusIn,__setAction_focusIn) : String;
		function __getAction_focusIn() {
			return try ScriptManager.getInstanceActionObject(this, "focusIn").code
			catch(e:Dynamic) null;
		}
		function __setAction_focusIn(v:String) : String {
			return ScriptManager.setInstanceScript(this, "focusIn", v);
		}

	public var action_focusOut(__getAction_focusOut,__setAction_focusOut) : String;
		function __getAction_focusOut() {
			return try ScriptManager.getInstanceActionObject(this, "focusOut").code
			catch(e:Dynamic) null;
		}
		function __setAction_focusOut(v:String) : String {
			return ScriptManager.setInstanceScript(this, "focusOut", v);
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
