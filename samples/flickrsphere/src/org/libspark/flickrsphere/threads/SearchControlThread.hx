/*
 * Flickr Sphere (Sample of the ActionScript Thread Library)
 * 
 * Licensed under the MIT License
 * 
 * Copyright (c) 2008 BeInteractive! (www.be-interactive.org) and
 *					  Spark project	 (www.libspark.org)
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
package org.libspark.flickrsphere.threads;

import nme.errors.Error;
import org.libspark.flickrsphere.threads.DisplayFlickrPhotoThread;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.events.MouseEvent;
import flash.text.TextField;
import org.libspark.flickrsphere.Context;
import org.libspark.flickrsphere.threads.flickr.SearchFlickrPhotoThread;
import org.libspark.thread.Thread;

/**
 * SearchControlThread クラスは、検索に関する制御を行います.
 */
class SearchControlThread extends Thread
{
	public function new(context:Context)
	{
		super();
		_context = context;
		_searchButton = cast((_context.layer.getChildByName("searchButton")), InteractiveObject);
		_keywordField = cast((_context.layer.getChildByName("keywordField")), TextField);
		_indicator = cast((_context.layer.getChildByName("indicator")), DisplayObject);
	}
	
	private var _context:Context;
	private var _searchButton:InteractiveObject;
	private var _keywordField:TextField;
	private var _indicator:DisplayObject;
	
	private var _searchFlickr:SearchFlickrPhotoThread;
	private var _displayPhotos:DisplayFlickrPhotoThread;
	
	override private function run():Void
	{
		// 検索ボタンクリック待ち
		event(_searchButton, MouseEvent.CLICK, searchClickHandler);
	}
	
	private function searchClickHandler(e:MouseEvent = null):Void
	{
		// インジケータ表示
		_indicator.visible = true;
		
		// 検索を開始して完了を待つ
		_searchFlickr = new SearchFlickrPhotoThread(_keywordField.text);
		_searchFlickr.start();
		_searchFlickr.join();
		// 完了したら searchComplete
		next(searchComplete);
		// 再びボタンをクリックされたら searchInterrupted
		event(_searchButton, MouseEvent.CLICK, searchInterrupted);
		// エラーが起きたら searchError
		error(Error, searchError);
	}
	
	private function searchInterrupted(e:MouseEvent = null):Void
	{
		// 現在の検索をキャンセルして
		_searchFlickr.interrupt();
		_searchFlickr = null;
		// 再検索
		searchClickHandler();
	}
	
	private function searchError(e:Error, t:Thread):Void
	{
		// エラーが起きたらリトライしてみる
		searchClickHandler();
	}
	
	private function searchComplete():Void
	{
		// インジケータ非表示
		_indicator.visible = false;
		
		// もし既に写真の表示がされていれば
		if (_displayPhotos != null) {
			// それをキャンセル
			_displayPhotos.interrupt();
			// 終わるのを待って
			_displayPhotos.join();
			// 新しい写真の表示を開始
			next(displayPhotos);
		}
		else {
			// 既に表示されている写真が無ければすぐに表示を開始
			displayPhotos();
		}
	}
	
	private function displayPhotos():Void
	{
		// 写真の表示を開始
		_displayPhotos = new DisplayFlickrPhotoThread(_context, _searchFlickr.photos);
		_displayPhotos.start();
		// もういらない
		_searchFlickr = null;
		// run に戻る
		run();
	}
}
