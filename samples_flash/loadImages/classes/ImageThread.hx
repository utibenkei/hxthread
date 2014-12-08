/**
 * ImageThread
 * 
 * @author utibenkei
 * @link
 * @version 0.1
 * @package classes
 */
package classes;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.errors.IOError;
import flash.errors.SecurityError;
import flash.net.URLRequest;
import haxe.xml.Fast;
import org.libspark.thread.Thread;
import org.libspark.thread.threads.display.LoaderThread;
import org.libspark.thread.threads.net.URLLoaderThread;
import org.libspark.thread.utils.Executor;
import org.libspark.thread.utils.ParallelExecutor;


class ImageThread extends Thread
{
	private var _layer:DisplayObjectContainer;
	
	private var _xmlLoader:URLLoaderThread;
	
	private var _xmlUrl:String = "./xml/image.xml";
	
	private var _xmlData:Array<Dynamic> = new Array<Dynamic>();
	
	private var _imageLoaders:Executor;
	
	
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
		
		//URLLoaderThreadを作成
		_xmlLoader = new URLLoaderThread(new URLRequest(_xmlUrl));
		
		//debug
		trace("MainThread XML Begin Loading.");
		
		// ロード処理を開始
		_xmlLoader.start();
		
		//ロード待ち
		_xmlLoader.join();
		
		
		//次に実行されるメソッドの設定
		Thread.next(executeCompleteXml);
		
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
	private function executeCompleteXml():Void
	{
	
		//debug
		trace("MainThread XML Complete Loading.");
		
		//URLLoaderThreadを作成
		_imageLoaders = new ParallelExecutor();
		
		//XMLデータを取得し、スレッドに追加
		var xml:Xml = Xml.parse(_xmlLoader.loader.data);
		var data:Fast = new Fast(xml.firstElement());
		
		var	 i:UInt = 0;
		for (obj in data.node.image.nodes.array) {
			var imageUrl:String = obj.node.path.innerData + "" + obj.node.name.innerData;
			_imageLoaders.addThread(new LoaderThread(new URLRequest(imageUrl)));
			_xmlData[i] = {
						id:i,
						url:imageUrl,
					};
			i++;
		}
		
		
		//debug	 
		trace("MainThread Image Begin Loading.");
		
		// ロード処理を開始
		_imageLoaders.start();
		
		//ロード待ち
		_imageLoaders.join();
		
		//次に実行されるメソッドの設定
		Thread.next(executeCompleteImage);
		
		//例外ハンドラの設定
		Thread.error(IOError, errorHandler);
		Thread.error(SecurityError, errorHandler);
	}
	
	
	/**
	 * 画像の取得
	 *
	 * @access private
	 * @param
	 * @return void
	 */
	private function executeCompleteImage():Void
	{
		//debug
		trace("MainThread Image Complete Loading.");
		
		for (i in 0..._xmlData.length){
			var imageThread:LoaderThread = cast((_imageLoaders.getThreadAt(i)), LoaderThread);
			var content:DisplayObject = imageThread.loader.content;
			content.x = i * 300;
			_layer.addChild(content);
		}
	}
	
	/**
	 * スレッド終了処理
	 *
	 * @access protected
	 * @param
	 * @return void
	 */
	override private function finalize():Void
	{
		_xmlLoader = null;
		_imageLoaders = null;
		
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
		
		//例外ハンドラから終了する
		Thread.next(null);
	}
}
