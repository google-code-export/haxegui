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

import flash.display.DisplayObject;
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
import haxegui.managers.FocusManager;
import haxegui.Haxegui;
import haxegui.Opts;
import haxegui.managers.ScriptManager;
import haxegui.Window;

import feffects.Tween;


/**
* Component Class
**/
class Component extends Sprite, implements haxegui.IMovable, implements haxegui.IToolTip
{
	/** The static component id counter **/
	private static var nextId : Int = 0;

	/** Rectangular dimensions **/
	public var box : Rectangle;

	/** The color of this component, which has different meanings per component **/
	public var color:Int;

	/** Disabled \ Enabled **/
	public var disabled(__getDisabled, __setDisabled) : Bool;

	public var dirty(__getDirty,__setDirty) : Bool;

	/** Whether the component can gain focus **/
	public var focusable : Bool;

	/** Unique component id number **/
	public var id(default,null) : Int;

	/** Text for tooltip **/
	public var text : String;

	/** Does object validate ? **/
	public var validate : Bool;

//~ public var margin : Rectangle;
//~ public var padding : Array<Float>;
//~ public var getBox : Void -> Rectangle;

	/** Current color tween in effect **/
	private var colorTween : Tween;

	/** The initial opts **/
	private var initOpts : Dynamic;

	/** Number of interval calls per second **/
	private var intervalUpdatesPerSec : Float;

	/** Last timestamp when an interval occured **/
	private var lastInterval : Float;

	/**
	*
	**/
	public function new (parent:DisplayObjectContainer=null, name:String=null, ?x:Float, ?y:Float)
	{
		super ();
		this.id = Component.nextId++;

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
		this.addEventListener (Event.ADDED, onAdded, false, 0, true);
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

		var aOps = Opts.clone(opts);
		Opts.removeFields(aOps, ["name","disabled","width","height","x","y","color","alpha","buttonMode","visible"]);
		/*
		for(f in Reflect.fields(aOps)) {
			if(Reflect.hasField(this, f)) {
				try {
					Reflect.setField(this, f, Reflect.field(aOps, f));
				} catch(e:Dynamic) {
					trace("Error on field " + f + " (type " + Std.string(Type.typeof(Reflect.field(aOps, f))) + "): " + e);
				}
			}
		}
		*/

		this.initOpts = Opts.clone(opts);
		this.dirty = true;
	}

/*
	override public function addChild(o : DisplayObject) : DisplayObject
	{
		addDisplayObjectEvents(o);
		return super.addChild(o);
	}

	override public function addChildAt(o : DisplayObject, index:Int) : DisplayObject
	{
		addDisplayObjectEvents(o);
		return super.addChildAt(o, index);
	}
*/

	/**
	* Destroy this component and all children
	*/
	public function destroy() {
		var idx : Int = 0;
		for(i in 0...numChildren) {
			var c = getChildAt(idx);
			if(Std.is(c,Component))
				(cast c).destroy();
			else
				idx++;
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
		try {
			return ScriptManager.getInstanceActionObject(this, action).code;
		}
		catch(e:Dynamic) {
			trace(e);
			return null;
		}
	}

	/**
	* Returns the code associated with this instance for the specified action.
	*
	* @param action Action name
	* @return String code
	**/
	public function getOwnAction(action:String) : String {
		return try ScriptManager.getInstanceOwnActionObject(this, action).code
		catch(e:Dynamic) null;
	}

	/**
	* Returns true if this component has an action
	* registered for the action type [action]. If this instance
	* does not have an override, the default from the style is
	* checked.
	*
	* @param action Action name
	* @return Bool true if an action exists
	**/
	public function hasAction(action:String) {
		var c = try ScriptManager.getInstanceActionObject(this, action) catch(e:Dynamic) null;
		return (c != null);
	}

	/**
	* Returns true if this component has an action registered
	* for the action type [action]. Only returns true if the
	* script is only for this instance.
	*
	* @param action Action name
	* @return Bool true if an action exists
	**/
	public function hasOwnAction(action:String) {
		return (ScriptManager.getInstanceOwnActionObject(this,action) != null);
	}

	/**
	* @todo complete focus, recurse, that is check all children's children too..
	**/
	public function hasFocus ():Bool
	{
		return if(FocusManager.getInstance().getFocus() == this) true else false;
	}

	/**
	* Returns the window this component is contained in, if any
	*
	* @return Parent window or null
	**/
	public function getParentWindow() : Window
	{
		var p = this.parent;
		while(p != null && !Std.is(p,Window))
			p = p.parent;
		return cast p;
	}

	/** Returns whether object validates **/
	public function isValid() : Bool
	{
		if(!hasAction("validate"))
			return true;
		var rv = ScriptManager.exec(this, "validate", {});
		if(rv == null) return true;
		return cast rv;
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
	* Excecute redrawing script
	**/
	public function redraw(opts:Dynamic=null) {
// 		trace(this.name + " redraw");
		ScriptManager.exec(this,"redraw", opts);
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

	/**
	* Sets the action code for the specified action name for this component.
	*
	* @param action Action name
	* @param code Action code
	**/
	public function setAction(action:String, code:String) : Void {
		ScriptManager.setInstanceScript(this, action, code);
	}

	/**
	* Starts an interval timer, which calls the "interval" action.
	*
	* @param updatesPerSecond Number of times per second the interval action will be called
	**/
	public function startInterval(updatesPerSecond : Float) : Void {
		stopInterval();
		startIntervalDelayed(updatesPerSecond, 0.0);
	}

	/**
	* Starts an interval timer, which calls the "interval" action, after waiting [wait] seconds
	*
	* @param updatesPerSecond Number of times per second the interval action will be called
	* @param wait Number of seconds to wait before the first update.
	**/
	public function startIntervalDelayed(updatesPerSecond : Float, wait : Float) : Void {
		stopInterval();
		if(updatesPerSecond < 1) return;
		if(Math.isNaN(wait)) wait = 0.0;
		lastInterval = haxe.Timer.stamp() + wait;
		intervalUpdatesPerSec = updatesPerSecond;
		this.addEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame);
	}

	/**
	* Stop the current interval timer
	**/
	public function stopInterval() : Void {
		this.removeEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame);
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
		// relatedObject is one gaining focus
		// target is object losing focus
		// currentTarget == this
 		//trace("------" + Std.string(this) + " __focusHandler");
 		//trace("__focusHandler " + (if(e.currentTarget != this) " ******* " + Std.string(e.currentTarget) else "") + " :  from " + Std.string(e.target) + " to " + Std.string(e.relatedObject));
		//var o = e.target;

		var comp : Component = asComponent(e.currentTarget);
		// first event is fired to the target about to lose focus
		if(e.currentTarget == e.target && comp != null) {
			// see if current object will relinquish focus to gainer.
			if(!comp.onLosingFocus(cast asComponentIfIs(e.relatedObject))) {
				e.preventDefault();
				e.stopImmediatePropagation();
				comp.stage.focus = comp;
				trace("Losing focus prevented by " + asComponentIfIs(e.relatedObject).name);
				return;
			}
		}

		comp = asComponent(e.relatedObject);
		// check if the object gaining focus rejects
		if(comp != null) {
			if(!comp.onGainingFocus(cast asComponentIfIs(e.relatedObject))) {
				e.preventDefault();
				e.stopImmediatePropagation();
				comp.stage.focus = comp;
				trace("Gain of focus denied by " + asComponentIfIs(e.relatedObject));
				return;
			}
		}

		// if we are the last Component in the chain, simulate the focusOut and focusIn
		//ar p =
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
		//trace("++++ " + Std.string(this) + " onFocusIn");
		//trace("onFocusIn relatedObject: " + Std.string(e.relatedObject));
		//trace("onFocusIn currentTarget: " + Std.string(e.currentTarget));
		//trace("onFocusIn target: " + Std.string(e.target));

		ScriptManager.exec(this, "focusIn", {focusFrom : e.target});
	}

	/**
	* When a component is losing focus, this event occurs
	*
	* [focusTo] is set to the object gaining focus.
	*
	**/
	private function onFocusOut(e:FocusEvent) : Void {
 		//trace("++++ " + Std.string(this) + " onFocusOut");
 		//trace("onFocusOut relatedObject: " + Std.string(e.relatedObject));
 		//trace("onFocusOut currentTarget: " + Std.string(e.currentTarget));
 		//trace("onFocusOut target: " + Std.string(e.target));
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
		//trace(here.methodName + " " + rv);
		if(rv == null || rv == true)
			return true;
		return false;
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
		if(e.target == this)
			trace("onMouseClick " + this.name + " (trgt: " + e.target + ") hasOwnAction:" + hasOwnAction("mouseClick"));
		ScriptManager.exec(this,"mouseClick", {event : e});
	}

	public function onMouseDown(e:MouseEvent) : Void
	{
		if(e.target == this)
			trace("onMouseDown " + this.name + " (trgt: " + e.target + ") hasOwnAction:" + hasOwnAction("mouseDown"));
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

	private function onEnterFrame(e:Event) : Void
	{
		var now = haxe.Timer.stamp();
		var stepsF : Float  = (now - lastInterval) * intervalUpdatesPerSec;
		var steps : Int = Math.floor( stepsF );
		lastInterval += steps / intervalUpdatesPerSec;

		for(x in 0...steps) {
			ScriptManager.exec(this,"interval",{event:e});
		}
	}


	//////////////////////////////////////////////////
	////               Actions                    ////
	//////////////////////////////////////////////////
	// redraw, mouseClick, mouseOver, mouseOut
	// mouseDown, mouseUp, validate, gainingFocus
	// losingFocus, focusIn, focusOut
	// interval


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

	//////////////////////////////////////////////////
	////               Privates                   ////
	//////////////////////////////////////////////////
	/** add the focus events to any child that is not a Component **/
	private function addDisplayObjectEvents(o : DisplayObject) {
		if(!Std.is(o, Component)) {
			removeDisplayObjectEvents(o);
			o.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, __focusHandler, false, 0, true);
			o.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, __focusHandler, false, 0, true);
			//o.addEventListener(FocusEvent.FOCUS_IN, onFocusIn, false, 0, true);
			//o.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut, false, 0, true);
		}
	}

	private function removeDisplayObjectEvents(o : DisplayObject) {
		if(!Std.is(o, Component)) {
			o.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, __focusHandler);
			o.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, __focusHandler);
			o.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			o.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
		}
	}

	//////////////////////////////////////////////////
	////               Statics                    ////
	//////////////////////////////////////////////////
	/**
	* Return the Component the DisplayObject belongs to. If the [obj] DisplayObject
	* is a Component, then it will be returned. Useful for finding what Component
	* a Sprite belongs to.
	*
	* @param obj DisplayObject or Component
	* @return Component, or null if is not a Component and does not belong to a Component.
	**/
	public static function asComponent( obj : DisplayObject ) : Component {
		if(Std.is(obj, Component))
			return cast obj;
		if(obj == null) return null;
		var p = obj.parent;
		while(p != null && !Std.is(p,Component)) {
			p = p.parent;
		}
		if(p == null)
			return null;
		return cast p;
	}

	/**
	* Return the Component the DisplayObject belongs to. If the [obj] DisplayObject
	* is a Component, then it will be returned. Useful for finding what Component
	* a Sprite belongs to.
	*
	* @param obj DisplayObject or Component
	* @return Component, or [obj] if is not a Component and does not belong to a Component.
	**/
	public static function asComponentIfIs( obj : DisplayObject ) : DisplayObject {
		if(Std.is(obj, Component))
			return obj;
		if(obj == null) return null;
		var p = obj.parent;
		while(p != null && !Std.is(p,Component)) {
			p = p.parent;
		}
		if(p == null)
			return obj;
		return p;
	}

	/**
	* Find the containing Component for any DisplayObject, if any.
	*
	* @param obj Any display object
	* @return Parent Component, or null
	**/
	public static function getParentComponent(obj : DisplayObject) : Component {
		var p = obj.parent;
		while(p != null && !Std.is(p, Component))
			p = p.parent;
		if(p == null) return null;
		return cast p;
	}
}
