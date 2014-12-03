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
 * IThreadExecutor インターフェイスはスレッドの実行タイミングを制御する役割を持ちます.
 * 
 * <p>IThreadExecutor インターフェイスの実装クラスは、 Thread#executeAllThreads メソッドを呼び出して、
 * スレッドを実行する必要があります。この動作は、何らかの条件に基づいて、 start メソッドが呼び出されてから、
 * stop メソッドが呼び出されるまで、断続的に行う必要があります。</p>
 * 
 * @author	utibenkei
 * @see	Thread#executeAllThreads()
 */
interface IThreadExecutor
{

	/**
	 * IThreadExecutor の実行を開始します.
	 * 
	 * <p>このメソッドが呼び出された後は、何らかの条件に基づいて、 stop メソッドが呼び出されるまで、
	 * Thread#executeAllThreads メソッドを断続的に呼び出すことが求められます。</p>
	 */
	function start():Void;
	
	/**
	 * IThreadExecutor の実行を終了します.
	 */
	function stop():Void;
}
