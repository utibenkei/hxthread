/*
 * ActionScript Thread Library
 * 
 * Licensed under the MIT License
 * 
 * Copyright (c) 2008 BeInteractive! (www.be-interactive.org) and
 *                    Spark project  (www.libspark.org)
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


import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import org.libspark.thread.Thread;

/**
	 * EventDispatcherThread は IEventDispatcher インターフェイスを実装したスレッドです
	 * 
	 * @author	yossy:beinteractive
	 */
class EventDispatcherThread extends Thread implements IEventDispatcher
{
    public function new()
    {
        super();
        _dispatcher = new EventDispatcher(this);
    }
    
    private var _dispatcher : IEventDispatcher;
    
    /**
		 * @inheritDoc
		 */
    public function addEventListener(type : String, listener : Function, useCapture : Bool = false, priority : Int = 0, useWeakReference : Bool = false) : Void
    {
        _dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    
    /**
		 * @inheritDoc
		 */
    public function dispatchEvent(event : Event) : Bool
    {
        return _dispatcher.dispatchEvent(event);
    }
    
    /**
		 * @inheritDoc
		 */
    public function hasEventListener(type : String) : Bool
    {
        return _dispatcher.hasEventListener(type);
    }
    
    /**
		 * @inheritDoc
		 */
    public function removeEventListener(type : String, listener : Function, useCapture : Bool = false) : Void
    {
        _dispatcher.removeEventListener(type, listener, useCapture);
    }
    
    /**
		 * @inheritDoc
		 */
    public function willTrigger(type : String) : Bool
    {
        return _dispatcher.willTrigger(type);
    }
}

