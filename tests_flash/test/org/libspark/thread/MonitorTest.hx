package org.libspark.thread;

import flash.errors.Error;
import flash.events.Event;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import massive.munit.util.Timer;
import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.errors.InterruptedError;
import org.libspark.thread.Thread;


class MonitorTest
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
	 * wait を呼び出して待機しているスレッドが notify の呼び出しで起きるかどうか。
	 * 待機しているスレッドのうち、ひとつだけが起きる。
	 */
	@AsyncTest
	public function notify(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new NotifyTestThread());
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("run wait wait notify wakeup notify wakeup ", Static.log);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * wait を呼び出して待機しているスレッドが notifyAll の呼び出しで起きるかどうか。
	 * 待機しているスレッドのすべてが起きる。
	 */
	@AsyncTest
	public function notifyAll(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new NotifyAllTestThread());
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("run wait wait notifyAll wakeup wakeup ", Static.log);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * wait で待機中のスレッドの state が WAITING になっているかどうか。
	 * スレッドが起きた後は RUNNABLE に戻る。
	 */
	@AsyncTest
	public function state(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var s:StateTestThread = new StateTestThread();
		var t:TesterThread = new TesterThread(s);
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
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
	@AsyncTest
	public function timeout(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new TimeoutTestThread());
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("run wait wakeup2 notify ", Static.log);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * 待機時間を設定した wait で待機中のスレッドの state が TIMED_WAITING になっているかどうか。
	 * スレッドが起きた後は RUNNABLE に戻る。
	 */
	@AsyncTest
	public function timedState(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var s:TimedStateTestThread = new TimedStateTestThread();
		var t:TesterThread = new TesterThread(s);
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual(ThreadState.TIMED_WAITING, s.state1);
							Assert.areEqual(ThreadState.RUNNABLE, s.state2);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * 終了フェーズに入る直前で wait した場合きちんと動作するかどうか。
	 */
	@AsyncTest
	public function waitFinalize(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new WaitFinalizeTestThread());
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("wait notifyAll finalize ", Static.log);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * 終了フェーズに入る直前で wait がタイムアウトした場合きちんと動作するかどうか。
	 */
	@AsyncTest
	public function timeoutFinalize(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new TimeoutFinaizeTestThread());
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("wait finalize ", Static.log);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * 終了直前で wait した場合きちんと動作するかどうか。
	 */
	@AsyncTest
	public function finalizeWait(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new FinalizeWaitTestThread());
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("finalize notifyAll ", Static.log);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * 終了直前で wait がタイムアウトした場合きちんと動作するかどうか。
	 */
	@AsyncTest
	public function finalizeTimeout(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new FinalizeTimeoutTestThread());
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("finalize ", Static.log);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * 終了直前で wait がタイムアウトした場合タイムアウトハンドラを実行して終了できるかどうか。
	 */
	@AsyncTest
	public function finalizeTimeoutHandler(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new FinalizeTimeoutHandlerTestThread());
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("finalize wakeup ", Static.log);
						}, 1000));
		t.start();
		
	}
	
}

class NotifyTestThread extends Thread
{
	private var _monitor:IMonitor;
	
	override private function run():Void
	{
		Static.log += "run ";
		
		_monitor = new Monitor();
		new WaitThread(_monitor).start();
		new WaitThread(_monitor).start();
		
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Thread.next(run3);
	}
	
	private function run3():Void
	{
		Thread.next(run4);
	}
	
	private function run4():Void
	{
		Static.log += "notify ";
		_monitor.notify();
		Thread.next(run5);
	}
	
	private function run5():Void
	{
		Static.log += "notify ";
		_monitor.notify();
		Thread.next(run6);
	}
	
	private function run6():Void
	{
		
		
	}

	public function new()
	{
		super();
	}
}

class NotifyAllTestThread extends Thread
{
	private var _monitor:IMonitor;
	
	override private function run():Void
	{
		Static.log += "run ";
		
		_monitor = new Monitor();
		new WaitThread(_monitor).start();
		new WaitThread(_monitor).start();
		
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Thread.next(run3);
	}
	
	private function run3():Void
	{
		Thread.next(run4);
	}
	
	private function run4():Void
	{
		Static.log += "notifyAll ";
		_monitor.notifyAll();
		Thread.next(run5);
	}
	
	private function run5():Void
	{
		
	}

	public function new()
	{
		super();
	}
}

class StateTestThread extends Thread
{
	public var thread:Thread;
	public var state1:Int = ThreadState.NEW;
	public var state2:Int = ThreadState.NEW;
	
	private var _monitor:IMonitor;
	
	override private function run():Void
	{
		_monitor = new Monitor();
		
		thread = new WaitThread(_monitor);
		thread.start();
		
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Thread.next(run3);
	}
	
	private function run3():Void
	{
		state1 = thread.state;
		Thread.next(run4);
	}
	
	private function run4():Void
	{
		_monitor.notifyAll();
		Thread.next(run5);
	}
	
	private function run5():Void
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
	public function new(monitor:IMonitor)
	{
		super();
		_monitor = monitor;
	}
	
	private var _monitor:IMonitor;
	
	override private function run():Void
	{
		Static.log += "wait ";
		_monitor.wait();
		Thread.next(wakeup);
	}
	
	private function wakeup():Void
	{
		Static.log += "wakeup ";
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		
		
	}
}

class TimeoutTestThread extends Thread
{
	public var thread:TimedWaitThread;
	
	private var _monitor:IMonitor;
	
	override private function run():Void
	{
		Static.log += "run ";
		
		_monitor = new Monitor();
		
		thread = new TimedWaitThread(_monitor);
		thread.start();
		
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Thread.next(run3);
	}
	
	private function run3():Void
	{
		if (!thread.wu) {
			Thread.next(run3);
		}
		else {
			Thread.next(run4);
		}
	}
	
	private function run4():Void
	{
		Static.log += "notify ";
		_monitor.notifyAll();
		Thread.next(run5);
	}
	
	private function run5():Void
	{
		
	}

	public function new()
	{
		super();
	}
}

class TimedStateTestThread extends Thread
{
	public var thread:TimedWaitThread;
	public var state1:Int;
	public var state2:Int;
	
	private var _monitor:IMonitor;
	
	override private function run():Void
	{
		_monitor = new Monitor();
		
		thread = new TimedWaitThread(_monitor);
		thread.start();
		
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Thread.next(run3);
	}
	
	private function run3():Void
	{
		state1 = thread.state;
		Thread.next(run4);
	}
	
	private function run4():Void
	{
		if (!thread.wu) {
			Thread.next(run4);
		}
		else {
			Thread.next(run5);
		}
	}
	
	private function run5():Void
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
	public function new(monitor:IMonitor)
	{
		super();
		_monitor = monitor;
	}
	
	public var wu:Bool = false;
	
	private var _monitor:IMonitor;
	
	override private function run():Void
	{
		Static.log += "wait ";
		_monitor.wait(500);
		Thread.next(wakeup);
		Thread.timeout(wakeup2);
	}
	
	private function wakeup():Void
	{
		wu = true;
		Static.log += "wakeup ";
		Thread.next(run2);
	}
	
	private function wakeup2():Void
	{
		wu = true;
		Static.log += "wakeup2 ";
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Thread.next(run3);
	}
	
	private function run3():Void
	{
		
		
	}
}

class WaitFinalizeTestThread extends Thread
{
	private var _monitor:IMonitor = new Monitor();
	
	override private function run():Void
	{
		Static.log += "wait ";
		
		_monitor.wait();
		
		//setTimeout(timeoutHandler, 100);
		untyped __global__["flash.utils.setTimeout"](test_timeoutHandler, 100);
	}
	
	private function test_timeoutHandler():Void
	{
		Static.log += "notifyAll ";
		
		_monitor.notifyAll();
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

class TimeoutFinaizeTestThread extends Thread
{
	override private function run():Void
	{
		Static.log += "wait ";
		
		new Monitor().wait(100);
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

class FinalizeWaitTestThread extends Thread
{
	private var _monitor:IMonitor = new Monitor();
	
	override private function finalize():Void
	{
		Static.log += "finalize ";
		
		_monitor.wait();
		
		//setTimeout(timeoutHandler, 500);
		untyped __global__["flash.utils.setTimeout"](test_timeoutHandler, 500);
	}
	
	private function test_timeoutHandler():Void
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
	override private function finalize():Void
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
	override private function finalize():Void
	{
		Static.log += "finalize ";
		
		new Monitor().wait(100);
		
		Thread.timeout(wakeup);
	}
	
	private function wakeup():Void
	{
		Static.log += "wakeup ";
	}

	public function new()
	{
		super();
	}
}