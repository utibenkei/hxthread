package org.libspark.thread;

import flash.events.Event;
import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.Thread;


class TesterThreadTest
{
	//private var timer:Timer;
	
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
	 * TesterThread が終了した際に Event.COMPLETE が配信されるかどうか。
	 */
	@AsyncTest
	public function testAsyncExample(factory:AsyncFactory):Void
	{
		//var handler:Dynamic = factory.createHandler(this, onTestAsyncExampleComplete, 300);
		//timer = Timer.delay(handler, 200);
		
		var t:TesterThread = new TesterThread(null);
		
/*		var handler:Dynamic = factory.createHandler(this, function():Void
						{
							Assert.isFalse(false);
						}, 300);*/
		
		t.addEventListener(Event.COMPLETE, factory.createHandler(this, function():Void
						{
							Assert.isFalse(false);
						}, 300));
		t.start();
		
	}
}