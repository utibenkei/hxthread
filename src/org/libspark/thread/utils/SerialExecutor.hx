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
package org.libspark.thread.utils;


import org.libspark.thread.Thread;
import org.libspark.thread.ThreadState;

/**
	 * SerialExecutor は複数のスレッドを順番に実行するためのユーティリティクラスです.
	 * 
	 * <p>開始したスレッドの終了を待って次のスレッドを実行し、全てのスレッドの実行が終了するとこのスレッドも終了します。</p>
	 * 
	 * <p>このスレッドに対して割り込みがかけられた場合、その時点で実行されているスレッドに対して同じように割り込みを掛けた上で
	 * そのスレッドの終了を待ち、それ以降のスレッドの実行をキャンセルします。</p>
	 * 
	 * <p>実行中のスレッドで例外が発生した場合、このスレッドは特に何もせず、例外を親に伝播させます。</p>
	 * 
	 * @author	yossy:beinteractive
	 */
class SerialExecutor extends Executor
{
    private var _index : Int;
    private var _current : Thread;
    
    /**
		 * @private
		 */
    override private function run() : Void
    {
        // 現在実行されているスレッドのインデックス
        _index = 0;
        // 現在実行されているスレッド
        _current = null;
        
        runThread();
    }
    
    /**
		 * @private
		 */
    private function runThread() : Void
    {
        // 実行されていたスレッドがあれば
        if (_current != null) {
            // 実行されていたスレッドを破棄
            _current = null;
            // 次のインデックスへ
            _index++;
        }  // もう実行するスレッドがない場合終了する  
        
        
        
        if (_threads.length <= _index) {
            return;
        }  // もしくは割り込まれた場合は終了する  
        
        if (checkInterrupted()) {
            return;
        }  // 新たなスレッドを取得  
        
        
        
        var thread : Thread = _threads[_index];
        
        // 現在実行されているスレッドに設定
        _current = thread;
        
        // スレッドを開始
        if (thread.state == ThreadState.NEW) {
            thread.start();
        }  // 終了を待つ  
        
        thread.join();
        
        // 割り込まれた場合
        interrupted(runInterrupted);
        
        // スレッドが終了した際に再びこのメソッドが実行されるよう設定
        next(runThread);
    }
    
    /**
		 * 割り込み処理
		 * 
		 * @private
		 */
    private function runInterrupted() : Void
    {
        // 現在実行中のスレッドに対して割り込みをかける
        _current.interrupt();
        // そのスレッドの終了を待って終了する
        _current.join();
    }

    public function new()
    {
        super();
    }
}
