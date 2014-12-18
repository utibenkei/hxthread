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
package org.libspark.thread.threads.net; #if flash


import flash.errors.IOError;
import flash.errors.SecurityError;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.FileReference;
import flash.net.URLRequest;
import org.libspark.thread.Thread;
import org.libspark.thread.utils.IProgress;
import org.libspark.thread.utils.IProgressNotifier;
import org.libspark.thread.utils.Progress;



/**
 * FileReference を用いてファイルをダウンロードするためのスレッドです.
 * 
 * <p>このスレッドを開始すると、与えられた URLRequest を用いてダウンロード処理を開始し、
 * ダウンロードが完了 （Event.COMPLETE） するとスレッドが終了します。</p>
 * 
 * <p>join メソッドを用いると、簡単にダウンロード待ちをすることができます。</p>
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
class FileDownloadThread extends Thread implements IProgressNotifier
{
	public var request(get, never):URLRequest;
	public var fileReference(get, never):FileReference;
	public var defaultFileName(get, set):String;
	public var progress(get, never):IProgress;
	
	/**
	 * 新しい FileDownloadThread クラスのインスタンスを生成します.
	 * 
	 * @param	request ダウンロード対象となる URLRequest
	 * @param	fileReference ダウンロードに使用する FileReference 。省略もしくは null の場合、新たに作成した FileReference を使用します
	 * @param	defaultFileName	アップロードの POST に使用するフィールド名。詳しくは FileReference.upload を参照してください
	 */
	public function new(request:URLRequest, fileReference:FileReference = null, defaultFileName:String = null)
	{
		super();
		_request = request;
		_fileReference = (fileReference != null) ? fileReference : new FileReference();
		_defaultFileName = defaultFileName;
		_progress = new Progress();
	}
	
	private var _request:URLRequest;
	private var _fileReference:FileReference;
	private var _defaultFileName:String;
	private var _progress:Progress;
	
	/**
	 * ロード対象となる URLRequest を返します.
	 */
	private function get_request():URLRequest
	{
		return _request;
	}
	
	/**
	 * ロードに使用する FileReference を返します.
	 */
	private function get_fileReference():FileReference
	{
		return _fileReference;
	}
	
	/**
	 * ダウンロードするファイルとしてダイアログボックスに表示するデフォルトファイル名。詳しくは FileReference.download を参照してください.
	 */
	private function get_defaultFileName():String
	{
		return _defaultFileName;
	}
	
	/**
	 * @private
	 */
	private function set_defaultFileName(value:String):String
	{
		_defaultFileName = defaultFileName;
		return value;
	}
	
	/**
	 * @inheritDoc
	 */
	private function get_progress():IProgress
	{
		return _progress;
	}
	
	/**
	 * アップロード処理をキャンセルします.
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
		
		// ダウンロード開始
		fileReference.download(request, defaultFileName);
	}
	
	/**
	 * イベントハンドラの登録
	 * 
	 * @private
	 */
	private function events():Void
	{
		Thread.event(fileReference, Event.COMPLETE, completeHandler);
		Thread.event(fileReference, ProgressEvent.PROGRESS, progressHandler);
		Thread.event(fileReference, IOErrorEvent.IO_ERROR, ioErrorHandler);
		Thread.event(fileReference, SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
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
		// 必要であれば開始を通知 (問題が発生しなければ通常 progressHandler で通知される)
		notifyStartIfNeeded(0);
		
		// アップロードをキャンセル
		fileReference.cancel();
		
		// キャンセルを通知
		_progress.cancel();
	}
}
#end