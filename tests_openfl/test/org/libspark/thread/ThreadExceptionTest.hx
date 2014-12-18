package org.libspark.thread;

import async.tests.AsyncTestCase;
import flash.events.Event;
import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.errors.IllegalThreadStateError;
import org.libspark.thread.errors.ThreadLibraryNotInitializedError;
import org.libspark.thread.Thread;


class ThreadExceptionTest extends AsyncTestCase
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
	 * start したら run が実行されるか
	 */
	public function test_start():Void
	{
		Static.run = false;
		
		var t:TesterThread = new TesterThread(new StartTestThread());
		
		assertFalse(Static.run);
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertTrue(Static.run);
						}, 1000));
		t.start();
	}
	
	/**
	 * 既に実行しているスレッドを start したら IllegalThreadStateError がスローされるか。
	 */
	public function test_testExample():Void
	{
		try {
			var t:Thread = new Thread();
			t.start();
			t.start();
		}
		catch (e:IllegalThreadStateError) {
			assertTrue(true);
		}
	}
	
	
	
	/**
	 * スレッドライブラリが初期化されていない状態で start したら ThreadLibraryNotInitializedError がスローされるか。
	 */
	public function test_initializeError():Void
	{
		try {
			Thread.initialize(null);
		
			var t:Thread = new Thread();
			t.start();
		}
		catch (e:ThreadLibraryNotInitializedError) {
			assertTrue(true);
		}
	}
	
	/**
	 * currentThread にきちんと現在実行中のスレッドが設定されているか。
	 * 実行中のスレッドが無い(擬似スレッドなのでこういうことが起こりうる)場合は null が設定される。
	 */
	public function test_currentThread():Void
	{
		var c:CurrentThreadTestThread = new CurrentThreadTestThread();
		var t:TesterThread = new TesterThread(c);
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertTrue((c == c.current));
						}, 1000));
		assertTrue((Thread.currentThread == null));
		
		t.start();
	}
	
	/**
	 * next による実行関数の切り替えが行えているか。
	 * next を呼び出さない場合、実行フェーズ → 終了フェーズ → 終了 という順で遷移する。
	 * next は finalize の中(終了フェーズ, state == ThreadState.TERMINATING)でも有効。
	 */
	public function test_next():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new NextTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("run run2 run3 finalize finalize2 ", Static.log);
						}, 1000));
		t.start();
	}
	
	/**
	 * state が NEW → RUNNABLE → TERMINATING → TERMINATED という順で切り替わっているか。
	 */
	public function test_state():Void
	{
		var s:StateTestThread = new StateTestThread();
		var t:TesterThread = new TesterThread(s);
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals(ThreadState.RUNNABLE, s.state1);
							assertEquals(ThreadState.RUNNABLE, s.state2);
							assertEquals(ThreadState.TERMINATING, s.state3);
							assertEquals(ThreadState.TERMINATING, s.state4);
 							assertEquals(ThreadState.TERMINATED, s.state);
						}, 1000));
						
		assertEquals(ThreadState.NEW, s.state);
		
		t.start();
	}
	
	/**
	 * 子スレッドが正しく呼び出されているか。
	 * あるスレッドが別のスレッドの start を呼び出した際、start を呼び出したほうのスレッドを親スレッド、start が呼び出されたほうのスレッドを子スレッドと呼ぶ。
	 * 子スレッドは、その親スレッドよりも前に、start された順で実行されることが保証される。
	 */
	@AsyncTest
	public function test_childThread():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new ChildThreadTestParentThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("p.run c1.run c2.run p.run2 c1.run2 c2.run2 p.run3 c1.finalize c2.finalize p.finalize ", Static.log);
						}, 1000));
		t.start();
	}
	
	/**
	 * 孤児スレッドが正しく呼び出されているか。
	 * 子スレッドの終了より先に親スレッドが終了した場合、子スレッドは孤児スレッドとなる。
	 * 孤児スレッドは親スレッドから切り離され、トップレベルに移されて実行が継続される。
	 */
	@AsyncTest
	public function test_orphanThread():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new OrphanTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("p.run c.run p.finalize c.run2 c.finalize ", Static.log);
						}, 1000));
		t.start();
	}
	
}

private class Static
{
	public static var run:Bool;
	public static var log:String;
}

private class StartTestThread extends Thread
{
	override private function run():Void
	{
		Static.run = true;
	}
	
	public function new()
	{
		super();
	}
}

private class CurrentThreadTestThread extends Thread
{
	public var current:Thread = null;
	
	override private function run():Void
	{
		current = Thread.currentThread;
	}
	
	public function new()
	{
		super();
	}
}

private class NextTestThread extends Thread
{
	override private function run():Void
	{
		Static.log += "run ";
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Static.log += "run2 ";
		Thread.next(run3);
	}
	
	private function run3():Void
	{
		Static.log += "run3 ";
	}
	
	override private function finalize():Void
	{
		Static.log += "finalize ";
		Thread.next(finalize2);
	}
	
	private function finalize2():Void
	{
		Static.log += "finalize2 ";
	}
	
	public function new()
	{
		super();
	}
}

private class StateTestThread extends Thread
{
	public var state1:UInt = ThreadState.NEW;
	public var state2:UInt = ThreadState.NEW;
	public var state3:UInt = ThreadState.NEW;
	public var state4:UInt = ThreadState.NEW;
	
	override private function run():Void
	{
		state1 = state;
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		state2 = state;
	}
	
	override private function finalize():Void
	{
		state3 = state;
		Thread.next(finalize2);
	}
	
	private function finalize2():Void
	{
		state4 = state;
	}
	
	public function new()
	{
		super();
	}
}

private class ChildThreadTestParentThread extends Thread
{
	override private function run():Void
	{
		Static.log += "p.run ";
		
		new ChildThreadTestChildThread("c1").start();
		new ChildThreadTestChildThread("c2").start();
		
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Static.log += "p.run2 ";
		Thread.next(run3);
	}
	
	private function run3():Void
	{
		Static.log += "p.run3 ";
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

private class ChildThreadTestChildThread extends Thread
{
	public function new(name:String)
	{
		super();
		test_name = name;
	}
	
	private var test_name:String;
	
	override private function run():Void
	{
		Static.log += test_name + ".run ";
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Static.log += test_name + ".run2 ";
	}
	
	override private function finalize():Void
	{
		Static.log += test_name + ".finalize ";
	}
}

private class OrphanTestThread extends Thread
{
	private var _c:OrphanTestChildThread;
	
	override private function run():Void
	{
		var t:OrphanTestParentThread = new OrphanTestParentThread();
		_c = t.child;
		t.start();
		Thread.next(waitChild);
	}
	
	private function waitChild():Void
	{
		if (!_c.isFinished) {
			Thread.next(waitChild);
		}
	}
	
	public function new()
	{
		super();
	}
}

private class OrphanTestParentThread extends Thread
{
	public var child:OrphanTestChildThread = new OrphanTestChildThread();
	
	override private function run():Void
	{
		Static.log += "p.run ";
		child.start();
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

private class OrphanTestChildThread extends Thread
{
	public var isFinished:Bool = false;
	
	override private function run():Void
	{
		Static.log += "c.run ";
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Static.log += "c.run2 ";
	}
	
	override private function finalize():Void
	{
		Static.log += "c.finalize ";
		isFinished = true;
	}
	
	public function new()
	{
		super();
	}
}