/**
 * MainThread
 * 
 * @author m.minaco < m.minaco[at-mark]gmail.com >
 * @link
 * @version 0.1
 * @package classes
 */
package classes;

import classes.PandaThread;

import classes.*;

import flash.display.MovieClip;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import flash.errors.IOError;

import org.libspark.thread.Thread;
import org.libspark.thread.threads.tweener.TweenerThread;
import org.libspark.thread.utils.ParallelExecutor;


class MainThread extends Thread
{
	private var _layer:DisplayObjectContainer;
	
	private var _parallel:ParallelExecutor;
	
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
	 * run
	 *
	 * @access protected
	 * @param
	 * @return void
	 */
	override private function run():Void
	{
		runMainThread();
	}
	
	/**
	 * 首を傾ける
	 *
	 * @access private
	 * @param
	 * @return void
	 */
	private function runMainThread():Void
	{
		var threadPanda1:PandaThread = new PandaThread(_layer.getChildByName("panda1_mc"));
		var threadPanda2:PandaThread = new PandaThread(_layer.getChildByName("panda2_mc"));
		
		_parallel = new ParallelExecutor();
		_parallel.addThread(threadPanda1);
		_parallel.addThread(threadPanda2);
		
		//debug
		trace("MainThread Begin Tweener.");
		
		//開始
		_parallel.start();
		
		//例外ハンドラの設定
		error(IOError, errorHandler);
		error(SecurityError, errorHandler);
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
		_parallel = null;
		
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
		next(null);
	}
}
