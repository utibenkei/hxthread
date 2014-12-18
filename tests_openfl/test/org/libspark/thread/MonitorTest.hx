package org.libspark.thread;

import async.tests.AsyncTestCase;
import flash.events.Event;
import haxe.Timer;
import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.Thread;


class MonitorTest extends AsyncTestCase
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
	 * wait を呼び出して待機しているスレッドが notify の呼び出しで起きるかどうか。
	 * 待機しているスレッドのうち、ひとつだけが起きる。
	 */
	public function test_notify():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new NotifyTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("run wait wait notify wakeup notify wakeup ", Static.log);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * wait を呼び出して待機しているスレッドが notifyAll の呼び出しで起きるかどうか。
	 * 待機しているスレッドのすべてが起きる。
	 */
	public function test_notifyAll():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new NotifyAllTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("run wait wait notifyAll wakeup wakeup ", Static.log);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * wait で待機中のスレッドの state が WAITING になっているかどうか。
	 * スレッドが起きた後は RUNNABLE に戻る。
	 */
	public function test_state():Void
	{
		Static.log = "";
		
		var s:StateTestThread = new StateTestThread();
		var t:TesterThread = new TesterThread(s);
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals(ThreadState.WAITING, s.state1);
							assertEquals(ThreadState.RUNNABLE, s.state2);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * 待機時間を設定した wait で指定時間経過後、timeout で指定した実行関数に移行するかどうか。
	 * 
	 */
	public function test_timeout():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new TimeoutTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("run wait wakeup2 notify ", Static.log);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * 待機時間を設定した wait で待機中のスレッドの state が TIMED_WAITING になっているかどうか。
	 * スレッドが起きた後は RUNNABLE に戻る。
	 */
	public function test_timedState():Void
	{
		Static.log = "";
		
		var s:TimedStateTestThread = new TimedStateTestThread();
		var t:TesterThread = new TesterThread(s);
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals(ThreadState.TIMED_WAITING, s.state1);
							assertEquals(ThreadState.RUNNABLE, s.state2);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * 終了フェーズに入る直前で wait した場合きちんと動作するかどうか。
	 */
	public function test_waitFinalize():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new WaitFinalizeTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("wait notifyAll finalize ", Static.log);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * 終了フェーズに入る直前で wait がタイムアウトした場合きちんと動作するかどうか。
	 */
	public function test_timeoutFinalize():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new TimeoutFinaizeTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("wait finalize ", Static.log);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * 終了直前で wait した場合きちんと動作するかどうか。
	 */
	public function test_finalizeWait():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new FinalizeWaitTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("finalize notifyAll ", Static.log);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * 終了直前で wait がタイムアウトした場合きちんと動作するかどうか。
	 */
	public function test_finalizeTimeout():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new FinalizeTimeoutTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("finalize ", Static.log);
						}, 1000));
		t.start();
		
	}
	
	/**
	 * 終了直前で wait がタイムアウトした場合タイムアウトハンドラを実行して終了できるかどうか。
	 */
	public function test_finalizeTimeoutHandler():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new FinalizeTimeoutHandlerTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("finalize wakeup ", Static.log);
						}, 1000));
		t.start();
		
	}
	
}

private class Static
{
	public static var log:String;
}

private class NotifyTestThread extends Thread
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

private class NotifyAllTestThread extends Thread
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

private private class StateTestThread extends Thread
{
	public var thread:Thread;
	public var state1:UInt = ThreadState.NEW;
	public var state2:UInt = ThreadState.NEW;
	
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

private private class WaitThread extends Thread
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

private class TimeoutTestThread extends Thread
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

private class TimedStateTestThread extends Thread
{
	public var thread:TimedWaitThread;
	public var state1:UInt;
	public var state2:UInt;
	
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

private class TimedWaitThread extends Thread
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

private class WaitFinalizeTestThread extends Thread
{
	private var _monitor:IMonitor = new Monitor();
	
	override private function run():Void
	{
		Static.log += "wait ";
		
		_monitor.wait();
		
		//setTimeout(timeoutHandler, 100);
		//untyped __global__["flash.utils.setTimeout"](test_timeoutHandler, 100);
		Timer.delay(test_timeoutHandler, 100);
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

private class TimeoutFinaizeTestThread extends Thread
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

private class FinalizeWaitTestThread extends Thread
{
	private var _monitor:IMonitor = new Monitor();
	
	override private function finalize():Void
	{
		Static.log += "finalize ";
		
		_monitor.wait();
		
		//setTimeout(timeoutHandler, 500);
		//untyped __global__["flash.utils.setTimeout"](test_timeoutHandler, 500);
		Timer.delay(test_timeoutHandler, 500);
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

private class FinalizeTimeoutTestThread extends Thread
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

private class FinalizeTimeoutHandlerTestThread extends Thread
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