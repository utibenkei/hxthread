package org.libspark.thread;

import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.TesterThread;

import flash.events.Event;
import org.libspark.as3unit.assert.*;
import org.libspark.as3unit.Before;
import org.libspark.as3unit.After;
import org.libspark.as3unit.Test;
import org.libspark.as3unit.Ignore;








import org.libspark.thread.Thread;
import org.libspark.thread.ThreadState;
import org.libspark.thread.IMonitor;
import org.libspark.thread.Monitor;
import flash.utils.SetTimeout;

class MonitorTest
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
		 * wait を呼び出して待機しているスレッドが notify の呼び出しで起きるかどうか。
		 * 待機しているスレッドのうち、ひとつだけが起きる。
		 */
    private function notify() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new NotifyTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("run wait wait notify wakeup notify wakeup ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * wait を呼び出して待機しているスレッドが notifyAll の呼び出しで起きるかどうか。
		 * 待機しているスレッドのすべてが起きる。
		 */
    private function notifyAll() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new NotifyAllTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("run wait wait notifyAll wakeup wakeup ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * wait で待機中のスレッドの state が WAITING になっているかどうか。
		 * スレッドが起きた後は RUNNABLE に戻る。
		 */
    private function state() : Void
    {
        var s : StateTestThread = new StateTestThread();
        var t : TesterThread = new TesterThread(s);
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual(ThreadState.WAITING, s.state1);
                            Assert.areEqual(ThreadState.RUNNABLE, s.state2);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 待機時間を設定した wait で指定時間経過後、timeout で指定した実行関数に移行するかどうか。
		 * 
		 */
    private function timeout() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new TimeoutTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("run wait wakeup2 notify ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 待機時間を設定した wait で待機中のスレッドの state が TIMED_WAITING になっているかどうか。
		 * スレッドが起きた後は RUNNABLE に戻る。
		 */
    private function timedState() : Void
    {
        var s : TimedStateTestThread = new TimedStateTestThread();
        var t : TesterThread = new TesterThread(s);
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual(ThreadState.TIMED_WAITING, s.state1);
                            Assert.areEqual(ThreadState.RUNNABLE, s.state2);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 終了フェーズに入る直前で wait した場合きちんと動作するかどうか。
		 */
    private function waitFinalize() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new WaitFinalizeTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("wait notifyAll finalize ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 終了フェーズに入る直前で wait がタイムアウトした場合きちんと動作するかどうか。
		 */
    private function timeoutFinalize() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new TimeoutFinaizeTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("wait finalize ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 終了直前で wait した場合きちんと動作するかどうか。
		 */
    private function finalizeWait() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new FinalizeWaitTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("finalize notifyAll ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 終了直前で wait がタイムアウトした場合きちんと動作するかどうか。
		 */
    private function finalizeTimeout() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new FinalizeTimeoutTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("finalize ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 終了直前で wait がタイムアウトした場合タイムアウトハンドラを実行して終了できるかどうか。
		 */
    private function finalizeTimeoutHandler() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new FinalizeTimeoutHandlerTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("finalize wakeup ", Static.log);
                        }, 1000));
        
        t.start();
    }

    public function new()
    {
    }
}




class Static
{
    public static var log : String;

    public function new()
    {
    }
}

class NotifyTestThread extends Thread
{
    private var _monitor : IMonitor;
    
    override private function run() : Void
    {
        Static.log += "run ";
        
        _monitor = new Monitor();
        new WaitThread(_monitor).start();
        new WaitThread(_monitor).start();
        
        next(run2);
    }
    
    private function run2() : Void
    {
        next(run3);
    }
    
    private function run3() : Void
    {
        next(run4);
    }
    
    private function run4() : Void
    {
        Static.log += "notify ";
        _monitor.notify();
        next(run5);
    }
    
    private function run5() : Void
    {
        Static.log += "notify ";
        _monitor.notify();
        next(run6);
    }
    
    private function run6() : Void
    {
        
        
    }

    public function new()
    {
        super();
    }
}

class NotifyAllTestThread extends Thread
{
    private var _monitor : IMonitor;
    
    override private function run() : Void
    {
        Static.log += "run ";
        
        _monitor = new Monitor();
        new WaitThread(_monitor).start();
        new WaitThread(_monitor).start();
        
        next(run2);
    }
    
    private function run2() : Void
    {
        next(run3);
    }
    
    private function run3() : Void
    {
        next(run4);
    }
    
    private function run4() : Void
    {
        Static.log += "notifyAll ";
        _monitor.notifyAll();
        next(run5);
    }
    
    private function run5() : Void
    {
        
    }

    public function new()
    {
        super();
    }
}

class StateTestThread extends Thread
{
    public var thread : Thread;
    public var state1 : Int = ThreadState.NEW;
    public var state2 : Int = ThreadState.NEW;
    
    private var _monitor : IMonitor;
    
    override private function run() : Void
    {
        _monitor = new Monitor();
        
        thread = new WaitThread(_monitor);
        thread.start();
        
        next(run2);
    }
    
    private function run2() : Void
    {
        next(run3);
    }
    
    private function run3() : Void
    {
        state1 = thread.state;
        next(run4);
    }
    
    private function run4() : Void
    {
        _monitor.notifyAll();
        next(run5);
    }
    
    private function run5() : Void
    {
        state2 = thread.state;
    }

    public function new()
    {
        super();
    }
}

class WaitThread extends Thread
{
    public function new(monitor : IMonitor)
    {
        super();
        _monitor = monitor;
    }
    
    private var _monitor : IMonitor;
    
    override private function run() : Void
    {
        Static.log += "wait ";
        _monitor.wait();
        next(wakeup);
    }
    
    private function wakeup() : Void
    {
        Static.log += "wakeup ";
        next(run2);
    }
    
    private function run2() : Void
    {
        
        
    }
}

class TimeoutTestThread extends Thread
{
    public var thread : TimedWaitThread;
    
    private var _monitor : IMonitor;
    
    override private function run() : Void
    {
        Static.log += "run ";
        
        _monitor = new Monitor();
        
        thread = new TimedWaitThread(_monitor);
        thread.start();
        
        next(run2);
    }
    
    private function run2() : Void
    {
        next(run3);
    }
    
    private function run3() : Void
    {
        if (!thread.wu) {
            next(run3);
        }
        else {
            next(run4);
        }
    }
    
    private function run4() : Void
    {
        Static.log += "notify ";
        _monitor.notifyAll();
        next(run5);
    }
    
    private function run5() : Void
    {
        
    }

    public function new()
    {
        super();
    }
}

class TimedStateTestThread extends Thread
{
    public var thread : TimedWaitThread;
    public var state1 : Int;
    public var state2 : Int;
    
    private var _monitor : IMonitor;
    
    override private function run() : Void
    {
        _monitor = new Monitor();
        
        thread = new TimedWaitThread(_monitor);
        thread.start();
        
        next(run2);
    }
    
    private function run2() : Void
    {
        next(run3);
    }
    
    private function run3() : Void
    {
        state1 = thread.state;
        next(run4);
    }
    
    private function run4() : Void
    {
        if (!thread.wu) {
            next(run4);
        }
        else {
            next(run5);
        }
    }
    
    private function run5() : Void
    {
        state2 = thread.state;
    }

    public function new()
    {
        super();
    }
}

class TimedWaitThread extends Thread
{
    public function new(monitor : IMonitor)
    {
        super();
        _monitor = monitor;
    }
    
    public var wu : Bool = false;
    
    private var _monitor : IMonitor;
    
    override private function run() : Void
    {
        Static.log += "wait ";
        _monitor.wait(500);
        next(wakeup);
        timeout(wakeup2);
    }
    
    private function wakeup() : Void
    {
        wu = true;
        Static.log += "wakeup ";
        next(run2);
    }
    
    private function wakeup2() : Void
    {
        wu = true;
        Static.log += "wakeup2 ";
        next(run2);
    }
    
    private function run2() : Void
    {
        next(run3);
    }
    
    private function run3() : Void
    {
        
        
    }
}

class WaitFinalizeTestThread extends Thread
{
    private var _monitor : IMonitor = new Monitor();
    
    override private function run() : Void
    {
        Static.log += "wait ";
        
        _monitor.wait();
        
        setTimeout(timeoutHandler, 100);
    }
    
    private function timeoutHandler() : Void
    {
        Static.log += "notifyAll ";
        
        _monitor.notifyAll();
    }
    
    override private function finalize() : Void
    {
        Static.log += "finalize ";
    }

    public function new()
    {
        super();
    }
}

class TimeoutFinaizeTestThread extends Thread
{
    override private function run() : Void
    {
        Static.log += "wait ";
        
        new Monitor().wait(100);
    }
    
    override private function finalize() : Void
    {
        Static.log += "finalize ";
    }

    public function new()
    {
        super();
    }
}

class FinalizeWaitTestThread extends Thread
{
    private var _monitor : IMonitor = new Monitor();
    
    override private function finalize() : Void
    {
        Static.log += "finalize ";
        
        _monitor.wait();
        
        setTimeout(timeoutHandler, 500);
    }
    
    private function timeoutHandler() : Void
    {
        Static.log += "notifyAll ";
        
        _monitor.notifyAll();
    }

    public function new()
    {
        super();
    }
}

class FinalizeTimeoutTestThread extends Thread
{
    override private function finalize() : Void
    {
        Static.log += "finalize ";
        
        new Monitor().wait(100);
    }

    public function new()
    {
        super();
    }
}

class FinalizeTimeoutHandlerTestThread extends Thread
{
    override private function finalize() : Void
    {
        Static.log += "finalize ";
        
        new Monitor().wait(100);
        
        timeout(wakeup);
    }
    
    private function wakeup() : Void
    {
        Static.log += "wakeup ";
    }

    public function new()
    {
        super();
    }
}