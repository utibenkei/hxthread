package org.libspark.thread;

import async.tests.AsyncTestCase;
import flash.errors.ArgumentError;
import flash.errors.Error;
import flash.events.Event;
import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.Thread;


class ExceptionTest extends AsyncTestCase
{
	
	public function new() 
	{
		super();
	}
	
	
	/**
	 * テストに相互作用が出ないようにテスト毎にスレッドライブラリを初期化。
	 * 通常であれば、initializeの呼び出しは一度きり。
	 */
	override public function setup():Void
	{
		Thread.initialize(new EnterFrameThreadExecutor());
	}
	
	/**
	 * 念のため、終了処理もしておく
	 */
	override public function tearDown():Void
	{
		Thread.initialize(null);
	}
	
	
	/**
	 * 例外が発生した場合に終了フェーズに移行して終了することができるか。
	 */
	public function test_exception():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new ExceptionTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("run finalize ", Static.log);
						}, 1000));
		t.start();
	}
	
	/**
	 * キャッチされない例外が発生した場合に uncaughtErrorHandler が呼び出されるか。
	 */
	public function test_uncaughtException():Void
	{
		Static.log = "";
		
		var u:UncaughtExceptionTestThread = new UncaughtExceptionTestThread();
		var t:TesterThread = new TesterThread(u, false);
		var e:Dynamic;
		var th:Thread;
		
		Thread.uncaughtErrorHandler = function(ee:Dynamic, tt:Thread):Void
				{
					e = ee;
					th = tt;
				};
		
		t.addEventListener(Event.COMPLETE, createAsync(function(ev:Event):Void
						{
							Thread.uncaughtErrorHandler = null;
							
							assertTrue((u.ex == e));
							assertTrue((u == th));
						}, 1000));
		t.start();
	}
	
	/**
	 * 例外が発生した場合に登録されている例外ハンドラを実行できるか。
	 * 例外ハンドラが実行された後は、元の実行関数に戻る。
	 */
	public function test_exceptionWithHandler():Void
	{
		Static.log = "";
		
		var e:ExceptionWithHandlerTestThread = new ExceptionWithHandlerTestThread();
		var t:TesterThread = new TesterThread(e);
		
		t.addEventListener(Event.COMPLETE, createAsync(function(ev:Event):Void
						{
							assertEquals("run error run2 finalize ", Static.log);
							assertTrue((e.ex == e.e));
							assertTrue((e == e.t));
						}, 1000));
		t.start();
	}
	
	/**
	 * 発生した例外の型によって正しい例外ハンドラを選択することができるか。
	 * 型のマッチはスーパークラスでも有効。
	 */
	public function test_exceptionHandlerSelect():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new ExceptionHandlerSelectTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("throw.error error throw.argument argument throw.string string throw.number finalize ", Static.log);
						}, 1000));
		t.start();
	}
	
	/**
	 * 例外ハンドラ内で次に実行する実行関数を指定した場合、その実行関数に移行することができるか。
	 */
	public function test_exceptionRecovery():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new ExceptionRecoveryTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("run error run3 finalize ", Static.log);
						}, 1000));
		t.start();
	}
	
	/**
	 * 次の実行関数に移った際に、前の実行関数で登録された例外ハンドラがリセットされているか。
	 */
	public function test_exceptionHandlerReset():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new ExceptionHandlerResetTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("run run2 finalize ", Static.log);
						}, 1000));
		t.start();
	}
	
	/**
	 * reset = false で例外ハンドラを登録した場合に、リセットされていないか。
	 */
	public function test_exceptionHandlerNoReset():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new ExceptionHandlerNoResetTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("run run2 error finalize ", Static.log);
						}, 1000));
		t.start();
	}
	
	/**
	 * 終了フェーズで例外が発生した場合に親に伝播することができるか。
	 */
	public function test_exceptionInFinalize():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new ExceptionInFinalizeTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("p.run c.finalize p.error p.finalize ", Static.log);
						}, 1000));
		t.start();
	}
	
	/**
	 * 終了フェーズで例外が発生した場合に例外ハンドラで処理することができるか。
	 */
	public function test_exceptionInFinalizeWithHandler():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new ExceptionInFinalizeWithHandlerTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("p.run c.finalize c.error p.finalize ", Static.log);
						}, 1000));
		t.start();
	}
	
	/**
	 * 例外ハンドラで例外が発生した場合に親に伝播することができるか。
	 */
	public function test_exceptionInHandler():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new ExceptionInHandlerTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("p.run c.run c.error p.error ", Static.log);
						}, 1000));
		t.start();
	}
	
	/**
	 * 子スレッドで発生した例外を親に伝播することができるか。
	 */
	public function test_childException():Void
	{
		Static.log = "";
		
		var c:ChildExceptionTestThread = new ChildExceptionTestThread();
		var t:TesterThread = new TesterThread(c);
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("p.run c.run p.error c.finalize p.finalize ", Static.log);
							assertTrue((c.child.ex == c.e));
							assertTrue((c.child == c.t));
						}, 1000));
		t.start();
	}
	
	/**
	 * 親スレッドが待機中に子スレッドで発生した例外を親に伝播することができるか。
	 */
	public function test_childExceptionWhileWaiting():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new ChildExceptionWhileWaitingTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("p.run c.run c.run2 p.error c.finalize p.finalize ", Static.log);
						}, 1000));
		t.start();
	}
	
	/**
	 * 子スレッドで発生した例外を子スレッドの例外ハンドラで処理することができるか。
	 */
	public function test_childExceptionHandler():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new ChildExceptionHandlerTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("p.run c.run p.run2 c.error p.finalize c.finalize ", Static.log);
						}, 1000));
		t.start();
	}
	
	/**
	 * 孫スレッドで発生した例外を伝播することができるか。
	 */
	public function test_grandchildException():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new GrandchildExceptionTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("p.run c.run p.run2 g.run c.run2 p.run2 g.run2 c.finalize p.error p.finalize g.finalize ", Static.log);
						}, 1000));
		t.start();
	}
	
	/**
	 * デフォルトの例外ハンドラが設定されている場合に、それを実行することが出来るか。
	 */
	public function test_defaultErrorHandler():Void
	{
		Static.log = "";
		
		var d:DefaultErrorHandlerTestThread = new DefaultErrorHandlerTestThread();
		var t:TesterThread = new TesterThread(d, false);
		var e:Dynamic;
		var th:Thread;
		
		
		var handler:Dynamic = function(ee:Dynamic, tt:Thread):Void
		{
			e = ee;
			th = tt;
			
			Thread.next(null);
		};
		
		Thread.registerDefaultErrorHandler(Error, handler);
		
		t.addEventListener(Event.COMPLETE, createAsync(function(ev:Event):Void
						{
							Thread.registerDefaultErrorHandler(Error, null);
							
							assertTrue((d.ex == e));
							assertTrue((d == th));
						}, 1000));
		t.start();
	}
	
	/**
	 * autoTermination = true の場合、エラーハンドラの実行後に next(null) が自動で呼び出されるか。
	 */
	public function test_autoTermination():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new AutoTerminationTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("run errorHandler finalize ", Static.log);
						}, 1000));
		t.start();
	}
	
}

private class Static
{
	public static var log:String;
}

private class ExceptionTestThread extends Thread
{
	override private function run():Void
	{
		Static.log += "run ";
		
		Thread.next(run2);
		
		throw new Error();
	}
	
	private function run2():Void
	{
		Static.log += "run2 ";
	}
	
	override private function finalize():Void
	{
		Static.log += "finalize ";
	}

	public function new()
	{
		super();
	}
}

private class UncaughtExceptionTestThread extends Thread
{
	public var ex:Error = new Error();
	
	override private function run():Void
	{
		throw ex;
	}
	
	public function new()
	{
		super();
	}
}

private class ExceptionWithHandlerTestThread extends Thread
{
	public var ex:Error = new Error();
	public var e:Error;
	public var t:Thread;
	
	override private function run():Void
	{
		Static.log += "run ";
		
		Thread.next(run2);
		Thread.error(Error, runError);
		
		throw ex;
	}
	
	private function run2():Void
	{
		Static.log += "run2 ";
	}
	
	private function runError(e:Error, t:Thread):Void
	{
		Static.log += "error ";
		
		this.e = e;
		this.t = t;
	}
	
	override private function finalize():Void
	{
		Static.log += "finalize ";
	}

	public function new()
	{
		super();
	}
}

private class ExceptionHandlerSelectTestThread extends Thread
{
	override private function run():Void
	{
		Thread.error(Error, runError, false);
		Thread.error(ArgumentError, runArgumentError, false);
		Thread.error(String, runString, false);
		
		Thread.next(throwError);
	}
	
	private function throwError():Void
	{
		Static.log += "throw.error ";
		
		throw new Error();
	}
	
	private function runError(e:Error, t:Thread):Void
	{
		Static.log += "error ";
		
		Thread.next(throwArgumentError);
	}
	
	private function throwArgumentError():Void
	{
		Static.log += "throw.argument ";
		
		throw new ArgumentError();
	}
	
	private function runArgumentError(e:Error, t:Thread):Void
	{
		Static.log += "argument ";
		
		Thread.next(throwString);
	}
	
	private function throwString():Void
	{
		Static.log += "throw.string ";
		
		throw new String("hoge");
	}
	
	private function runString(e:String, t:Thread):Void
	{
		Static.log += "string ";
		
		Thread.next(throwNumber);
	}
	
	private function throwNumber():Void
	{
		Static.log += "throw.number ";
		
		throw 1.0;
	}
	
	override private function finalize():Void
	{
		Static.log += "finalize ";
	}

	public function new()
	{
		super();
	}
}

private class ExceptionRecoveryTestThread extends Thread
{
	override private function run():Void
	{
		Static.log += "run ";
		
		Thread.next(run2);
		Thread.error(Error, runError);
		
		throw new Error();
	}
	
	private function run2():Void
	{
		Static.log += "run2 ";
	}
	
	private function runError(e:Error, t:Thread):Void
	{
		Static.log += "error ";
		
		Thread.next(run3);
	}
	
	private function run3():Void
	{
		Static.log += "run3 ";
	}
	
	override private function finalize():Void
	{
		Static.log += "finalize ";
	}

	public function new()
	{
		super();
	}
}

private class ExceptionHandlerResetTestThread extends Thread
{
	override private function run():Void
	{
		Static.log += "run ";
		
		Thread.next(run2);
		Thread.error(Error, runError);
	}
	
	private function run2():Void
	{
		Static.log += "run2 ";
		
		throw new Error();
	}
	
	private function runError(e:Error, t:Thread):Void
	{
		Static.log += "error ";
	}
	
	override private function finalize():Void
	{
		Static.log += "finalize ";
	}

	public function new()
	{
		super();
	}
}

private class ExceptionHandlerNoResetTestThread extends Thread
{
	override private function run():Void
	{
		Static.log += "run ";
		
		Thread.next(run2);
		Thread.error(Error, runError, false);
	}
	
	private function run2():Void
	{
		Static.log += "run2 ";
		
		throw new Error();
	}
	
	private function runError(e:Error, t:Thread):Void
	{
		Static.log += "error ";
	}
	
	override private function finalize():Void
	{
		Static.log += "finalize ";
	}

	public function new()
	{
		super();
	}
}

private class ExceptionInFinalizeTestThread extends Thread
{
	override private function run():Void
	{
		Static.log += "p.run ";
		
		new ExceptionInFinalizeTestChildThread().start();
		
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Thread.next(run2);
		Thread.error(Error, runError);
	}
	
	private function runError(e:Error, t:Thread):Void
	{
		Static.log += "p.error ";
		
		Thread.next(null);
	}
	
	override private function finalize():Void
	{
		Static.log += "p.finalize ";
	}

	public function new()
	{
		super();
	}
}

private class ExceptionInFinalizeTestChildThread extends Thread
{
	override private function finalize():Void
	{
		Static.log += "c.finalize ";
		
		throw new Error();
	}

	public function new()
	{
		super();
	}
}

private class ExceptionInFinalizeWithHandlerTestThread extends Thread
{
	override private function run():Void
	{
		Static.log += "p.run ";
		
		new ExceptionInFinalizeWithHandlerTestChildThread().start();
		
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Thread.next(run3);
		Thread.error(Error, runError);
	}
	
	private function run3():Void
	{
		Thread.next(run4);
		Thread.error(Error, runError);
	}
	
	private function run4():Void
	{
		Thread.error(Error, runError);
	}
	
	private function runError(e:Error, t:Thread):Void
	{
		Static.log += "p.error ";
	}
	
	override private function finalize():Void
	{
		Static.log += "p.finalize ";
	}

	public function new()
	{
		super();
	}
}

private class ExceptionInFinalizeWithHandlerTestChildThread extends Thread
{
	override private function finalize():Void
	{
		Static.log += "c.finalize ";
		
		Thread.error(Error, runError);
		
		throw new Error();
	}
	
	private function runError(e:Error, t:Thread):Void
	{
		Static.log += "c.error ";
	}

	public function new()
	{
		super();
	}
}

private class ExceptionInHandlerTestThread extends Thread
{
	override private function run():Void
	{
		Static.log += "p.run ";
		
		new ExceptionInHandlerTestChildThread().start();
		
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Thread.next(run2);
		Thread.error(Error, runError);
	}
	
	private function runError(e:Error, t:Thread):Void
	{
		Static.log += "p.error ";
		
		Thread.next(null);
	}

	public function new()
	{
		super();
	}
}

private class ExceptionInHandlerTestChildThread extends Thread
{
	override private function run():Void
	{
		Static.log += "c.run ";
		
		Thread.error(Error, runError);
		
		throw new Error();
	}
	
	private function runError(e:Error, t:Thread):Void
	{
		Static.log += "c.error ";
		
		throw new Error();
	}

	public function new()
	{
		super();
	}
}

private class ChildExceptionTestThread extends Thread
{
	public var child:ChildExceptionTestChildThread = new ChildExceptionTestChildThread();
	public var e:Error;
	public var t:Thread;
	
	override private function run():Void
	{
		Static.log += "p.run ";
		
		child.start();
		
		Thread.error(Error, runError);
	}
	
	private function runError(e:Error, t:Thread):Void
	{
		Static.log += "p.error ";
		
		this.e = e;
		this.t = t;
	}
	
	override private function finalize():Void
	{
		Static.log += "p.finalize ";
	}

	public function new()
	{
		super();
	}
}

private class ChildExceptionTestChildThread extends Thread
{
	public var ex:Error = new Error();
	
	override private function run():Void
	{
		Static.log += "c.run ";
		
		throw ex;
	}
	
	override private function finalize():Void
	{
		Static.log += "c.finalize ";
	}

	public function new()
	{
		super();
	}
}

private class ChildExceptionWhileWaitingTestThread extends Thread
{
	override private function run():Void
	{
		Static.log += "p.run ";
		
		new ChildExceptionWhileWaitingTestChildThread().start();
		
		Thread.error(Error, runError);
		wait();
	}
	
	private function runError(e:Error, t:Thread):Void
	{
		Static.log += "p.error ";
	}
	
	override private function finalize():Void
	{
		Static.log += "p.finalize ";
	}

	public function new()
	{
		super();
	}
}

private class ChildExceptionWhileWaitingTestChildThread extends Thread
{
	public var ex:Error = new Error();
	
	override private function run():Void
	{
		Static.log += "c.run ";
		
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Static.log += "c.run2 ";
		
		throw ex;
	}
	
	override private function finalize():Void
	{
		Static.log += "c.finalize ";
	}

	public function new()
	{
		super();
	}
}

private class ChildExceptionHandlerTestThread extends Thread
{
	override private function run():Void
	{
		Static.log += "p.run ";
		
		new ChildExceptionHandlerTestChildThread().start();
		
		Thread.error(Error, runError);
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Static.log += "p.run2 ";
	}
	
	private function runError(e:Error, t:Thread):Void
	{
		Static.log += "p.error ";
	}
	
	override private function finalize():Void
	{
		Static.log += "p.finalize ";
	}

	public function new()
	{
		super();
	}
}

private class ChildExceptionHandlerTestChildThread extends Thread
{
	override private function run():Void
	{
		Static.log += "c.run ";
		
		Thread.error(Error, runError);
		
		throw new Error();
	}
	
	private function runError(e:Error, t:Thread):Void
	{
		Static.log += "c.error ";
	}
	
	override private function finalize():Void
	{
		Static.log += "c.finalize ";
	}

	public function new()
	{
		super();
	}
}

private class GrandchildExceptionTestThread extends Thread
{
	override private function run():Void
	{
		Static.log += "p.run ";
		
		new GrandchildExceptionTestChildThread().start();
		
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Static.log += "p.run2 ";
		
		Thread.next(run2);
		Thread.error(Error, runError);
	}
	
	private function runError(e:Error, t:Thread):Void
	{
		Static.log += "p.error ";
		
		Thread.next(null);
	}
	
	override private function finalize():Void
	{
		Static.log += "p.finalize ";
	}

	public function new()
	{
		super();
	}
}

private class GrandchildExceptionTestChildThread extends Thread
{
	override private function run():Void
	{
		Static.log += "c.run ";
		
		new GrandchildExceptionTestGrandchildThread().start();
		
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Static.log += "c.run2 ";
		
		Thread.next(run2);
	}
	
	override private function finalize():Void
	{
		Static.log += "c.finalize ";
	}

	public function new()
	{
		super();
	}
}

private class GrandchildExceptionTestGrandchildThread extends Thread
{
	override private function run():Void
	{
		Static.log += "g.run ";
		
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Static.log += "g.run2 ";
		
		throw new Error();
	}
	
	override private function finalize():Void
	{
		Static.log += "g.finalize ";
	}

	public function new()
	{
		super();
	}
}

private class DefaultErrorHandlerTestThread extends Thread
{
    public var ex:Error = new Error();
    
    override private function run():Void
    {
        throw ex;
    }

    public function new()
    {
        super();
    }
}

private class AutoTerminationTestThread extends Thread
{
    override private function run():Void
    {
        Static.log += "run ";
        
        Thread.next(run2);
        Thread.error(Error, errorHandler, true, true);
        
        throw new Error();
    }
    
    private function run2():Void
    {
        Static.log += "run2 ";
    }
    
    private function errorHandler(e:Error, t:Thread):Void
    {
        Static.log += "errorHandler ";
        
        Thread.next(run2);
    }
    
    override private function finalize():Void
    {
        Static.log += "finalize ";
    }

    public function new()
    {
        super();
    }
}