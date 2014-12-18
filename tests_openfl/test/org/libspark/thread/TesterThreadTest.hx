package org.libspark.thread;

import async.tests.AsyncTestCase;
import flash.events.Event;


class TesterThreadTest extends AsyncTestCase
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
	 * TesterThread が終了した際に Event.COMPLETE が配信されるかどうか。
	 */
	public function testAsyncExample():Void
	{
		var t:TesterThread = new TesterThread(null);
		t.addEventListener(Event.COMPLETE, createAsync(function (e:Event) {
				assertTrue(e.type == Event.COMPLETE);
			}, 1000));
		t.start();
		
	}
	
}