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
package org.libspark.thread;


import flash.events.Event;
import flash.events.IEventDispatcher;

/**
	 * @author	utibenkei
	 * @private
	 */
class EventHandler
{
	@:allow(org.libspark.thread)
	public function new(dispatcher:IEventDispatcher, type:String, listener:Dynamic->EventHandler->Void, func:Dynamic->Void, useCapture:Bool, priority:Int, useWeakReference:Bool)
	{
		this.dispatcher = dispatcher;
		this.type = type;
		this.listener = listener;
		this.func = func;
		this.useCapture = useCapture;
		this.priority = priority;
		this.useWeakReference = useWeakReference;
	}
	
	public var dispatcher:IEventDispatcher;
	public var type:String;
	public var listener:Dynamic->EventHandler->Void;
	public var func:Dynamic->Void;
	public var useCapture:Bool;
	public var priority:Int;
	public var useWeakReference:Bool;
	
	public function register():Void
	{
		dispatcher.addEventListener(type, handler, useCapture, priority, useWeakReference);
	}
	
	public function unregister():Void
	{
		dispatcher.removeEventListener(type, handler, useCapture);
	}
	
	private function handler(e:Event):Void
	{
		//listener(e, this);
		Reflect.callMethod(this, listener, [e, this]);
	}
}
