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
package org.libspark.thread.utils;


import org.libspark.thread.Thread;

/**
 * Executor は複数のスレッドを実行するスレッドのための基底クラスです.
 * 
 * @author	utibenkei
 */
class Executor extends Thread
{
	public var numThreads(get, never):Int;

	/**
	 * 新しい Executor クラスのインスタンスを作成します.
	 */
	public function new()
	{
		super();
		_threads = [];
	}
	
	/**
	 * @private
	 */
	private var _threads:Array<Thread>;
	
	/**
	 * 実行されるスレッドの数を返します.
	 */
	private function get_numThreads():Int
	{
		return _threads.length;
	}
	
	/**
	 * 指定されたインデックスのスレッドを取得します.
	 * 
	 * @param	index	取得スレッドのインデックス
	 * @return	インデックスの位置にあるスレッド
	 */
	public function getThreadAt(index:Int):Thread
	{
		return _threads[index];
	}
	
	/**
	 * 指定されたスレッドを追加します.
	 * 
	 * @param	thread	追加するスレッド
	 * @return	追加されたスレッド
	 */
	public function addThread(thread:Thread):Thread
	{
		_threads.push(thread);
		
		return thread;
	}
}

