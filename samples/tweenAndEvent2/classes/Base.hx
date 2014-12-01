/**
 * Base
 * MovieClipを動かす＆イベントを操作するサンプル
 * 
 * 仕様
 *   パンダが首を、右、左に傾け動く。パンダをマウスオーバーすると停止し、マウスアウトすると再び動きだす。
 * 
 * @author m.minaco < m.minaco[at-mark]gmail.com >
 * @link
 * @version 0.1
 * @package classes
 */
package classes;

import classes.MainThread;

import classes.*;

import flash.display.MovieClip;

import org.libspark.thread.Thread;
import org.libspark.thread.EnterFrameThreadExecutor;

class Base extends MovieClip
{
    /**
		 * コンストラクタ
		 *
		 * @access public
		 * @param
		 * @return
		 */
    public function new()
    {
        super();
        //スレッドライブラリを初期化
        Thread.initialize(new EnterFrameThreadExecutor());
        
        //MainTheread起動
        var main : MainThread = new MainThread(this);
        main.start();
    }
}
