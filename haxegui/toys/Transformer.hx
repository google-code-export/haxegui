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

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.FocusEvent;
import haxegui.events.ResizeEvent;
import haxegui.managers.ScriptManager;
import haxegui.managers.StyleManager;

import haxegui.controls.Component;
import haxegui.controls.AbstractButton;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;

/**
 * A Transformation widget, pass it a target on creation and use it's 8 square handles on the 
 * corners and edges for resizing, and the center circle for moving it.
 * It listens for focus events from the target, if target has lost focus for anyone else but the 
 * transformer, it will automatically self-destruct.
 * 
 */
class Transformer extends Component
{
	/** Component to transform **/
	public var target  : Component;

	private var pivot   : AbstractButton;
	private var handles : Array<AbstractButton>;

	public function new (trgt:Component) {
		target = trgt;
		super(flash.Lib.current, "Transformer_"+target.name, target.x, target.y);
	}

	override public function init(?opts:Dynamic) {
		color = cast Math.random() * 0xFFFFFF;
		handles = [];
		//~ this.text = null;
		if(target.box==null || target.box.isEmpty()) 
			box = target.getBounds(this);
		else
			box = target.box.clone();
		box.inflate(8,8);
			
		super.init(opts);
	
		blendMode = flash.display.BlendMode.DIFFERENCE;
		if(Std.is(target, Component))
			target.addEventListener(FocusEvent.FOCUS_OUT, onTargetFocusOut, false, 0, true);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onClose, false, 0, true);
		 
			
		for(i in 0...8) {
			handles.push(new AbstractButton(this, "handle"+i));
			handles[i].init();
			handles[i].text = null;
			handles[i].setAction("redraw",
			"
			this.graphics.clear();
			this.graphics.lineStyle (1, Math.min(0xFFFFFF, this.color | 0x4D4D4D), .5, true,
				 flash.display.LineScaleMode.NONE,
				 flash.display.CapsStyle.ROUND,
				 flash.display.JointStyle.ROUND);		
			this.graphics.beginFill( this.color, .35);
			this.graphics.drawRect(0,0,8,8);
			this.graphics.endFill();
			"
			);
			handles[i].setAction("mouseDown",
			"
			this.startDrag();
			this.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, parent.onMouseMove, false, 0, true);
			"
			);

			handles[i].setAction("mouseUp",
			"
			this.stopDrag();
			this.removeEventListener(flash.events.MouseEvent.MOUSE_MOVE, parent.onMouseMove);
			"
			);

			var mid = new Point(Std.int(this.box.width) >> 1,Std.int(this.box.height) >> 1);

			switch(i) {
				case 0:
				case 1:
					handles[i].moveTo( mid.x - 4, 0 );
				case 2:
					handles[i].moveTo( this.box.width - 8, 0 );
				case 3:
					handles[i].moveTo( this.box.width - 8, mid.y - 4 );
				case 4:
					handles[i].moveTo( this.box.width - 8, this.box.height - 8 );
				case 5:
					handles[i].moveTo( mid.x - 4, this.box.height - 8 );
				case 6:
					handles[i].moveTo( 0,  this.box.height - 8 );
				case 7:
					handles[i].moveTo( 0,  mid.y - 4 );
			}
			
		}


	
		// center pivot
		pivot = new AbstractButton(this, "pivot") ;
		pivot.init();
		pivot.text = null;
		pivot.setAction("redraw",
		"
		this.graphics.clear();
		this.graphics.lineStyle (1, Math.min(0xFFFFFF, this.color | 0x4D4D4D), 1, true,
			 flash.display.LineScaleMode.NONE,
			 flash.display.CapsStyle.ROUND,
			 flash.display.JointStyle.ROUND);		
		this.graphics.beginFill(0xFFFFFF, .5);
		this.graphics.drawCircle(0,0,4);
		this.graphics.endFill();
		"
		);
		pivot.setAction("mouseClick", "");

		pivot.setAction("mouseDown",
		"
		parent.startDrag();
		this.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, parent.onMouseMove, false, 0, true);	
		"
		);
		pivot.setAction("mouseUp",
		"
		parent.stopDrag();
		this.removeEventListener(flash.events.MouseEvent.MOUSE_MOVE, parent.onMouseMove);		
		"
		);	
		pivot.moveTo( Std.int(this.box.width)>>1, Std.int(this.box.height)>>1 );

	
		// draw the frame
		this.setAction("redraw",
		"
		this.graphics.clear();
		this.graphics.lineStyle (1, Math.min(0xFFFFFF, this.color | 0x4D4D4D), .35, true,
			 flash.display.LineScaleMode.NONE,
			 flash.display.CapsStyle.ROUND,
			 flash.display.JointStyle.ROUND);		
		this.graphics.beginFill(this.color, .15);
		this.graphics.drawRect(0,0,this.box.width,this.box.height);
		this.graphics.drawRect(8,8,this.box.width-16,this.box.height-16);
		this.graphics.endFill();
		"
		);
		
		

	}

	static function __init__() {
		haxegui.Haxegui.register(Transformer);
	}
	
	public function onTargetFocusOut(e:FocusEvent) {
		if(!Std.is(e.relatedObject, Component)) return;
		if(e.relatedObject==this || this.contains(e.relatedObject)) return;
		trace(e);
		this.destroy();
	}

	public function onMouseMove(e:MouseEvent) {
		if(!this.contains(e.target)) return;
		var p = target.parent.globalToLocal(new Point(this.x, this.y));
		var i = this.getChildIndex(e.target);
		var mid = new Point(Std.int(this.box.width) >> 1,Std.int(this.box.height) >> 1);
		switch(i) {
			case 0:
				this.move( e.target.x, e.target.y );
				target.moveTo( p.x + 8, p.y + 8 );
				this.box.width -= e.target.x;
				this.box.height -= e.target.y;
				e.target.moveTo(0,0);
				handles[2].x = handles[3].x = handles[4].x = this.box.width - 8;
				handles[1].x = handles[5].x = mid.x - 4;
				handles[3].y = handles[7].y = mid.y - 4;
				handles[4].y = handles[5].y = handles[6].y = this.box.height - 8;
			case 1:
				this.y += e.target.y;
				this.box.height -= e.target.y;
				e.target.y = 0;
				handles[3].y = handles[7].y = mid.y - 4;
				handles[4].y = handles[5].y = handles[6].y = this.box.height - 8;
				target.moveTo( p.x + 8, p.y + 8 );
			case 2:
				this.move( 0, e.target.y );
				this.box.width = e.target.x + 8;
				this.box.height -= e.target.y ;
				e.target.y = 0;
				handles[3].x = handles[4].x = e.target.x;
				handles[1].x = handles[5].x = mid.x - 4;
				handles[3].y = handles[7].y = mid.y - 4;
				handles[4].y = handles[5].y = handles[6].y = this.box.height - 8;
				target.moveTo( p.x + 8, p.y + 8 );				
			case 3:
				this.box.width = e.target.x + 8;
				handles[1].x = handles[5].x = mid.x - 4;
				handles[2].x = handles[4].x = e.target.x;
			case 4:
				this.box.width = e.target.x + 8;
				this.box.height = e.target.y + 8;
				handles[1].x = handles[5].x = mid.x - 4;
				handles[2].x = handles[3].x = e.target.x;
				handles[3].y = handles[7].y = mid.y - 4;
				handles[5].y = handles[6].y = e.target.y;
			case 5:
				this.box.height = e.target.y + 8;
				handles[3].y = handles[7].y = mid.y - 4;
				handles[4].y = handles[6].y = e.target.y;
			case 6:
				this.x += e.target.x;
				this.box.width -= e.target.x;
				this.box.height = e.target.y + 8;
				e.target.moveTo(0, this.box.height - 8);
				handles[1].x = handles[5].x = mid.x - 4;
				handles[2].x = handles[3].x = handles[4].x = this.box.width - 8;
				handles[3].y = handles[7].y = mid.y - 4;
				handles[4].y = handles[5].y = e.target.y;
				target.moveTo( p.x + 8, p.y + 8 );
			case 7:
				this.x += e.target.x;
				this.box.width -= e.target.x;
				e.target.moveTo(0, mid.y - 4);
				handles[1].x = handles[5].x = mid.x - 4;
				handles[2].x = handles[3].x = handles[4].x = this.box.width - 8;
				target.moveTo( p.x + 8, p.y + 8 );
			case 8: //pivot
				target.moveTo( p.x + 8, p.y + 8 );
				
		}
		pivot.moveTo( mid.x, mid.y );
		//~ dirty = true;
		redraw();

		target.box = this.box.clone();
		target.box.inflate(-8,-8);
		if(i==8)
			target.dispatchEvent(new MoveEvent(MoveEvent.MOVE));
		else
			target.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
		//~ target.dispatchEvent(new Event(Event.CHANGE));
		target.redraw();
		//~ target.dirty = true;
	}

	function onClose(e:Dynamic) {
		if(Std.is(e, MouseEvent))
			if(e.target==this || this.contains(e.target)) return;
		this.destroy();
	}
	


		
}
