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

import org.libspark.thread.Thread;

//import flash.utils.SetTimeout;
//import flash.utils.ClearTimeout;

/**
 * Monitor クラスは IMonitor インターフェイスの実装クラスで、モニタ機構の最も一般的な実装を提供します.
 * 
 * @author	utibenkei
 */
class Monitor implements IMonitor
{
	/**
	 * 新しい Monitor クラスのインスタンスを生成します.
	 */
	public function new()
	{
		
	}
	
	private var _waitors:Array<Thread>;
	private var _timeoutList:Map<Thread, Int>;
	
	/**
	 * ウェイトセットを返します.
	 * 
	 * @return	ウェイトセット
	 * @private
	 */
	private function getWaitors():Array<Thread>
	{
		return (_waitors != null) ? _waitors : _waitors = [];
	}
	
	/**
	 * タイムアウトを設定します.
	 * 
	 * @param	thread	設定するスレッド
	 * @param	timeout	タイムアウトするまでの時間
	 * @private
	 */
	private function registerTimeout(thread:Thread, timeout:UInt):Void
	{
		// マップがなければ生成
		if (_timeoutList == null) {
			_timeoutList = new Map<Thread, Int>();//new Dictionary();
		}
		
		// タイムアウトを設定して、thread をキーにして タイムアウトID を保存  
		//_timeoutList[thread] = setTimeout(timeoutHandler, timeout, thread);//AS3 code.
		_timeoutList[thread] = untyped __global__["flash.utils.setTimeout"](timeoutHandler, timeout, thread);
	}
	
	/**
	 * タイムアウトを解除します.
	 * 
	 * @param	thread	解除するスレッド
	 * @private
	 */
	private function unregisterTimeout(thread:Thread):Void
	{
		// マップがなければ何もしない
		if (_timeoutList == null) {
			return;
		} 
		
		
		// thread をキーにして タイムアウトID を検索 
		var id:Dynamic = _timeoutList[thread];
		
		// 見つかったらタイムアウトを解除する
		if (id != null) {
			//clearTimeout(Int(id));//AS3 code.
			untyped __global__["flash.utils.clearTimeout"](Std.int(id));
			//delete _timeoutList[thread];//as3 code.
			_timeoutList.remove(thread);
			
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function wait(timeout:UInt = 0):Void
	{
		// カレントスレッドを取得
		var thread:Thread = Thread.getCurrentThread();
		
		// スレッドに wait するよう依頼
		thread.monitorWait(timeout != 0, this);
		
		// 待機セットに並ばせる
		getWaitors().push(thread);
		
		// 待機時間が設定されている場合、タイムアウトハンドラを設定
		if (timeout != 0) {
			registerTimeout(thread, timeout);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function notify():Void
	{
		// 待機しているスレッドがいなければ何もしない
		if (_waitors == null || _waitors.length < 1) {
			return;
		}
		
		
		// スレッドをひとつ取り出す
		var thread:Thread = _waitors.shift();
		
		// タイムアウトを解除
		unregisterTimeout(thread);
		
		// スレッドを起こす
		thread.monitorWakeup(this);
	}
	
	/**
	 * @inheritDoc
	 */
	public function notifyAll():Void
	{
		// 待機しているスレッドがいなければ何もしない
		if (_waitors == null || _waitors.length < 1) {
			return;
		}
		
		
		// 例外保存用  
		var ex:Dynamic = null;
		
		// 全てのスレッドを起こす
		for (thread in _waitors){
			
			// タイムアウトを解除
			unregisterTimeout(thread);
			
			// ここで try-catch を行うのは確実に全てのスレッドを起こすため
			try{
				thread.monitorWakeup(this);
			}
			catch (e:Dynamic){
				// 最初に起きた例外は保存
				if (ex == null) {
					ex = e;
				}
			}
		}
		
		
		// 待機セットを空にする
		#if !(cpp || php)
			untyped _waitors.length = 0;
		#else
			_waitors.splice(0,_waitors.length);
		#end
		
		// 例外が発生していた場合は再スロー
		if (ex != null) {
			throw ex;
		}
	}
	
	/**
	 * タイムアウトした際に実行されるハンドラです.
	 * 
	 * @param	thread	タイムアウトしたスレッド
	 * @private
	 */
	private function timeoutHandler(thread:Thread):Void
	{
		// 既に待機セットが空になっていたら何もしない
		if (_waitors == null || _waitors.length < 1) {
			return;
		}
		
		
		// 待機セットから該当するスレッドを検索
		var index:Int = Lambda.indexOf(_waitors, thread);
		
		// 見つからなければ何もしない
		if (index == -1) {
			return;
		}
		
		
		// 待機セットから削除  
		_waitors.splice(index, 1);
		
		// スレッドを起こす
		thread.monitorTimeout(this);
	}
	
	/**
	 * @inheritDoc
	 */
	public function leave(thread:Thread):Void
	{
		// 既に待機セットが空になっていたら何もしない
		if (_waitors == null || _waitors.length < 1) {
			return;
		} 
		
		
		// 待機セットから該当するスレッドを検索
		var index:Int = Lambda.indexOf(_waitors, thread);
		
		// 見つからなければ何もしない
		if (index == -1) {
			return;
		} 
		
		
		// 待機セットから削除 
		_waitors.splice(index, 1);
		
		// タイムアウトを解除
		unregisterTimeout(thread);
	}
}
