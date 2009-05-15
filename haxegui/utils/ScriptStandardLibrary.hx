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

package haxegui.utils;

import hscript.Interp;

import haxegui.CursorManager;
import haxegui.StyleManager;

/**
* Functions for setting up a scripting environment with standard libraries.
*
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class ScriptStandardLibrary
{
	/**
	* Sets all the exported library methods to the given interpreter.
	* <ul>
	* <li>Math
	* <li>flash.display.GradientType
	* <li>flash.geom.Matrix
	* </ul>
	**/
	public static function set(interp:Interp)
	{
		interp.variables.set( "trace", haxe.Log.trace );
		interp.variables.set( "root", flash.Lib.current );
		interp.variables.set( "Std", Std );
		interp.variables.set( "String", String );
		interp.variables.set( "Math", Math );
		interp.variables.set( "Type", Type );
		interp.variables.set( "Reflect", Reflect );
		interp.variables.set( "Timer", haxe.Timer );
		interp.variables.set( "Xml", Xml );


		interp.variables.set("feffects",
			{
				Tween : feffects.Tween,
				easing : {
					Back : feffects.easing.Back,
					Bounce : feffects.easing.Bounce,
					Circ : feffects.easing.Circ,
					Cubic : feffects.easing.Cubic,
					Sine : feffects.easing.Sine,
					Elastic : feffects.easing.Elastic,
					Expo : feffects.easing.Expo,
					Linear : feffects.easing.Linear,
					Quad : feffects.easing.Quad,
					Quart : feffects.easing.Quart,
					Quint : feffects.easing.Quint,
				},
			});
		interp.variables.set("flash",
			{
				display : {
					GradientType : {
						LINEAR: flash.display.GradientType.LINEAR,
						RADIAL: flash.display.GradientType.RADIAL,
					},
					LineScaleMode : {
						VERTICAL : flash.display.LineScaleMode.VERTICAL,
						NORMAL : flash.display.LineScaleMode.NORMAL,
						NONE : flash.display.LineScaleMode.NONE,
						HORIZONTAL : flash.display.LineScaleMode.HORIZONTAL,
					},
					JointStyle : {
						ROUND : flash.display.JointStyle.ROUND,
						MITER : flash.display.JointStyle.MITER,
						BEVEL : flash.display.JointStyle.BEVEL
					},
					CapsStyle : {
					SQUARE : flash.display.CapsStyle.SQUARE,
					ROUND : flash.display.CapsStyle.ROUND,
					NONE : flash.display.CapsStyle.NONE
					}
					
				},
				filters : {
					BevelFilter : flash.filters.BevelFilter,
					BitmapFilter : flash.filters.BitmapFilter,
					BitmapFilterQuality : {
						HIGH : flash.filters.BitmapFilterQuality.HIGH,
						LOW : flash.filters.BitmapFilterQuality.LOW,
						MEDIUM : flash.filters.BitmapFilterQuality.MEDIUM,
					},
					BitmapFilterType : {
						OUTER : flash.filters.BitmapFilterType.OUTER,
						INNER : flash.filters.BitmapFilterType.INNER,
						FULL : flash.filters.BitmapFilterType.FULL,
					},
					BlurFilter : flash.filters.BlurFilter,
					ColorMatrixFilter : flash.filters.ColorMatrixFilter,
					ConvolutionFilter : flash.filters.ConvolutionFilter,
					DisplacementMapFilter : flash.filters.DisplacementMapFilter,
					DisplacementMapFilterMode : {
						WRAP : flash.filters.DisplacementMapFilterMode.WRAP,
						IGNORE : flash.filters.DisplacementMapFilterMode.IGNORE,
						COLOR : flash.filters.DisplacementMapFilterMode.COLOR,
						CLAMP : flash.filters.DisplacementMapFilterMode.CLAMP,
					},
					DropShadowFilter : flash.filters.DropShadowFilter,
					GlowFilter : flash.filters.GlowFilter,
					GradientBevelFilter : flash.filters.GradientBevelFilter,
					GradientGlowFilter : flash.filters.GradientGlowFilter,
// 					ShaderFilter : flash.filters.ShaderFilter,
				},
				geom : {
					Matrix : flash.geom.Matrix,
					Point : flash.geom.Point,
					Rectangle : flash.geom.Rectangle,
				},
				text : {
					TextField : flash.text.TextField,
					TextFieldType : flash.text.TextFieldType,
					TextFormat : flash.text.TextFormat,
					TextFormatAlign : flash.text.TextFormatAlign,
					StyleSheet : flash.text.StyleSheet
				},
				events :
					{
					Event : flash.events.Event,
					MouseEvent : flash.events.MouseEvent,
					KeyboardEvent : flash.events.KeyboardEvent
					},
				net :
					{
					URLLoader	: flash.net.URLLoader,
					URLRequest	: flash.net.URLRequest
					}
			});


		interp.variables.set("Keyboard", flash.ui.Keyboard);
		
		
		interp.variables.set("CodeHighlighter", CodeHighlighter);


		/** haxegui exported with haxegui package stripped **/
		interp.variables.set("ColorPicker", haxegui.ColorPicker);
		interp.variables.set("Console", haxegui.Console);
		interp.variables.set("Container", haxegui.Container);

		interp.variables.set("Cursor",{
				ARROW : Cursor.ARROW,
				HAND : Cursor.HAND,
				HAND2 : Cursor.HAND2,
				DRAG : Cursor.DRAG,
				IBEAM : Cursor.IBEAM,
				NE : Cursor.NE,
				NW : Cursor.NW,
				SIZE_ALL : Cursor.SIZE_ALL,
				CROSSHAIR : Cursor.CROSSHAIR,
			});
		interp.variables.set("CursorManager", CursorManager);
		interp.variables.set("DefaultStyle", DefaultStyle);
		interp.variables.set("DragManager", haxegui.DragManager);
		interp.variables.set("FocusManager", haxegui.FocusManager);
		interp.variables.set("Image", haxegui.Image);
		interp.variables.set("Menubar", haxegui.Menubar);
		interp.variables.set("MouseManager", haxegui.MouseManager);
		interp.variables.set("Opts", haxegui.Opts);
		interp.variables.set("PopupMenu", haxegui.PopupMenu);
		interp.variables.set("ScrollPane", haxegui.ScrollPane);
		interp.variables.set("Stats", haxegui.Stats);
		interp.variables.set("StyleManager", StyleManager);
		interp.variables.set("Toolbar", haxegui.Toolbar);
		interp.variables.set("Utils", haxegui.Utils);
		interp.variables.set("Window", haxegui.Window);
		interp.variables.set("WindowManager", haxegui.WindowManager);
		interp.variables.set("XmlDeserializer", haxegui.XmlDeserializer);
		interp.variables.set("ScriptStandardLibrary", haxegui.utils.ScriptStandardLibrary);

		interp.variables.set("events",
			{
				ResizeEvent			: haxegui.events.ResizeEvent,
				MoveEvent			: haxegui.events.MoveEvent,
				MenuEvent			: haxegui.events.MenuEvent	
			}
			);

		interp.variables.set("controls",
			{
				AbstractButton		: haxegui.controls.AbstractButton,
				Button				: haxegui.controls.Button,
				CheckBox			: haxegui.controls.CheckBox,
				ComboBox			: haxegui.controls.ComboBox,
				Component			: haxegui.controls.Component,
				Input				: haxegui.controls.Input,
				Label				: haxegui.controls.Label,
				RadioButton			: haxegui.controls.RadioButton,
				Scrollbar			: haxegui.controls.Scrollbar,
				Slider				: haxegui.controls.Slider,
				Stepper				: haxegui.controls.Stepper,
				TitleBar			: haxegui.controls.TitleBar,
				UiList				: haxegui.controls.UiList,
			});
	}

}
