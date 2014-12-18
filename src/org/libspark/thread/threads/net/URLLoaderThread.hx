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
package org.libspark.thread.threads.net;


import flash.errors.IOError;
import flash.errors.SecurityError;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import org.libspark.thread.Thread;
import org.libspark.thread.utils.IProgress;
import org.libspark.thread.utils.IProgressNotifier;
import org.libspark.thread.utils.Progress;


/**
 * URLLoader を用いてデータを読み込むためのスレッドです.
 * 
 * <p>このスレッドを開始すると、与えられた URLRequest を用いてロード処理を開始し、
 * ロードが完了 （Event.COMPLETE） するとスレッドが終了します。</p>
 * 
 * <p>join メソッドを用いると、簡単にロード待ちをすることができます。</p>
 * 
 * <p>ロード中にエラーが発生した場合は、以下の例外がスローされます。
 * これらの例外は、このスレッドを開始したスレッド（親スレッド）で捕捉する事が出来ます。</p>
 *
 * <ul>
 * <li>flash.events.IOErrorEvent.IO_ERROR: flash.errors.IOError</li>
 * <li>flash.events.SecurityErrorEvent.SECURITY_ERROR: SecurityError</li>
 * </ul>
 * 
 * @author	utibenkei
 */
class URLLoaderThread extends Thread implements IProgressNotifier
{
	public var request(get, never):URLRequest;
	public var loader(get, never):URLLoader;
	public var progress(get, never):IProgress;
	
	/**
	 * 新しい URLLoaderThread クラスのインスタンスを生成します.
	 * 
	 * @param request ロード対象となる URLRequest
	 * @param loader ロードに使用する URLLoader 。省略もしくは null の場合、新たに作成した URLLoader を使用します
	 */
	public function new(request:URLRequest, ?loader:URLLoader = null)
	{
		super();
		_request = request;
		_loader = (loader != null) ? loader : new URLLoader();
		_progress = new Progress();
		
	}
	
	private var _request:URLRequest;
	private var _loader:URLLoader;
	private var _progress:Progress;
	
	/**
	 * ロード対象となる URLRequest を返します.
	 */
	private function get_request():URLRequest
	{
		return _request;
	}
	
	/**
	 * ロードに使用する URLLoader を返します.
	 *
	 * <p>ロード完了（スレッドの終了）後に、ロードしたデータ （URLLoader.data） を取得したい場合などに
	 * このプロパティを使用します。</p>
	 */
	private function get_loader():URLLoader
	{
		return _loader;
	}
	
	/**
	 * @inheritDoc
	 */
	private function get_progress():IProgress
	{
		return _progress;
	}
	
	/**
	 * ロード処理をキャンセルします.
	 */
	public function cancel():Void
	{
		// 割り込みをかける
		interrupt();
	}
	
	/**
	 * 実行
	 * 
	 * @private
	 */
	override private function run():Void
	{
		// イベントハンドラを設定
		// Note: イベントハンドラを設定した場合、自動的に wait がかかる
		events();
		
		// 割り込みハンドラを設定
		Thread.interrupted(interruptedHandler);
		
		#if (native || html5)
			// １フレーム遅らせてからロード開始する
			// openflのnativeターゲットではローカル上のファイルをロードした際に瞬時に完了イベントが発行される？
			// (internalExecute()内のeventHandler.register()でリスナーが設定される前にロード完了イベントが発行されてしまうことへの対処)
			openfl.Lib.current.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		#else
			// ロード開始
			_loader.load(_request);
		#end
	}
	
	#if (native || html5)
	private function enterFrameHandler(e:Event):Void
	{
		openfl.Lib.current.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		// ロード開始
		_loader.load(_request);
	}
	#end
	
	/**
	 * イベントハンドラの登録
	 * 
	 * @private
	 */
	private function events():Void
	{
		Thread.event(_loader, Event.COMPLETE, completeHandler);
		Thread.event(_loader, ProgressEvent.PROGRESS, progressHandler);
		Thread.event(_loader, IOErrorEvent.IO_ERROR, ioErrorHandler);
		Thread.event(_loader, SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
	}
	
	/**
	 * まだ開始を通知していなければ通知する
	 * 
	 * @private
	 */
	private function notifyStartIfNeeded(total:Float):Void
	{
		if (!_progress.isStarted) {
			_progress.start(total);
		}
	}
	
	/**
	 * ProgressEvent.PROGRESS ハンドラ
	 * 
	 * @private
	 */
	private function progressHandler(e:ProgressEvent):Void
	{
		// 必要であれば開始を通知
		notifyStartIfNeeded(e.bytesTotal);
		
		// 進捗を通知
		_progress.progress(e.bytesLoaded);
		
		// 割り込みハンドラを設定
		Thread.interrupted(interruptedHandler);
		
		// 再びイベント待ち
		events();
	}
	
	/**
	 * Event.COMPLETE ハンドラ
	 * 
	 * @private
	 */
	private function completeHandler(e:Event):Void
	{
		// 必要であれば開始を通知 (問題が発生しなければ通常 progressHandler で通知される)
		notifyStartIfNeeded(0);
		
		// 完了を通知
		_progress.complete();
	}
	
	/**
	 * IOErrorEvent.IO_ERROR ハンドラ
	 * 
	 * @private
	 */
	private function ioErrorHandler(e:IOErrorEvent):Void
	{
		// 必要であれば開始を通知 (問題が発生しなければ通常 progressHandler で通知される)
		notifyStartIfNeeded(0);
		
		// 失敗を通知
		_progress.fail();
		
		// IOError をスロー
		throw new IOError(e.text);
	}
	
	/**
	 * SecurityErrorEvent.SECURITY_ERROR ハンドラ
	 * 
	 * @private
	 */
	private function securityErrorHandler(e:SecurityErrorEvent):Void
	{
		// 必要であれば開始を通知 (問題が発生しなければ通常 progressHandler で通知される)
		notifyStartIfNeeded(0);
		
		// 失敗を通知
		_progress.fail();
		
		// SecurityError をスロー
		throw new SecurityError(e.text);
	}
	
	/**
	 * 割り込みハンドラ
	 * 
	 * @private
	 */
	private function interruptedHandler():Void
	{
		#if (native || html5)
		openfl.Lib.current.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		#end
		
		// 必要であれば開始を通知 (問題が発生しなければ通常 progressHandler で通知される)
		notifyStartIfNeeded(0);
		
		// ロードをキャンセル
		_loader.close();
		
		// キャンセルを通知
		_progress.cancel();
	}
}

