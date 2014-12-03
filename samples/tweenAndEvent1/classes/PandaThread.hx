/**
 * PandaTheread
 *	パンダMovieClipを動かすためのスレッド
 * 
 * @author m.minaco < m.minaco[at-mark]gmail.com >
 * @link
 * @version 0.1
 * @package classes
 */
package classes;


import classes.*;

import flash.display.MovieClip;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import flash.errors.IOError;

import org.libspark.thread.Thread;
import org.libspark.thread.threads.tweener.TweenerThread;
import org.libspark.thread.utils.SerialExecutor;


class PandaThread extends Thread
{
	private var _serial:SerialExecutor;
	
	public var _panda:DisplayObject;
	
	public var _head:MovieClip;
	
	/**
	 * コンストラクタ
	 *
	 * @access public
	 * @param
	 * @return
	 */
	public function new(panda:DisplayObject)
	{
		super();
		_panda = panda;
		_head = cast((panda), Object).getChildByName("head");
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
		rotateHead();
	}
	
	/**
	 * 首を傾ける
	 *
	 * @access private
	 * @param
	 * @return void
	 */
	private function rotateHead():Void
	{
		var threadRtoL:Thread = new TweenerThread(_head, {
			rotation:-10,
			transition:"easeInOutCubic",
			time:2.0,

		});
		var threadLtoR:Thread = new TweenerThread(_head, {
			rotation:10,
			transition:"easeInOutCubic",
			time:2.0,

		});
		
		_serial = new SerialExecutor();
		_serial.addThread(threadRtoL);
		_serial.addThread(threadLtoR);
		
		//debug
		trace("PandaTheread Begin Tweener.");
		
		//Tween開始
		_serial.start();
		
		//Tween終了待ち
		_serial.join();
		
		//イベント
		event(_panda, MouseEvent.CLICK, clickHandler);
		
		//次に実行されるメソッドの設定
		next(rotateHead);
		
		//例外ハンドラの設定
		error(IOError, errorHandler);
		error(SecurityError, errorHandler);
	}
	
	/**
	 * クリックした場合、Traceされ5秒後再び動きだす
	 *
	 * @access protected
	 * @param
	 * @return void
	 */
	private function clickHandler(e:Event):Void{
		//debug
		trace("##Panda Click!!");
		
		sleep(5 * 1000);
		
		next(rotateHead);
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
		_serial = null;
		
		//debug
		trace("PandaTheread End.");
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
		trace("PandaTheread Error.");
		
		//例外を出力して終了
		trace(e.getStackTrace());
		
		//例外ハンドラから終了する
		next(null);
	}
}
