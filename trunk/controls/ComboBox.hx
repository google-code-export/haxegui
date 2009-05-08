//      ComboBox.hx
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

package controls;

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

import events.MoveEvent;

import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;

import CursorManager;
import StyleManager;

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
				box = new Rectangle(0,0,140,30);

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
		back.graphics.drawRoundRectComplex (0, 0, box.width - 30 , box.height, 4, 0, 4, 0 );
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
		
		tf.height = box.height - 8;
		tf.x = tf.y = 8;
		
		tf.setTextFormat(StyleManager.getTextFormat());
		this.addChild(tf);


		dropButton = new Button(this, "button");
		dropButton.init({x: box.width - 30, width: 30});	
		//~ dropButton.label.text = ">";
		//~ dropButton.label.setTextFormat(StyleManager.getTextFormat(flash.text.TextFormatAlign.CENTER));
		dropButton.removeChild( dropButton.getChildByName("label") );
		//~ dropButton.filters = null;
		dropButton.redraw = redrawButton;
		
		var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.2, 4, 4, 0.65, BitmapFilterQuality.HIGH, false, false, false );
		dropButton.filters = [shadow];
			
		this.addEventListener (MouseEvent.ROLL_OUT, onRollOut);
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
	public function redrawButton(?color:UInt) : Void
	{

		if(color == 0 ) color = this.color;

		dropButton.graphics.clear();
		//~ dropButton.graphics.lineStyle (2, color - 0x191919 );		
		dropButton.graphics.lineStyle (2, color - 0x333333 );		

		if( disabled ) 
			{
			color = StyleManager.BACKGROUND - 0x141414;
			//~ color = color - 0x141414;
			this.graphics.lineStyle (2, color);		
			
			}
			
   		  var colors = [ color | 0x323232, color - 0x141414 ];
		  
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
		dropButton.graphics.moveTo(10,10);
		dropButton.graphics.lineTo(20,10);
		dropButton.graphics.lineTo(15,20);
		
		dropButton.graphics.endFill ();
		
			var shadow:DropShadowFilter = new DropShadowFilter (4, 45, StyleManager.DROPSHADOW, 0.2, 4, 4, 0.65, BitmapFilterQuality.HIGH, false, false, false );
			dropButton.filters = [shadow];
	}

	/**
	 *
	 */
	public override function redraw(?color:UInt) : Void {

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
		back.graphics.drawRoundRectComplex (0, 0, box.width - 30 , box.height, 4, 0, 4, 0 );
		back.graphics.endFill ();

			
		dropButton.redraw(color);
		//~ dropButton.filters = null;


	}
}
