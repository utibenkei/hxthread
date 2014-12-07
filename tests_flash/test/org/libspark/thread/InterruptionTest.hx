package org.libspark.thread;

import flash.errors.Error;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import massive.munit.util.Timer;
import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.errors.InterruptedError;
import org.libspark.thread.Thread;
import org.libspark.thread.utils.ParallelExecutor;


class InterruptionTest
{
	
	public function new() 
	{
		
	}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	/**
	 * テストに相互作用が出ないようにテスト毎にスレッドライブラリを初期化。
	 * 通常であれば、initializeの呼び出しは一度きり。
	 */
	@Before
	public function setup():Void
	{
		Thread.initialize(new EnterFrameThreadExecutor());
	}
	
	/**
	 * 念のため、終了処理もしておく
	 */
	@After
	public function tearDown():Void
	{
		Thread.initialize(null);
	}
	
	
	/**
	 * 割り込みフラグが正しく設定されるか。
	 * 待機中でない場合は、割り込みハンドラが実行されたり InterruptedError が発生したりすることはない。
	 * 一度 checkInterrupted を呼び出すと、割り込みフラグがクリアされる。
	 */
	@AsyncTest
	public function interrupt(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var i:InterruptTestThread = new InterruptTestThread();
		var t:TesterThread = new TesterThread(i);
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("run run2 finalize ", Static.log);
							Assert.isTrue(i.flag1);
							Assert.isTrue(i.flag2);
							Assert.isFalse(i.flag3);
							Assert.isFalse(i.flag4);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * スレッドが待機中に割り込み、かつ割り込みハンドラが設定されている場合、割り込みハンドラが実行されるか。
	 * 割り込みハンドラが実行される場合、割り込みフラグは設定されない。
	 */
	@AsyncTest
	public function interruptedHandler(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var i:InterruptedHandlerTestThread = new InterruptedHandlerTestThread();
		var t:TesterThread = new TesterThread(i);
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("run interrupt interrupted finalize ", Static.log);
							Assert.isFalse(i.flag);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * スレッドが待機中に割り込み、かつ割り込みハンドラが設定されていない場合、InterruptedError が発生するか。
	 * InterruptedError が発生する場合、割り込みフラグは設定されない。
	 */
	@AsyncTest
	public function interruptedException(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var i:InterruptedHandlerTestThread = new InterruptedHandlerTestThread();
		var t:TesterThread = new TesterThread(i);
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("run interrupt interrupted finalize ", Static.log);
							Assert.isFalse(i.flag);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * 割り込みハンドラが実行のたびにリセットされているかどうか
	 */
	@AsyncTest
	public function clearInterruptedHandler(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new ClearInterruptedHandlerTestThread());
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("run interrupt runInterrupted interrupt runInterrupted2 finalize ", Static.log);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * イベントの発生前に割り込みを掛けた場合に割り込みハンドラが実行され、その後のイベントを受け取らないかどうか
	 * 
	 * @see http://www.libspark.org/ticket/117
	 */
	@AsyncTest
	public function interruptionBeforeEvent(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new InterruptionBeforeEventTestThread());
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("run EventWait::run interrupt EventWait::eventInterrupted dispatch EventWait::finalize dispatch2 finalize ", Static.log);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * イベントの発生後に割り込みを掛けた場合に割り込みハンドラが実行されるかどうか
	 * 
	 * @see http://www.libspark.org/ticket/117
	 */
	@AsyncTest
	public function interruptionAfterEvent(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new InterruptionAfterEventTestThread());
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("run EventWait::run dispatch EventWait::eventHandler EventWait::run interrupt EventWait::eventInterrupted EventWait::finalize dispatch2 finalize ", Static.log);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * 親子関係のあるスレッドの親スレッドに割り込んだ際に子スレッドの割り込みが実行され、その後のイベントを受け取らないかどうか
	 * 
	 * @see http://www.libspark.org/ticket/117
	 * @see http://www.libspark.org/ticket/104
	 */
	@AsyncTest
	public function childInterruption(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new ChildInterruptionTestThread());
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("run EventWait::run EventWait::run interrupt EventWait::eventInterrupted EventWait::eventInterrupted dispatch EventWait::finalize EventWait::finalize dispatch2 finalize ", Static.log);
						}, 1000));
		t.start();
		
	}
	
}

class InterruptTestThread extends Thread
{
	public var flag1:Bool;
	public var flag2:Bool;
	public var flag3:Bool;
	public var flag4:Bool;
	
	override private function run():Void
	{
		Static.log += "run ";
		
		Thread.next(run2);
		Thread.interrupted(runInterrupted);
		
		interrupt();
	}
	
	private function run2():Void
	{
		Static.log += "run2 ";
		
		flag1 = isInterrupted;
		flag2 = Thread.checkInterrupted();
		flag3 = isInterrupted;
		flag4 = Thread.checkInterrupted();
	}
	
	private function runInterrupted():Void
	{
		Static.log += "interrupted ";
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

class InterruptedHandlerTestThread extends Thread
{
	public var flag:Bool;
	
	override private function run():Void
	{
		Static.log += "run ";
		
		Thread.next(run2);
		Thread.interrupted(runInterrupted);
		
		wait();
		
		//setTimeout(doInterrupt, 100);
		untyped __global__["flash.utils.setTimeout"](doInterrupt, 100);
	}
	
	private function doInterrupt():Void
	{
		Static.log += "interrupt ";
		
		interrupt();
	}
	
	private function run2():Void
	{
		Static.log += "run2 ";
	}
	
	private function runInterrupted():Void
	{
		Static.log += "interrupted ";
		
		flag = Thread.checkInterrupted();
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

class InterruptedExceptionTestThread extends Thread
{
	public var flag:Bool;
	
	override private function run():Void
	{
		Static.log += "run ";
		
		Thread.next(run2);
		Thread.error(InterruptedError, runInterrupted);
		
		wait();
		
		//setTimeout(doInterrupt, 100);
		untyped __global__["flash.utils.setTimeout"](doInterrupt, 100);
	}
	
	private function doInterrupt():Void
	{
		Static.log += "interrupt ";
		
		interrupt();
	}
	
	private function run2():Void
	{
		Static.log += "run2 ";
	}
	
	private function runInterrupted(e:Error, t:Thread):Void
	{
		Static.log += "interrupted ";
		
		flag = Thread.checkInterrupted();
		
		Thread.next(null);
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

class ClearInterruptedHandlerTestThread extends Thread
{
	override private function run():Void
	{
		Static.log += "run ";
		
		Thread.interrupted(runInterrupted);
		wait();
		
		//setTimeout(doInterrupt, 10);
		untyped __global__["flash.utils.setTimeout"](doInterrupt, 10);
	}
	
	private function doInterrupt():Void
	{
		Static.log += "interrupt ";
		
		interrupt();
	}
	
	private function runInterrupted():Void
	{
		Static.log += "runInterrupted ";
		
		Thread.error(InterruptedError, runInterrupted2);
		wait();
		
		//setTimeout(doInterrupt, 10);
		untyped __global__["flash.utils.setTimeout"](doInterrupt, 10);
	}
	
	private function runInterrupted2(e:Error, t:Thread):Void
	{
		Static.log += "runInterrupted2 ";
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

class EventWaitThread extends Thread
{
	public var dispatcher:IEventDispatcher;
	
	override private function run():Void
	{
		Static.log += "EventWait::run ";
		
		Thread.event(dispatcher, "event", test_eventHandler);
		Thread.interrupted(eventInterrupted);
	}
	
	private function test_eventHandler(e:Event):Void
	{
		Static.log += "EventWait::eventHandler ";
		
		run();
	}
	
	private function eventInterrupted():Void
	{
		Static.log += "EventWait::eventInterrupted ";
	}
	
	override private function finalize():Void
	{
		Static.log += "EventWait::finalize ";
	}
	
	public function new()
	{
		super();
	}
}

class InterruptionBeforeEventTestThread extends Thread
{
	private var _dispatcher:IEventDispatcher = new EventDispatcher();
	private var _thread:EventWaitThread;
	private var _frame:Int = 0;
	
	override private function run():Void
	{
		Static.log += "run ";
		
		_thread = new EventWaitThread();
		_thread.dispatcher = _dispatcher;
		_thread.start();
		
		Thread.next(process);
	}
	
	private function process():Void
	{
		_frame++;
		
		if (_frame == 1) {
			Static.log += "interrupt ";
			_thread.interrupt();
			Static.log += "dispatch ";
			_dispatcher.dispatchEvent(new Event("event"));
			Thread.next(process);
		}
		if (_frame == 2) {
			Static.log += "dispatch2 ";
			_dispatcher.dispatchEvent(new Event("event"));
		}
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

class InterruptionAfterEventTestThread extends Thread
{
	private var _dispatcher:IEventDispatcher = new EventDispatcher();
	private var _thread:EventWaitThread;
	private var _frame:Int = 0;
	
	override private function run():Void
	{
		Static.log += "run ";
		
		_thread = new EventWaitThread();
		_thread.dispatcher = _dispatcher;
		_thread.start();
		
		Thread.next(process);
	}
	
	private function process():Void
	{
		_frame++;
		
		if (_frame == 1) {
			Static.log += "dispatch ";
			_dispatcher.dispatchEvent(new Event("event"));
			Static.log += "interrupt ";
			_thread.interrupt();
			Thread.next(process);
		}
		if (_frame == 2) {
			Static.log += "dispatch2 ";
			_dispatcher.dispatchEvent(new Event("event"));
		}
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

class ChildInterruptionTestThread extends Thread
{
	private var _dispatcher:IEventDispatcher = new EventDispatcher();
	private var _thread:ParallelExecutor;
	private var _frame:Int = 0;
	
	override private function run():Void
	{
		Static.log += "run ";
		
		var t1:EventWaitThread = new EventWaitThread();
		t1.dispatcher = _dispatcher;
		
		var t2:EventWaitThread = new EventWaitThread();
		t2.dispatcher = _dispatcher;
		
		_thread = new ParallelExecutor();
		_thread.addThread(t1);
		_thread.addThread(t2);
		_thread.start();
		
		Thread.next(process);
	}
	
	private function process():Void
	{
		_frame++;
		
		if (_frame == 1) {
			Thread.next(process);
		}
		if (_frame == 2) {
			Static.log += "interrupt ";
			_thread.interrupt();
			Static.log += "dispatch ";
			_dispatcher.dispatchEvent(new Event("event"));
			Thread.next(process);
		}
		if (_frame == 3) {
			Static.log += "dispatch2 ";
			_dispatcher.dispatchEvent(new Event("event"));
		}
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
