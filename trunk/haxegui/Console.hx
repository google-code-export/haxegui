// 
// The MIT License
// 
// Copyright (c) 2004 - 2006 Paul D Turner & The CEGUI Development Team
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

import Type;

import flash.geom.Rectangle;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.LineScaleMode;

import flash.text.TextField;
import flash.text.TextFormat;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.events.FocusEvent;
import flash.events.EventDispatcher;

import flash.ui.Keyboard;

import haxegui.events.MoveEvent;
import haxegui.events.ResizeEvent;
import haxegui.events.DragEvent;
import haxegui.events.MenuEvent;

import flash.ui.Mouse;

import flash.Error;
import haxe.Timer;
//~ import flash.utils.Timer;

import haxegui.controls.Scrollbar;


/**
 * 
 * 
 * 
 * 
 */
class Console extends Window, implements ITraceListener
{


  var parser : hscript.Parser;
  var history : Array<String>;
  var pwd : DisplayObjectContainer;
  
  var tf : TextField;
  var input : TextField;
  var vert : Scrollbar;

  
	/**
	 * 
	 */
  public function new (?parent:DisplayObjectContainer, ?x:Float, ?y:Float)  
  {
    super (parent, x, y);
    
    tf = new TextField ();
    input = new TextField();
    vert = new Scrollbar(this, "vscrollbar");

  }//end new

    
    /**
     * 
     * 
     * 
     * 
     */
    //~ public override function init(?name:String, ?x:Float, ?y:Float, ?width:Float, ?height:Float, ?sizeable:Bool)
    public override function init(?initObj:Dynamic)
    {
    
    //~ this.name =  ;
    //~ super.init("Console", x, y, width, height, sizeable);
    super.init({name:"Console", x:x, y:y, width:width, height:height, sizeable:true, color: 0x666666});
        

    box = new Rectangle (0, 0, 640, 240);

    //
    var menubar = new Menubar (this, "Menubar", 10,20);
    menubar.init ();


    //
	var container = new Container (this, "Container", 10, 44);
	container.init({color: 0x222222, alpha: .8});
    
    
        
    //    
    //~ tf = new TextField ();
    tf.name = "tf";
    tf.htmlText = "";
    tf.width = box.width - 40;
    tf.height = box.height - 70;
    //~ tf.background = true;
    //~ tf.backgroundColor = 0x222222;
    tf.border = true;
    tf.wordWrap = true;
    tf.multiline = true;
    tf.autoSize = flash.text.TextFieldAutoSize.NONE;
    tf.type = flash.text.TextFieldType.DYNAMIC;

    tf.selectable = true;
    tf.mouseEnabled = true;
    tf.focusRect = true;
    tf.tabEnabled = true;




    // 
    //~ input = new TextField();
    input.name = "input";
    input.type = flash.text.TextFieldType.INPUT;
    input.background = true;
    input.backgroundColor = 0x4D4D4D;
    input.border = true;
  
    input.width = box.width - 40;
    input.height = 20;
    input.y = box.height - 70;
    
    
    input.addEventListener (KeyboardEvent.KEY_DOWN, onKeyDown);


    //~ container.box.width -= 20;
    //~ vert = new Scrollbar(container, "vscrollbar");
    //~ vert = new Scrollbar(this, "vscrollbar");
    //~ vert.x = box.width - 40;
    vert.y = 44;
    vert.color = color;
    //~ vert.init(content);
    vert.init(tf);


    container.addChild (tf);
    container.addChild(input);


    //~ redraw (null);
    //~ menubar.redraw();

    if(isSizeable())
    {
      bl.y = frame.height - 32;
      br.x = frame.width - 32;
      br.y = frame.height - 32;
    }

   
    parser = new hscript.Parser();
    history = new Array<String>();
    pwd = flash.Lib.current;

    //~ redraw(null);
    dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));



    }
    

    

  
  

  /*
   * 
   * 
   *
   */
  public  function log( e : Dynamic, ?inf : haxe.PosInfos ) : Void 
  {
    //~ var text:String =  "";
    var text:String =  "<FONT FACE=\"MONO\" SIZE=\"10\" COLOR=\"#eeeeee\">";
    
    
    text += DateTools.format (Date.now (), "%H:%M:%S") + "\t" ;


      if(Std.is(e,Event))
       {
        text += "<B>"+e.target;
        if(Reflect.hasField(e.target, "name"))
            text += ":"+e.target.name;
        text += "</B>\t" ;
        }

        
    text += e ;
              
    tf.htmlText += text;
    tf.htmlText += "</FONT>";
    tf.scrollV = tf.maxScrollV + 1;
    
  }

    
  /*
   * 
   * 
   * 
   */
  public override function onResize (e:ResizeEvent) : Void
  {

    
    super.onResize(e);

    e.stopImmediatePropagation ();
    //~ e.stopPropagation ();

    tf.width = box.width - 32;
    tf.height = box.height - 64;

    input.width = box.width - 32;
    input.y = box.height - 64;
    
    
    vert.x = box.width - 20;
    vert.y = 44;
    vert.box.height = box.height - 44;
    vert.box.width = box.width - 20;
    vert.onResize(null);

    if( this.getChildByName("Container")!=null )
    {
    var container = cast this.getChildByName("Container");
    //~ container.box = box.clone();
    //~ container.box -=
    container.onResize(e);
    }


    if( this.getChildByName("Menubar")!=null )
    {
    var menubar = untyped this.getChildByName("Menubar");
    menubar.onResize(e);
    //~ menubar.dispatchEvent(e.clone());
    }
    
    //~ dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));

  }


    

    public function onKeyDown(e:KeyboardEvent) : Void
    {
        
        switch(e.keyCode)
        {
         case Keyboard.ENTER :
            if(input.text=="")
                //~ { tf.text += "\n"; return; }
                {
                    trace("\n");
                    return;
                }
                
                //~ 
            var program = parser.parseString(input.text);
            history.push(input.text);
            input.text = "";


            var interp = new hscript.Interp();
            interp.variables.set( "this", this );
            interp.variables.set( "pwd", this.pwd );
            interp.variables.set( "root", flash.Lib.current );
            interp.variables.set( "Timer", Timer );
            interp.variables.set( "Math", Math );

            interp.variables.set( "clear", clear() );
            interp.variables.set( "print_r", Utils.print_r );
            interp.variables.set( "ls", Utils.print_r(pwd) );

            interp.variables.set( "new", createInstance );
            interp.variables.set( "class", getClass );            

            //~ var ret : Dynamic = interp.execute(program);
                   //~ trace( ret==null ? "\n" : ret ); 
            
            try
            {
                trace(interp.execute(program));

            }
            catch(e:Dynamic)
            {
                trace("ERROR: " + e);
            }
            
        //~ default:

         case Keyboard.UP :
            input.text = history.pop();
         

        }
        
    }

    public function clear()
    {
        tf.text = "";
    }
    
    

    function createInstance( s : String, a : Array<Dynamic> )
	{
		return Type.createInstance( Type.resolveClass( s ), a );
	}

	function getClass( s : String )
	{
		return Type.resolveClass( s );
	}
    

}
