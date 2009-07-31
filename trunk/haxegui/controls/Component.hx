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

//{{{ Imports
package haxegui.controls;

import flash.accessibility.Accessibility;
import flash.accessibility.AccessibilityProperties;
import flash.accessibility.AccessibilityImplementation;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;

import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.Haxegui;
import haxegui.managers.CursorManager;
import haxegui.managers.FocusManager;
import haxegui.managers.ScriptManager;
import haxegui.managers.TooltipManager;
import haxegui.Window;

import haxegui.utils.Size;
import haxegui.utils.Color;
import haxegui.utils.Opts;

import feffects.Tween;
//}}}


/**
*
* Component is the basic protoype for all components.<br/>
* <p>It is not an abstract class, in a sense, it is amorphic, its visual appearance can easily and dynamically change at runtime.</p>
* <p>It derives from [Sprite], so all the flash api drawing functions apply, but take a look at [redraw()] for what you more you can do.</p>
* <p>Each component carries around not only an id, but also a [box], its the [Rectangle] that will be used for drawing calculations.</p>
* <p>Likewise, the following actions can be used along with normal event listeners:
* validate, interval, mouseClick, mouseOver, mouseOut, mouseDown, mouseUp, gainingFocus, losingFocus, focusIn, focusOut</p>
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.2
*
*
*/
class Component extends Sprite, implements IMovable, implements IToolTip, implements ITween, implements IComposite
{
	////////////////////////////////////////////////////////////////////////////
	//{{{ Members

	// Static members
	/** The static component id counter **/
	private static var nextId : Int = 0;


	// Private members
	/** Current color tween in effect **/
	private var colorTween : Tween;

	/** Current position tween in effect **/
	private var positionTween : Tween;


	/** The initial opts **/
	private var initOpts : Dynamic;

	/** Number of interval calls per second **/
	private var intervalUpdatesPerSec : Float;

	/** Last timestamp when an interval occured **/
	private var lastInterval : Float;


	// Public members
	public var isTweening : Bool;

	/** Rectangular dimensions **/
	public var box : Rectangle;
	public var minSize : Size;

	/** The color of this component, which has different meanings per component **/
	public var color : UInt;

	/** Disabled \ Enabled **/
	public var disabled(__getDisabled, __setDisabled) : Bool;

	/** Flag for when component needs a redraw **/
	public var dirty(__getDirty,__setDirty) : Bool;

	/** Whether the component can gain focus **/
	public var focusable : Bool;

	/** Unique component id number **/
	public var id(default,null) : Int;

	/** Reference for tooltip **/
	public var tooltip : Tooltip;

	/** Component description for tooltip \ accessbility **/
	public var description : String;

	/** Does object validate ? **/
	public var validates : Bool;

	/** Fit horizontaly to parent **/
	public var fitH : Bool;

	/** Fit verticaly to parent **/
	public var fitV : Bool;

	public var allowedParents : Array<Class<Dynamic>>;
	//}}}
	////////////////////////////////////////////////////////////////////////////


	////////////////////////////////////////////////////////////////////////////
	//{{{ Constructor
	/**
	* The common constructor for all components.<br>
	*
	* Each component is given a unique id, it then gets his name either by parameter, or by its class name.<br>
	*
	* Next the constructor sets some variables to default, like disabled to false, and focusable to true,
	* and registers all event listeners, component is moved to position, and is waiting to get more properties at init().
	*
	* @param DisplayObjectContainer to attach to, will default to root
	* @param Component's name
	* @param Horizontal position relative to parent
	* @param Vertical position relative to parent
	**/
	public function new (parent:DisplayObjectContainer=null, name:String=null, ?x:Float, ?y:Float) {
		super ();
		this.id = Component.nextId++;

		color = Color.MAGENTA;
		box = new Rectangle();

		tabEnabled = mouseEnabled = true;
		buttonMode = false;
		focusable = true;
		doubleClickEnabled = true;
		disabled = false;

		// name from given parameter or classname and id
		if(name!=null)
		this.name = name;
		else
		this.name = Type.getClassName(Type.getClass(this)).split(".").pop() + id;

		// tooltip text
		description = this.name;

		// attach to parent
		if(parent!=null)
		parent.addChild(this);
		else
		flash.Lib.current.addChild(this);

		//
		move(x,y);

		// Listeners
		this.addEventListener (Event.ADDED, onAdded, false, 0, true);
		this.addEventListener (ResizeEvent.RESIZE, onResize, false, 0, true);
		this.addEventListener (MouseEvent.CLICK, onMouseClick, false, 0, true);
		this.addEventListener (MouseEvent.DOUBLE_CLICK, onMouseDoubleClick, false, 0, true);
		this.addEventListener (MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		this.addEventListener (MouseEvent.MOUSE_UP,   onMouseUp, false, 0, true);

		this.addEventListener (MouseEvent.MOUSE_OVER, onRollOver, false, 0, true);
		this.addEventListener (MouseEvent.MOUSE_OUT,  onRollOut, false, 0, true);

		this.addEventListener (MouseEvent.MOUSE_WHEEL,  onMouseWheel, false, 0, true);
		this.addEventListener (KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
		this.addEventListener (KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
		this.addEventListener (FocusEvent.KEY_FOCUS_CHANGE, __focusHandler, false, 0, true);
		this.addEventListener (FocusEvent.MOUSE_FOCUS_CHANGE, __focusHandler, false, 0, true);
		this.addEventListener (FocusEvent.FOCUS_IN, onFocusIn, false, 0, true);
		this.addEventListener (FocusEvent.FOCUS_OUT, onFocusOut, false, 0, true);

	}
	//}}}
	////////////////////////////////////////////////////////////////////////////


	////////////////////////////////////////////////////////////////////////////
	//{{{ Functions
	/**
	* Initialize a component<br>
	*
	* When init() is called, the component overrides any default properties, and sets any new, it is ready draw to screen,
	* and sets the dirty flag to true.
	*
	* Writing in haxe, it is true to assume that the component and all his children have finished initializing and are on screen by the next line of code,
	* in xml that is not the case, please use the onLoaded action for that.
	*
	* <pre class="code haxe">
	* var c = new Component();
	* c.init({});
	* </pre>
	*
	* The function does'nt return anything, but it's still possible in haxe to do:
	* <pre class="code haxe">
	* var c = new Component().init({});
	* </pre>
	*
	* Note that hscript does'nt support dynamic objects, so just set any needed property manually:
	* <pre class="code haxe">
	* var c = new Component();
	* c.box = new Size(100,40).toRect();
	* c.color = 0xff00ff;
	* c.init();
	* </pre>
	*
	* @param opts Initial options object
	*/
	public function init(opts:Dynamic=null) {
		if(opts == null || !Reflect.isObject(opts)) opts = {};
		this.name = Opts.optString(opts, "name", this.name);
		this.description = Opts.optString(opts, "description", this.description);
		this.disabled = Opts.optBool(opts, "disabled", false);
		this.box.width = Opts.optFloat(opts, "width", this.box.width);
		this.box.height = Opts.optFloat(opts, "height", this.box.height);
		this.x = Opts.optFloat(opts, "x", this.x);
		this.y = Opts.optFloat(opts, "y", this.y);
		this.color = Opts.optInt(opts, "color", this.color);
		this.alpha = Opts.optFloat(opts, "alpha", this.alpha);
		this.buttonMode = Opts.optBool(opts, "buttonMode", false);
		this.visible = Opts.optBool(opts, "visible", true);
		this.fitH = Opts.optBool(opts,"fitH", false);
		this.fitV = Opts.optBool(opts,"fitV", false);


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

		var accessProps = new AccessibilityProperties();
		accessProps.name = name;
		accessProps.description = description;
		this.accessibilityProperties = accessProps;

		this.initOpts = Opts.clone(opts);
		this.dirty = true;

	}

	/*
	override public function addChild(o : DisplayObject) : DisplayObject {
	addDisplayObjectEvents(o);
	return super.addChild(o);
	}

	override public function addChildAt(o : DisplayObject, index:Int) : DisplayObject {
	addDisplayObjectEvents(o);
	return super.addChildAt(o, index);
	}
	*/

	/**
	* Remove all children
	*/
	public function removeChildren() : Void {
		for(child in this)
		if(Std.is(child, Component))
		(cast child).destroy();
		else
		removeChild(child);
	}

	public function swapParent(np:DisplayObjectContainer) : Void {
		if(np==null) throw "new parent is null";
		np.addChild(this);
		parent.removeChild(this);
	}

	public function swapChildrenVisible(c:DisplayObject, d:DisplayObject) {
		c.visible = !c.visible;
		d.visible = !d.visible;
	}
	
	public function swapChildrenVisibleAt(i:Int, j:Int) {
		swapChildrenVisible(getChildAt(i), getChildAt(j));
	}
	/**
	* Destroy this component and all children
	*/
	public function destroy() : Void {
		removeChildren();
		if(this.parent != null)
		this.parent.removeChild(this);
		//~ flash.system.System.gc();
	}

	/**
	* Returns the code associated with the specified action. If this instance
	* does not have a script, the default from the upstyle is returned.
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
	* Returns the window this component is contained in, if any
	*
	* @return Parent [Window] or null
	**/
	public function getParentWindow() : Window {
		var p = this.parent;
		while(p != null && !Std.is(p,Window)) {
			p = p.parent;
		}
		return cast p;
	}

	public function getParentContainer() : Dynamic {
		for(i in ancestors())
		if(Std.is(i, haxegui.containers.IContainer)) return i;
		return null;
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
	public function hasAction(action:String) : Bool {
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
	public function hasOwnAction(action:String) : Bool {
		return (ScriptManager.getInstanceOwnActionObject(this,action) != null);
	}

	/**
	* @todo
	**/
	public function hasFocus() : Bool {
		return FocusManager.getInstance().getFocus() == this ? true : false;
	}


	/** Returns whether object validates **/
	public function isValid() : Bool {
		if(!hasAction("validate"))
		return true;
		var rv = ScriptManager.exec(this, "validate", {});
		if(rv == null) return true;
		return cast rv;
	}

	/**
	* @todo
	*/
	public function clone() : Dynamic {
		var type = Type.getClass(this);
		var inst = Type.createInstance(type, [parent, name+"_clone", x, y]);
		//inst.init(Opts.clone(initOpts));
		Reflect.callMethod( inst, inst.init, [Opts.clone(initOpts)] );
		trace(inst);

		return inst;
	}

	/**
	* Move to specific location.
	* @param x Horizontal offset relative to parent
	* @param y Vertical offset relative to parent
	**/
	public function moveTo(x : Float, y : Float) : Void	{
		var event = new MoveEvent(MoveEvent.MOVE, this.x, this.y);

		this.x = x;
		this.y = y;

		box.x = x;
		box.y = y;

		if(Haxegui.gridSnapping) {
			box.x = this.x -= this.x % Haxegui.gridSpacing;
			box.y = this.y -= this.y % Haxegui.gridSpacing;
		}

		if(!isTweening)
		dispatchEvent(event);
	}



	/**
	* Move relative to current location.
	* @param x Horizontal offset relative to current position
	* @param y Vertical offset relative to current position
	**/
	public function move(x : Float, y : Float) : Void {
		moveTo(this.x + x, this.y + y);
	}

	/** Move to absolute position [Point], relative to parent **/
	public function moveToPoint(p:Point) : Void {
		moveTo(p.x, p.y);
	}

	/** Move by [Point], relative to current position **/
	public function movePoint(p:Point) : Void {
		moveToPoint(p.add(new Point(x,y)));
	}

	/** Snap position to grid
	* @see [Haxegui.gridSpacing]
	*/
	public function snap() {
		move(- x % Haxegui.gridSpacing, - y % Haxegui.gridSpacing);
	}

	/** Move to parent's center **/
	public function center() {
		moveTo(Std.int((cast parent).box.width-box.width)>>1, Std.int((cast parent).box.height-box.height)>>1);
	}

	/**
	* Resize box to [Size]
	* @return Rectangle new size
	**/
	public function resize(b:Size) : Rectangle	{

		var event = new ResizeEvent(ResizeEvent.RESIZE);

		event.oldWidth = box.width;
		event.oldHeight = box.height;

		box = b.setAtLeastZero().toRect();

		if(Haxegui.gridSnapping) {
			box.width = box.width - box.width % Haxegui.gridSpacing;
			box.height = box.height - box.height % Haxegui.gridSpacing;
		}

		dispatchEvent(event);

		return box;
	}

	////////////////////////////////////////////////////////////////////////////
	// Layering function
	////////////////////////////////////////////////////////////////////////////
	/**
	* Raise one layer
	* @return Int new depth
	**/
	public function raise() : Int {
		var d = Std.int(Math.max(0, Math.min(parent.numChildren-1, parent.getChildIndex(this)+1)));
		parent.setChildIndex(this, d);
		return d;
	}

	/**
	* Lower one layer
	* @return Int new depth
	**/
	public function lower() : Int {
		var d = Std.int(Math.max(0, Math.min(parent.numChildren-1, parent.getChildIndex(this)-1)));
		parent.setChildIndex(this, d);
		return d;
	}

	/**
	* Raise to top layer
	* @return Int new depth
	**/
	public function toFront() : Int {
		parent.setChildIndex(this, parent.numChildren-1);
		//return parent.numChildren-1;
		return parent.getChildIndex(this);
	}

	/**
	* Lower to bottom
	* @return Void
	**/
	public function toBack() : Void {
		parent.setChildIndex(this, 0);
	}



	////////////////////////////////////////////////////////////////////////////
	// Iterators and child matching functions
	////////////////////////////////////////////////////////////////////////////

	/**
	* Returns iterator of all children.
	* <pre class="code haxe">
	* if(this.haxeNext())
	*	for(child in this)
	*	 ...
	* </pre>
	* @return Iterator<DisplayObject> Iterator for children
	*/
	public function iterator() : Iterator<DisplayObject> {
		var l = new List<DisplayObject>();
		for(i in 0...numChildren)
		l.add(getChildAt(i));
		return l.iterator();
	}

	/**
	* Returns iterator of all ancestors.
	* Example:
	* 	for(parent in component.ancestors())
	*
	* @return Iterator<DisplayObject> Iterator for parents
	*/
	public function ancestors() : Iterator<DisplayObject> {
		var l = new List<DisplayObject>();
		var p = parent;
		while(p!=null) {
			l.add(p);
			p = p.parent;
		}
		return l.iterator();
	}

	/** @return First child as [DisplayObject] **/
	public function firstChild() : DisplayObject {
		return getChildAt(0);
	}

	/** @return True when component has no children **/
	public function isEmpty() : Bool {
		return firstChild() == null;
	}

	/** @return The previous sibling in the display list **/
	public function prevSibling() : DisplayObject {
		var p = Component.asComponent(parent);
		for(i in p)
		if(i==this)
		if(p.getChildIndex(this)>0) return p.getChildAt(p.getChildIndex(this)-1);
		return null;
	}

	/** @return Tet next sibling in the display list **/
	public function nextSibling() : DisplayObject {
		var p = Component.asComponent(parent);
		for(i in p)
		if(i==this)
		if(p.getChildIndex(this)<p.numChildren) return p.getChildAt(p.getChildIndex(this)+1);
		return null;
	}

	/** @return Returns a child by given id number **/
	public function getChildById(id:Int) : DisplayObject {
		for(i in this)
		if(Std.is(i, Component))
		if((cast i).id==id) return i;
		return null;
	}

	/**
	* Returns an iterator for all children of type.
	* @param c Class to match
	* @return All children of type [c]
	*/
	public function getElementsByClass(c:Class<Dynamic>) : Iterator<Dynamic> {
		var l = new List<Dynamic>();
		for(i in this)
		if(Std.is(i, c))
		l.add(i);
		return l.iterator();
	}

	/**
	* @param newChild Child to add
	* @param oldChild Child to replace
	* @return Reference to new child
	**/
	public function replaceChild(newChild:Component, oldChild:Component) : Component {
		var i = getChildIndex(oldChild);
		oldChild.destroy();
		setChildIndex(newChild, i);
		return newChild;
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
		//~ this.addEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame);
		this.addEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame, false, 200, true);
	}

	/**
	* Stop the current interval timer
	**/
	public function stopInterval() : Void {
		this.removeEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame);
	}

	override public function toString() : String {
		return this.name + "[" + Type.getClassName(Type.getClass(this)) + "]";
	}

	/**
	* Stops the current(if there is one), and creates a new color tween
	* <pre class="code haxe">
	* this.updateColorTween( new feffects.Tween(0, 100, 1000, feffects.easing.Expo.easeOut ) );
	* </pre>
	* @param t The [Tween] to use
	* @todo rgb color transformation
	**/
	public function updateColorTween(?t : Tween = null) : Void {
		var me = this;
		var colorTrans = new ColorTransform();
		if(colorTween != null)
		colorTween.stop();
		colorTween = t;
		if(t==null) return;
		colorTween.setTweenHandlers(
		function(v) {
			//~ if(me.dirty) return;
			colorTrans.redOffset =
			colorTrans.greenOffset =
			colorTrans.blueOffset = v;
			me.transform.colorTransform = colorTrans;
		},
		function(v){
			me.colorTween = null;
			colorTrans = null;
		}
		);
		colorTween.start();
	}

	/**
	* Stops the old position tween and assign a new one.
	* <pre class="code haxe">
	* this.updatePositionTween( new feffects.Tween(0, 1, 1000, feffects.easing.Expo.easeOut ), new Point(x,y));
	* </pre>
	* @param t Tween to use
	* @param p Relative destination
	* @param f Optional function called on update
	* @return Void
	*/
	public function updatePositionTween(?t:Tween=null, ?p:Point, ?f:Float->Void) : Void {
		var me = this;
		var oldPos = new Point(this.x,this.y);
		if(positionTween != null)
		positionTween.stop();
		positionTween = t;
		if(t==null) return;
		positionTween.setTweenHandlers(
		function(v) {
			var pos = Point.interpolate(p, new Point(), v);
			pos = pos.add(oldPos);
			me.isTweening = true;
			me.moveTo(pos.x, pos.y);
			//~ me.x = pos.x;
			//~ me.y = pos.y;
			if(f!=null) f(v);
		},
		function(v) {
			me.positionTween = null;
			me.isTweening = false;
		}
		);
		positionTween.start();
	}

	//////////////////////////////////////////////////
	////               Events                     ////
	//////////////////////////////////////////////////
	//{{{
	/** Triggered by addChild() or addChildAt() **/
	public function onAdded(e:Event) {}

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
				#if debug
				trace("Losing focus prevented by " + asComponentIfIs(e.relatedObject).name);
				#end
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
				#if debug
				trace("Gain of focus denied by " + asComponentIfIs(e.relatedObject));
				#end
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
	* @param e the [FocusEvent]
	**/
	public function onFocusIn(e:FocusEvent) {
		if(disabled) return;
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
	* @param e the [FocusEvent]
	**/
	private function onFocusOut(e:FocusEvent) : Void {
		if(disabled) return;
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
	*
	* @param from the [InteractiveObject] who lost focus
	* @return Bool wheter the component will take focus
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
	* @param losingTo the [InteractiveObject] who is currently getting focused
	* @return Bool true to allow change, false to prevent focus change
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
		if(CursorManager.getInstance().lock) return;
		if(description!=null) TooltipManager.getInstance().create(this);
		ScriptManager.exec(this,"mouseOver", {event : e});
	}

	/** onRollOut Event **/
	public function onRollOut(e:MouseEvent) : Void
	{
		if(CursorManager.getInstance().lock) return;
		if(description!=null) TooltipManager.getInstance().destroy();
		ScriptManager.exec(this,"mouseOut", {event : e});
	}


	/** Mouse double-click **/
	public function onMouseDoubleClick(e:MouseEvent) : Void
	{
		#if debug
		if(e.target == this)
		trace("onMouseDoubleClick " + this.name + " (trgt: " + e.target + ") hasOwnAction:" + hasOwnAction("mouseDoubleClick"));
		#end
		ScriptManager.exec(this,"mouseDoubleClick", {event : e});
	}

	/** Mouse click **/
	public function onMouseClick(e:MouseEvent) : Void
	{
		#if debug
		trace(e);
		#end
		if(description!=null) TooltipManager.getInstance().destroy();
		ScriptManager.exec(this,"mouseClick", {event : e});
	}

	/** Mouse Down **/
	public function onMouseDown(e:MouseEvent) : Void
	{
		#if debug
		trace(e);
		#end

		if(e.ctrlKey) {
			e.stopImmediatePropagation();
			// dont transform transformers
			if(Std.is(this, haxegui.toys.Transformer) || Std.is(this.parent, haxegui.toys.Transformer)) return;
			var t = new haxegui.toys.Transformer(this);
			t.init();
			var p = (cast this).localToGlobal( new flash.geom.Point(this.x, this.y) );
			//~ t.moveTo( p.x - this.x - t.handleSize, p.y - this.y - t.handleSize );
			t.x = p.x - this.x - t.handleSize;
			t.y = p.y - this.y - t.handleSize;
			// no point in doing the normal action, user wants to transform
			return;
		}

		if(description!=null) TooltipManager.getInstance().destroy();
		ScriptManager.exec(this,"mouseDown", {event : e});
	}

	/** Mouse Up **/
	public function onMouseUp(e:MouseEvent) : Void	{
		ScriptManager.exec(this,"mouseUp", {event : e});
	}

	/** Mouse Wheel **/
	public function onMouseWheel(e:MouseEvent) : Void	{
		ScriptManager.exec(this,"mouseWheel", {event : e});
	}

	/** Overiden in sub-classes **/
	public function onKeyDown(e:KeyboardEvent) : Void {}

	/** Overiden in sub-classes **/
	public function onKeyUp(e:KeyboardEvent) : Void {}

	/** Overiden in sub-classes **/
	public function onResize(e:ResizeEvent) : Void {}

	private function onEnterFrame(e:Event) : Void {
		var now = haxe.Timer.stamp();
		var stepsF : Float  = (now - lastInterval) * intervalUpdatesPerSec;
		var steps : Int = Math.floor( stepsF );
		lastInterval += steps / intervalUpdatesPerSec;

		for(x in 0...steps) {
			ScriptManager.exec(this,"interval",{event:e});
		}
	}
	//}}}

	//////////////////////////////////////////////////
	////               Actions                    ////
	//////////////////////////////////////////////////
	// redraw, validate, interval
	// mouseClick, mouseOver, mouseOut, mouseDown, mouseUp
	// gainingFocus, losingFocus, focusIn, focusOut

	/**
	* Excecute redrawing script
	* <pre class="code haxe">
	* // example of sending variables to hscript redraw action
	* var com = new Component();
	* var opts = { color: Color.RED, size: new Size(100,40) };
	* com.setAction("redraw", "
	* 	this.graphics.beginFill(color);
	*	this.graphics.drawRect(0,0,size.width,size.height);
	*	this.graphics.endFill();
	* ");
	* com.redraw(opts);
	* </pre>
	* @param opts An [Opts] object to pass the redrawing script
	**/
	public function redraw(opts:Dynamic=null) {
		ScriptManager.exec(this,"redraw", opts);
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
		for(c in this) {
			if(Std.is(c,Component))
			(cast c).disabled = v;
		}
		return v;
	}

	////////////////////////////////////////////////////////////////////////////
	//{{{ Privates
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
	//}}}
	////////////////////////////////////////////////////////////////////////////


	////////////////////////////////////////////////////////////////////////////
	//{{{ Static Functions
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

	/**
	* @return Bitmap a [Bitmap] copy of the component
	*/
	public static function rasterize(content:DisplayObjectContainer,rect:Rectangle=null,precision:Float=1.0) : flash.display.Bitmap {
		if (rect==null)
		//~ rect = content.getBounds(content);
		if(Std.is(content, Component))
		rect = (cast content).box;

		if(rect.isEmpty()) return null;
		var tmp:Rectangle = rect.clone();
		tmp.inflate((precision - 1) * rect.width, (precision - 1) * rect.height);

		var data = new BitmapData(cast rect.width * precision,cast rect.height * precision, true, 0x00000000);
		data.draw(content, new flash.geom.Matrix(precision, 0, 0, precision, -rect.x * precision, -rect.y * precision),
		null, null, null,true);

		var bitmap = new flash.display.Bitmap(data);
		bitmap.name ="contentBitmap";
		//~ bitmap.x = tmp.x;
		//~ bitmap.y = tmp.y;
		bitmap.scaleX = bitmap.scaleY = 1 / precision;

		//~ for (i in 0...content.numChildren)
		//~ {
		//~ content.getChildAt(i).visible = false;
		//~ }
		//~ content.addChild(bitmap);

		return bitmap;
	}
	//}}}
	////////////////////////////////////////////////////////////////////////////

	//}}}
	////////////////////////////////////////////////////////////////////////////
}
