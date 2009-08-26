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


//{{{ imports
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import haxegui.DataSource;
import haxegui.XmlParser;
import haxegui.controls.Component;
import haxegui.controls.IData;
import haxegui.controls.Seperator;
import haxegui.events.DataEvent;
import haxegui.events.DragEvent;
import haxegui.events.ListEvent;
import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.managers.CursorManager;
import haxegui.managers.DragManager;
import haxegui.managers.StyleManager;
import haxegui.toys.Arrow;
import haxegui.utils.Color;
import haxegui.utils.Opts;
import haxegui.utils.Size;
//}}}


using haxegui.controls.Component;
using haxegui.utils.Color;

//{{{ ListSelectionMode
enum ListSelectionMode {
	SINGLE;
	MULTI;
}
//}}}


//{{{ ListHeader
/**
* List header with labels, seperators and an arrow to show the sort direction.<br/>
*
* @todo Sharing single header among multiple lists, to create a multi-column datagrid like widget...
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir'
*
*/
class ListHeader extends AbstractButton, implements IComposite {

	public var labels : Array<Label>;
	public var seperators : Array<Seperator>;
	public var arrow : Arrow;

	static var xml = Xml.parse('
	<haxegui:Layout name="ListHeader">
	<haxegui:controls:Label x="4" y="2" text="{parent.name}"/>
	<haxegui:toys:Arrow
	width="8"
	height="8"
	color="{Color.darken(parent.color, 20)}"
	rotation="{parent.parent.sortReverse ? -90 : 90}"/>
	<haxegui:controls:Seperator/>
	</haxegui:Layout>
	').firstElement();

	//{{{  init
	/**
	* @throws String when not parented to a [UiList]
	*/
	override public function init(opts:Dynamic=null) {if(!Std.is(parent, UiList)) throw parent+" not a UiList";
		if(!Std.is(parent, UiList)) throw parent+" not a UiList";
		box = new Size(140, 24).toRect();
		color = DefaultStyle.BACKGROUND;

		super.init(opts);

		xml.set("name", name);

		XmlParser.apply(ListHeader.xml, this);


		// labels = [new Label(this)];
		labels = [cast firstChild()];
		// labels[0].init({text : name});
		// labels[0].moveTo(4,4);


		// arrow = new Arrow(this);
		// arrow.init({ width: 8, height: 8, color: haxegui.utils.Color.darken(this.color, 20)});
		arrow = cast firstChild().asComponent().nextSibling();
		// arrow.rotation = (cast parent).sortReverse ? -90 : 90;
		//~ arrow.moveTo((cast parent).box.width - 10, 10);
		arrow.moveTo( labels[0].x + labels[0].width + 10, 10);


		seperators = [cast arrow.nextSibling()];
		// seperators[0].init({});
		seperators[0].moveTo(labels[0].x + labels[0].width + 18, 0);


		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);
	} //}}}


	//{{{ onMouseDown
	override public function onMouseDown(e:MouseEvent) : Void {
		// if(Std.is(e.target, Label)) {
		// 	e.target.startDrag(false, new Rectangle(0, e.target.y, box.width - e.target.box.width, 0));
		// 	CursorManager.getInstance().lock = true;
		// 	return;
		// }
		super.onMouseDown(e);
	}
	//}}}


	//{{{ onMouseUp
	override public function onMouseUp(e:MouseEvent) : Void {
		if(Std.is(e.target, Label)) {
			e.target.stopDrag();
			//~ e.stopImmediatePropagation();
			CursorManager.getInstance().lock = false;
			return;
		}
		super.onMouseUp(e);
	}
	//}}}


	//{{{ onParentResize
	public function onParentResize(e:ResizeEvent) {
		box.width = parent.asComponent().box.width;
		dirty = true;
	}
	//}}}


	///{{{ destroy
	public override function destroy() {
		removeEventListener(MoveEvent.MOVE, (cast parent).onHeaderMoved);
		parent.removeEventListener(ResizeEvent.RESIZE, onParentResize);

		super.destroy();
	}
	//}}}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(ListHeader);
	}
	//}}}
}
//}}}


//{{{ ListItem
/**
*
* ListItem Class
*
* @todo Add an ICellRenderer interface maybe?
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir'
*
*/
class ListItem extends AbstractButton, implements IData, implements IRubberBand, implements IAggregate {

	public var label : Label;
	public var selected : Bool;
	public var data : Dynamic;

	var oldPos : flash.geom.Point;
	var oldParent : flash.display.DisplayObjectContainer;

	static var layoutXml = Xml.parse('
	<haxegui:Layout name="ListItem">
		<haxegui:controls:Label x="4" y="2" height="{parent.box.height}"/>
	</haxegui:Layout>
	').firstElement();

	static var styleXml = Xml.parse('
	<haxegui:Style name="ListItem">
		<haxegui:controls:ListItem>
			<events>
				<script type="text/hscript" action="mouseClick">
					<![CDATA[
						this.selected = ! this.selected;
						this.color = this.selected ? DefaultStyle.FOCUS : DefaultStyle.INPUT_BACK;
						this.redraw();
					]]>
				</script>
			</events>
		</haxegui:controls:ListItem>
	</haxegui:Style>
	').firstElement();


	//{{{ init
	override public function init(opts:Dynamic=null) {
		if(!Std.is(parent, UiList) && !Std.is(parent, PopupMenu)) throw parent+" not a UiList";
		box = new Size(140, 24).toRect();
		color = DefaultStyle.INPUT_BACK;
		oldParent = parent;
		data = name;

		super.init(opts);

		// xml.set("name", name);

		XmlParser.apply(ListItem.styleXml, true);
		XmlParser.apply(ListItem.layoutXml, this);


		description = null;


		label = cast firstChild();
		label.setText(Opts.optString(opts, "label", name));
		label.mouseEnabled = false;


		try {
			data = Opts.classInstance(opts, "data", untyped [String, Float, Int, Bool, Dynamic]);
		}
		catch(e:Dynamic) {
			data = name;
		}

		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);
	}
	//}}}


	//{{{ onParentResize
	public function onParentResize(e:ResizeEvent) {
		box.width = parent.asComponent().box.width;
		dirty = true;
		// redraw();

		// dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}
	//}}}

	public override function destroy() {
		parent.removeEventListener(ResizeEvent.RESIZE, onParentResize);

		super.destroy();
	}


	//{{{ onChanged
	public function onChanged(e:Event) {
	}
	//}}}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(ListItem);
	}
	//}}}
}
//}}}


//{{{ UiList
/**
*
* Sortable List Class.<br/>
*
* The list will follow it's header if moved.
*
* @todo implements ArrayAccess<ListItem>
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir'
*
*/
class UiList extends Component, implements IDataSource, implements ArrayAccess<ListItem> {

	//{{{ Members
	/** Header for this list **/
	public var header : ListHeader;

	/** [Array] of items **/
	public var items  : List<ListItem>;

	// public var selectedIndex	(default, null) : Null<Int>;
	// public var selectedIndexes	(default, null) : Array<Null<Int>>;
	// public var selectedItem		(default, null) : ListItem;
	// public var selectedItems	(default, null) : Array<ListItem>;

	public var selectionMode : ListSelectionMode;

	/** DataSource **/
	public var dataSource(default, setDataSource) : DataSource;

	/** sort direction, default (false) is ascending **/
	public var sortReverse : Bool;

	/** true to enable dragging of items **/
	public var dragEnabled : Bool;

	/** true to enable dropping of items **/
	public var dropEnabled : Bool;


	static var layoutXml = Xml.parse('
	<haxegui:Layout name="UiList">
	<haxegui:controls:ListHeader width="{parent.box.width}" color="{parent.color}"/>
	</haxegui:Layout>
	').firstElement();

	static var styleXml = Xml.parse('
	<haxegui:Style name="UiList">
		<haxegui:controls:UiList>
		<events>
			<script type="text/hscript" action="mouseClick">
				<![CDATA[
				]]>
			</script>
			</events>
		</haxegui:controls:UiList>
	</haxegui:Style>
	').firstElement();
	//}}}


	//{{{ init
	public override function init(opts : Dynamic=null) {
		box = new Size(140, 100).toRect();
		color = DefaultStyle.BACKGROUND;
		items = new List<ListItem>();
		minSize = new Size(100,24);
		sortReverse = false;

		// dataSource = new DataSource();
		// dataSource.data = ["1", "2", "3", "4"];

		super.init(opts);

		// xml.set("name", name);

		haxegui.XmlParser.apply(UiList.styleXml, true);
		haxegui.XmlParser.apply(UiList.layoutXml, this);


		// if(opts == null) opts = {}
		// if(opts.innerData!=null)
		// data = opts.innerData.split(",");
		// if(opts.data!=null)
		// data = opts.data;


		header = cast firstChild();


		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);

		header.addEventListener(ResizeEvent.RESIZE, onHeaderResize, false, 0, true);
		header.addEventListener(MoveEvent.MOVE, 	onHeaderMoved,  false, 0, true);

		// addEventListener(ListEvent.CHANGE, 	onData,  false, 0, true);


		if(dataSource==null) return;
		dataSource.addEventListener(DataEvent.CHANGE, onData, false, 0, true);
		dataSource.dispatchEvent(new DataEvent(DataEvent.CHANGE));

		addEventListener(ListEvent.CHANGE, onData, false, 0, true);
	}
	//}}}

	// public function clearSelection() {}

	// public function setSelected(i:ListItem) : ListItem {}
	// public function setSelectedIndex(i:Int) : Int {}

	// public function getSelected() : ListItem {}
	// public function getSelectedIndex() : Int {}

	// public function getSelectedItems() : Array<ListItem> {}
	// public function getSelectedIndices() : Array<Int> {}

	// public function setSelectedItems(l:Array<ListItem>) : Array<ListItem> {}
	// public function setSelectedIndices(i:Array<Int>) : Array<Int> {}


	//{{{ onHeaderResized
	public function onHeaderResize(e:ResizeEvent) {
		box = header.box.clone();
		dirty = true;
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}
	//}}}

	//{{{ setDataSource
	public function setDataSource(d:DataSource) : DataSource {
		dataSource = d;
		dataSource.addEventListener(DataEvent.CHANGE, onData, false, 0, true);

		var l = 0;
		if(Std.is(dataSource.data, Array) || Std.is(dataSource.data, List))
		l = dataSource.data.length;

		dataSource.dispatchEvent(new DataEvent(DataEvent.CHANGE, 0, l));
		// dispatchEvent(new ListEvent(ListEvent.CHANGE));

		return dataSource;
	}
	//}}}


	//{{{ onHeaderMoved
	public function onHeaderMoved(e:MoveEvent) {
		this.move(header.x, header.y);
		header.x = header.y = 0;
	}
	//}}}


	//{{{ addChild
	override function addChild(child : DisplayObject) : DisplayObject {
		if(Std.is(child, ListItem)) items.push(cast child);
		return super.addChild(child);
	}
	//}}}


	//{{{ onParentResize
	private function onParentResize(e:ResizeEvent) : Void {
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}
	//}}}


	//{{{ onResize
	public override function onResize(e:ResizeEvent) : Void {
		// header.box.width = box.width;
		// header.dirty = true;
		// dirty = true;
		// header.redraw();

		super.onResize(e);
	}
	//}}}


	//{{{ onItemMouseUp
	public function onItemMouseUp(e:MouseEvent) : Void {
		e.target.dispatchEvent (new DragEvent (DragEvent.DRAG_COMPLETE));
		e.target.x = 0;
		// e.target.y = dragItem * 20;
		// setChildIndex(e.target, dragItem);
	}
	//}}}


	//{{{ redraw
	override public function redraw(opts:Dynamic=null) {
		// super.redraw(opts);
		this.graphics.clear();
		this.graphics.lineStyle(1, DefaultStyle.BACKGROUND.darken(20), 1);
		this.graphics.beginFill(DefaultStyle.INPUT_BACK);
		this.graphics.drawRect(-1,-1, this.box.width+1, this.box.height+1);
		this.graphics.endFill();
	}
	//}}}


	//{{{ destroy
	public override function destroy() {
		parent.removeEventListener(ResizeEvent.RESIZE, onParentResize);
		super.destroy();
	}
	//}}}



	//{{{ onData
	/**
	* @todo Xml
	*/
	public function onData(?e:DataEvent) {
		// if(dataSource==null) return;

		if(Std.is(dataSource.data, Array)) {
			var data = cast(dataSource.data, Array<Dynamic>);
			for (i in e.startIndex...e.endIndex-1) {
				if(i<numChildren) {
					var item = cast getChildAt(i);
					if(Std.is(item, ListItem)) {
						item.label.setText(data[i]);
						box.width = Math.max( box.width, item.label.tf.width + 8 );
					}
				}
				else {
					var item = new ListItem(this);
					item.init({
						// width: box.width,
						color: DefaultStyle.INPUT_BACK,
						label: data[i],
						data: data[i]
					});
					item.move(0,24*i+1);
					// box.width = Math.max( box.width, item.label.tf.width + 8 );
				}
			}
		}
		else
		if(Std.is(dataSource.data, List)) {
			var j=0;
			var data = cast(dataSource.data, List<Dynamic>);
			var items : Iterator<Dynamic> = data.iterator();
			for(i in items) {
				var item = new ListItem(this);
				item.init({
					color: DefaultStyle.INPUT_BACK,
					label: i,
					data: i
				});
				item.move(0,24+24*j+1);
				box.width = Math.max( box.width, item.label.tf.width + 8 );
				j++;
			}
		}


		// box.height = Math.max( box.height, 20*items.length );

		// for(i in this)
		// (cast i).dirty=true;
	}
	//}}}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(UiList);
	}
	//}}}
}
//}}}


//{{{ ListBox
/**
* Alias for a [UiList] with a [ScrollBar]
* @todo
*/
class ListBox extends UiList {
	public var scrollbar : ScrollBar;

	//{{{ init
	public override function init(opts:Dynamic=null) {
		super.init(opts);


		scrollbar = new ScrollBar(this);
		scrollbar.init({target: null, height: box.height});

		scrollbar.addEventListener(Event.CHANGE, onScroll, false, 0, true);
		scrollRect = box.clone();
	}
	//}}}


	//{{{ onScroll
	public function onScroll(e:Event) {
		// trace(e);
	}
	//}}}


	//{{{ onResize
	public override function onResize(e:ResizeEvent) {
		scrollbar.moveTo(0, 24);
		scrollbar.toFront();
		scrollRect = box.clone();
		super.onResize(e);
	}
	//}}}


	//{{{ __init__
	static function __init__() {
		haxegui.Haxegui.register(ListBox);
	}
	//}}}
}
//}}}