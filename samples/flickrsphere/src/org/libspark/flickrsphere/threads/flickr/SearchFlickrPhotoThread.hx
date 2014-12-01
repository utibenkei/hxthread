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

import flash.net.URLRequest;
import flash.net.URLVariables;
import org.libspark.flickrsphere.models.FlickrPhoto;
import org.libspark.thread.Thread;
import org.libspark.flickrsphere.FLICKRAPIKEY;
import org.libspark.thread.threads.net.URLLoaderThread;

/**
	 * SearchFlickrPhotoThread クラスは、Flickr の API を用いて写真を検索します.
	 */
class SearchFlickrPhotoThread extends Thread
{
    public var photos(get, never) : Array<Dynamic>;

    private static inline var REST_URL : String = "http://api.flickr.com/services/rest/";
    private static inline var REST_METHOD_NAME : String = "flickr.photos.search";
    
    /**
		 * @param	keyword	検索キーワード
		 */
    public function new(keyword : String)
    {
        super();
        _keyword = keyword;
        _photos = [];
    }
    
    private var _keyword : String;
    private var _loader : URLLoaderThread;
    private var _photos : Array<Dynamic>;
    
    /**
		 * 読み込んだ写真の FlickrPhoto の配列を返します.
		 */
    private function get_Photos() : Array<Dynamic>
    {
        return _photos;
    }
    
    /**
		 * API を呼び出すための URLRequest を生成して返します.
		 * 
		 * @return	URLRequest
		 * @private
		 */
    private function createURLRequest() : URLRequest
    {
        var req : URLRequest = new URLRequest(REST_URL);
        req.data = createURLVariables();
        return req;
    }
    
    /**
		 * API を呼び出すための URLVariables を生成して返します.
		 * 
		 * @return	URLVariables
		 * @private
		 */
    private function createURLVariables() : URLVariables
    {
        var val : URLVariables = new URLVariables();
        Reflect.setField(val, "api_key", FLICKR_APIKEY);
        Reflect.setField(val, "method", REST_METHOD_NAME);
        Reflect.setField(val, "text", _keyword);
        return val;
    }
    
    override private function run() : Void
    {
        // URLLoaderThread を使ってリクエストを投げる
        _loader = new URLLoaderThread(createURLRequest());
        _loader.start();
        _loader.join();
        // 完了したら loadComplete
        next(loadComplete);
        // 割り込まれたら loadInterrupted
        interrupted(loadInterrupted);
    }
    
    private function loadInterrupted() : Void
    {
        // URLLoaderThread にも割り込みをかけて終了
        _loader.interrupt();
        _loader = null;
    }
    
    private function loadComplete() : Void
    {
        // XML 取得
        var xml : FastXML = cast((_loader.loader.data), XML);
        
        // REST レスポンスが正常であれば
        if (Lambda.has(xml, "@stat") && Std.string(xml.att.stat) == "ok") {
            _photos.length = 0;
            // 写真データを FlickrPhoto クラスに詰め込んで配列に入れる
            for (photoXML/* AS3HX WARNING could not determine type for var: photoXML exp: EField(EField(EIdent(xml),photos),photo) type: null */ in xml.nodes.photos.node.photo.innerData){
                var photo : FlickrPhoto = new FlickrPhoto();
                photo.id = Std.string(photoXML.att.id);
                photo.secret = Std.string(photoXML.att.secret);
                photo.serverId = Std.string(photoXML.att.server);
                photo.farmId = Std.string(photoXML.att.farm);
                _photos.push(photo);
            }
        }
        else {
            // 正常でなければエラー
            throw new Error("flickr.photos.search");
        }
    }
}
