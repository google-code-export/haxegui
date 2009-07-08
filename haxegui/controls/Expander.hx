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

import flash.display.Sprite;
import flash.display.MovieClip;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;

import haxegui.managers.CursorManager;
import haxegui.managers.FocusManager;
import haxegui.Opts;
import haxegui.managers.StyleManager;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;

import haxegui.toys.Arrow;
import haxegui.utils.Color;

import feffects.Tween;




/**
* Expander class, may be expanded or collapsed by the user to reveal or hide child widgets.
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
**/
class Expander extends AbstractButton
{
	public var expanded(__getExpanded,__setExpanded) : Bool;

	
	public var arrow : Arrow;
	public var label : Label;

	public var scrollTween : Tween;
	public var arrowTween : Tween;


	override public function init(opts:Dynamic=null)
	{
		box = new Rectangle(0, 0, 140, 15);
		color = cast Math.max(0, DefaultStyle.BACKGROUND - 0x202020);
		expanded = false;

		expanded = Opts.optBool(opts, "expanded", expanded);

		arrow = new Arrow(this);
		arrow.init({color: Color.darken(DefaultStyle.BACKGROUND, 16)});
		//arrow.move(arrow.box.width,arrow.box.height);
		
		label = new Label(this);
		//~ label.text = Opts.optString(opts, "label", name);
		label.init({innerData: this.name});
		label.move(20,0);
		label.mouseEnabled = false;
		label.tf.mouseEnabled = false;

		//scrollRect = new Rectangle(0, 0, box.width, box.height);
		//cacheAsBitmap = true;

		super.init(opts);

	}



	override public function onMouseClick(e:MouseEvent) {
		if(disabled) return;

		var self = this;
		var r = new Rectangle(0,0,this.stage.stageWidth,expanded?this.stage.stageHeight:0);
			
		if(scrollTween!=null)
			scrollTween.stop();
				
		if(!expanded)  
			scrollTween = new Tween(box.height, this.stage.stageHeight, 3500, r, "height", feffects.easing.Linear.easeNone);
		else
			scrollTween = new Tween(this.stage.stageHeight, box.height, 1500, r, "height", feffects.easing.Expo.easeOut);
		
		scrollTween.setTweenHandlers( function(v) { self.scrollRect = r; });

		scrollTween.start();
	


		if(arrowTween!=null)
			arrowTween.stop();
			
		arrowTween = new Tween(expanded?90:0, expanded?0:90, 500, arrow, "rotation", feffects.easing.Linear.easeNone);
			
		arrowTween.start();

		
		e.stopImmediatePropagation();
		
		expanded = !expanded;

		for(i in 2...numChildren)
//			this.getChildAt(i).visible = expanded;
			this.getChildAt(i).visible = true;
		
		//~ dirty = true;
		dispatchEvent(new Event(Event.CHANGE));
		

				
		super.onMouseClick(cast e.clone());
	}


	//////////////////////////////////////////////////
	////           Getters/Setters                ////
	//////////////////////////////////////////////////
	private function __getExpanded() : Bool {
		return this.expanded;
	}

	private function __setExpanded(v:Bool) : Bool {
		if(v == this.expanded) return v;
		this.expanded = v;
		this.dirty = true;
		return v;
	}

	override private function __setDisabled(v:Bool) : Bool {
		super.__setDisabled(v);
		if(this.disabled) {
			mouseEnabled = false;
			buttonMode = false;
		}
		else {
			mouseEnabled = Opts.optBool(initOpts,"mouseEnabled",true);
			buttonMode = Opts.optBool(initOpts,"buttonMode",true);
		}
		return v;
	}


	//////////////////////////////////////////////////
	////           Initialization                 ////
	//////////////////////////////////////////////////
	static function __init__() {
		haxegui.Haxegui.register(Expander);
	}

}
