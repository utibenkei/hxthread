/**
 * ImageAndSoundThread
 * 
 * @author utibenkei
 * @link
 * @version 0.1
 * @package classes
 */

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.errors.IOError;
import flash.errors.SecurityError;
import flash.net.URLRequest;
import haxe.xml.Fast;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.media.SoundChannel;
import org.libspark.thread.Thread;
import org.libspark.thread.threads.display.LoaderThread;
import org.libspark.thread.threads.media.SoundLoaderThread;
import org.libspark.thread.threads.net.URLLoaderThread;
import org.libspark.thread.threads.utils.FunctionThread;
import org.libspark.thread.utils.Executor;
import org.libspark.thread.utils.ParallelExecutor;
import org.libspark.thread.utils.SerialExecutor;


class ImageThread extends Thread
{
	private var _layer:DisplayObjectContainer;
	
	private var _mainExecutor:Executor;
	
	private var _xmlLoader:URLLoaderThread;
	private var _imageXmlData:Array<Dynamic> = new Array<Dynamic>();
	
	private var _imageLoaders:Executor;
	
	private var _imageLoaderSingle:LoaderThread;
	
	private var _soundLoaderSingle:SoundLoaderThread;
	private var _soundLoaderSingleSC:SoundChannel;
	
	
	/**
	 * コンストラクタ
	 *
	 * @access public
	 * @param
	 * @return
	 */
	public function new(layer:DisplayObjectContainer)
	{
		super();
		_layer = layer;
		
	}
	
	/**
	 * XMLの取得
	 *
	 * @access protected
	 * @param
	 * @return void
	 */
	override private function run():Void
	{
		//直列実行されるメソッドを指定
		_mainExecutor = new SerialExecutor();
		
		// 画像をロード・表示
		// ※制限※　native ターゲットではgif形式の画像ファイルはロードできない
		//　※html5 ターゲットでExecutorを経由してロードした画像が表示されない現象あり
		_mainExecutor.addThread(new FunctionThread(loadXml4Images, ["xml/image.xml"]));
		
		_mainExecutor.addThread(new FunctionThread(loadImageSingle, ["image/chinchilla.png"]));
		_mainExecutor.addThread(new FunctionThread(loadImageSingle, ["image/donkey.jpg"]));
		#if (flash || html5)
		_mainExecutor.addThread(new FunctionThread(loadImageSingle, ["image/penguin.gif"]));
		#end
		//
		
		//休憩
		_mainExecutor.addThread(new FunctionThread(waitFunc, [1000]));
		//
		
		//サウンドをロード・再生
		// ※制限※　flash ターゲットではwav/ogg形式のサウンドファイルはロードできない
		// ※native ターゲットではsound.load()未対応なのでストリーミング再生きないが、"HXTHREAD_USE_LOADBYTES_SOUNDLOADER"コンパイルフラグをつけることで、
		// URLLoaderでバイナリデータを完全ロードする方式で再生できるようにしました(ogg/wav形式のみ)
		#if (flash || html5)
		_mainExecutor.addThread(new FunctionThread(loadSoundSingle, ["sound/theme.mp3"]));
		#end
		#if (native || html5)
		_mainExecutor.addThread(new FunctionThread(loadSoundSingle, ["sound/theme.ogg"]));
		_mainExecutor.addThread(new FunctionThread(loadSoundSingle, ["sound/theme.wav"]));
		#end
		//
		
		
		/*
		// Assetsから画像を取得して表示
		_mainExecutor.addThread(new FunctionThread(addImgaeSingleFromAssets, ["image/chinchilla.png"]));
		_mainExecutor.addThread(new FunctionThread(addImgaeSingleFromAssets, ["image/donkey.jpg"]));
		_mainExecutor.addThread(new FunctionThread(addImgaeSingleFromAssets, ["image/penguin.gif"]));
		*/
		
		/*
		// Assetsからサウンドを取得して再生
		_mainExecutor.addThread(new FunctionThread(playSoundSingleFromAssets, ["sound/theme.mp3"]));
		_mainExecutor.addThread(new FunctionThread(playSoundSingleFromAssets, ["sound/theme.ogg"]));
		_mainExecutor.addThread(new FunctionThread(playSoundSingleFromAssets, ["sound/theme.wav"]));
		*/
		
		_mainExecutor.start();
		_mainExecutor.join();
	}
	
	/*-----------------*/
	
	/**
	 * XMLの取得完了
	 *
	 * @access private
	 * @param
	 * @return void
	 */
	private function loadXml4Images(url:String):Void
	{
		//URLLoaderThreadを作成
		_xmlLoader = new URLLoaderThread(new URLRequest(url));
		
		//debug
		trace("MainThread XML Begin Loading. " + url);
		
		// ロード処理を開始
		_xmlLoader.start();
		
		//ロード待ち
		_xmlLoader.join();
		
		//次に実行されるメソッドの設定
		Thread.next(loadCompleteXml4Images);
		
		
		//例外ハンドラの設定
		Thread.error(IOError, errorHandler);
		Thread.error(SecurityError, errorHandler);
	}
	
	/**
	 * XMLの取得完了
	 *
	 * @access private
	 * @param
	 * @return void
	 */
	private function loadCompleteXml4Images():Void
	{
	
		//debug
		trace("MainThread XML Complete Loading.");
		
		//XMLデータを取得し、スレッドに追加
		var xml:Xml = Xml.parse(_xmlLoader.loader.data);
		var data:Fast = new Fast(xml.firstElement());
		
		var	 i:UInt = 0;
		for (obj in data.node.image.nodes.array) {
			var imageUrl:String = obj.node.path.innerData + "" + obj.node.name.innerData;
			_imageXmlData[i] = {
						id:i,
						url:imageUrl,
					};
			i++;
		}
		
		//次に実行されるメソッドの設定
		Thread.next(loadImagesFromXml);
	}
	
	/**
	 * XMLのデータの画像群を並列ロード
	 *
	 * @access private
	 * @param
	 * @return void
	 */
	private function loadImagesFromXml():Void
	{
		//debug	 
		trace("MainThread Images Begin Loading.");
		
		//URLLoaderThreadを作成
		_imageLoaders = new ParallelExecutor();
		
		for (data in _imageXmlData){
			_imageLoaders.addThread(new LoaderThread(new URLRequest(data.url)));
		}
		
		
		// ロード処理を開始
		_imageLoaders.start();
		
		//ロード待ち
		_imageLoaders.join();
		
		//次に実行されるメソッドの設定
		Thread.next(loadCompleteImagesFromXml);
		
		//例外ハンドラの設定
		Thread.error(IOError, errorHandler);
		Thread.error(SecurityError, errorHandler);
	}
	
	/**
	 * XMLのデータの画像群の並列ロード完了
	 *
	 * @access private
	 * @param
	 * @return void
	 */
	private function loadCompleteImagesFromXml():Void
	{
		//debug
		trace("MainThread Images Complete Loading.");// trace(_xmlData);
		
		for (i in 0..._imageXmlData.length){
			var imageThread:LoaderThread = cast((_imageLoaders.getThreadAt(i)), LoaderThread);
			
			// flash と　html5 環境ではloadBytes()でロードした場合、loder.contntがnullになっていることがある
			//trace("loader.content is null: " + (imageThread.loader.content == null));
			
			var content:DisplayObject = imageThread.loader.content;
			content.x = i * 300;
			content.y = Math.random() * 100;
			_layer.addChild(content);
			
		}
	}
	
	/*-----------------*/
	
	/**
	 * 画像を単体ロード
	 *
	 * @access private
	 * @param
	 * @return void
	 */
	private function loadImageSingle(url:String):Void
	{
		//debug	 
		trace("MainThread SingleImage Begin Loading. " + url);
		
		_imageLoaderSingle = new LoaderThread(new URLRequest(url));
		
		// ロード処理を開始
		_imageLoaderSingle.start();
		
		//ロード待ち
		_imageLoaderSingle.join();
		
		//次に実行されるメソッドの設定
		Thread.next(loadCompleteImageSingle);
		
		//例外ハンドラの設定
		Thread.error(IOError, errorHandler);
		Thread.error(SecurityError, errorHandler);
	}
	
	/**
	 * 画像の単体ロード完了
	 *
	 * @access private
	 * @param
	 * @return void
	 */
	private function loadCompleteImageSingle():Void
	{
		//debug
		trace("MainThread SingleImage Complete Loading.");
		
		// flash と　html5 環境ではloadBytes()でロードした場合、loder.contntがnullになっていることがある
		//trace("loader.content is null: " + (_imageLoaderSingle.loader.content == null));
		
		var content:DisplayObject = _imageLoaderSingle.loader.content;
		content.x = Math.random() * 300;
		content.y = 200;
		_layer.addChild(content);
		
	}
	
		
	// Assetsから取得して表示
	private function addImgaeSingleFromAssets(url:String):Void
	{
		//flash (png / jpg / gif)
		//native (png / jpg)
		//html5  (png / jpg / gif)
		trace("MainThread SingleImage From Assets. " + url);
		
		var content:Bitmap = new Bitmap(Assets.getBitmapData(url));
		content.x = Math.random() * 300;
		content.y = 200;
		_layer.addChild(content);
	}
	
	
	/*-----------------*/
	
	/**
	 * サウンドの単体ロード
	 *
	 * @access private
	 * @param
	 * @return void
	 */
	private function loadSoundSingle(url:String):Void
	{
		trace("MainThread SingleSound Begin Loading. " + url);
		
		_soundLoaderSingle = new SoundLoaderThread(new URLRequest(url));
		// ロード処理を開始
		_soundLoaderSingle.start();
		//ロード待ち
		_soundLoaderSingle.join();
		
		Thread.next(loadCompleteSoundSingle);
		
		//例外ハンドラの設定
		Thread.error(IOError, errorHandler);
		Thread.error(SecurityError, errorHandler);
	}
	
	/**
	 * サウンドの単体ロード完了・再生
	 *
	 * @access private
	 * @param
	 * @return void
	 */
	private function loadCompleteSoundSingle():Void
	{
		trace("MainThread SingleSound Complete Loading.");
		
		_soundLoaderSingleSC = _soundLoaderSingle.sound.play();
		
		trace("MainThread SingleSound Will Play The 3000ms Sound.");
		
		Thread.sleep(3000);
		
		Thread.next(stopSoundSingle);
	}
	
	/**
	 * サウンドの停止
	 *
	 * @access private
	 * @param
	 * @return void
	 */
	private function stopSoundSingle():Void
	{
		trace("MainThread SingleSound Stop Sound.");
		
		_soundLoaderSingleSC.stop();
	}
	
	
		
	// Assetsから取得して再生
	private function playSoundSingleFromAssets(url:String):Void
	{
		//flash (mp3 / wav)
		//native (ogg / wav)
		//html5  (mp3 / ogg / wav)
		trace("MainThread SingleSound  From Assets. " + url);
		
		_soundLoaderSingleSC = Assets.getMusic(url).play();
		
		trace("MainThread SingleSound Will Play The 3000ms Sound.");
		
		Thread.sleep(3000);
		
		Thread.next(stopSoundSingle);
	}
	
	
	/*-----------------*/
	
	/**
	 * 一定時間待つ
	 *
	 * @access private
	 * @param time
	 * @return void
	 */
	private function waitFunc(time:UInt = 1000):Void
	{
		trace("MainThread Will Wait For " + time + "ms.");
		
		Thread.sleep(time);
	}
	
	
	/*-----------------*/
	
	
	/**
	 * スレッド終了処理
	 *
	 * @access protected
	 * @param
	 * @return void
	 */
	override private function finalize():Void
	{
		_mainExecutor = null;
		_xmlLoader = null;
		_imageLoaders = null;
		_imageLoaderSingle = null;
		_soundLoaderSingle = null;
		
		//debug
		trace("MainThread End.");
	}
	
	/**
	 * 例外ハンドラ
	 *
	 * @access private
	 * @param e 発生した例外
	 * @param thread 発生元のスレッド
	 * @return void
	 */
	private function errorHandler(e:IOError, t:Thread):Void
	{
		//debug
		trace("MainThread Error.");
		
		//例外を出力して終了
		trace(e.getStackTrace());
		trace(e.message);
		
		//例外ハンドラから終了する
		Thread.next(null);
	}
}
