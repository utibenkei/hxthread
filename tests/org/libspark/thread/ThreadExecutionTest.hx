package org.libspark.thread;

import org.libspark.thread.EnterFrameThreadExecutor;

import flash.events.Event;
import org.libspark.as3unit.assert.*;
import org.libspark.as3unit.Before;
import org.libspark.as3unit.After;
import org.libspark.as3unit.Test;
import org.libspark.as3unit.TestExpected;
import org.libspark.thread.errors.IllegalThreadStateError;
import org.libspark.thread.errors.ThreadLibraryNotInitializedError;







import org.libspark.thread.Thread;
import org.libspark.thread.ThreadState;

class ThreadExecutionTest
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
		 * start したら run が実行されるか
		 */
    private function start() : Void
    {
        Static.run = false;
        
        var t : TesterThread = new TesterThread(new StartTestThread());
        
        Assert.isFalse(Static.run);
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.isTrue(Static.run);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 既に実行しているスレッドを start したら IllegalThreadStateError がスローされるか。
		 */
    private static var startError : Class<Dynamic> = IllegalThreadStateError;
    private function startError() : Void
    {
        var t : Thread = new Thread();
        t.start();
        t.start();
    }
    
    /**
		 * スレッドライブラリが初期化されていない状態で start したら ThreadLibraryNotInitializedError がスローされるか。
		 */
    private static var initializeError : Class<Dynamic> = ThreadLibraryNotInitializedError;
    private function initializeError() : Void
    {
        Thread.initialize(null);
        
        var t : Thread = new Thread();
        t.start();
    }
    
    /**
		 * currentThread にきちんと現在実行中のスレッドが設定されているか。
		 * 実行中のスレッドが無い(擬似スレッドなのでこういうことが起こりうる)場合は null が設定される。
		 */
    private function currentThread() : Void
    {
        var c : CurrentThreadTestThread = new CurrentThreadTestThread();
        var t : TesterThread = new TesterThread(c);
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            assertSame(c, c.current);
                        }, 1000));
        
        Assert.isNull(Thread.currentThread);
        
        t.start();
    }
    
    /**
		 * next による実行関数の切り替えが行えているか。
		 * next を呼び出さない場合、実行フェーズ → 終了フェーズ → 終了 という順で遷移する。
		 * next は finalize の中(終了フェーズ, state == ThreadState.TERMINATING)でも有効。
		 */
    private function next() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new NextTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("run run2 run3 finalize finalize2 ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * state が NEW → RUNNABLE → TERMINATING → TERMINATED という順で切り替わっているか。
		 */
    private function state() : Void
    {
        var s : StateTestThread = new StateTestThread();
        var t : TesterThread = new TesterThread(s);
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual(ThreadState.RUNNABLE, s.state1);
                            Assert.areEqual(ThreadState.RUNNABLE, s.state2);
                            Assert.areEqual(ThreadState.TERMINATING, s.state3);
                            Assert.areEqual(ThreadState.TERMINATING, s.state4);
                            Assert.areEqual(ThreadState.TERMINATED, s.state);
                        }, 1000));
        
        Assert.areEqual(ThreadState.NEW, s.state);
        
        t.start();
    }
    
    /**
		 * 子スレッドが正しく呼び出されているか。
		 * あるスレッドが別のスレッドの start を呼び出した際、start を呼び出したほうのスレッドを親スレッド、start が呼び出されたほうのスレッドを子スレッドと呼ぶ。
		 * 子スレッドは、その親スレッドよりも前に、start された順で実行されることが保証される。
		 */
    private function childThread() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new ChildThreadTestParentThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("p.run c1.run c2.run p.run2 c1.run2 c2.run2 p.run3 c1.finalize c2.finalize p.finalize ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 孤児スレッドが正しく呼び出されているか。
		 * 子スレッドの終了より先に親スレッドが終了した場合、子スレッドは孤児スレッドとなる。
		 * 孤児スレッドは親スレッドから切り離され、トップレベルに移されて実行が継続される。
		 */
    private function orphanThread() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new OrphanTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("p.run c.run p.finalize c.run2 c.finalize ", Static.log);
                        }, 1000));
        
        t.start();
    }

    public function new()
    {
    }
}



class Static
{
    public static var run : Bool;
    public static var log : String;

    public function new()
    {
    }
}

class StartTestThread extends Thread
{
    override private function run() : Void
    {
        Static.run = true;
    }

    public function new()
    {
        super();
    }
}

class CurrentThreadTestThread extends Thread
{
    public var current : Thread = null;
    
    override private function run() : Void
    {
        current = currentThread;
    }

    public function new()
    {
        super();
    }
}

class NextTestThread extends Thread
{
    override private function run() : Void
    {
        Static.log += "run ";
        next(run2);
    }
    
    private function run2() : Void
    {
        Static.log += "run2 ";
        next(run3);
    }
    
    private function run3() : Void
    {
        Static.log += "run3 ";
    }
    
    override private function finalize() : Void
    {
        Static.log += "finalize ";
        next(finalize2);
    }
    
    private function finalize2() : Void
    {
        Static.log += "finalize2 ";
    }

    public function new()
    {
        super();
    }
}

class StateTestThread extends Thread
{
    public var state1 : Int = ThreadState.NEW;
    public var state2 : Int = ThreadState.NEW;
    public var state3 : Int = ThreadState.NEW;
    public var state4 : Int = ThreadState.NEW;
    
    override private function run() : Void
    {
        state1 = state;
        next(run2);
    }
    
    private function run2() : Void
    {
        state2 = state;
    }
    
    override private function finalize() : Void
    {
        state3 = state;
        next(finalize2);
    }
    
    private function finalize2() : Void
    {
        state4 = state;
    }

    public function new()
    {
        super();
    }
}

class ChildThreadTestParentThread extends Thread
{
    override private function run() : Void
    {
        Static.log += "p.run ";
        
        new ChildThreadTestChildThread("c1").start();
        new ChildThreadTestChildThread("c2").start();
        
        next(run2);
    }
    
    private function run2() : Void
    {
        Static.log += "p.run2 ";
        next(run3);
    }
    
    private function run3() : Void
    {
        Static.log += "p.run3 ";
    }
    
    override private function finalize() : Void
    {
        Static.log += "p.finalize ";
    }

    public function new()
    {
        super();
    }
}

class ChildThreadTestChildThread extends Thread
{
    public function new(name : String)
    {
        super();
        _name = name;
    }
    
    private var _name : String;
    
    override private function run() : Void
    {
        Static.log += _name + ".run ";
        next(run2);
    }
    
    private function run2() : Void
    {
        Static.log += _name + ".run2 ";
    }
    
    override private function finalize() : Void
    {
        Static.log += _name + ".finalize ";
    }
}

class OrphanTestThread extends Thread
{
    private var _c : OrphanTestChildThread;
    
    override private function run() : Void
    {
        var t : OrphanTestParentThread = new OrphanTestParentThread();
        _c = t.child;
        t.start();
        next(waitChild);
    }
    
    private function waitChild() : Void
    {
        if (!_c.isFinished) {
            next(waitChild);
        }
    }

    public function new()
    {
        super();
    }
}

class OrphanTestParentThread extends Thread
{
    public var child : OrphanTestChildThread = new OrphanTestChildThread();
    
    override private function run() : Void
    {
        Static.log += "p.run ";
        child.start();
    }
    
    override private function finalize() : Void
    {
        Static.log += "p.finalize ";
    }

    public function new()
    {
        super();
    }
}

class OrphanTestChildThread extends Thread
{
    public var isFinished : Bool = false;
    
    override private function run() : Void
    {
        Static.log += "c.run ";
        next(run2);
    }
    
    private function run2() : Void
    {
        Static.log += "c.run2 ";
    }
    
    override private function finalize() : Void
    {
        Static.log += "c.finalize ";
        isFinished = true;
    }

    public function new()
    {
        super();
    }
}