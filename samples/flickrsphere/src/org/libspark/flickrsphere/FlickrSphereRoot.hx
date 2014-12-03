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
package org.libspark.flickrsphere;

import org.libspark.flickrsphere.MainClass;

import flash.display.MovieClip;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;


/**
 * FlickrSphereRoot クラスは、FlickrSphere のドキュメントルートとなるクラスです.
 * 
 * SWF 全体のロード完了を待って、メインのクラスである FlickrSphere クラスを実行します。
 */
class FlickrSphereRoot extends MovieClip
{
	public function new()
	{
		super();
		// ステージ設定
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.LEFT;
		
		// 初期フレームハンドラ
		addEventListener(Event.ENTER_FRAME, initialEnterFrameHandler);
	}
	
	private function initialEnterFrameHandler(e:Event):Void
	{
		// 3 フレーム目まで到達すればロードが完了している
		if (currentFrame == 3) {
			// のでイベントリスナー削除
			removeEventListener(Event.ENTER_FRAME, initialEnterFrameHandler);
			// これ以上進まないようストップ
			stop();
			
			// メインのクラスを取得
			var mainClass:Class<Dynamic> = Type.getClass(Type.resolveClass("org.libspark.flickrsphere.FlickrSphere"));
			// 開始
			addChild(Type.createInstance(mainClass, []));
		}
	}
}
