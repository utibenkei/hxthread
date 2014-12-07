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
import flash.events.DataEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.net.URLRequest;
import org.libspark.thread.Thread;
import org.libspark.thread.utils.IProgress;
import org.libspark.thread.utils.IProgressNotifier;
import org.libspark.thread.utils.Progress;


/**
	 * FileReference を用いてファイルをアップロードするためのスレッドです.
	 * 
	 * <p>このスレッドを開始すると、与えられた URLRequest を用いてアップロード処理を開始し、
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
class FileUploadThread extends Thread implements IProgressNotifier
{
	public var request(get, never):URLRequest;
	public var fileReference(get, never):FileReference;
	public var uploadDataFieldName(get, set):String;
	public var testUpload(get, set):Bool;
	public var waitCompleteData(get, set):Bool;
	public var data(get, never):String;
	public var doBrowse(get, set):Bool;
	public var typeFilter(get, set):Array<FileFilter>;
	public var progress(get, never):IProgress;

	/**
	 * 新しい FileReferenceThread クラスのインスタンスを生成します.
	 * 
	 * @param request ロード対象となる URLRequest
	 * @param fileReference ロードに使用する FileReference 。省略もしくは null の場合、新たに作成した FileReference を使用します
	 * @param	updateDataFieldName	アップロードの POST に使用するフィールド名。詳しくは FileReference.upload を参照してください
	 * @param	testUpload	アップロードのテストをするかどうか。詳しくは FileReference.upload を参照してください
	 * @param	waitCompleteData	DataEvent.UPLOAD_COMPLETE_DATA を待ってスレッドを終了するのであれば true そうでなければ false
	 * @param	doBrowse	アップロードの前に browse メソッドを呼び出すのであれば true、そうでなければ false
	 * @param	typeFilter	doBrowse が true の場合、拡張子フィルタ。詳しくは FileReference.browse を参照してください
	 */
	public function new(request:URLRequest, fileReference:FileReference = null, uploadDataFieldName:String = "Filedata", testUpload:Bool = false, waitCompleteData:Bool = false, doBrowse:Bool = true, typeFilter:Array<FileFilter> = null)
	{
		super();
		_request = request;
		_fileReference = (fileReference != null) ? fileReference : new FileReference();
		_uploadDataFieldName = uploadDataFieldName;
		_testUpload = testUpload;
		_waitCompleteData = waitCompleteData;
		_doBrowse = doBrowse;
		_typeFilter = typeFilter;
		_progress = new Progress();
		_data = null;
	}
	
	private var _request:URLRequest;
	private var _fileReference:FileReference;
	private var _uploadDataFieldName:String;
	private var _testUpload:Bool;
	private var _waitCompleteData:Bool;
	private var _doBrowse:Bool;
	private var _typeFilter:Array<FileFilter>;
	private var _progress:Progress;
	private var _data:String;
	
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
	 * アップロードの POST に使用するフィールド名。詳しくは FileReference.upload を参照してください.
	 */
	private function get_uploadDataFieldName():String
	{
		return _uploadDataFieldName;
	}
	
	/**
	 * @private
	 */
	private function set_uploadDataFieldName(value:String):String
	{
		_uploadDataFieldName = value;
		return value;
	}
	
	/**
	 * アップロードのテストをするかどうか。詳しくは FileReference.upload を参照してください.
	 */
	private function get_testUpload():Bool
	{
		return _testUpload;
	}
	
	/**
	 * @private
	 */
	private function set_testUpload(value:Bool):Bool
	{
		_testUpload = value;
		return value;
	}
	
	/**
	 * DataEvent.UPLOAD_COMPLETE_DATA を待ってスレッドを終了するのであれば true そうでなければ false を設定します.
	 */
	private function get_waitCompleteData():Bool
	{
		return _waitCompleteData;
	}
	
	/**
	 * @private
	 */
	private function set_waitCompleteData(value:Bool):Bool
	{
		_waitCompleteData = value;
		return value;
	}
	
	/**
	 * waitCompleteData が true の場合に、DataEvent で受け取ることのできる data プロパティの内容を返します.
	 * 
	 * @see	#waitCompleteData
	 */
	private function get_data():String
	{
		return _data;
	}
	
	/**
	 * アップロードの前に browse メソッドを呼び出すのであれば true、そうでなければ false を設定します.
	 */
	private function get_doBrowse():Bool
	{
		return _doBrowse;
	}
	
	/**
	 * @private
	 */
	private function set_doBrowse(value:Bool):Bool
	{
		_doBrowse = value;
		return value;
	}
	
	/**
	 * doBrowse が true の場合、拡張子フィルタ。詳しくは FileReference.browse を参照してください.
	 */
	private function get_typeFilter():Array<FileFilter>
	{
		return _typeFilter;
	}
	
	/**
	 * @private
	 */
	private function set_typeFilter(value:Array<FileFilter>):Array<FileFilter>
	{
		_typeFilter = value;
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
		// browse メソッド呼び出しが要求されている場合
		if (doBrowse) {
			// 呼び出す
			browse();
		}
		else {
			// そうでなければアップロード
			upload();
		}
	}
	
	/**
	 * browse メソッド呼び出し
	 * 
	 * @private
	 */
	private function browse():Void
	{
		// browse 呼び出し
		if (fileReference.browse(typeFilter)) {
			// 成功の場合イベントハンドラ設定
			Thread.event(fileReference, Event.SELECT, browseSelectHandler);
			Thread.event(fileReference, Event.CANCEL, browseCancelHandler);
		}
		else {
			// 失敗の場合キャンセルと同等の処理をする
			browseCancelHandler(null);
		}
	}
	
	/**
	 * browse 選択ハンドラ
	 * 
	 * @private
	 */
	private function browseSelectHandler(e:Event):Void
	{
		// 選択されたらアップロードする
		upload();
	}
	
	/**
	 * browse キャンセルハンドラ
	 * 
	 * @private
	 */
	private function browseCancelHandler(e:Event):Void
	{
		// とりあえず開始したことにして
		_progress.start(0);
		// すぐキャンセル
		_progress.cancel();
	}
	
	/**
	 * アップロード
	 * 
	 * @private
	 */
	private function upload():Void
	{
		// イベントハンドラを設定
		// Note: イベントハンドラを設定した場合、自動的に wait がかかる
		events();
		
		// 割り込みハンドラを設定
		Thread.interrupted(interruptedHandler);
		
		// アップロード開始
		fileReference.upload(request, uploadDataFieldName, testUpload);
	}
	
	/**
	 * イベントハンドラの登録
	 * 
	 * @private
	 */
	private function events():Void
	{
		if (waitCompleteData) {
			Thread.event(fileReference, DataEvent.UPLOAD_COMPLETE_DATA, completeHandler);
		}
		else {
			Thread.event(fileReference, Event.COMPLETE, completeHandler);
		}
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
		if (Std.is(e, DataEvent)) {
			_data = cast((e), DataEvent).data;
		}
		
		
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