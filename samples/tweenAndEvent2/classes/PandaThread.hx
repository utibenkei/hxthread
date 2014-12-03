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

import caurina.transitions.Tweener;


class PandaThread extends Thread
{
	private var _serial:SerialExecutor;
	
	public var _panda:DisplayObject;
	
	public var _head:MovieClip;
	
	private var _tweener:TweenerThread;
	
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
		moveRight();
	}
	
	/**
	 * 首を右に傾ける
	 *
	 * @access private
	 * @param
	 * @return void
	 */
	private function moveRight():Void
	{
		_tweener = new TweenerThread(_head, {
					rotation:-10,
					transition:"easeInOutCubic",
					time:2.0,

				});
		
		//debug
		trace("PandaTheread Begin Tweener.");
		
		_tweener.start();
		_tweener.join();
		
		next(moveLeft);
		
		//イベント
		event(_head, MouseEvent.MOUSE_OVER, stopAnimation);
		
		error(IOError, errorHandler);
		error(SecurityError, errorHandler);
	}
	
	/**
	 * 首を左に傾ける
	 *
	 * @access private
	 * @param
	 * @return void
	 */
	private function moveLeft():Void
	{
		_tweener = new TweenerThread(_head, {
					rotation:10,
					transition:"easeInOutCubic",
					time:2.0,

				});
		
		//debug
		trace("PandaTheread Begin Tweener.");
		
		_tweener.start();
		_tweener.join();
		
		next(moveRight);
		
		//イベント
		event(_panda, MouseEvent.MOUSE_OVER, stopAnimation);
		
		error(IOError, errorHandler);
		error(SecurityError, errorHandler);
	}
	
	/**
	 * アニメーションを開始する
	 *
	 * @access private
	 * @param
	 * @return void
	 */
	private function startAnimation(e:MouseEvent = null):Void
	{
		//debug
		trace("PandaThread Start Animation.");
		
		moveRight();
	}
	
	/**
	 * アニメーションを停止する
	 *
	 * @access private
	 * @param
	 * @return void
	 */
	private function stopAnimation(e:MouseEvent = null):Void
	{
		//debug
		trace("PandaThread Stop Animation.");
		
		_tweener.cancel();
		event(_panda, MouseEvent.MOUSE_OUT, startAnimation);
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
		trace("PandaThread End.");
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
		trace("PandaThread Error.");
		
		//例外を出力して終了
		trace(e.getStackTrace());
		
		//例外ハンドラから終了する
		next(null);
	}
}
