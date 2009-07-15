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

package haxegui.controls;

import flash.geom.Rectangle;
import haxegui.Opts;
import haxegui.managers.StyleManager;
import haxegui.Image;
import haxegui.utils.Size;

/**
*
* Button Class
*
* A chromed button.
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
*/
class Button extends AbstractButton
{

	public var label : Label;
	public var icon  : Icon;
	//~ public var fmt : TextFormat;

	public var toggle : Bool;
	
	public var selected( __getSelected, __setSelected ) : Bool;
	
	override public function init(opts:Dynamic=null) {
		color = DefaultStyle.BACKGROUND;
		mouseChildren = false;
		
		// dont create zero sized buttons
		if(box==null || box.isEmpty()) 
			//box = new Rectangle(0,0,90,30);
			box = new Size(90,30).toRect();
		
		toggle = Opts.optBool(opts, "toggle", false);
		selected = Opts.optBool(opts, "selected", false);
		
		super.init(opts);
		text = name;
		
		// Default to a no-label simple button
		if(Opts.optString(opts, "label", null)!=null) {
		//~ label = cast this.addChild(new Label());
		label = new Label(this);
		label.text = Opts.optString(opts, "label", name);
		label.init();
		label.mouseEnabled = false;
		label.tabEnabled = false;
		}
		
		if(Opts.optString(opts, "icon", null)!=null) {
		
		icon = new Icon(this);
		var src = Opts.optString(opts, "icon", null);
		
		// check for STOCK_ type icon
		if(Reflect.field(Icon, src)!=null)
			src = Reflect.field(Icon, src);
		
		icon.init({src: src});
		icon.mouseEnabled = false;
		icon.tabEnabled = false;
		icon.move(4,4);
		}
		
		if(Std.is(parent, haxegui.ToolBar)) {
			redraw();
			dirty = false;
			this.graphics.clear();
			setAction("mouseOut", "event.target.updateColorTween( new feffects.Tween(event.buttonDown ? -50 : 50, 0, 100, feffects.easing.Expo.easeOut ) );	this.graphics.clear();");
			setAction("mouseUp", "event.target.updateColorTween( new feffects.Tween(event.buttonDown ? -50 : 50, 0, 100, feffects.easing.Expo.easeOut ) );	this.graphics.clear();");
			setAction("mouseOver","this.redraw();");
			}
	}

	static function __init__() {
		haxegui.Haxegui.register(Button);
	}
	
	public function __getSelected() : Bool {
		return selected;
	}

	public function __setSelected(v:Bool) {
		selected = v;
		redraw();
		return selected;
	}


	public override function onMouseClick(e:flash.events.MouseEvent) {
		if(disabled) return;
		if(toggle)
			selected = !selected;
		super.onMouseClick(e);
	}
	
}

