// 
// The MIT License
// 
// Copyright (c) 2004 - 2006 Paul D Turner & The CEGUI Development Team
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


import flash.geom.Rectangle;
import flash.geom.Transform;

import flash.display.LineScaleMode;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.MovieClip;

import flash.text.TextField;

import flash.events.Event;
import flash.events.MouseEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;

import haxegui.controls.Component;
import haxegui.CursorManager;
import haxegui.StyleManager;

import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;


import feffects.Tween;
import feffects.easing.Quint;
import feffects.easing.Sine;
import feffects.easing.Back;
import feffects.easing.Bounce;
import feffects.easing.Circ;
import feffects.easing.Cubic;
import feffects.easing.Elastic;
import feffects.easing.Expo;
import feffects.easing.Linear;
import feffects.easing.Quad;
import feffects.easing.Quart;


//~ class ScrollbarButtonUp extends flash.display.MovieClip { public function new() { super(); } }


enum ScrollbarType {
	VERTICAL;
	HORIZONTAL;
}



class Scrollbar extends haxegui.controls.Component 
{
	
	public var color : UInt;
	
	var horizontal : Bool;
	
	var frame : Sprite;
	var handle : Sprite;
	var up : Sprite;
	var down : Sprite;
	
	public var scrollee : Dynamic;
	public var scroll : Float;
	
	public function new(?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float, ?horz : Bool) 
	{
		super(parent, name, x, y);
		horizontal = horz;
		
		frame = new Sprite();
		handle = new Sprite();
		up = new Sprite();
		down = new Sprite();

	}
	
	public function init(?scrollee:Dynamic)
	{
		scroll = 0;
		//~ box = new Rectangle(0,0,20,90);
		this.scrollee = scrollee;

	
	    
		//~ frame.mouseEnabled = false;
		frame.buttonMode = false;
		frame.focusRect = false;
		frame.tabEnabled = false;	
				
		frame.graphics.lineStyle (1, color - 0x141414);
		frame.graphics.beginFill (color - 0x0A0A0A);		
		frame.graphics.drawRect (0, 0, box.width, box.height - 40 );
		frame.graphics.endFill ();

		//~ var f = new ScrollbarFrame();
		//~ frame = flash.Lib.attach("ScrollbarFrame");
		frame.name = "frame";		
		//~ frame.height = box.height - 40;
		frame.y = 20;
		

		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.5, 8, 8, .75, BitmapFilterQuality.HIGH, true, false, false);
		frame.filters = [shadow];
    
		this.addChild(frame);
		

		
		
		handle.buttonMode = true;
		handle.focusRect = true;
		handle.tabEnabled = true;
		
		handle.name = "handle";
		handle.y = 20;

		redrawHandle();



		shadow = new DropShadowFilter (0, 0, StyleManager.DROPSHADOW, 0.75, horizontal ? 8 : 0, horizontal ? 0 : 8, 0.75, BitmapFilterQuality.LOW, false, false, false);
		handle.filters = [shadow];

		handle.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
		handle.addEventListener(MouseEvent.ROLL_OUT, onRollOut);

		this.addChild(handle);


		
		up.buttonMode = true;
		up.focusRect = true;
		up.tabEnabled = true;		
		up.name = "up";
		up.graphics.lineStyle (2, color - 0x141414, 1, LineScaleMode.NONE );

   		  var colors = [ color - 0x141414, color | 0x323232 ];
   		  if(horizontal)
			colors = [ color | 0x323232, color - 0x141414 ];
		  var alphas = [ 100, 100 ];
		  var ratios = [ 0, 0xFF ];
		  var matrix = new flash.geom.Matrix();
		  matrix.createGradientBox(20, 20, Math.PI, 0, 0);
		  up.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );

		//~ up.graphics.beginFill (color);
		up.graphics.drawRect (0, 0, 20, 20 );
		up.graphics.endFill ();
		
		//~ up = flash.Lib.attach("scrollbarButtonUp");
		//~ up = new ScrollbarButtonUp();
		
		up.y=0;

		this.addChild(up);
		
		
		down.buttonMode = true;
		down.focusRect = true;
		down.tabEnabled = true;			
		down.name = "down";
		down.graphics.lineStyle (2, color - 0x141414, 1, LineScaleMode.NONE );
		//~ down.graphics.beginFill (color);
		down.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );
		down.graphics.drawRect (0, 0, 20, 20 );
		down.graphics.endFill ();
		
		

		//~ down = flash.Lib.attach("scrollbarButtonDown");
		
		down.name = "down";
		down.mouseEnabled = true;
		down.y = box.height - 20;

		//~ var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.5, 4, 4, .75, BitmapFilterQuality.HIGH, true, false, false);
		down.filters = [shadow];

		this.addChild(down);



		this.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
		this.addEventListener(MouseEvent.ROLL_OUT, onRollOut);

		this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);



		//
		parent.addEventListener(ResizeEvent.RESIZE, onResize);
	
	
	
	}//init



	/*
	 * 
	 * 
	 * 
	 * 
	 */
	public function onResize(e:Dynamic) 
	{
		
		//~ if(box.isEmpty())
		if(Std.is(e, ResizeEvent))
			box = untyped parent.box.clone();
		//~ var pbox = cast(parent, Component).box;
		//~ box = pbox.clone() ;
		//~ box.inflate(-10,-24);
		//~ box.inflate(-10,-4);
	
		frame.graphics.clear();
		frame.graphics.lineStyle (1, color - 0x141414);
		frame.graphics.beginFill (color - 0x0A0A0A);		
		
		if(horizontal) 
		{
			this.y = box.height + 20;
			down.y = box.width - 20;
			frame.graphics.drawRect (0, 0, 20, box.width - 40 );
		}
		else
		{
			this.x = box.width ;
			down.y = box.height - 20 ;
			
			frame.graphics.drawRect (0, 0, 20, box.height - 40 );
			//~ adjust();
					
			if(Std.is(scrollee, DisplayObject))
			{
				if(handle.y>20)
					handle.y = scroll * ( frame.height - handle.height + 2) + 20;
			}
				
		}

		frame.graphics.endFill ();
		
		//
		redrawHandle();

		//~ var transform = scrollee.transform;
		//~ var bounds = transform.pixelBounds.clone();
		//~ handle.y = (.5*bounds.height-40) * scroll ;
		//~ scroll = (handle.y-20) / (frame.height - 40 + 2) ;

		if(Std.is(e, ResizeEvent))
			e.updateAfterEvent();
		
	}
	
    public function onRollOver(e:MouseEvent)  : Void	
	{
		if(e.target == handle)
			redrawHandle(color | 0x4D4D4D);
			
	    CursorManager.getInstance().setCursor(Cursor.HAND);
		//~ Tweener.addTween(e.target, {_brightness:.5, time:.15, transition:"linear"});
    }

    public function onRollOut(e:MouseEvent) 
	{

		if(!e.buttonDown) 
			{
			
			if(e.target == handle)
				redrawHandle();
			flash.Lib.current.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			e.target.stopDrag();		
			//~ Tweener.addTween(e.target, {_brightness:0, time:.35, transition:"linear"});		
			}
			//~ Tweener.addTween(e.target, {_brightness:0, time:.35, transition:"linear"});		
    }	
	
	
	public function onMouseWheel(e:MouseEvent)
	{

			redrawHandle(color | 0x666666);

			//~ var y = handle.y + 50 * e.delta;
			var y = handle.y + 50 * -e.delta;
			if( y < 20 ) y = 20;
			if( y > frame.height - handle.height + 20) y = frame.height - handle.height + 20;
			//~ e.target.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			//~ var t = new Tween( handle.y, handle.y - 50, 500, handle, "y", Linear.easeNone );
			var t = new Tween( handle.y, y, 1000, handle, "y", Expo.easeOut );
			var scope = this;
			t.setTweenHandlers( function ( e ) { scope.adjust(); } );
			t.start();

	}
	
	
	
	/**
	 * onMouseDown
	 * 
	 * 
	 */
    public function onMouseDown(e:MouseEvent) 
	{
			//~ redrawHandle(color | 0x4D4D4D);
		
		switch(e.target)
		{
		case handle:
		
			redrawHandle( color | 0x666666);

			if(horizontal) 
				e.target.startDrag(false,new Rectangle(0,up.height-2, 0, box.width - 2*down.height - handle.height + 4));
			else
				e.target.startDrag(false,new Rectangle(0,up.height-2, 0, box.height - 2*down.height - handle.height + 4));
				
			//~ e.target.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			flash.Lib.current.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

			CursorManager.getInstance ().setCursor (Cursor.DRAG);

		case up:
			
			var y = handle.y - 50;
			if( y < 20 ) y = 20;
			//~ e.target.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			//~ var t = new Tween( handle.y, handle.y - 50, 500, handle, "y", Linear.easeNone );
			var t = new Tween( handle.y, y, 1000, handle, "y", Expo.easeOut );
			var scope = this;
			t.setTweenHandlers( function ( e ) { scope.adjust(); } );
			t.start();
			//~ t.setTweenHandlers( function ( e ) scope.update( sprite, e ) );

			CursorManager.getInstance ().setCursor (Cursor.HAND2);
		
		case down:
			var y = handle.y + 50;
			if( y > frame.height - handle.height + 20) y = frame.height - handle.height + 20;
			
	
			//~ e.target.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			var t = new Tween( handle.y, y, 1000, handle, "y", Expo.easeOut );
			var scope = this;
			t.setTweenHandlers( function ( e ) { scope.adjust(e); } );
			t.start();

			CursorManager.getInstance ().setCursor (Cursor.HAND2);

		case frame:
			CursorManager.getInstance ().setCursor (Cursor.HAND2);

			var y = e.target.mouseY ;
			if(y+handle.height+20 > frame.height ) y = frame.height - handle.height + 20;
			
			var t = new Tween( handle.y, y, 500, handle, "y", Back.easeInOut );
			var scope = this;
			t.setTweenHandlers( function ( e ) { scope.adjust(e); } );
			t.start();

			haxe.Timer.delay( function(){CursorManager.getInstance ().setCursor (Cursor.DRAG);}, 500 );
			
			if(horizontal) 
				handle.startDrag(false,new Rectangle(0,up.height-2, 0, box.width - 2*down.height - handle.height + 4));
			else
				handle.startDrag(false,new Rectangle(0,up.height-2, 0, box.height - 2*down.height - handle.height + 4));
				
			flash.Lib.current.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

				
		}
		adjust();
    //~ e.stopImmediatePropagation ();
    e.updateAfterEvent ();


	}	


	public function onEnterFrame(e:Event)
	{


		switch(e.target)
		{
			case up:
				//~ handle.y -= ( frame.height - handle.height ) / 20 ;
				handle.y -=2 ;
			case down:
		//~ }		handle.y += ( frame.height - handle.height ) / 20 ;
		}		handle.y ++ ;

		adjust();
	}
	

    public function onMouseUp(e:MouseEvent) 
	{		
		if(e.target.hitTestObject( CursorManager.getInstance().getCursor() ))
			{
			//~ redrawHandle(color | 0x4D4D4D);
			CursorManager.getInstance().setCursor (Cursor.HAND);	    
			}
		
	}	


	public function onMouseMove(e:MouseEvent)
	{
		//~ if(e.buttonDown) 
			adjust();
	}
	
	
	/**
	 * 
	 * 
	 * 
	 */
	public function adjust(?e:Dynamic)
	{
		if(!scrollee) return;

		if(scroll<0 || handle.y < 20)
		{
			scroll=0;
			handle.y = 20;
			return;
		}


		if(scroll>1 || handle.y > frame.height - handle.height + 20)
		{
			scroll=1;
			handle.y = frame.height - handle.height + 20;
			return;
		}
		

		if(Std.is(scrollee, TextField))
		{
			scroll = (handle.y-20) / (frame.height - handle.height + 2) ;
			if(horizontal) 
				scrollee.scrollH = scrollee.maxScrollH * scroll;
			else
				scrollee.scrollV = scrollee.maxScrollV * scroll;
			
			return;
		}
					
		if(Std.is(scrollee, DisplayObject))
		{
			if(scrollee.scrollRect==null || scrollee.scrollRect.isEmpty()) return;
			
			var rect = scrollee.scrollRect.clone();
			
			var transform = scrollee.transform;
			var bounds = transform.pixelBounds.clone();
			
			scroll = (handle.y-20) / (frame.height - handle.height + 2) ;
			
			if(horizontal) 
			{
				rect.x = ( bounds.width - rect.width ) * scroll ;
			}
			else
			{
				rect.y = ( bounds.height - rect.height ) * scroll ;
			}
			
			scrollee.scrollRect = rect;
			//~ trace(Std.int(scrollee.scrollRect.y)+"/"+(bounds.height)+" "+Std.int(100*scroll)+"% "+rect);
		}

	//~ if(Std.is(e, Event))
		//~ e.updateAfterEvent();

	}//adjust



	/**
	 * 
	 * 
	 * 
	 */
	function redrawHandle(?color:UInt)
	{
		if(color == 0)
			color = this.color;
		//~ var h = 20 + .5*(frame.height - handle.height); 
		var h = 20 + .5*(frame.height - handle.height + 20); 

		handle.graphics.clear();
		handle.graphics.lineStyle (2, color - 0x141414, 1, LineScaleMode.NONE);

   		  var colors = [ color - 0x141414, color | 0x323232 ];
   		  if(horizontal)
			colors = [ color | 0x323232, color - 0x141414 ];
		  var alphas = [ 100, 100 ];
		  var ratios = [ 0, 0xFF ];
		  var matrix = new flash.geom.Matrix();
		  matrix.createGradientBox(20, h, Math.PI, 0, 0);
		  handle.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );

		//~ handle.graphics.beginFill (color);
		handle.graphics.drawRect (0, 0, 20, h );
		handle.graphics.endFill ();
	}
	
}//Scrollbar
