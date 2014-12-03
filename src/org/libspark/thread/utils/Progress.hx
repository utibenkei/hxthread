/*
 * Haxe port of ActionScript Thread Library
 * 
 * Licensed under the MIT License
 * 
 * Copyright (c) 2014 utibenkei
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 */
package org.libspark.thread.utils;


import flash.events.EventDispatcher;
import org.libspark.thread.utils.events.ProgressEvent;

/**
 * 仕事が進行し、 <code>total</code> プロパティか <code>current</code> プロパティか <code>percent</code> プロパティの
 * いずれかが更新されると送出されます.
 * 
 * @eventType	org.libspark.thread.utils.events.ProgressEvent.UPDATE
 * @see	org.libspark.thread.utils.IProgress#total
 * @see	org.libspark.thread.utils.IProgress#current
 * @see	org.libspark.thread.utils.IProgress#percent
 */
@:meta(Event(name="update",type="org.libspark.thread.utils.events.ProgressEvent"))


/**
 * 仕事が開始されると送出されます.
 * 
 * @eventType	org.libspark.thread.utils.events.ProgressEvent.START
 * @see	org.libspark.thread.utils.IProgress#isStarted
 */
@:meta(Event(name="start",type="org.libspark.thread.utils.events.ProgressEvent"))


/**
 * 仕事が完了すると送出されます.
 * 
 * @eventType	org.libspark.thread.utils.events.ProgressEvent.COMPLETED
 * @see	org.libspark.thread.utils.IProgress#isCompleted
 */
@:meta(Event(name="completed",type="org.libspark.thread.utils.events.ProgressEvent"))


/**
 * 仕事が失敗すると送出されます.
 * 
 * @eventType	org.libspark.thread.utils.events.ProgressEvent.FAILED
 * @see	org.libspark.thread.utils.IProgress#isFailed
 */
@:meta(Event(name="failed",type="org.libspark.thread.utils.events.ProgressEvent"))


/**
 * 仕事がキャンセルされると送出されます.
 * 
 * @eventType	org.libspark.thread.utils.events.ProgressEvent.CANCELED
 * @see	org.libspark.thread.utils.IProgress#isCanceled
 */
@:meta(Event(name="canceled",type="org.libspark.thread.utils.events.ProgressEvent"))


/**
 * Progress クラスは、 IProgress インターフェイスの最も単純な実装クラスです.
 * 
 * <p><code>start</code> メソッド、 <code>progress</code> メソッドそして <code>complete</code> または <code>failed</code>
 * または <code>cancel</code> メソッドを順番に呼び出すことで、進捗状況を通知することができます。</p>
 * 
 * @author	utibenkei
 * @see	#start()
 * @see	#progress()
 * @see	#complete()
 * @see	#cancel()
 */
class Progress extends EventDispatcher implements IProgress
{
	public var total(get, never):Float;
	public var current(get, never):Float;
	public var percent(get, never):Float;
	public var isStarted(get, never):Bool;
	public var isCompleted(get, never):Bool;
	public var isFailed(get, never):Bool;
	public var isCanceled(get, never):Bool;

	private var _isStarted:Bool = false;
	private var _isCompleted:Bool = false;
	private var _isCanceled:Bool = false;
	private var _isFailed:Bool = false;
	private var _total:Float = 0;
	private var _current:Float = 0;
	
	/**
	 * @inheritDoc
	 */
	private function get_total():Float
	{
		return _total;
	}
	
	/**
	 * @inheritDoc
	 */
	private function get_current():Float
	{
		return _current;
	}
	
	/**
	 * @inheritDoc
	 */
	private function get_percent():Float
	{
		return total != (0) ? current / total:0;
	}
	
	/**
	 * @inheritDoc
	 */
	private function get_isStarted():Bool
	{
		return _isStarted;
	}
	
	/**
	 * @inheritDoc
	 */
	private function get_isCompleted():Bool
	{
		return _isCompleted;
	}
	
	/**
	 * @inheritDoc
	 */
	private function get_isFailed():Bool
	{
		return _isFailed;
	}
	
	/**
	 * @inheritDoc
	 */
	private function get_isCanceled():Bool
	{
		return _isCanceled;
	}
	
	/**
	 * 仕事の開始を通知します.
	 * 
	 * <p>このメソッドの呼び出しによって、現在の仕事量と、完了またはキャンセルフラグはクリアされた後、開始フラグがセットされ、
	 * <code>ProgressEvent.START</code> イベントが送出されます。</p>
	 * 
	 * @param	total	仕事量の合計。未知の場合は 0 を渡します。
	 * @see	#total
	 */
	public function start(total:Float):Void
	{
		if (_isStarted) {
			return;
		}
		
		_total = total;
		_current = 0;
		_isCompleted = false;
		_isCanceled = false;
		_isFailed = false;
		_isStarted = true;
		
		dispatchEvent(new ProgressEvent(ProgressEvent.START));
	}
	
	/**
	 * 仕事の進捗を通知します.
	 * 
	 * <p>このメソッドの呼び出しによって、現在の仕事量と、<code>percent</code> プロパティの値が更新され、
	 * <code>ProgressEvent.UPDATE</code> イベントが送出されます。</p>
	 * 
	 * @param	current	現在までに完了している仕事量。
	 * @see	#total
	 * @see	#current
	 * @see	#percent
	 */
	public function progress(current:Float):Void
	{
		_current = current;
		
		dispatchEvent(new ProgressEvent(ProgressEvent.UPDATE));
	}
	
	/**
	 * 仕事の完了を通知します.
	 * 
	 * <p>このメソッドの呼び出しによって、 <code>isCompleted</code> プロパティが <code>true</code> にセットされ、
	 * <code>ProgressEvent.COMPLETED</code> イベントが送出されます。 </p>
	 * 
	 * <p>ただし、現在の仕事量が変わることはありません。 <code>percent</code> プロパティが完全に 1.0 になるよう、
	 * 先に <code>progress</code> メソッドを呼び出してください。</p>
	 * 
	 * @see	#isCompleted
	 * @see	#progress()
	 */
	public function complete():Void
	{
		_isCompleted = true;
		_isCanceled = false;
		_isFailed = false;
		
		dispatchEvent(new ProgressEvent(ProgressEvent.COMPLETED));
	}
	
	/**
	 * 仕事の失敗を通知します.
	 * 
	 * <p>このメソッドの呼び出しによって、 <code>isFailed</code> プロパティが <code>true</code> にセットされ、
	 * <oce>ProgressEvent.FAILED</code> イベントが送出されます。</p>
	 * 
	 * @see	#isFailed
	 */
	public function fail():Void
	{
		_isFailed = true;
		_isCompleted = false;
		_isCanceled = false;
		
		dispatchEvent(new ProgressEvent(ProgressEvent.FAILED));
	}
	
	/**
	 * 仕事のキャンセルを通知します.
	 * 
	 * <p>このメソッドの呼び出しによって、 <code>isCanceled</code> プロパティが <code>true</code> にセットされ、
	 * <code>ProgressEvent.CANCELED</code> イベントが送出されます。</p>
	 * 
	 * @see	#isCanceled
	 */
	public function cancel():Void
	{
		_isCanceled = true;
		_isCompleted = false;
		_isFailed = false;
		
		dispatchEvent(new ProgressEvent(ProgressEvent.CANCELED));
	}

	public function new()
	{
		super();
	}
}

