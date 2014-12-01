/*
 * ActionScript Thread Library
 * 
 * Licensed under the MIT License
 * 
 * Copyright (c) 2008 BeInteractive! (www.be-interactive.org) and
 *                    Spark project  (www.libspark.org)
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

import org.libspark.thread.Thread;

/**
	 * IMonitor インターフェイスは、スレッドのモニタ機構に関するメソッドを提供します.
	 * 
	 * <p>モニタ機構は、スレッドを協調動作させるために使用します。たとえば、あるリソースが利用可能になるまで、
	 * そのリソースを利用する必要があるスレッドを待機させる、といったことが出来ます。</p>
	 * 
	 * @author	yossy:beinteractive
	 */
interface IMonitor
{

    /**
		 * 別のスレッドがこのモニターの notify メソッドまたは notifyAll メソッドを呼び出すか、指定された時間が経過するまで、現在のスレッドを待機させます.
		 * 
		 * @param	timeout	待機させる時間 (ミリ秒)。 0 を指定した場合、永遠に待ち続けます
		 * @see	#notify()
		 * @see	#notifyAll()
		 */
    function wait(timeout : Int = 0) : Void;
    
    /**
		 * このモニターで待機中のスレッドを 1 つ再開します.
		 * 
		 * @see	#wait()
		 */
    function notify() : Void;
    
    /**
		 * このモニターで待機中のすべてのスレッドを再開します.
		 * 
		 * @see	#wait()
		 */
    function notifyAll() : Void;
    
    /**
		 * 待機中に例外が発生した等の理由で、指定されたスレッドがこのモニタの待機セットから抜けることを伝えます.
		 * 
		 * <p>通常、このメソッドは内部的にのみ使用され、ユーザーが呼び出す必要はありません。</p>
		 * 
		 * @param	thread	待機セットから抜けるスレッド
		 */
    function leave(thread : Thread) : Void;
}
