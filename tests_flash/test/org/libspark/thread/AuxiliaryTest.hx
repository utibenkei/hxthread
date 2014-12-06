package org.libspark.thread;

import flash.events.Event;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import massive.munit.util.Timer;
import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.Thread;


class AuxiliaryTest
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
	 * join によってスレッドの終了を待機できているかどうか。
	 * join の呼び出しによってスレッドが待機状態に入る場合は true それ以外(つまりスレッドがすでに終了している場合)は false が返る。
	 */
	@AsyncTest
	public function join(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var j:JoinTestThread = new JoinTestThread();
		var t:TesterThread = new TesterThread(j);
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("run child child child run2 ", Static.log);
							Assert.isTrue(j.join1);
							Assert.isFalse(j.join2);
						}, 1000));
		t.start();
		
	}
	
	
	
	/**
	 * 待機時間を指定した join で指定時間経過後、timeout で指定した実行関数に移行するかどうか。
	 */
	@AsyncTest
	public function timedJoin(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new TimedJoinTestThread());
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("run joined2 ", Static.log);
						}, 1000));
		t.start();
	}
	
	/**
	 * 指定した時間以上 sleep できているかどうか。
	 */
	@AsyncTest
	public function sleep(factory:AsyncFactory):Void
	{
		var s:SleepTestThread = new SleepTestThread();
		var t:TesterThread = new TesterThread(s);
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.isTrue(s.time >= 500);
						}, 1000));
		t.start();
	}
}




class JoinTestThread extends Thread
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

class JoinChildThread extends Thread
{
	private var _count:Int = 0;
	
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

class TimedJoinTestThread extends Thread
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

class SleepTestThread extends Thread
{
	public var time:Int = 0;
	private var _t:Int;
	
	override private function run():Void
	{
		_t = Math.round(haxe.Timer.stamp() * 1000);
		
		Thread.sleep(500);
		Thread.next(slept);
	}
	
	private function slept():Void
	{
		time = Math.round(haxe.Timer.stamp() * 1000) - _t;
	}

	public function new()
	{
		super();
	}
}