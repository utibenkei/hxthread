package org.libspark.thread;


import async.tests.AsyncTestCase;
import flash.events.Event;
import haxe.Timer;
import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.Thread;


class AuxiliaryTest extends AsyncTestCase
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
	 * join によってスレッドの終了を待機できているかどうか。
	 * join の呼び出しによってスレッドが待機状態に入る場合は true それ以外(つまりスレッドがすでに終了している場合)は false が返る。
	 */
	public function test_joinExample():Void
	{
		Static.log = "";
		
		var j:JoinTestThread = new JoinTestThread();
		var t:TesterThread = new TesterThread(j);
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("run child child child run2 ", Static.log);
							assertTrue(j.join1);
							assertFalse(j.join2);
						}, 1000));
		t.start();
		
	}
	
	
	/**
	 * 待機時間を指定した join で指定時間経過後、timeout で指定した実行関数に移行するかどうか。
	 */
	public function test_timedJoin():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new TimedJoinTestThread());
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertEquals("run joined2 ", Static.log);
						}, 1000));
		t.start();
	}
	
	/**
	 * 指定した時間以上 sleep できているかどうか。
	 */
	public function test_sleep():Void
	{
		var s:SleepTestThread = new SleepTestThread();
		var t:TesterThread = new TesterThread(s);
		
		t.addEventListener(Event.COMPLETE, createAsync(function(e:Event):Void
						{
							assertTrue(s.time >= 500);
						}, 1000));
		t.start();
	}
	
}


private class Static
{
	public static var log:String;
}

private class JoinTestThread extends Thread
{
	public var join1:Bool = false;
	public var join2:Bool = false;
	
	private var _thread:Thread;
	
	override private function run():Void
	{
		Static.log += "run ";
		
		_thread = new JoinChildThread();
		_thread.start();
		
		join1 = _thread.join();
		
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		Static.log += "run2 ";
		
		join2 = _thread.join();
	}

	public function new()
	{
		super();
	}
}

private class JoinChildThread extends Thread
{
	private var _count:UInt = 0;
	
	override private function run():Void
	{
		Static.log += "child ";
		
		if (++_count < 3) {
			Thread.next(run);
		}
	}

	public function new()
	{
		super();
	}
}

private class TimedJoinTestThread extends Thread
{
	override private function run():Void
	{
		Static.log += "run ";
		var t:Thread = new Thread();
		t.start();
		t.join(20);
		Thread.next(joined1);
		Thread.timeout(joined2);
	}
	
	private function joined1():Void
	{
		Static.log += "joined1 ";
	}
	
	private function joined2():Void
	{
		Static.log += "joined2 ";
	}

	public function new()
	{
		super();
	}
}

private class SleepTestThread extends Thread
{
	public var time:UInt = 0;
	private var _t:UInt;
	
	override private function run():Void
	{
		_t = Math.round(Timer.stamp() * 1000);
		
		Thread.sleep(500);
		Thread.next(slept);
	}
	
	private function slept():Void
	{
		time = Math.round(Timer.stamp() * 1000) - _t;
	}

	public function new()
	{
		super();
	}
}
