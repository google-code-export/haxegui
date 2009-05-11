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

import flash.display.Sprite;
import flash.display.MovieClip;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import flash.text.TextField;
import flash.text.TextFormat;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;

import haxegui.events.MoveEvent;

import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;

import haxegui.CursorManager;
import haxegui.StyleManager;

/**
 * 
 * 
 * 
 * 
 */
class ComboBox extends Button, implements Dynamic
{
  public var back : Sprite;
  public var dropButton : Button;
  public var tf : TextField;

  public function new (?parent:DisplayObjectContainer, ?name:String, ?x:Float, ?y:Float)
	{
		super(parent, name, x, y);
	}



  /**
   * 
   * Initiate a new ComboBox
   * @param initObj
   * 
   */
  public override function init(?initObj:Dynamic)
	{
		//~ super.init(initObj);
		color = StyleManager.BACKGROUND;
				box = new Rectangle(0,0,140,20);

	if(Reflect.isObject(initObj))
		{
			this.name = (initObj.name == null) ? name : initObj.name;
			move(initObj.x, initObj.y);
			//~ box.width = initObj.width;
			//~ box.height = initObj.height;
			for(f in Reflect.fields(initObj))
				if(Reflect.hasField(this, f))
					Reflect.setField(this, f, Reflect.field(initObj, f));

		}

		back = new Sprite();
		back.name = "back";
		back.graphics.lineStyle (2, StyleManager.BACKGROUND - 0x202020);
		back.graphics.beginFill (StyleManager.INPUT_BACK);
		back.graphics.drawRoundRectComplex (0, 0, box.width - 20 , box.height, 4, 0, 4, 0 );
		back.graphics.endFill ();
		addChild(back);
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.8, 4, 4, 0.65, BitmapFilterQuality.HIGH, true, false, false );
		back.filters = [shadow];
		

		tf = new TextField();
		tf.name = "tf";
		tf.type = flash.text.TextFieldType.INPUT;
		tf.text = name;
		//~ tf.background = true;
		//~ tf.border = true;
		//~ tf.borderColor = color - 0x202020;
		tf.embedFonts = true;
		
		tf.height = box.height - 4;
		tf.x = tf.y = 4;
		
		tf.setTextFormat(StyleManager.getTextFormat());
		this.addChild(tf);


		dropButton = new Button(this, "button");
		dropButton.init({x: box.width - 20, width: 20, height: 20});	
		//~ dropButton.label.text = ">";
		//~ dropButton.label.setTextFormat(StyleManager.getTextFormat(flash.text.TextFormatAlign.CENTER));
		dropButton.removeChild( dropButton.getChildByName("label") );
		//~ dropButton.filters = null;
		dropButton.redraw = redrawButton;
		
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.2, 4, 4, 0.65, BitmapFilterQuality.HIGH, false, false, false );
		dropButton.filters = [shadow];
			
		//~ this.addEventListener (MouseEvent.ROLL_OUT, onRollOut);
		this.addEventListener (MouseEvent.ROLL_OVER, onRollOver);
		
		this.addEventListener (Event.ACTIVATE, onEnabled);
		this.addEventListener (Event.DEACTIVATE, onDisabled);


		redraw();
	}

	public function onEnabled(e:Event)
	{
	}
	
	public function onDisabled(e:Event)
	{
	}


	/**
	*
	*/
	//~ public function redrawButton(?color:UInt) : Void
	public function redrawButton() : Void
	{

		//~ if(color == 0 ) color = this.color;

		dropButton.graphics.clear();
		//~ dropButton.graphics.lineStyle (2, color - 0x191919 );		
		dropButton.graphics.lineStyle (2, color - 0x333333 );		

		var colors = [ color | 0x323232, color - 0x141414 ];
	
		if( disabled ) 
			{
			color = StyleManager.BACKGROUND - 0x141414;
			//~ color = color - 0x141414;
			this.graphics.lineStyle (2, color);		
			
			}
			
   		  
		  var alphas = [ 100, 100 ];
		  var ratios = [ 0, 0xFF ];
		  var matrix = new flash.geom.Matrix();
		  matrix.createGradientBox(dropButton.box.width, dropButton.box.height, Math.PI/2, 0, 0);
		  dropButton.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, ratios, matrix );


		
		//~ this.graphics.drawRoundRect (0, 0, box.width, box.height, 8, 8 );
		dropButton.graphics.drawRoundRectComplex (0, 0, dropButton.box.width, dropButton.box.height, 0, 4, 0, 4 );
		dropButton.graphics.endFill ();
		
		dropButton.graphics.lineStyle (1, color - 0x333333 );		
		//~ dropButton.graphics.beginFill( StyleManager.BACKGROUND - 0x141414 );
		dropButton.graphics.beginGradientFill( flash.display.GradientType.LINEAR, colors, alphas, [0, 0x66], matrix );
		dropButton.graphics.moveTo(5,5);
		dropButton.graphics.lineTo(15,5);
		dropButton.graphics.lineTo(10,15);
		
		dropButton.graphics.endFill ();
		
			var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.2, 4, 4, 0.65, BitmapFilterQuality.HIGH, false, false, false );
			dropButton.filters = [shadow];
	}

	/**
	 *
	 */
	//~ public override function redraw(?color:UInt) : Void {
	public override function redraw() : Void {

		if(color==0 || Math.isNaN(color))
			color = StyleManager.BACKGROUND;

		tf.setTextFormat( StyleManager.getTextFormat( 8, StyleManager.LABEL_TEXT ));
			
		if( disabled ) 
			{
			
			dropButton.disabled = disabled;
			
			//~ color = StyleManager.BACKGROUND - 0x141414;
			color = StyleManager.BACKGROUND;

			
			//~ var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.2, 4, 4, 0.65, BitmapFilterQuality.HIGH, true, false, false );
			//~ this.filters = [shadow];
			
			
			//~ tf.backgroundColor = StyleManager.BACKGROUND + 0x141414;
			tf.setTextFormat( StyleManager.getTextFormat( 8, StyleManager.BACKGROUND - 0x141414 ));
			}
				
		back.graphics.lineStyle (2, StyleManager.BACKGROUND - 0x202020);
		//~ back.graphics.beginFill (color);
		back.graphics.beginFill ( disabled ? StyleManager.BACKGROUND : StyleManager.INPUT_BACK );
		back.graphics.drawRoundRectComplex (0, 0, box.width - 20 , box.height, 4, 0, 4, 0 );
		back.graphics.endFill ();

			
		dropButton.redraw();
		//~ dropButton.filters = null;


	}
}
