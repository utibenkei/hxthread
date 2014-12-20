/**
 * ImageBase
 * XMLと画像を取得するサンプル
 * 
 * 仕様
 *	 XMLをはじめに読み込みし、XMLの中に記述されている画像のURLと画像名を取得する。
 *	 画像のURLと画像名から、画像を読み込み、表示する。
 * 
 * @author utibenkei
 * @link
 * @version 0.1
 * @package classes
 */

import flash.display.MovieClip;
import flash.events.Event;
import flash.Lib;
import flash.events.ProgressEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.display.Loader;
import flash.events.IOErrorEvent;
import openfl.display.DisplayObjectContainer;

import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.Thread;


class ImageBase extends MovieClip
{
	
	public var loader:Loader;
	
	private function init() 
	{
		//レッドライブラリを初期化
		Thread.initialize(new EnterFrameThreadExecutor());
		
		//MainThread起動
		var main:ImageThread = new ImageThread(this);
		main.start();
		
		//var aaa:MovieClip = new MovieClip();
		//var aaa:flash.display.Sprite = new flash.display.Sprite();
		//this.addChild(aaa);
		//aaa.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		
/*		trace("aaaaaaaaa");
		var loader:URLLoader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, enterFrameHandler);
		loader.addEventListener(ProgressEvent.PROGRESS, enterFrameHandler);
	loader.load(new URLRequest("http://mail-keishicho.org/feed"));*/
	
/*		trace("aaaaaaaaa");
		loader = new Loader();
		//this.addChild(loader);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
		loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, enterFrameHandler);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		
		loader.load(new URLRequest("image/chinchilla.png"));
		//trace(loader.loaderInfo.url);
		trace("aaaaaaaaa");*/
		
	}
	
	private function enterFrameHandler(e:Event):Void
	{
		trace("aaaa" + e);
	}
	
	private function completeHandler(e:Event):Void
	{
		trace("completeHandler" + e);
		Lib.current.addChild(loader.content);
	}
	
	private function ioErrorHandler(e:IOErrorEvent):Void
	{
		trace("ioErrorHandler" + e);
	}
	
	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		init();
	}
	
	/**
	 * コンストラクタ
	 *
	 * @access public
	 * @param
	 * @return
	 */
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new ImageBase());
	}
}
