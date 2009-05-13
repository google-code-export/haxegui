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
		interp.variables.set("Math",Math);
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
				},
				geom : {
					Matrix : flash.geom.Matrix,
				},
			});
		interp.variables.set("DefaultStyle", DefaultStyle);
		interp.variables.set("CursorManager", CursorManager);
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
	}

}