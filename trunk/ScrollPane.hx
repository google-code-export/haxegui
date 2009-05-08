//      ScrollPane.hx
//      
//      Copyright 2009 gershon <gershon@yellow>
//      
//      This program is free software; you can redistribute it and/or modify
//      it under the terms of the GNU General Public License as published by
//      the Free Software Foundation; either version 2 of the License, or
//      (at your option) any later version.
//      
//      This program is distributed in the hope that it will be useful,
//      but WITHOUT ANY WARRANTY; without even the implied warranty of
//      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//      GNU General Public License for more details.
//      
//      You should have received a copy of the GNU General Public License
//      along with this program; if not, write to the Free Software
//      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
//      MA 02110-1301, USA.


import controls.Component;
import Scrollbar;

import flash.geom.Rectangle;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.display.Sprite;
import events.ResizeEvent;

class ScrollPane extends Component, implements Dynamic {

	public var color : UInt;
	
	public var content : Sprite;
	
	public var vert : Scrollbar;
	public var horz : Scrollbar;
	

  public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super(parent, name, x, y);
		//~ this.name = (name==null) ? "scroll_pane" : name;

	}

	
	public override function addChild(o : DisplayObject) : DisplayObject
	{
		if(content!=null && vert!=null && horz!=null)
			return content.addChild(o);
		return super.addChild(o);
	}
	
		
	//~ public function init(?name, ?x:Float, ?y:Float) {
	public function init(?initObj:Dynamic) 
	{
		
		
		
		color = (cast parent).color;
		//~ box = untyped parent.box.clone();

		if(Reflect.isObject(initObj))
		{
			for(f in Reflect.fields(initObj))
				if(Reflect.hasField(this, f))
					if(f!="width" && f!="height")
						Reflect.setField(this, f, Reflect.field(initObj, f));
			
			box.width = ( Math.isNaN(initObj.width) ) ? box.width : initObj.width;
			box.height = ( Math.isNaN(initObj.height) ) ? box.height : initObj.height;
			//~ name = ( initObj.name == null) ? "container" : name;
			//~ move(initObj.x, initObj.y);
			//~ color = (initObj.color==null) ? color : initObj.color;
			//~ trace(Std.string(initObj));
		}	
		
		content = new Sprite();
		content.name = "content";
		//~ content.scrollRect = new Rectangle(0,0,box.width,box.height);
		content.scrollRect = new Rectangle(0,0, flash.Lib.current.stage.stageWidth, flash.Lib.current.stage.stageHeight);
		//~ content.scrollRect = new Rectangle();
		content.cacheAsBitmap = true;
		this.addChild(content);
		
		vert = cast this.addChild(new Scrollbar());
		vert.x = box.width - 20;
		vert.y = 0;
		vert.name = "vscrollbar";
		vert.color = color;
		vert.init(content);


		horz = cast this.addChild(new Scrollbar(true));
		horz.rotation = -90;
		//~ horz.y = box.height + 36 ;
		horz.name = "hscrollbar";
		horz.color = color;
		horz.init(content);

		//~ vert.scrollee = content;
		//~ horz.scrollee = content;
		
		cacheAsBitmap = true;
		content.cacheAsBitmap = true;

		parent.addEventListener(ResizeEvent.RESIZE, onResize);	
		parent.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
		
    	}

	/**
	 * 
	 * 
	 */
	public function onResize(e:ResizeEvent)
	{
		box = untyped parent.box.clone();

		box.width -= x;
		box.height -= y;

		if(horz.visible) box.height -= 20;
		if(vert.visible) box.width -= 20;

	
				//~ var transform = content.transform;
				//~ var bounds = transform.pixelBounds.clone();

				//~ horz.visible = bounds.width > box.width ;
				//~ vert.visible = bounds.height > box.height ;
	
	
			

				this.graphics.clear();
				if(horz.visible || vert.visible)
				{
					this.graphics.beginFill(color - 0x141414);
					this.graphics.drawRect(box.width, box.height,22 ,22);
					this.graphics.endFill();
				}
				

			
		//~ if(content.scrollRect==null || content.scrollRect.isEmpty())
			//~ content.scrollRect = new Rectangle();

		//~ content.scrollRect = new Rectangle(0,0,box.width,box.height);
		
		var r = box.clone();
		r.x = content.scrollRect.x;
		r.y = content.scrollRect.y;
		content.scrollRect = r.clone();
		
		//~ content.scrollRect = box.clone();
		//~ content.scrollRect.width  = box.width;
		//~ content.scrollRect.height  = box.height;
		//~ content.scrollRect = getRect(this);



		content.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));

		//~ e.updateAfterEvent();
		
	}//resize


}//scrollpane
