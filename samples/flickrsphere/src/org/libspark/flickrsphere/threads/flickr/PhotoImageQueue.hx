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
package org.libspark.flickrsphere.threads.flickr;


import flash.display.Loader;
import org.libspark.thread.IMonitor;
import org.libspark.thread.Monitor;

/**
 * PhotoImageQueue クラスは、ロードした写真イメージをストックするためのキューです.
 */
class PhotoImageQueue
{
	public var isEmpty(get, never):Bool;

	public function new()
	{
		_queue = [];
		_monitor = new Monitor();
	}
	
	private var _queue:Array<Dynamic>;
	private var _monitor:IMonitor;
	
	/**
	 * キューが空であれば true、そうでなければ false を返します.
	 */
	private function get_IsEmpty():Bool
	{
		return _queue.length == 0;
	}
	
	/**
	 * キューに指定されたイメージを追加します.
	 * 
	 * @param	image	追加するイメージ
	 */
	public function offer(image:Loader):Void
	{
		// キューに追加
		_queue.push(image);
		// checkPoll でイメージを取得可能になるまで待機しているスレッドを起こす
		_monitor.notifyAll();
	}
	
	/**
	 * キューからイメージを取得可能かどうかをチェックし、可能でなければ取得可能になるまでスレッドを待機させます.
	 * 
	 * @return	スレッドが待機する場合に true、そうでなければ false
	 */
	public function checkPoll():Bool
	{
		// キューが空であれば
		if (isEmpty) {
			// スレッドを待機させる
			_monitor.wait();
			return true;
		}
		return false;
	}
	
	/**
	 * キューからイメージを取得します.
	 * 
	 * @return	イメージ
	 */
	public function poll():Loader
	{
		// キューから取得
		return _queue.shift();
	}
}
