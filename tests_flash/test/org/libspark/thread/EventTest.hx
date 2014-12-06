package org.libspark.thread;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.Thread;


class EventTest
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
	 * イベントハンドラが正しく動作するか。
	 * イベントハンドラが設定された場合かつ next が設定されていない場合は、自動的に待機状態になる。
	 * イベントが来るとスレッドは起床し、指定されたイベントハンドラを次の実行関数に設定する。
	 * 複数のイベントハンドラが設定されていた場合、最初に起きたイベントのみ有効となる。
	 * 次の実行関数が実行される際に、イベントハンドラの設定はリセットされる。
	 */
	@AsyncTest
	public function event(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var e:EventTestThread = new EventTestThread();
		var t:TesterThread = new TesterThread(e);
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(ev:Event):Void
						{
							Assert.areEqual("run dispatch hoge finalize ", Static.log);
							Assert.isNotNull(e.e);
							Assert.areSame(e.ev.type, e.e.type);
						}, 1000));
		t.start();
		
	}
	
	
	
	/**
	 * 既に wait している状態でもイベントハンドラを仕掛けることが出来るか
	 */
	@AsyncTest
	public function timedJoin(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new WaitAndEventTestThread());
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(ev:Event):Void
						{
							Assert.areEqual("run dispatch event finalize ", Static.log);
						}, 1000));
		t.start();
	}
	
	/**
	 * イベントハンドラが設定されている場合でも、 next が設定された場合は待機状態にならずに動作することができるか
	 */
	@AsyncTest
	public function nextAndEvent(factory:AsyncFactory):Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new NextAndEventTestThread());
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function(e:Event):Void
						{
							Assert.areEqual("run run run dispatch event finalize ", Static.log);
						}, 1000));
		t.start();
	}
}

class EventTestThread extends Thread
{
	public var dispatcher:IEventDispatcher = new EventDispatcher();
	public var ev:Event = new Event("hoge");
	public var e:Event;
	
	override private function run():Void
	{
		Static.log += "run ";
		
		Thread.event(dispatcher, "hoge", hogeEvent);
		Thread.event(dispatcher, "fuga", fugaEvent);
		
		//setTimeout(dispatch, 100);
		untyped __global__["flash.utils.setTimeout"](dispatch, 100);
	}
	
	private function hogeEvent(e:Event):Void
	{
		Static.log += "hoge ";
		
		this.e = e;
	}
	
	private function fugaEvent(e:Event):Void
	{
		Static.log += "fuga ";
	}
	
	private function dispatch():Void
	{
		Static.log += "dispatch ";
		
		dispatcher.dispatchEvent(ev);
		dispatcher.dispatchEvent(new Event("fuga"));
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

class WaitAndEventTestThread extends Thread
{
	private var _dispatcher:IEventDispatcher = new EventDispatcher();
	
	override private function run():Void
	{
		Static.log += "run ";
		
		Thread.event(_dispatcher, "myEvent", myEventHandler);
		wait();
		
		//setTimeout(dispatch, 100);
		untyped __global__["flash.utils.setTimeout"](dispatch, 100);
	}
	
	private function myEventHandler(e:Event):Void
	{
		Static.log += "event ";
	}
	
	override private function finalize():Void
	{
		Static.log += "finalize ";
	}
	
	private function dispatch():Void
	{
		Static.log += "dispatch ";
		
		_dispatcher.dispatchEvent(new Event("myEvent"));
	}

	public function new()
	{
		super();
	}
}

class NextAndEventTestThread extends Thread
{
	private var _dispatcher:IEventDispatcher = new EventDispatcher();
	private var _count:Int = 0;
	
	override private function run():Void
	{
		Static.log += "run ";
		
		Thread.event(_dispatcher, "myEvent", myEventHandler);
		Thread.next(run);
		
		_count++;
		if (_count == 3) {
			new EventFireThread(_dispatcher).start();
		}
	}
	
	private function myEventHandler(e:Event):Void
	{
		Static.log += "event ";
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

class EventFireThread extends Thread
{
	public function new(dispatcher:IEventDispatcher)
	{
		super();
		_dispatcher = dispatcher;
	}
	
	private var _dispatcher:IEventDispatcher;
	
	override private function run():Void
	{
		Static.log += "dispatch ";
		
		_dispatcher.dispatchEvent(new Event("myEvent"));
	}
}