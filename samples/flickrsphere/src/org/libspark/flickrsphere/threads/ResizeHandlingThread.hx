/*
 * Flickr Sphere (Sample of the ActionScript Thread Library)
 * 
 * Licensed under the MIT License
 * 
 * Copyright (c) 2008 BeInteractive! (www.be-interactive.org) and
 *					  Spark project	 (www.libspark.org)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 */
package org.libspark.flickrsphere.threads;


import flash.display.Stage;
import flash.events.Event;
import org.libspark.flickrsphere.Context;
import org.libspark.thread.Thread;
import org.libspark.thread.threads.tweener.TweenerThread;

/**
 * ResizeHandlingThread クラスは、リサイズ時の再レイアウトを行います.
 */
class ResizeHandlingThread extends Thread
{
	public function new(context:Context)
	{
		super();
		_context = context;
	}
	
	private var _context:Context;
	
	override private function run():Void
	{
		resizeHandler();
	}
	
	private function resizeHandler(e:Event = null):Void
	{
		var stage:Stage = _context.stage;
		var sw:Float = stage.stageWidth;
		var sh:Float = stage.stageHeight;
		
		// Viewport 位置
		_context.viewport.x = (sw - 800) / 2;
		
		// タイトル位置
		_context.layer.getChildByName("title").x = sw - 10;
		
		// ロゴ位置
		_context.layer.getChildByName("logos").x = sw - 10;
		
		event(stage, Event.RESIZE, resizeHandler);
	}
}
