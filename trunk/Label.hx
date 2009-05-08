//      Label.hx
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

import flash.display.DisplayObjectContainer;

import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFieldAutoSize;

import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import controls.Component;

import StyleManager;

class Label extends Component
{
	
	public var tf : TextField;

	
	public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{

		//~ super(parent, name, x, y);
		super(parent, "label", x, y);
	}
	
	/**
	 * 
	 * 
	 * 
	 */
	public function init(?initObj : Dynamic)
	{
			
		tf = new TextField();
		tf.name = "tf";
		tf.text = ( text==null ) ? name : text;
		tf.type = TextFieldType.DYNAMIC;
		tf.embedFonts = true;
		tf.multiline = true;
		tf.autoSize =  TextFieldAutoSize.LEFT;
		//~ tf.autoSize =  TextFieldAutoSize.CENTER;
		//~ tf.autoSize =  TextFieldAutoSize.NONE;
		tf.selectable = false;

		//~ tf.border = true;
		
		tf.mouseEnabled = false;
		tf.tabEnabled = false;
		tf.focusRect = false;

		this.mouseEnabled = false;
		this.tabEnabled = false;
		this.focusRect = false;
		
		if(Reflect.isObject(initObj))
		{
			name = (initObj.name == null) ? name : initObj.name;
			move(initObj.x, initObj.y);
			//~ box.width = initObj.width;
			//~ box.height = initObj.height;
			for(f in Reflect.fields(initObj))
				if(Reflect.hasField(this, f))
					Reflect.setField(this, f, Reflect.field(initObj, f));
					
			tf.text = (initObj.innerData == null) ? text : initObj.innerData;
		}

		tf.setTextFormat(StyleManager.getTextFormat());
		this.addChild(tf);

	}
	
	
}
