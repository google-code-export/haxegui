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

import flash.events.Event;
import flash.events.EventDispatcher;

/**
 * AdjustmentObject
 */
typedef AdjustmentObject<Dynamic> = {
    var value : Dynamic;
    var min   : Dynamic;
    var max   : Dynamic;
    var step  : Dynamic;
    var page  : Dynamic;
}

/**
* Adjustment class allows reuse \ sharing of values for "range widgets".<br/>
* It clamps to min&max, and dispatches an event when one of the values has changed.
*
* Notice when using hscript use must use the getters and setters:
* <pre class="code xml">
* <haxegui:controls:Slider value="0">
* <events>
* 	<script type="text/hscript" action="onLoaded">
* 		this.adjustment.setValue(50);
* 	</script>
* </events>
* </haxegui:controls:Slider>
* </pre>
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class Adjustment extends EventDispatcher {
    
    public var object(default, adjust) : AdjustmentObject<Dynamic>;
    
    public function new(?a:AdjustmentObject<Dynamic>) {
	super();
	
	object = { value: null, min:null, max:null, step:null, page:null};
	
	if(a!=null)
	    object = a;

    }

    public function adjust(?a:AdjustmentObject<Dynamic>) : AdjustmentObject<Dynamic> {
	object = a;
	dispatchEvent(new Event(Event.CHANGE));
	return object;
    }
    
    public function setValue(v:Float) : Float {
	object.value = v;
	adjust(object);
	return v;
    }
        
    public function getValue() : Float {
	return object.value;
    }

    public function getStep() : Float {
	return object.step;
    }
    
    public function valueAsString() : String {
	return Std.string(getValue());
    }
    
}


/**
* Interface for adjustable widgets.
*
*/
interface IAdjustable {
    public var adjustment : Adjustment;
}


