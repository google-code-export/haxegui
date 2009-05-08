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
