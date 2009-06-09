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

import flash.ui.Keyboard;

import hscript.Interp;

import haxegui.managers.CursorManager;
import haxegui.managers.StyleManager;

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
		interp.variables.set( "Lambda", Lambda );
		interp.variables.set( "String", String );
		interp.variables.set( "StringTools", StringTools );
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
					BlendMode : {
						SUBTRACT : flash.display.BlendMode.SUBTRACT,
						//~ SHADER : flash.display.BlendMode.SHADER,
						SCREEN : flash.display.BlendMode.SCREEN,
						OVERLAY : flash.display.BlendMode.OVERLAY,
						NORMAL : flash.display.BlendMode.NORMAL,
						MULTIPLY : flash.display.BlendMode.MULTIPLY,
						LIGHTEN : flash.display.BlendMode.LIGHTEN,
						LAYER : flash.display.BlendMode.LAYER,
						INVERT : flash.display.BlendMode.INVERT,
						HARDLIGHT : flash.display.BlendMode.HARDLIGHT,
						ERASE : flash.display.BlendMode.ERASE,
						DIFFERENCE : flash.display.BlendMode.DIFFERENCE,
						DARKEN : flash.display.BlendMode.DARKEN,
						ALPHA : flash.display.BlendMode.ALPHA,
						ADD : flash.display.BlendMode.ADD,
					},
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
					StyleSheet : flash.text.StyleSheet,
					AntiAliasType: {
						NORMAL  : flash.text.AntiAliasType.NORMAL,
						ADVANCED  : flash.text.AntiAliasType.ADVANCED
					},
					TextFieldAutoSize: {
							LEFT  : flash.text.TextFieldAutoSize.LEFT,
							RIGHT  : flash.text.TextFieldAutoSize.RIGHT,
							CENTER  : flash.text.TextFieldAutoSize.CENTER,
							NONE  : flash.text.TextFieldAutoSize.NONE,								
					}
				},
				events : {
					Event 		  : flash.events.Event,
					FocusEvent    : flash.events.FocusEvent,
					KeyboardEvent : flash.events.KeyboardEvent,
					MouseEvent    : flash.events.MouseEvent,
					TextEvent     : flash.events.TextEvent
				},
				net : {
					URLLoader	: flash.net.URLLoader,
					URLRequest	: flash.net.URLRequest
				},
				ui : {
					Keyboard : keyboard(),
					Mouse	 : flash.ui.Mouse
				},
			});


		interp.variables.set("Keyboard", keyboard());
		interp.variables.set("Mouse", flash.ui.Mouse);

		interp.variables.set("CodeHighlighter", CodeHighlighter);


		/** haxegui exported with haxegui package stripped **/
		interp.variables.set("ColorPicker", haxegui.ColorPicker);
		interp.variables.set("ColorPicker2", haxegui.ColorPicker2);
		interp.variables.set("Component", haxegui.Component);
		interp.variables.set("Console", haxegui.Console);
		interp.variables.set("Container", haxegui.Container);

		interp.variables.set("Cursor",{
				ARROW 	  : Cursor.ARROW,
				HAND 	  : Cursor.HAND,
				HAND2 	  : Cursor.HAND2,
				DRAG 	  : Cursor.DRAG,
				IBEAM 	  : Cursor.IBEAM,
				SIZE_ALL  : Cursor.SIZE_ALL,
				NESW 	  : Cursor.NESW,
				NS 	 	  : Cursor.NS,
				NWSE 	  : Cursor.NWSE,
				WE 		  : Cursor.WE,
				CROSSHAIR : Cursor.CROSSHAIR,
			});
		interp.variables.set("Appearance", haxegui.Appearance);
		interp.variables.set("CursorManager", CursorManager);
		interp.variables.set("DefaultStyle", DefaultStyle);
		interp.variables.set("DragManager", haxegui.managers.DragManager);
		interp.variables.set("FocusManager", haxegui.managers.FocusManager);
		interp.variables.set("Haxegui", haxegui.Haxegui);
		interp.variables.set("Image", haxegui.Image);
		interp.variables.set("Introspector", haxegui.Introspector);
		interp.variables.set("LayoutManager", haxegui.managers.LayoutManager);
		interp.variables.set("MenuBar", haxegui.MenuBar);
		interp.variables.set("MouseManager", haxegui.managers.MouseManager);
		interp.variables.set("Opts", haxegui.Opts);
		interp.variables.set("PopupMenu", haxegui.PopupMenu);
		interp.variables.set("RichTextEditor", haxegui.RichTextEditor);
		interp.variables.set("ScrollPane", haxegui.ScrollPane);
		interp.variables.set("ScriptManager", haxegui.managers.ScriptManager);
		interp.variables.set("ScriptStandardLibrary", ScriptStandardLibrary);
		interp.variables.set("Stats", haxegui.Stats);
		interp.variables.set("StyleManager", StyleManager);
		interp.variables.set("ToolBar", haxegui.ToolBar);
		interp.variables.set("TooltipManager", haxegui.managers.TooltipManager);
		interp.variables.set("Utils", haxegui.Utils);
		interp.variables.set("Window", haxegui.Window);
		interp.variables.set("WindowManager", haxegui.managers.WindowManager);
		interp.variables.set("XmlParser", haxegui.XmlParser);

		interp.variables.set("windowClasses", {
				TitleBar			: haxegui.windowClasses.TitleBar,
				WindowFrame			: haxegui.windowClasses.WindowFrame
			}
			);

		interp.variables.set("events",
			{
				ResizeEvent			: haxegui.events.ResizeEvent,
				MoveEvent			: haxegui.events.MoveEvent,
				MenuEvent			: haxegui.events.MenuEvent,
				WindowEvent			: haxegui.events.WindowEvent,
			}
			);

		interp.variables.set("controls",
			{
				AbstractButton		: haxegui.controls.AbstractButton,
				Button				: haxegui.controls.Button,
				CheckBox			: haxegui.controls.CheckBox,
				ComboBox			: haxegui.controls.ComboBox,
				Input				: haxegui.controls.Input,
				Label				: haxegui.controls.Label,
				ProgressBar			: haxegui.controls.ProgressBar,
				RadioButton			: haxegui.controls.RadioButton,
				ScrollBar			: haxegui.controls.ScrollBar,
				Slider				: haxegui.controls.Slider,
				Stepper				: haxegui.controls.Stepper,
				Tree				: haxegui.controls.Tree,
				UiList				: haxegui.controls.UiList,
			});


		interp.variables.set("toys",
			{
				Curvy				: haxegui.toys.Curvy,
				Rectangle			: haxegui.toys.Rectangle,
				Transformer			: haxegui.toys.Transformer
			}
			);

	}

	//grep -e "static var" /usr/share/haxe/std/flash9/ui/Keyboard.hx | awk '{print "\t\t\t",$3," : Keyboard.",$3,","}' >> haxegui/utils/ScriptStandardLibrary.hx
	private static function keyboard() : Dynamic {
		return {
			BACKSPACE  : Keyboard.BACKSPACE,
			CAPS_LOCK  : Keyboard.CAPS_LOCK,
			CONTROL  : Keyboard.CONTROL,
			DELETE  : Keyboard.DELETE,
			DOWN  : Keyboard.DOWN,
			END  : Keyboard.END,
			ENTER  : Keyboard.ENTER,
			ESCAPE  : Keyboard.ESCAPE,
			F1  : Keyboard.F1,
			F10  : Keyboard.F10,
			F11  : Keyboard.F11,
			F12  : Keyboard.F12,
			F13  : Keyboard.F13,
			F14  : Keyboard.F14,
			F15  : Keyboard.F15,
			F2  : Keyboard.F2,
			F3  : Keyboard.F3,
			F4  : Keyboard.F4,
			F5  : Keyboard.F5,
			F6  : Keyboard.F6,
			F7  : Keyboard.F7,
			F8  : Keyboard.F8,
			F9  : Keyboard.F9,
			HOME  : Keyboard.HOME,
			INSERT  : Keyboard.INSERT,
			LEFT  : Keyboard.LEFT,
			NUMPAD_0  : Keyboard.NUMPAD_0,
			NUMPAD_1  : Keyboard.NUMPAD_1,
			NUMPAD_2  : Keyboard.NUMPAD_2,
			NUMPAD_3  : Keyboard.NUMPAD_3,
			NUMPAD_4  : Keyboard.NUMPAD_4,
			NUMPAD_5  : Keyboard.NUMPAD_5,
			NUMPAD_6  : Keyboard.NUMPAD_6,
			NUMPAD_7  : Keyboard.NUMPAD_7,
			NUMPAD_8  : Keyboard.NUMPAD_8,
			NUMPAD_9  : Keyboard.NUMPAD_9,
			NUMPAD_ADD  : Keyboard.NUMPAD_ADD,
			NUMPAD_DECIMAL  : Keyboard.NUMPAD_DECIMAL,
			NUMPAD_DIVIDE  : Keyboard.NUMPAD_DIVIDE,
			NUMPAD_ENTER  : Keyboard.NUMPAD_ENTER,
			NUMPAD_MULTIPLY  : Keyboard.NUMPAD_MULTIPLY,
			NUMPAD_SUBTRACT  : Keyboard.NUMPAD_SUBTRACT,
			PAGE_DOWN  : Keyboard.PAGE_DOWN,
			PAGE_UP  : Keyboard.PAGE_UP,
			RIGHT  : Keyboard.RIGHT,
			SHIFT  : Keyboard.SHIFT,
			SPACE  : Keyboard.SPACE,
			TAB  : Keyboard.TAB,
			UP  : Keyboard.UP,
			capsLock : Keyboard.capsLock,
			numLock : Keyboard.numLock,
			isAccessible : Keyboard.isAccessible,
		};
	}
}


