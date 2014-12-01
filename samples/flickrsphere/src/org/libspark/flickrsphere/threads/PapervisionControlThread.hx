/*
 * Flickr Sphere (Sample of the ActionScript Thread Library)
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
package org.libspark.flickrsphere.threads;


import org.libspark.flickrsphere.Context;
import org.libspark.thread.Thread;

/**
	 * PapervisionControlThread クラスは、3D 関係の基本的な制御を行います.
	 */
class PapervisionControlThread extends Thread
{
    public function new(context : Context)
    {
        super();
        _context = context;
    }
    
    private var _context : Context;
    
    override private function run() : Void
    {
        // 最初のレンダリングがおかしいので 1 回多くレンダリングする
        _context.renderer.renderScene(_context.scene, _context.camera, _context.viewport);
        
        render();
    }
    
    private function render() : Void
    {
        // Sphere の回転
        _context.sphere.rotationY += _context.sphereRotation;
        
        // レンダリング
        _context.renderer.renderScene(_context.scene, _context.camera, _context.viewport);
        
        // ループさせる
        next(render);
    }
}
