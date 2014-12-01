package org.libspark.thread;

import org.libspark.thread.EnterFrameThreadExecutor;

import flash.events.Event;
import org.libspark.as3unit.assert.*;
import org.libspark.as3unit.Before;
import org.libspark.as3unit.After;
import org.libspark.as3unit.Test;





class TesterThreadTest
{
    /**
		 * テストに相互作用が出ないようにテスト毎にスレッドライブラリを初期化。
		 * 通常であれば、initializeの呼び出しは一度きり。
		 */
    private function initialize() : Void
    {
        Thread.initialize(new EnterFrameThreadExecutor());
    }
    
    /**
		 * 念のため、終了処理もしておく
		 */
    private function finalize() : Void
    {
        Thread.initialize(null);
    }
    
    /**
		 * TesterThread が終了した際に Event.COMPLETE が配信されるかどうか。
		 */
    private function tester() : Void
    {
        var t : TesterThread = new TesterThread(null);
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.isTrue(true);
                        }, 1000));
        t.start();
    }

    public function new()
    {
    }
}
