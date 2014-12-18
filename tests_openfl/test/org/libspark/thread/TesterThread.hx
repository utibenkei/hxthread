package org.libspark.thread;


#if HXTHREAD_USE_HAXETIMER
import haxe.Timer;
#elseif openfl
import flash.events.TimerEvent;
import flash.utils.Timer;
#end
import flash.errors.Error;
import flash.events.Event;
import flash.events.EventDispatcher;

import org.libspark.thread.Thread;

//import flash.utils.SetTimeout;


class TesterThread extends Thread
{
	public function new(t:Thread, handleError:Bool = true)
	{
		super();
		_t = t;
		_e = new EventDispatcher();
		_handleError = handleError;
	}
	
	private var _t:Thread;
	private var _e:EventDispatcher;
	private var _handleError:Bool;
	
	public function addEventListener(type:String, func:Dynamic->Void):Void
	{
		_e.addEventListener(type, func);
	}
	
	override private function run():Void
	{
		if (_handleError) {
			// error(Object, catchError); // as3 code.
			Thread.error(Object, catchError);
			// haxeではType.getSuperClass()で親クラスをたどってもas3でいう"Object"まではたどることができないため、"Object"という専用のクラスで「全ての型にマッチする型」を指定する。
		}
		if (_t != null) {
			_t.start();
			_t.join();
		}
	}
	
	private function catchError(e:Dynamic, t:Thread):Void
	{
		Thread.next(null);
	}
	
	override private function finalize():Void
	{
		//setTimeout(dispatchHandler, 1)// as3 code.
		
		#if HXTHREAD_USE_HAXETIMER
		
		Timer.delay(dispatchHandler, 1);
		
		#elseif openfl
		
		var timer:Timer = new Timer(1, 1);
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, dispatchHandler);
		timer.start();
		
		#else
		
		untyped __global__["flash.utils.setTimeout"](dispatchHandler, 1);
		
		#end

	}
	
	#if HXTHREAD_USE_HAXETIMER
	
	private function dispatchHandler():Void
	{
		_e.dispatchEvent(new Event(Event.COMPLETE));
	}
	
	#elseif openfl
	
	private function dispatchHandler(e:TimerEvent):Void
	{
		cast(e.currentTarget, Timer).removeEventListener(TimerEvent.TIMER_COMPLETE, dispatchHandler);
		_e.dispatchEvent(new Event(Event.COMPLETE));
	}
	
	#else
	
	private function dispatchHandler():Void
	{
		_e.dispatchEvent(new Event(Event.COMPLETE));
	}
	
	#end
}