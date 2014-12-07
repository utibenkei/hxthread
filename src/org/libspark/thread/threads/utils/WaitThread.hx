/*
 * Haxe port of ActionScript Thread Library
 * 
 * Licensed under the MIT License
 * 
 * Copyright (c) 2014 utibenkei
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
package org.libspark.thread.threads.utils;


import flash.events.TimerEvent;
import flash.utils.Timer;
import org.libspark.thread.Thread;

class WaitThread extends Thread
{
	private var _timer:Timer;
	
	/**
	 * 新しい WaitThread インスタンスを作成します.
	 *
	 * @param time 待機したいミリ秒です.
	 */
	public function new(time:Int)
	{
		super();
		_timer = new Timer(time, 1);
	}
	
	override private function run():Void
	{
		Thread.event(_timer, TimerEvent.TIMER_COMPLETE, completeHandler);
		Thread.interrupted(interruptedHandler);
		_timer.start();
	}
	
	override private function finalize():Void
	{
		_timer = null;
	}
	
	private function completeHandler(e:TimerEvent):Void
	{
		// do nothing.
		
	}
	
	private function interruptedHandler():Void
	{
		if (_timer.running) {
			_timer.stop();
		}
	}
}

