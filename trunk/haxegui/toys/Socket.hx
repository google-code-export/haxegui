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

package haxegui.toys;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.BitmapData;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.FocusEvent;

import haxegui.Haxegui;

import haxegui.managers.StyleManager;

import haxegui.utils.Size;
import haxegui.utils.Color;
import haxegui.utils.Opts;

import haxegui.controls.AbstractButton;
import haxegui.controls.Component;

import haxegui.toys.Patch;

/**
 * Socket.<br/>
 * 
 * 
 */
class Socket extends AbstractButton
{
	
	override public function init(?opts:Dynamic=null) {
		box = new Size(10,10).toRect();

		super.init(opts);

		color = Color.tint(Color.random(), .35);

		setAction("redraw",
		"
		this.graphics.clear();
		this.graphics.lineStyle(1, Color.darken(DefaultStyle.BACKGROUND, 40), 0, false, flash.display.LineScaleMode.NONE);
		this.graphics.beginFill(this.color,1);
		var points = [];
		this.graphics.moveTo(0, 6);
		for(i in 1...7) 
			this.graphics.lineTo(6*Math.sin(i/3*Math.PI), 6*Math.cos(i/3*Math.PI));
		this.graphics.drawCircle(0,0,3);
		this.graphics.endFill();
		this.graphics.beginFill(Color.darken(DefaultStyle.BACKGROUND, 120), .7);
		this.graphics.drawCircle(0,0,3);
		this.graphics.endFill();
		"
		);
		
		filters = [	new flash.filters.DropShadowFilter (1, 45, Color.BLACK, 1, 2, 2, .5, flash.filters.BitmapFilterQuality.LOW, false, false, false ), 
					new flash.filters.BevelFilter(1, 60, Color.WHITE, .85, Color.BLACK, .65, 1, 1, 1)];
		
				
	}
	
	public override function onMouseDown(e:MouseEvent) {
		if(Std.is(e.target.getParentWindow(), haxegui.Node)) return;
		
		var patchLayer = cast flash.Lib.current.getChildByName('patchLayer');
		var patch = new Patch(patchLayer);
		patch.init();
		
		// find the parent container
		var container = this.getParentContainer();
		patch.container = container;

		// set the source
		patch.source = this.parent;

		//
		var p = container.localToGlobal(new Point(this.x, this.y));
		patch.moveToPoint(p);

		//~ container.graphics.clear();
		//~ container.graphics.beginFill(Color.BLACK, 0);
		//~ container.graphics.drawRect(0,0,Std.int(container.box.width), Std.int(container.box.height));
		//~ container.graphics.endFill();
		
		//~ var bitmap = Component.rasterize(container, container.box, 1);
		//~ (cast root).addChild(bitmap);
		//~ bitmap.x = p.x;
		//~ bitmap.y = p.y;
		//~ bitmap.visible = false;
		
		//
		container.redraw();	
		//~ patch.bitmap = bitmap;
		patch.setupMap(Std.int(container.box.width/Haxegui.gridSpacing), Std.int(container.box.height/Haxegui.gridSpacing), Haxegui.gridSpacing);
		patch.setStartPoint();
		
		stage.addEventListener(MouseEvent.MOUSE_MOVE, patch.setEndPoint, false, 0, true);
		stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, patch.onMouseUp, false, 0, true);
		//~ patch.setAction("interval", "this.setEndPoint(null); this.redraw();");
		//~ patch.startInterval(12);
		
		super.onMouseDown(e);
	}
	

	static function __init__() {
		haxegui.Haxegui.register(Socket);
	}
	
	
}
