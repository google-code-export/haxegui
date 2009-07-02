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

import feffects.Tween;

import flash.geom.Rectangle;
import flash.geom.Transform;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;

import haxegui.Component;
import haxegui.managers.CursorManager;
import haxegui.Opts;
import haxegui.managers.StyleManager;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;


/**
*
* ProgressBarIndicator class
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class ProgressBarIndicator extends Component
{
	override public function init(opts:Dynamic=null) {
		color = DefaultStyle.PROGRESS_BAR;
		super.init(opts);
		
		mouseEnabled = false;
	}
		
		static function __init__() {
		haxegui.Haxegui.register(ProgressBarIndicator);
	}

}


/**
*
* ProgressBar class
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class ProgressBar extends Component
{
	public var bar : ProgressBarIndicator;
	public var mazk : Shape;
	public var label : Label;
	
	public var progress : Float;


	override public function init(opts:Dynamic=null)
	{
		progress = .5;
		color = DefaultStyle.BACKGROUND;
		box = new Rectangle(0,0,140,20);	
		
		super.init(opts);

	    progress = Opts.optFloat(opts, "progress", progress);
	    
		var shadow = new flash.filters.DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 8, 8, disabled ? .35 : .75, flash.filters.BitmapFilterQuality.HIGH, true, false, false);
		this.filters = [shadow];
		
		
		bar = new ProgressBarIndicator(this, "Indicator");
		bar.init();
		bar.cacheAsBitmap = true;
		this.cacheAsBitmap = true;
		

		var shadow = new flash.filters.DropShadowFilter (4, 0, DefaultStyle.DROPSHADOW, 0.5, 4, 4, disabled ? .35 : .75, flash.filters.BitmapFilterQuality.LOW, false, false, false);
		//~ var glow = new flash.filters.GlowFilter (DefaultStyle.PROGRESS_BAR, 1, 16, 16, 1.5, flash.filters.BitmapFilterQuality.HIGH, false, false);
		//~ if(this.disabled)
			bar.filters = [shadow];
		//~ else 
			//~ bar.filters = [glow, shadow];
		
		
		mazk = cast addChild(new Shape());
		mazk.graphics.beginFill(0xFF00FF);
		mazk.graphics.drawRect(0,0,progress*box.width,box.height);
		mazk.graphics.endFill();
		bar.mask = mazk;


		bar.setAction("interval", 
		"
		var x = -1;
		if(this.x < -parent.box.width/10) x = parent.box.width/10;
		this.move(x,0);
		"
		);
		bar.moveTo(0,1);
		//bar.startInterval(12);

		label = new Label(this);
		label.init();
		label.text = null;
		label.tf.text = Math.round(100*progress) + "%";
		label.moveTo( .5*(box.width-label.width), .5*(box.height-label.height) + 1 );
		
		
		/*
		var t = new feffects.Tween(0, 1, 10000+Std.random(20000), this, "progress", feffects.easing.Linear.easeNone);
		var self = this;
		t.setTweenHandlers( function(v) { self.update(); } , function(v) { t.stop(); t.start(); } );
		t.start();
		*/

	}


	static function __init__() {
		haxegui.Haxegui.register(ProgressBar);
	}

	public function update() {

		progress = Math.max(0, Math.min(1, progress));
		
		if(label!=null) 
			label.tf.text = Math.round(100*progress) + "%";

		
		if(mask!=null) {
			mazk = cast addChild(new Shape());
			mazk.graphics.clear();
			mazk.graphics.beginFill(0xFF00FF);
			mazk.graphics.drawRect(2,1,progress*box.width, box.height);
			mazk.graphics.endFill();
			bar.mask = mazk;
		}
		mazk.width = progress*box.width;
		mazk.height = box.height;
	
	}
	
	
	public override function onResize(e:ResizeEvent) {
		label.moveTo( .5*(box.width-label.width), .5*(box.height-label.height) + 1 );
		bar.dirty = true;
		update();
		super.onResize(e);
	}
	
	

}//ProgressBar
