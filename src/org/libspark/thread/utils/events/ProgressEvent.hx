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
package org.libspark.thread.utils.events;


import flash.events.Event;

/**
 * ProgressEvent クラスは、 IProgress インターフェイスに関連するイベントが発生すると送出されます.
 * 
 * @author	utibenkei
 * @see	org.libspark.thread.utils.IProgress
 */
class ProgressEvent extends Event
{
	/**
	 * <code>ProgressEvent.START</code> 定数は、 <code>type</code> プロパティ
	 * (<code>start</code> イベントオブジェクト)の値を定義します.
	 * 
	 * <p>このイベントには、次のプロパティがあります。</p>
	 * <table class="innertable">
	 *	 <tr><th>プロパティ</th><th>値</th></tr>
	 *	 <tr><td><code>bubbles</code></td><td>false</td></tr>
	 *	 <tr><td><code>cancelable</code></td><td>false。キャンセルデフォルトの動作がないことを示します。</td></tr>
	 *	 <tr><td><code>currentTarget</code><td>イベントリスナーで <code>Event</code> オブジェクトをアクティブに処理しているオブジェクトです。</td></tr>
	 *	 <tr><td><code>target</code></td><td>仕事が開始されたオブジェクトです。</td></tr>
	 * </table>
	 * 
	 * @eventType	start
	 */
	public static inline var START:String = "start";
	
	/**
	 * <code>ProgressEvent.UPDATE</code> 定数は、 <code>type</code> プロパティ
	 * (<code>update</code> イベントオブジェクト)の値を定義します.
	 * 
	 * <p>このイベントには、次のプロパティがあります。</p>
	 * <table class="innertable">
	 *	 <tr><th>プロパティ</th><th>値</th></tr>
	 *	 <tr><td><code>bubbles</code></td><td>false</td></tr>
	 *	 <tr><td><code>cancelable</code></td><td>false。キャンセルデフォルトの動作がないことを示します。</td></tr>
	 *	 <tr><td><code>currentTarget</code><td>イベントリスナーで <code>Event</code> オブジェクトをアクティブに処理しているオブジェクトです。</td></tr>
	 *	 <tr><td><code>target</code></td><td>値が更新されたオブジェクトです。</td></tr>
	 * </table>
	 * 
	 * @eventType	update
	 */
	public static inline var UPDATE:String = "update";
	
	/**
	 * <code>ProgressEvent.COMPLETED</code> 定数は、 <code>type</code> プロパティ
	 * (<code>completed</code> イベントオブジェクト)の値を定義します.
	 * 
	 * <p>このイベントには、次のプロパティがあります。</p>
	 * <table class="innertable">
	 *	 <tr><th>プロパティ</th><th>値</th></tr>
	 *	 <tr><td><code>bubbles</code></td><td>false</td></tr>
	 *	 <tr><td><code>cancelable</code></td><td>false。キャンセルデフォルトの動作がないことを示します。</td></tr>
	 *	 <tr><td><code>currentTarget</code><td>イベントリスナーで <code>Event</code> オブジェクトをアクティブに処理しているオブジェクトです。</td></tr>
	 *	 <tr><td><code>target</code></td><td>仕事が完了したオブジェクトです。</td></tr>
	 * </table>
	 * 
	 * @eventType	completed
	 */
	public static inline var COMPLETED:String = "completed";
	
	/**
	 * <code>ProgressEvent.FAILED</code> 定数は、 <code>type</code> プロパティ
	 * (<code>failed</code> イベントオブジェクト)の値を定義します.
	 * 
	 * <p>このイベントには、次のプロパティがあります。</p>
	 * <table class="innertable">
	 *	 <tr><th>プロパティ</th><th>値</th></tr>
	 *	 <tr><td><code>bubbles</code></td><td>false</td></tr>
	 *	 <tr><td><code>cancelable</code></td><td>false。キャンセルデフォルトの動作がないことを示します。</td></tr>
	 *	 <tr><td><code>currentTarget</code><td>イベントリスナーで <code>Event</code> オブジェクトをアクティブに処理しているオブジェクトです。</td></tr>
	 *	 <tr><td><code>target</code></td><td>仕事が失敗したオブジェクトです。</td></tr>
	 * </table>
	 * 
	 * @eventType	failed
	 */
	public static inline var FAILED:String = "failed";
	
	/**
	 * <code>ProgressEvent.CANCELED</code> 定数は、 <code>type</code> プロパティ
	 * (<code>canceled</code> イベントオブジェクト)の値を定義します.
	 * 
	 * <p>このイベントには、次のプロパティがあります。</p>
	 * <table class="innertable">
	 *	 <tr><th>プロパティ</th><th>値</th></tr>
	 *	 <tr><td><code>bubbles</code></td><td>false</td></tr>
	 *	 <tr><td><code>cancelable</code></td><td>false。キャンセルデフォルトの動作がないことを示します。</td></tr>
	 *	 <tr><td><code>currentTarget</code><td>イベントリスナーで <code>Event</code> オブジェクトをアクティブに処理しているオブジェクトです。</td></tr>
	 *	 <tr><td><code>target</code></td><td>仕事がキャンセルされたオブジェクトです。</td></tr>
	 * </table>
	 * 
	 * @eventType	canceled
	 */
	public static inline var CANCELED:String = "canceled";
	
	/**
	 * 新しい ProgressEvent クラスのインスタンスを作成します.
	 * 
	 * @param	type	イベントのタイプです。
	 * @param	bubbles	Event オブジェクトがイベントフローのバブリング段階で処理されるのであれば true、そうでなければ false を設定します。
	 * @param	cancelable	Event オブジェクトがキャンセル可能であれば true、そうでなければ false を設定します。
	 */
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false)
	{
		super(type, bubbles, cancelable);
	}
	
	/**
	 * @private
	 */
	override public function clone():Event
	{
		return new ProgressEvent(type, bubbles, cancelable);
	}
}

