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

package haxegui;

/**
* LayoutManager handles loading layouts from XML files, and setting a layout.
*
* @version 0.1
* @author Russell Weir <damonsbane@gmail.com>
* @author Omer Goshen <gershon@goosemoose.com>
*/
class LayoutManager
{
	public static var layouts : Hash<Xml> = new Hash<Xml>();

	public static function loadLayouts(xml:Xml) {
		for(elem in xml.elements()) {
			if(!XmlParser.isLayoutNode(elem))
				continue;
			var name = XmlParser.getLayoutName(elem);
			if(name == null)
				continue;
			layouts.set(name, elem);
		}
	}

	public static function setLayout(name:String) {
		if(!layouts.exists(name)) {
			throw("Layout '"+name+"' does not exist");
			return;
		}
		XmlParser.apply(layouts.get(name));
	}
}