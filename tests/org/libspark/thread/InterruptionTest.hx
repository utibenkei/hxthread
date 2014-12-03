package org.libspark.thread;

import nme.errors.Error;
import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.TesterThread;

import flash.events.Event;
import org.libspark.as3unit.assert.*;
import org.libspark.as3unit.Before;
import org.libspark.as3unit.After;
import org.libspark.as3unit.Test;
import org.libspark.as3unit.TestExpected;








import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.SetTimeout;
import org.libspark.thread.errors.InterruptedError;
import org.libspark.thread.Thread;
import org.libspark.thread.ThreadState;

class InterruptionTest
{
	/**
	 * テストに相互作用が出ないようにテスト毎にスレッドライブラリを初期化。
	 * 通常であれば、initializeの呼び出しは一度きり。
	 */
	private function initialize():Void
	{
		Thread.initialize(new EnterFrameThreadExecutor());
	}
	
	/**
	 * 念のため、終了処理もしておく
	 */
	private function finalize():Void
	{
		Thread.initialize(null);
	}
	
	/**
	 * 割り込みフラグが正しく設定されるか。
	 * 待機中でない場合は、割り込みハンドラが実行されたり InterruptedError が発生したりすることはない。
	 * 一度 checkInterrupted を呼び出すと、割り込みフラグがクリアされる。
	 */
	private function interrupt():Void
	{
		Static.log = "";
		
		var i:InterruptTestThread = new InterruptTestThread();
		var t:TesterThread = new TesterThread(i);
		
		t.addEventListener(Event.COMPLETE, async(function(e:Event):Void
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
	private function interruptedHandler():Void
	{
		Static.log = "";
		
		var i:InterruptedHandlerTestThread = new InterruptedHandlerTestThread();
		var t:TesterThread = new TesterThread(i);
		
		t.addEventListener(Event.COMPLETE, async(function(e:Event):Void
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
	private function interruptedException():Void
	{
		Static.log = "";
		
		var i:InterruptedExceptionTestThread = new InterruptedExceptionTestThread();
		var t:TesterThread = new TesterThread(i);
		
		t.addEventListener(Event.COMPLETE, async(function(e:Event):Void
						{
							Assert.areEqual("run interrupt interrupted finalize ", Static.log);
							Assert.isFalse(i.flag);
						}, 1000));
		
		t.start();
	}
	
	/**
	 * 割り込みハンドラが実行のたびにリセットされているかどうか
	 */
	private function clearInterruptedHandler():Void
	{
		Static.log = "";
		
		var t:TesterThread = new TesterThread(new ClearInterruptedHandlerTestThread());
		
		t.addEventListener(Event.COMPLETE, async(function(e:Event):Void
						{
							Assert.areEqual("run interrupt runInterrupted interrupt runInterrupted2 finalize ", Static.log);
						}, 1000));
		
		t.start();
	}

	public function new()
	{
	}
}



class Static
{
	public static var log:String;

	public function new()
	{
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
		
		next(run2);
		interrupted(runInterrupted);
		
		interrupt();
	}
	
	private function run2():Void
	{
		Static.log += "run2 ";
		
		flag1 = isInterrupted;
		flag2 = checkInterrupted();
		flag3 = isInterrupted;
		flag4 = checkInterrupted();
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
		
		next(run2);
		interrupted(runInterrupted);
		
		wait();
		
		setTimeout(doInterrupt, 100);
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
		
		flag = checkInterrupted();
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
		
		next(run2);
		error(InterruptedError, runInterrupted);
		
		wait();
		
		setTimeout(doInterrupt, 100);
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
		
		flag = checkInterrupted();
		
		next(null);
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
		
		interrupted(runInterrupted);
		wait();
		
		setTimeout(doInterrupt, 10);
	}
	
	private function doInterrupt():Void
	{
		Static.log += "interrupt ";
		
		interrupt();
	}
	
	private function runInterrupted():Void
	{
		Static.log += "runInterrupted ";
		
		error(InterruptedError, runInterrupted2);
		wait();
		
		setTimeout(doInterrupt, 10);
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