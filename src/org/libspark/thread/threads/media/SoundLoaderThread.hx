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
package org.libspark.thread.threads.media;


import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.media.Sound;
import flash.media.SoundLoaderContext;
import flash.net.URLRequest;
import flash.errors.IOError;
import org.libspark.thread.utils.IProgress;
import org.libspark.thread.utils.IProgressNotifier;
import org.libspark.thread.utils.Progress;

import org.libspark.thread.Thread;

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
	 * @author	yossy:beinteractive
	 */
class SoundLoaderThread extends Thread implements IProgressNotifier
{
    public var request(get, never) : URLRequest;
    public var context(get, never) : SoundLoaderContext;
    public var sound(get, never) : Sound;
    public var progress(get, never) : IProgress;

    /**
		 * 新しい LoaderThread クラスのインスタンスを生成します.
		 * 
		 * @param request ロード対象となる URLRequest
		 * @param context ロードに用いる SoundLoaderContext
		 * @param sound ロードに使用する Sound 。省略もしくは null の場合、新たに生成した Sound を使用します
		 */
    public function new(request : URLRequest, context : SoundLoaderContext = null, sound : Sound = null)
    {
        super();
        _request = request;
        _context = context;
        _sound = sound || new Sound();
        _progress = new Progress();
    }
    
    private var _request : URLRequest;
    private var _context : SoundLoaderContext;
    private var _sound : Sound;
    private var _progress : Progress;
    
    /**
		 * ロード対象となる URLRequest を返します.
		 */
    private function get_Request() : URLRequest
    {
        return _request;
    }
    
    /**
		 * ロードに用いる SoundLoaderContext を返します.
		 */
    private function get_Context() : SoundLoaderContext
    {
        return _context;
    }
    
    /**
		 * ロードに使用する Sound を返します.
		 * 
		 * <p>ロード完了 （スレッド終了） 後に、ロードしたサウンドを取得したい場合などにこのプロパティを使用します。</p>
		 */
    private function get_Sound() : Sound
    {
        return _sound;
    }
    
    /**
		 * @inheritDoc
		 */
    private function get_Progress() : IProgress
    {
        return _progress;
    }
    
    /**
		 * 実行
		 * 
		 * @throws SecurityError
		 * @private
		 */
    override private function run() : Void
    {
        // イベントハンドラを設定
        // Note: イベントハンドラを設定した場合、自動的に wait がかかる
        events();
        
        // 割り込みハンドラを設定
        interrupted(interruptedHandler);
        
        // ロード開始
        _sound.load(_request, _context);
    }
    
    /**
		 * イベントハンドラの登録
		 * 
		 * @private
		 */
    private function events() : Void
    {
        event(_sound, Event.COMPLETE, completeHandler);
        event(_sound, ProgressEvent.PROGRESS, progressHandler);
        event(_sound, IOErrorEvent.IO_ERROR, ioErrorHandler);
    }
    
    /**
		 * まだ開始を通知していなければ通知する
		 * 
		 * @private
		 */
    private function notifyStartIfNeeded(total : Float) : Void
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
    private function progressHandler(e : ProgressEvent) : Void
    {
        // 必要であれば開始を通知
        notifyStartIfNeeded(e.bytesTotal);
        
        // 進捗を通知
        _progress.progress(e.bytesLoaded);
        
        // 割り込みハンドラを設定
        interrupted(interruptedHandler);
        
        // 再びイベント待ち
        events();
    }
    
    /**
		 * Event.COMPLETE ハンドラ
		 * 
		 * @private
		 */
    private function completeHandler(e : Event) : Void
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
    private function ioErrorHandler(e : IOErrorEvent) : Void
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
    private function interruptedHandler() : Void
    {
        // 必要であれば開始を通知 (問題が発生しなければ通常 progressHandler で通知される)
        notifyStartIfNeeded(0);
        
        // ロードをキャンセル
        _sound.close();
        
        // キャンセルを通知
        _progress.cancel();
    }
}
