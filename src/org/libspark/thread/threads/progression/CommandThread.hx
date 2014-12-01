/*
 * ActionScript Thread Library
 * 
 * Licensed under the MIT License
 * 
 * Copyright (c) 2008 BeInteractive! (www.be-interactive.org) and
 *                    Spark project  (www.libspark.org)
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
package org.libspark.thread.threads.progression;


import jp.progression.core.commands.Command;
import jp.progression.events.CommandEvent;
import org.libspark.thread.Thread;

/**
	 * Progression の Command を Thread として実行するためのクラスです.
	 * 
	 * <p>スレッドが開始されると、コンストラクタで指定されたコマンドの実行を開始し、
	 * コマンドの実行が終了するとスレッドの実行も終了します。</p>
	 * 
	 * <p>このスレッドに対して割り込みを掛けるとコマンドの interrupt メソッドを呼び出した上で
	 * コマンドの終了を待ちます。</p>
	 * 
	 * <p>コマンド内で例外が発生した場合は、その例外がスローされ、親スレッドに伝播します。</p>
	 * 
	 * @author	yossy:beinteractive
	 */




class CommandThread extends Thread
{
    /**
		 * 新しい CommandThread クラスのインスタンスを作成します.
		 * 
		 * @param	c	実行するコマンド
		 */
    public function new(c : Command)
    {
        super();
        _command = c;
    }
    
    private var _command : Command;
    
    /**
		 * @private
		 */
    private function events() : Void
    {
        event(_command, CommandEvent.COMMAND_COMPLETE, completeHandler);
        event(_command, CommandEvent.COMMAND_INTERRUPT, completeHandler);
        event(_command, CommandEvent.COMMAND_ERROR, errorHandler);
    }
    
    /**
		 * @private
		 */
    override private function run() : Void
    {
        // イベントハンドラ設定
        events();
        // 割り込みハンドラ設定
        interrupted(interruptedHandler);
        // 実行
        // 別スレッドにして実行しているのは、 Command を execute した瞬間イベントが飛んでくることがあるので、
        // 確実にイベントハンドラが設定された状態で execute を呼び出すため (イベントハンドラはこの関数を抜けた後に設定される)
        new CommandFireThread(_command).start();
    }
    
    /**
		 * @private
		 */
    private function interruptedHandler() : Void
    {
        // イベントハンドラ設定
        events();
        // 中断をかける
        _command.interrupt();
    }
    
    /**
		 * @private
		 */
    private function completeHandler(e : CommandEvent) : Void
    {
        // おわる
        
    }
    
    /**
		 * @private
		 */
    private function errorHandler(e : CommandEvent) : Void
    {
        // エラーを再スロー
        throw e.errorObject;
    }
}



class CommandFireThread extends Thread
{
    public function new(command : Command)
    {
        super();
        _command = command;
    }
    
    private var _command : Command;
    
    override private function run() : Void
    {
        _command.execute();
    }
}