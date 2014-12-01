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

import org.libspark.thread.IThreadExecutor;

import flash.events.TimerEvent;
import flash.utils.Timer;

/**
	 * IntervalThreadExecutor クラスは IThreadExecutor インターフェイスの実装クラスで、
	 * 指定された時間の間隔でスレッドを実行します.
	 * 
	 * @author	yossy:beinteractive
	 */
class IntervalThreadExecutor implements IThreadExecutor
{
    /**
		 * 新しい IntervalThreadExecutor クラスのインスタンスを作成します.
		 * 
		 * <p>ここで指定された時間の間隔でスレッドが実行されます。</p>
		 * 
		 * @param	interval	スレッドを実行する時間の間隔 (ミリ秒)
		 */
    public function new(interval : Float)
    {
        _timer = new Timer(interval);
        _timer.addEventListener(TimerEvent.TIMER, timerHandler);
    }
    
    private var _timer : Timer;
    
    /**
		 * @inheritDoc
		 */
    public function start() : Void
    {
        if (_timer.running) {
            return;
        }
        
        _timer.start();
    }
    
    /**
		 * @inheritDoc
		 */
    public function stop() : Void
    {
        if (!_timer.running) {
            return;
        }
        
        _timer.stop();
    }
    
    /**
		 * タイマーハンドラ
		 * 
		 * @private
		 */
    private function timerHandler(e : TimerEvent) : Void
    {
        Thread.executeAllThreads();
    }
}
