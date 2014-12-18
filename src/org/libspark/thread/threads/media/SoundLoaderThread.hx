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
package org.libspark.thread.threads.media;


import flash.errors.IOError;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.media.Sound;
import flash.media.SoundLoaderContext;
import flash.net.URLRequest;
import org.libspark.thread.Thread;
import org.libspark.thread.utils.IProgress;
import org.libspark.thread.utils.IProgressNotifier;
import org.libspark.thread.utils.Progress;

#if (HXTHREAD_USE_LOADBYTES_SOUNDLOADER && !html5)
import flash.net.URLLoaderDataFormat;
import flash.net.URLLoader;
#end

/**
 * Sound を読み込むためのスレッドです.
 * 
 * <p>このスレッドを start すると、与えられた URLRequest と SoundLoaderContext を用いてロード処理を開始し、
 * ロードが完了 （Event.COMPLETE） するとスレッドが終了します。</p>
 * 
 * <p>join メソッドを用いると、簡単にロード待ちをすることが出来ます。</p>
 * 
 * <p>ロード中にエラーが発生した場合は、以下の例外がスローされます。
 * これからの例外は、このスレッドを start したスレッド （親スレッド） で捕捉することができます。</p>
 * 
 * <ul>
 * <li>flash.events.IOErrorEvent.IO_ERROR: flash.errors.IOError</li>
 * </ul>
 * 
 * 
 * //flash (mp3)
 * //native (ogg / wav)※
 * //html5  (mp3 / ogg / wav)
 * 
 * // ※native ターゲットではsound.load()未対応なのでストリーミング再生きないが、"HXTHREAD_USE_LOADBYTES_SOUNDLOADER"コンパイルフラグをつけることで、
 * // URLLoaderでバイナリデータを完全ロードする方式で再生できるようにしました(ogg/wav形式のみ)
 * 
 * // TODO flashターゲットではwav形式のストリーミング再生は未対応だが、一旦バイナリでロードしてからloadPCMFromByteArray()でロード可能になるかも？
 * 
 * @author	utibenkei
 */
class SoundLoaderThread extends Thread implements IProgressNotifier
{
	public var request(get, never):URLRequest;
	public var context(get, never):SoundLoaderContext;
	public var sound(get, never):Sound;
	public var progress(get, never):IProgress;

	/**
	 * 新しい LoaderThread クラスのインスタンスを生成します.
	 * 
	 * @param request ロード対象となる URLRequest
	 * @param context ロードに用いる SoundLoaderContext
	 * @param sound ロードに使用する Sound 。省略もしくは null の場合、新たに生成した Sound を使用します
	 */
	public function new(request:URLRequest, context:SoundLoaderContext = null, ?sound:Sound = null)
	{
		super();
		_request = request;
		_context = context;
		_sound = (sound != null) ? sound : new Sound();
		_progress = new Progress();
		
		#if (HXTHREAD_USE_LOADBYTES_SOUNDLOADER && !html5)
		_binLoader = new URLLoader();
		#end
	}
	
	private var _request:URLRequest;
	private var _context:SoundLoaderContext;
	private var _sound:Sound;
	private var _progress:Progress;
	
	#if (HXTHREAD_USE_LOADBYTES_SOUNDLOADER && !html5)
	private var _binLoader:URLLoader;
	#end
	
	/**
	 * ロード対象となる URLRequest を返します.
	 */
	private function get_request():URLRequest
	{
		return _request;
	}
	
	/**
	 * ロードに用いる SoundLoaderContext を返します.
	 */
	private function get_context():SoundLoaderContext
	{
		return _context;
	}
	
	/**
	 * ロードに使用する Sound を返します.
	 * 
	 * <p>ロード完了 （スレッド終了） 後に、ロードしたサウンドを取得したい場合などにこのプロパティを使用します。</p>
	 */
	private function get_sound():Sound
	{
		return _sound;
	}
	
	/**
	 * @inheritDoc
	 */
	private function get_progress():IProgress
	{
		return _progress;
	}
	
	/**
	 * 実行
	 * 
	 * @throws SecurityError
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
			// openflの native/html5 ターゲットではローカル上のファイルをロードした際に瞬時に完了イベントが発行される？
			// (internalExecute()内のeventHandler.register()でリスナーが設定される前にロード完了イベントが発行されてしまうことへの対処)
			openfl.Lib.current.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		#else
			// ロード開始
			#if !HXTHREAD_USE_LOADBYTES_SOUNDLOADER
				_sound.load(_request, _context);
			#else
				_binLoader.dataFormat = URLLoaderDataFormat.BINARY;
				_binLoader.load(_request);
			#end
		#end
	}
	
	#if (native || html5)
	private function enterFrameHandler(e:Event):Void
	{
		openfl.Lib.current.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		// ロード開始
		#if !(HXTHREAD_USE_LOADBYTES_SOUNDLOADER && !html5)
			_sound.load(_request, _context);
		#else
			_binLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_binLoader.load(_request);
		#end
	}
	#end
	
	/**
	 * イベントハンドラの登録
	 * 
	 * @private
	 */
	private function events():Void
	{
		#if !(HXTHREAD_USE_LOADBYTES_SOUNDLOADER && !html5)
			Thread.event(_sound, Event.COMPLETE, completeHandler);
			Thread.event(_sound, ProgressEvent.PROGRESS, progressHandler);
			Thread.event(_sound, IOErrorEvent.IO_ERROR, ioErrorHandler);
		#else
			Thread.event(_binLoader, Event.COMPLETE, completeHandler);
			Thread.event(_binLoader, ProgressEvent.PROGRESS, progressHandler);
			Thread.event(_binLoader, IOErrorEvent.IO_ERROR, ioErrorHandler);
		#end
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
		#if (HXTHREAD_USE_LOADBYTES_SOUNDLOADER && !html5)
		_sound.loadCompressedDataFromByteArray(_binLoader.data, _binLoader.data.length);
		#end
		
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
		#if !(HXTHREAD_USE_LOADBYTES_SOUNDLOADER && !html5)
			_sound.close();
		#else
			_binLoader.close();
		#end
		
		// キャンセルを通知
		_progress.cancel();
	}
}
