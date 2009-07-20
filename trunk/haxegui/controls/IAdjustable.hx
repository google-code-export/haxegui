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

/**
* Adjustment class allows reuse \ sharing of values for "range widgets".
* It clamps to min&max, and dispatches an event when one of the values has changed.
*
* Notice when using hscript use must use the getters and setters:
* <pre class="code xml">
* <haxegui:controls:Slider value="0">
* <events>
* 	<script type="text/hscript" action="onLoaded">
* 		this.adjustment.__setValue(50);
* 	</script>
* </events>
* </haxegui:controls:Slider>
* </pre>
*
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir <damonsbane@gmail.com>
* @version 0.1
*/
class Adjustment extends flash.events.EventDispatcher {
    
    public var value    (default, __setValue) : Float;
    public var min      (default, __setMin)   : Float;
    public var max      (default, __setMax)   : Float;
    public var step     (default, __setStep)  : Float;
    public var page     (default, __setPage)  : Float;
    
    public function 
    new(?value  : Float,
    	?min	: Float,
    	?max	: Float,
    	?step	: Float,
    	?page	: Float) { 
		super();
		this.value = value;
		this.min = min;
		this.max = max;
		this.step = step;
		this.page = page;
		notifyChanged();       
    }
    
    public function notifyChanged() {
        dispatchEvent(new Event(Event.CHANGE));
    }
    
    
    public override function toString() : String {
        return "[Adjustment]"+Std.string({value: value, min: min, max: max, step: step, page: page});
    }
       

	//////////////////////////////////////////////////
	////           Getters/Setters                ////
	//////////////////////////////////////////////////
	/** Set value **/
    public function __setValue(v:Float) : Float {
        value = v;
        value = Math.min(max, Math.max(min, value));       
        notifyChanged();
        return v;
    }
    
	/** Set the minimum value **/
    public function __setMin(v:Float) : Float {
        min = v;
        notifyChanged();
        return v;
    }

	/** Set the maximum value **/
    public function __setMax(v:Float) : Float {
        max = v;
        notifyChanged();
        return v;
    }

	/** Set the step value **/
    public function __setStep(v:Float) : Float {
        step = v;
        notifyChanged();
        return v;
    }

	/** Set the page value **/
    public function __setPage(v:Float) : Float {
        page = v;
        notifyChanged();
        return v;
    }
    
    
}


/**
* Interface for adjustable widgets.
*
*/
interface IAdjustable {
    public var adjustment : Adjustment;
}


