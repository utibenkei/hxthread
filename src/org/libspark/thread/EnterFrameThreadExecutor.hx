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
package org.libspark.thread;


import org.libspark.thread.IThreadExecutor;
import flash.display.MovieClip;
import flash.events.Event;

/**
 * EnterFrameThreadExecutor クラスは IThreadExecutor インターフェイスの実装クラスで、
 * フレーム実行のタイミングでスレッドを実行します.
 * 
 * @author	utibenkei
 */
class EnterFrameThreadExecutor implements IThreadExecutor
{
	/**
	 * 新しい EnterFrameThreadExecutor クラスのインスタンスを作成します
	 */
	public function new()
	{
		
	}
	
	private var _clip:MovieClip;
	
	/**
	 * @inheritDoc
	 */
	public function start():Void
	{
		if (_clip != null) {
			return;
		}
		
		_clip = new MovieClip();
		_clip.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		
		
		#if (native || html5)
		// openflの native/html5 ターゲットではaddChild()しないとイベントが発行されない現象への対処
		openfl.Lib.current.addChild(_clip);
		#end
		
	}
	
	/**
	 * @inheritDoc
	 */
	public function stop():Void
	{
		if (_clip == null) {
			return;
		}
		
		#if (native || html5)
		openfl.Lib.current.removeChild(_clip);
		#end
		
		_clip.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		_clip = null;
	}
	
	/**
	 * フレーム実行ハンドラ
	 * 
	 * @param	e	イベント
	 * @private
	 */
	private function enterFrameHandler(e:Event):Void
	{
		Thread.executeAllThreads();
	}
}
