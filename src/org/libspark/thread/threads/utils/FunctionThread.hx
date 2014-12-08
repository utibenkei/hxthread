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
package org.libspark.thread.threads.utils;


import flash.utils.Function;
import org.libspark.thread.Thread;

class FunctionThread extends Thread
{
	private var _func:Function;
	private var _params:Array<Dynamic>;
	
	/**
	 * 新しい FunctionThread インスタンスを作成します.
	 * 
	 * @param func 実行したい関数です.
	 * @param params 関数に渡す引数です.
	 */
	public function new(func:Function, params:Array<Dynamic>)
	{
		super();
		_func = func;
		_params = params;
	}
	
	override private function run():Void
	{
		Reflect.callMethod(null, _func, _params);
	}
	
	override private function finalize():Void
	{
		_func = null;
		_params = null;
	}
}
