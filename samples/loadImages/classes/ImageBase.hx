/**
 * ImageBase
 * XMLと画像を取得するサンプル
 * 
 * 仕様
 *   XMLをはじめに読み込みし、XMLの中に記述されている画像のURLと画像名を取得する。
 *   画像のURLと画像名から、画像を読み込み、表示する。
 * 
 * @author m.minaco < m.minaco[at-mark]gmail.com >
 * @link
 * @version 0.1
 * @package classes
 */
package classes;

import classes.ImageThread;

import classes.*;
import flash.display.MovieClip;

import org.libspark.thread.Thread;
import org.libspark.thread.EnterFrameThreadExecutor;

class ImageBase extends MovieClip
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
        //レッドライブラリを初期化
        Thread.initialize(new EnterFrameThreadExecutor());
        
        //MainThread起動
        var main : ImageThread = new ImageThread(this);
        main.start();
    }
}
