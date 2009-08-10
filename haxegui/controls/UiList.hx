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
import haxegui.controls.Component;
import haxegui.controls.IData;
import haxegui.controls.Seperator;
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

	//{{{  init
	/**
	* @throws String when not parented to a [UiList]
	*/
	override public function init(opts:Dynamic=null) {if(!Std.is(parent, UiList)) throw parent+" not a UiList";
		if(!Std.is(parent, UiList)) throw parent+" not a UiList";

		//~ mouseChildren = true;

		super.init(opts);

		labels = [new Label(this)];
		labels[0].init({text : name});
		labels[0].moveTo(4,4);

		arrow = new Arrow(this);
		arrow.init({ width: 8, height: 8, color: haxegui.utils.Color.darken(this.color, 20)});
		arrow.rotation = (cast parent).sortReverse ? -90 : 90;
		//~ arrow.moveTo((cast parent).box.width - 10, 10);
		arrow.moveTo( labels[0].x + labels[0].width + 10, 10);


		seperators = [new Seperator(this)];
		seperators[0].init({});
		seperators[0].moveTo(labels[0].x + labels[0].width + 18, 4);


		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);
	} //}}}


	//{{{ onMouseDown
	override public function onMouseDown(e:MouseEvent) : Void {
		if(Std.is(e.target, Label)) {
			e.target.startDrag(false, new Rectangle(0, e.target.y, box.width - e.target.box.width, 0));
			//~ e.stopImmediatePropagation();
			CursorManager.getInstance().lock = true;
			return;
		}
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
		box = (cast parent).box.clone();
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
class ListItem extends AbstractButton, implements IRubberBand, implements IAggregate {
	public var label : Label;
	public var selected : Bool;

	//{{{ init
	override public function init(opts:Dynamic=null) {
		if(!Std.is(parent, UiList) && !Std.is(parent, PopupMenu)) throw parent+" not a UiList";
		box = new Size(140, 20).toRect();
		color = DefaultStyle.INPUT_BACK;

		super.init(opts);

		label = new Label(this);
		label.init({text: Opts.optString(opts, "label", name), color: DefaultStyle.INPUT_TEXT });
		label.move(4,4);
		label.mouseEnabled = false;

		description = null;

		// add the drop-shadow filter
		//~ var shadow:DropShadowFilter = new DropShadowFilter (4, 45, DefaultStyle.DROPSHADOW, 0.5, 4, 4, 0.5, BitmapFilterQuality.HIGH, true, false, false );
		//~ this.filters = [shadow];
		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);

		//~ setAction("mouseOver", "");
		//~ setAction("mouseOut", "");

	}
	//}}}


	//{{{ onParentResize
	public function onParentResize(e:ResizeEvent) {box.width = (cast parent).box.width;
		box.width = (cast parent).box.width;
		dirty = true;
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
* The list will follow it's header it moved.
*
* @version 0.1
* @author Omer Goshen <gershon@goosemoose.com>
* @author Russell Weir'
*
*/
class UiList extends Component, implements IData, implements ArrayAccess<ListItem> {
	//{{{ Members
	/** Header for this list **/
	public var header : ListHeader;

	/** [Array] of items **/
	public var items  : List<ListItem>;


	public var data : Dynamic;
	public var dataSource( default, __setDataSource ) : DataSource;

	/** sort direction, default (false) is ascending **/
	public var sortReverse : Bool;

	/** true to enable dragging of items **/
	public var dragEnabled : Bool;

	/** index of the dragged item **/
	var dragItem : Int;
	//}}}


	//{{{ init
	public override function init(opts : Dynamic=null) {
		box = new Size(140, 100).toRect();
		color = DefaultStyle.BACKGROUND;
		sortReverse = false;
		items = new List<ListItem>();

		if(Std.is(parent, Component))
		color = parent.asComponent().color;

		if(data==null)
		data = [];

		super.init(opts);

		if(opts == null) opts = {}
		if(opts.innerData!=null)
		data = opts.innerData.split(",");
		if(opts.data!=null)
		data = opts.data;


		header = new ListHeader(this);
		header.init({color: this.color, width: this.box.width});


		if(Std.is(data, Array)) {
			data = cast(data, Array<Dynamic>);
			for (i in 0...data.length) {
				var item = new ListItem(this);
				item.init({ width: this.box.width,
					color: DefaultStyle.INPUT_BACK,
					label: data[i]
				});
				//item.label.mouseEnabled = false;
				item.move(0,20+20*i+1);
			}
		}
		else
		if(Std.is(data, List)) {
			var j=0;
			data = cast(data, List<Dynamic>);
			var items : Iterator<Dynamic> = data.iterator();
			for(i in items) {
				var item = new ListItem(this);
				item.init({ color: DefaultStyle.INPUT_BACK,
					label: i
				});
				//item.label.mouseEnabled = false;
				item.move(0,20+20*j+1);
				j++;
			}
		}

		for(i in this) {
			//untyped box.width = i.box.width = Math.max(box.width, i.label.tf.width);
			(cast i).dirty=true;
		}

		parent.addEventListener(ResizeEvent.RESIZE, onParentResize, false, 0, true);
		header.addEventListener(MoveEvent.MOVE, onHeaderMoved, false, 0, true);
	}
	//}}}


	//{{{ onHeaderMoved
	public function onHeaderMoved(e:MoveEvent) {
		this.move(header.x, header.y);
		header.x = 0;
		header.y = 0;
	}
	//}}}


	//{{{ __setDataSource
	public function __setDataSource(d:DataSource) : DataSource {
		dataSource = d;
		dataSource.addEventListener(Event.CHANGE, onData, false, 0, true);

		#if debug
		trace(this.dataSource+" => "+this);
		trace(this.dataSource+": "+dataSource.data);
		#end

		if(Std.is(dataSource.data, List)) {
			var j=0;
			data = cast(dataSource.data, List<Dynamic>);
			var items : Iterator<Dynamic> = data.iterator();
			for(i in items) {
				var item = new ListItem(this);
				item.init({ color: DefaultStyle.INPUT_BACK,
					label: i
				});
				box.width = item.box.width = Math.max(box.width, item.label.tf.width);
				item.label.mouseEnabled = false;
				item.move(0,header==null ? 0 : 20+20*j+1);
				j++;
			}
		}
		return dataSource;
	}
	//}}}


	//{{{ addChild
	override function addChild(child : DisplayObject) : DisplayObject {
		if(Std.is(child, ListItem)) items.push(cast child);
		return super.addChild(child);
	}
	//}}}


	//{{{ onData
	private  function onData(e:Event) {
		#if debug
		trace(e);
		#end

		data = dataSource.data;
		dirty = true;
	}
	//}}}


	//{{{ onParentResize
	private function onParentResize(e:ResizeEvent) : Void {
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
	}
	//}}}


	//{{{ onItemMouseUp
	public function onItemMouseUp(e:MouseEvent) : Void {
		e.target.dispatchEvent (new DragEvent (DragEvent.DRAG_COMPLETE));
		e.target.x = 0;
		//~ e.target.y = dragItem * 20;
		//~ e.target.y = 20 + e.target.x % 20;
		e.target.y = dragItem * 20;
		setChildIndex(e.target, dragItem);
	}
	//}}}


	//{{{ redraw
	override public function redraw(opts:Dynamic=null) {
		super.redraw(opts);

		/* Draw the frame */
		this.graphics.clear();
		this.graphics.lineStyle(1, haxegui.utils.Color.darken(DefaultStyle.BACKGROUND, 20), 1);
		//~ this.graphics.beginFill(this.color);
		this.graphics.beginFill(DefaultStyle.INPUT_BACK);
		if(header!=null)
		this.graphics.drawRect(-1,header.box.height-1, box.width+1, box.height-header.box.height+1 );
		else
		this.graphics.drawRect(-1,-1, box.width+1, box.height+1 );

		this.graphics.endFill();
	}
	//}}}


	//{{{ destroy
	public override function destroy() {
		parent.removeEventListener(ResizeEvent.RESIZE, onParentResize);
		super.destroy();
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
		scrollbar.init({target: this, height: box.height});
	}
	//}}}


	//{{{ onResize
	public override function onResize(e:ResizeEvent) {
		scrollbar.moveTo(box.width - 20, 20);
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