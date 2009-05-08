//      StyleManager.hx
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

import flash.text.TextFormat;
import flash.text.TextFormatAlign;

class StyleManager 
{
	
		public static var BACKGROUND:UInt = 0xADD8E6;
		public static var BUTTON_FACE:UInt = 0xCFB675;
		public static var INPUT_BACK:UInt = 0xE5E5E5;
		public static var INPUT_TEXT:UInt = 0x333333;
		public static var LABEL_TEXT:UInt = 0x1A1A1A;
		public static var DROPSHADOW:UInt = 0x000000;
		public static var PANEL:UInt = 0xF3F3F3;
		public static var PROGRESS_BAR:UInt = 0xFFFFFF;	
		
		public static function getTextFormat(?size:UInt, ?color:UInt, ?align:flash.text.TextFormatAlign) : TextFormat
		{
			var fmt = new TextFormat ();
			//~ fmt.align = flash.text.TextFormatAlign.CENTER;
			fmt.align = align;
			//~ fmt.font = "FFF_FORWARD";
			//~ fmt.font = "Impact";
			//~ fmt.font = "FFF_Manager_Bold";
			fmt.font = "FFF_Harmony";
			//~ fmt.font = "FFF_Freedom_Trial";
			//~ fmt.font = "FFF_Reaction_Trial";
			//~ fmt.font = "Amiga_Forever_Pro2";
			//~ fmt.font = "Silkscreen";
			//~ fmt.font = "04b25";
			//~ fmt.font = "Pixel_Classic";
			fmt.size = ( size == 0 ) ? 8 : size;
			fmt.align = ( align == null ) ? TextFormatAlign.LEFT : align;
			fmt.color = ( color == 0 ) ? LABEL_TEXT : color ;
			return fmt;
		}
		
}
