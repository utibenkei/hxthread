package org.libspark.thread;


import flash.errors.Error;
import flash.utils.Function;
import org.libspark.thread.Thread;

import flash.events.Event;
import flash.events.EventDispatcher;
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
	
	public function addEventListener(type:String, func:Function):Void
	{
		_e.addEventListener(type, func);
	}
	
	override private function run():Void
	{
		if (_handleError) {
			Thread.error(Error, catchError);
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
		//trace("TesterThread::finalize");
		
		//setTimeout(dispatchHandler, 1);
		untyped __global__["flash.utils.setTimeout"](dispatchHandler, 200);
	}
	
	private function dispatchHandler():Void
	{
		_e.dispatchEvent(new Event(Event.COMPLETE));
	}
}
