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


/**
 * ThreadState クラスは、スレッドの状態を表す定数を定義します.
 * 
 * <p>スレッドの状態は state プロパティで知ることができます。スレッドは特定の時点でひとつの状態しか取れません。</p>
 * 
 * @author	utibenkei
 * @see	Thread#state
 */
class ThreadState
{
	/**
	 * まだ起動されていないスレッドの状態です
	 */
	public static inline var NEW:UInt = 0;
	
	/**
	 * 実行可能なスレッド (実行フェーズ) の状態です
	 */
	public static inline var RUNNABLE:UInt = 1;
	
	/**
	 * 待機中のスレッドの状態です
	 */
	public static inline var WAITING:UInt = 2;
	
	/**
	 * 指定された時間、待機中のスレッドの状態です
	 */
	public static inline var TIMED_WAITING:UInt = 3;
	
	/**
	 * 終了処理中のスレッド (終了フェーズ) の状態です
	 */
	public static inline var TERMINATING:UInt = 4;
	
	/**
	 * 終了したスレッドの状態です
	 */
	public static inline var TERMINATED:UInt = 5;
	
}
