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
package org.libspark.thread.threads.frocessing;


import flash.display.Graphics;
import frocessing.core.F5Graphics;
import frocessing.core.F5Graphics3D;
import org.libspark.thread.Thread;

/**
	 * Forcessing を実行するためのスレッドです.
	 * 
	 * <p>描画には F5Graphics3D クラスが使用されます。</p>
	 * 
	 * @author	yossy:beinteractive
	 */
class Frocessing3DThread extends Thread
{
    private var fg(get, never) : F5Graphics3D;

    /**
		 * 新しい Frocessing3DThread クラスのインスタンスを作成します.
		 * 
		 * @param	target	描画先となる Graphics
		 */
    public function new(target : Graphics)
    {
        super();
        _fg = new F5Graphics3D(target, 100, 100);
    }
    
    private var _fg : F5Graphics3D;
    
    /**
		 * 描画をするための F5Graphics3D
		 */
    private function get_Fg() : F5Graphics3D
    {
        return _fg;
    }
    
    /**
		 * @private
		 */
    override private function run() : Void
    {
        setup();
        doDraw();
    }
    
    /**
		 * @private
		 */
    private function doDraw() : Void
    {
        fg.beginDraw();
        draw();
        fg.endDraw();
        
        next(doDraw);
    }
    
    /**
		 * このメソッドをオーバーライドして初期化処理を記述します.
		 */
    private function setup() : Void
    {
        
        
    }
    
    /**
		 * このメソッドをオーバーライドして描画処理を記述します.
		 */
    private function draw() : Void
    {
        
        
    }
}
