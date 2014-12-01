/*
 * Flickr Sphere (Sample of the ActionScript Thread Library)
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
package org.libspark.flickrsphere.threads.flickr;

import nme.errors.Error;
import org.libspark.flickrsphere.threads.flickr.PhotoImageQueue;

import flash.net.URLRequest;
import flash.system.LoaderContext;
import org.libspark.flickrsphere.models.FlickrPhoto;
import org.libspark.thread.Thread;
import org.libspark.thread.threads.display.LoaderThread;

/**
	 * LoadFlickrPhotoImagesThread クラスは、FlickPhoto のイメージを読み込んで PhotoImageQueue に追加します.
	 */
class LoadFlickrPhotoImagesThread extends Thread
{
    /**
		 * @param	photos	読み込む FlickrPhoto の配列
		 * @param	queue	読み込んだイメージを格納する PhotoImageQueue
		 */
    public function new(photos : Array<Dynamic>, queue : PhotoImageQueue)
    {
        super();
        _photos = photos;
        _queue = queue;
    }
    
    private var _photos : Array<Dynamic>;
    private var _queue : PhotoImageQueue;
    private var _loader : LoaderThread;
    
    override private function run() : Void
    {
        // もう読み込む写真が無ければ終了
        if (_photos.length == 0) {
            return;
        }  // 読み込む写真  
        
        
        
        var photo : FlickrPhoto = cast((_photos.shift()), FlickrPhoto);
        
        // ロード開始
        _loader = new LoaderThread(new URLRequest(photo.smallSquareImageURL), new LoaderContext(true));
        _loader.start();
        _loader.join();
        
        // 完了したら loadComplete
        next(loadComplete);
        // 割り込まれたら loadInterrupted
        interrupted(loadInterrupted);
        // エラーが起きたら loadError
        error(Error, loadError);
    }
    
    private function loadComplete() : Void
    {
        // 読み込んだ写真をキューに追加
        _queue.offer(_loader.loader);
        
        // LoaderThread 破棄
        _loader = null;
        
        // 次を読み込む
        run();
    }
    
    private function loadInterrupted() : Void
    {
        // LoaderThread にも割り込みをかけて終了
        _loader.interrupt();
        _loader = null;
    }
    
    private function loadError(e : Error, t : Thread) : Void
    {
        // 写真イメージの読み込みでエラーが起きた際には無視する
        _loader = null;
        // 何事も無かったかのように次へ
        run();
    }
}
