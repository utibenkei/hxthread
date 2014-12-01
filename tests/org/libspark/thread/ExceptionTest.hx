package org.libspark.thread;

import nme.errors.ArgumentError;
import nme.errors.Error;
import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.TesterThread;

import flash.events.Event;
import org.libspark.as3unit.assert.*;
import org.libspark.as3unit.Before;
import org.libspark.as3unit.After;
import org.libspark.as3unit.Test;
import org.libspark.as3unit.TestExpected;







import org.libspark.thread.Thread;
import org.libspark.thread.ThreadState;

class ExceptionTest
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
		 * 例外が発生した場合に終了フェーズに移行して終了することができるか。
		 */
    private function exception() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new ExceptionTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("run finalize ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * キャッチされない例外が発生した場合に uncaughtErrorHandler が呼び出されるか。
		 */
    private function uncaughtException() : Void
    {
        Static.log = "";
        
        var u : UncaughtExceptionTestThread = new UncaughtExceptionTestThread();
        var t : TesterThread = new TesterThread(u, false);
        var e : Dynamic;
        var th : Thread;
        
        Thread.uncaughtErrorHandler = function(ee : Dynamic, tt : Thread) : Void
                {
                    e = ee;
                    th = tt;
                };
        
        t.addEventListener(Event.COMPLETE, async(function(ev : Event) : Void
                        {
                            Thread.uncaughtErrorHandler = null;
                            
                            assertSame(u.ex, e);
                            assertSame(u, th);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 例外が発生した場合に登録されている例外ハンドラを実行できるか。
		 * 例外ハンドラが実行された後は、元の実行関数に戻る。
		 */
    private function exceptionWithHandler() : Void
    {
        Static.log = "";
        
        var e : ExceptionWithHandlerTestThread = new ExceptionWithHandlerTestThread();
        var t : TesterThread = new TesterThread(e);
        
        t.addEventListener(Event.COMPLETE, async(function(ev : Event) : Void
                        {
                            Assert.areEqual("run error run2 finalize ", Static.log);
                            assertSame(e.ex, e.e);
                            assertSame(e, e.t);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 発生した例外の型によって正しい例外ハンドラを選択することができるか。
		 * 型のマッチはスーパークラスでも有効。
		 */
    private function exceptionHandlerSelect() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new ExceptionHandlerSelectTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("throw.error error throw.argument argument throw.string string throw.number finalize ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 例外ハンドラ内で次に実行する実行関数を指定した場合、その実行関数に移行することができるか。
		 */
    private function exceptionRecovery() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new ExceptionRecoveryTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("run error run3 finalize ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 次の実行関数に移った際に、前の実行関数で登録された例外ハンドラがリセットされているか。
		 */
    private function exceptionHandlerReset() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new ExceptionHandlerResetTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("run run2 finalize ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * reset = false で例外ハンドラを登録した場合に、リセットされていないか。
		 */
    private function exceptionHandlerNoReset() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new ExceptionHandlerNoResetTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("run run2 error finalize ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 終了フェーズで例外が発生した場合に親に伝播することができるか。
		 */
    private function exceptionInFinalize() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new ExceptionInFinalizeTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("p.run c.finalize p.error p.finalize ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 終了フェーズで例外が発生した場合に例外ハンドラで処理することができるか。
		 */
    private function exceptionInFinalizeWithHandler() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new ExceptionInFinalizeWithHandlerTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("p.run c.finalize c.error p.finalize ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 例外ハンドラで例外が発生した場合に親に伝播することができるか。
		 */
    private function exceptionInHandler() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new ExceptionInHandlerTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("p.run c.run c.error p.error ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 子スレッドで発生した例外を親に伝播することができるか。
		 */
    private function childException() : Void
    {
        Static.log = "";
        
        var c : ChildExceptionTestThread = new ChildExceptionTestThread();
        var t : TesterThread = new TesterThread(c);
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("p.run c.run p.error c.finalize p.finalize ", Static.log);
                            assertSame(c.child.ex, c.e);
                            assertSame(c.child, c.t);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 親スレッドが待機中に子スレッドで発生した例外を親に伝播することができるか。
		 */
    private function childExceptionWhileWaiting() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new ChildExceptionWhileWaitingTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("p.run c.run c.run2 p.error c.finalize p.finalize ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 子スレッドで発生した例外を子スレッドの例外ハンドラで処理することができるか。
		 */
    private function childExceptionHandler() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new ChildExceptionHandlerTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("p.run c.run p.run2 c.error p.finalize c.finalize ", Static.log);
                        }, 1000));
        
        t.start();
    }
    
    /**
		 * 孫スレッドで発生した例外を伝播することができるか。
		 */
    private function grandchildException() : Void
    {
        Static.log = "";
        
        var t : TesterThread = new TesterThread(new GrandchildExceptionTestThread());
        
        t.addEventListener(Event.COMPLETE, async(function(e : Event) : Void
                        {
                            Assert.areEqual("p.run c.run p.run2 g.run c.run2 p.run2 g.run2 c.finalize p.error p.finalize g.finalize ", Static.log);
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

class ExceptionTestThread extends Thread
{
    override private function run() : Void
    {
        Static.log += "run ";
        
        next(run2);
        
        throw new Error();
    }
    
    private function run2() : Void
    {
        Static.log += "run2 ";
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

class UncaughtExceptionTestThread extends Thread
{
    public var ex : Error = new Error();
    
    override private function run() : Void
    {
        throw ex;
    }

    public function new()
    {
        super();
    }
}

class ExceptionWithHandlerTestThread extends Thread
{
    public var ex : Error = new Error();
    public var e : Error;
    public var t : Thread;
    
    override private function run() : Void
    {
        Static.log += "run ";
        
        next(run2);
        error(Error, runError);
        
        throw ex;
    }
    
    private function run2() : Void
    {
        Static.log += "run2 ";
    }
    
    private function runError(e : Error, t : Thread) : Void
    {
        Static.log += "error ";
        
        this.e = e;
        this.t = t;
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

class ExceptionHandlerSelectTestThread extends Thread
{
    override private function run() : Void
    {
        error(Error, runError, false);
        error(ArgumentError, runArgumentError, false);
        error(String, runString, false);
        
        next(throwError);
    }
    
    private function throwError() : Void
    {
        Static.log += "throw.error ";
        
        throw new Error();
    }
    
    private function runError(e : Error, t : Thread) : Void
    {
        Static.log += "error ";
        
        next(throwArgumentError);
    }
    
    private function throwArgumentError() : Void
    {
        Static.log += "throw.argument ";
        
        throw new ArgumentError();
    }
    
    private function runArgumentError(e : Error, t : Thread) : Void
    {
        Static.log += "argument ";
        
        next(throwString);
    }
    
    private function throwString() : Void
    {
        Static.log += "throw.string ";
        
        throw new String("hoge");
    }
    
    private function runString(e : String, t : Thread) : Void
    {
        Static.log += "string ";
        
        next(throwNumber);
    }
    
    private function throwNumber() : Void
    {
        Static.log += "throw.number ";
        
        throw new Float(1.0);
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

class ExceptionRecoveryTestThread extends Thread
{
    override private function run() : Void
    {
        Static.log += "run ";
        
        next(run2);
        error(Error, runError);
        
        throw new Error();
    }
    
    private function run2() : Void
    {
        Static.log += "run2 ";
    }
    
    private function runError(e : Error, t : Thread) : Void
    {
        Static.log += "error ";
        
        next(run3);
    }
    
    private function run3() : Void
    {
        Static.log += "run3 ";
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

class ExceptionHandlerResetTestThread extends Thread
{
    override private function run() : Void
    {
        Static.log += "run ";
        
        next(run2);
        error(Error, runError);
    }
    
    private function run2() : Void
    {
        Static.log += "run2 ";
        
        throw new Error();
    }
    
    private function runError(e : Error, t : Thread) : Void
    {
        Static.log += "error ";
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

class ExceptionHandlerNoResetTestThread extends Thread
{
    override private function run() : Void
    {
        Static.log += "run ";
        
        next(run2);
        error(Error, runError, false);
    }
    
    private function run2() : Void
    {
        Static.log += "run2 ";
        
        throw new Error();
    }
    
    private function runError(e : Error, t : Thread) : Void
    {
        Static.log += "error ";
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

class ExceptionInFinalizeTestThread extends Thread
{
    override private function run() : Void
    {
        Static.log += "p.run ";
        
        new ExceptionInFinalizeTestChildThread().start();
        
        next(run2);
    }
    
    private function run2() : Void
    {
        next(run2);
        error(Error, runError);
    }
    
    private function runError(e : Error, t : Thread) : Void
    {
        Static.log += "p.error ";
        
        next(null);
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

class ExceptionInFinalizeTestChildThread extends Thread
{
    override private function finalize() : Void
    {
        Static.log += "c.finalize ";
        
        throw new Error();
    }

    public function new()
    {
        super();
    }
}

class ExceptionInFinalizeWithHandlerTestThread extends Thread
{
    override private function run() : Void
    {
        Static.log += "p.run ";
        
        new ExceptionInFinalizeWithHandlerTestChildThread().start();
        
        next(run2);
    }
    
    private function run2() : Void
    {
        next(run3);
        error(Error, runError);
    }
    
    private function run3() : Void
    {
        next(run4);
        error(Error, runError);
    }
    
    private function run4() : Void
    {
        error(Error, runError);
    }
    
    private function runError(e : Error, t : Thread) : Void
    {
        Static.log += "p.error ";
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

class ExceptionInFinalizeWithHandlerTestChildThread extends Thread
{
    override private function finalize() : Void
    {
        Static.log += "c.finalize ";
        
        error(Error, runError);
        
        throw new Error();
    }
    
    private function runError(e : Error, t : Thread) : Void
    {
        Static.log += "c.error ";
    }

    public function new()
    {
        super();
    }
}

class ExceptionInHandlerTestThread extends Thread
{
    override private function run() : Void
    {
        Static.log += "p.run ";
        
        new ExceptionInHandlerTestChildThread().start();
        
        next(run2);
    }
    
    private function run2() : Void
    {
        next(run2);
        error(Error, runError);
    }
    
    private function runError(e : Error, t : Thread) : Void
    {
        Static.log += "p.error ";
        
        next(null);
    }

    public function new()
    {
        super();
    }
}

class ExceptionInHandlerTestChildThread extends Thread
{
    override private function run() : Void
    {
        Static.log += "c.run ";
        
        error(Error, runError);
        
        throw new Error();
    }
    
    private function runError(e : Error, t : Thread) : Void
    {
        Static.log += "c.error ";
        
        throw new Error();
    }

    public function new()
    {
        super();
    }
}

class ChildExceptionTestThread extends Thread
{
    public var child : ChildExceptionTestChildThread = new ChildExceptionTestChildThread();
    public var e : Error;
    public var t : Thread;
    
    override private function run() : Void
    {
        Static.log += "p.run ";
        
        child.start();
        
        error(Error, runError);
    }
    
    private function runError(e : Error, t : Thread) : Void
    {
        Static.log += "p.error ";
        
        this.e = e;
        this.t = t;
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

class ChildExceptionTestChildThread extends Thread
{
    public var ex : Error = new Error();
    
    override private function run() : Void
    {
        Static.log += "c.run ";
        
        throw ex;
    }
    
    override private function finalize() : Void
    {
        Static.log += "c.finalize ";
    }

    public function new()
    {
        super();
    }
}

class ChildExceptionWhileWaitingTestThread extends Thread
{
    override private function run() : Void
    {
        Static.log += "p.run ";
        
        new ChildExceptionWhileWaitingTestChildThread().start();
        
        error(Error, runError);
        wait();
    }
    
    private function runError(e : Error, t : Thread) : Void
    {
        Static.log += "p.error ";
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

class ChildExceptionWhileWaitingTestChildThread extends Thread
{
    public var ex : Error = new Error();
    
    override private function run() : Void
    {
        Static.log += "c.run ";
        
        next(run2);
    }
    
    private function run2() : Void
    {
        Static.log += "c.run2 ";
        
        throw ex;
    }
    
    override private function finalize() : Void
    {
        Static.log += "c.finalize ";
    }

    public function new()
    {
        super();
    }
}

class ChildExceptionHandlerTestThread extends Thread
{
    override private function run() : Void
    {
        Static.log += "p.run ";
        
        new ChildExceptionHandlerTestChildThread().start();
        
        error(Error, runError);
        next(run2);
    }
    
    private function run2() : Void
    {
        Static.log += "p.run2 ";
    }
    
    private function runError(e : Error, t : Thread) : Void
    {
        Static.log += "p.error ";
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

class ChildExceptionHandlerTestChildThread extends Thread
{
    override private function run() : Void
    {
        Static.log += "c.run ";
        
        error(Error, runError);
        
        throw new Error();
    }
    
    private function runError(e : Error, t : Thread) : Void
    {
        Static.log += "c.error ";
    }
    
    override private function finalize() : Void
    {
        Static.log += "c.finalize ";
    }

    public function new()
    {
        super();
    }
}

class GrandchildExceptionTestThread extends Thread
{
    override private function run() : Void
    {
        Static.log += "p.run ";
        
        new GrandchildExceptionTestChildThread().start();
        
        next(run2);
    }
    
    private function run2() : Void
    {
        Static.log += "p.run2 ";
        
        next(run2);
        error(Error, runError);
    }
    
    private function runError(e : Error, t : Thread) : Void
    {
        Static.log += "p.error ";
        
        next(null);
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

class GrandchildExceptionTestChildThread extends Thread
{
    override private function run() : Void
    {
        Static.log += "c.run ";
        
        new GrandchildExceptionTestGrandchildThread().start();
        
        next(run2);
    }
    
    private function run2() : Void
    {
        Static.log += "c.run2 ";
        
        next(run2);
    }
    
    override private function finalize() : Void
    {
        Static.log += "c.finalize ";
    }

    public function new()
    {
        super();
    }
}

class GrandchildExceptionTestGrandchildThread extends Thread
{
    override private function run() : Void
    {
        Static.log += "g.run ";
        
        next(run2);
    }
    
    private function run2() : Void
    {
        Static.log += "g.run2 ";
        
        throw new Error();
    }
    
    override private function finalize() : Void
    {
        Static.log += "g.finalize ";
    }

    public function new()
    {
        super();
    }
}