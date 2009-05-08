//      Window.hx
//      
//      Copyright 2009 gershon <gershon@yellow>
//      
//      This program is free software; you can redistribute it and/or modify
//      it under the terms of the GNU General Public License as published by
//      the Free Software Foundation; either version 2 of the License, or
//      (at your option) any later version.
//      
//      This program is distributed in the hope that it will be useful,
//      but WITHOUT ANY WARRANTY; without even the implied warranty of
//      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//      GNU General Public License for more details.
//      
//      You should have received a copy of the GNU General Public License
//      along with this program; if not, write to the Free Software
//      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
//      MA 02110-1301, USA.

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

import events.MoveEvent;
import events.ResizeEvent;
import events.DragEvent;
import events.MenuEvent;

import flash.ui.Mouse;

import flash.Error;
import haxe.Timer;
//~ import flash.utils.Timer;



import controls.UiList;



/**
 * 
 * 
 * 
 */
class Stats extends Window, implements Dynamic
{

  var list : UiList;
  
  var interval : Int;
  
  var frameCounter : Int;
  var timer : Timer;
  var delta : Float;
  
  var maxFPS : Float;
  var minFPS : Float;
  
  var avgFPS : Array<Float>;
  
	/**
	 * 
	 */
  public function new (?parent:DisplayObjectContainer, ?x:Float, ?y:Float)  
  {
    super (parent, x, y);
  }//end new

    
    //~ public override function init(?name:String, ?x:Float, ?y:Float, ?width:Float, ?height:Float, ?sizeable:Bool)
    public override function init(?initObj:Dynamic)
    {
        

        //~ super.init({name:"Stats", x:x, y:y, width:width, height:height, sizeable:false, color: 0x666666});
        super.init({name:"Stats", x:x, y:y, width:width, height:height, color: 0x2A7ACD});

        frameCounter = 0;
        delta = 0;
        maxFPS = 0;
        minFPS = Math.POSITIVE_INFINITY;
        avgFPS = [.0];
        interval = 750;
        timer = new haxe.Timer(interval);
        timer.run = update;


        box = new Rectangle (0, 0, 150, 160);

        //
        var container = new Container (this, "container", 10, 20);
        //~ container.init({color: 0x222222, alpha: .5});
        container.init({color: 0x2A7ACD, alpha: .5});
        
            
        list = new UiList(container, "List");
        list.data=["FPS", "minFPS", "maxFPS", "avgFPS", "Mem", "Uptime"];
        list.init({color: 0xE5E5E5, width: 140});
        

        
        
        
        if(isSizeable())
        {
          bl.y = frame.height - 32;
          br.x = frame.width - 32;
          br.y = frame.height - 32;
        }

          this.addEventListener (Event.ENTER_FRAME, onEnterFrame);    
          

        //~ redraw(null);
        dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));


    }
    
    /**
     *
     * 
     */
    public function update() {

        //~ stats.text = "FPS: " + Std.string(frameCounter*100*(haxe.Timer.stamp() - delta)).substr(0,5);
        var fps = frameCounter/(haxe.Timer.stamp() - delta);
        
        if(fps > maxFPS) maxFPS = fps;
        if(fps < minFPS) minFPS = fps;
        
        avgFPS.push(fps);
        var avg : Float = 0;
        for(i in avgFPS)
            avg += i;
        avg /= avgFPS.length;    
        //~ if(avgFPS.length > .5*fps) avgFPS.shift();
        if(avgFPS.length > 10) avgFPS.shift();
        
        //~ stats.text = "Update every " + Std.string(interval/1000) + "sec\n\n";
        //~ stats.text += "FPS: \t\t\t" + Std.string(fps).substr(0,5) + "\n";
        //~ stats.text += "minFPS: \t\t" + Std.string(minFPS).substr(0,5) + "\n";
        //~ stats.text += "maxFPS: \t\t" + Std.string(maxFPS).substr(0,5) + "\n";
        //~ stats.text += "avgFPS: \t\t" + Std.string(avg).substr(0,5) + "\n";
        //~ stats.text += "Mem(MB): \t\t" + Std.string(flash.system.System.totalMemory/Math.pow(10,6)).substr(0,5)+"\n";
        //~ stats.text += "Uptime: \t\t" + Std.string(haxe.Timer.stamp()).substr(0,5) + "\n";
        //~ 

            list.data[0] = "FPS: \t\t\t" + Std.string(fps).substr(0,5);
            list.data[1] = "minFPS: \t\t" + Std.string(minFPS).substr(0,5);
            list.data[2] = "maxFPS: \t\t" + Std.string(maxFPS).substr(0,5);
            list.data[3] = "avgFPS: \t\t" + Std.string(avg).substr(0,5);
            list.data[4] = "Mem(MB): \t\t" + Std.string(flash.system.System.totalMemory/Math.pow(10,6)).substr(0,5);
            list.data[5] = "Uptime: \t\t\t" + Std.string(haxe.Timer.stamp()).substr(0,5);
        
        list.redraw();
        
        frameCounter = 0;
        delta = haxe.Timer.stamp();

        //~ stats.setTextFormat( StyleManager.getTextFormat(8, 0xffffff) );

    }
    
    
  public function onEnterFrame(e:Event) : Void
  {
    frameCounter++;    
  }
  
  



    





}
