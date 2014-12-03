/*
 * Flickr Sphere (Sample of the ActionScript Thread Library)
 * 
 * Licensed under the MIT License
 * 
 * Copyright (c) 2008 BeInteractive! (www.be-interactive.org) and
 *					  Spark project	 (www.libspark.org)
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
package org.libspark.flickrsphere;


import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.Thread;
import org.papervision3d.cameras.Camera3D;
import org.papervision3d.objects.primitives.Sphere;
import org.papervision3d.render.BasicRenderEngine;
import org.papervision3d.scenes.Scene3D;
import org.papervision3d.view.Viewport3D;

/**
 * Context クラスは、アプリケーションで必要ないくつかのオブジェクトを保持します.
 */
class Context
{
	// Stage
	public var stage:Stage;
	
	// Papervision3D 関連
	public var viewport:Viewport3D;
	public var renderer:BasicRenderEngine;
	public var camera:Camera3D;
	public var scene:Scene3D;
	
	// Sphere
	public var sphere:Sphere;
	// Sphere の回転度合い
	public var sphereRotation:Float = 0.1;
	
	// メインレイヤー
	public var layer:DisplayObjectContainer;

	public function new()
	{
	}
}
