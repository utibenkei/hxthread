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
package org.libspark.flickrsphere;


import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import org.libspark.flickrsphere.threads.CameraControlThread;
import org.libspark.flickrsphere.threads.IntroThread;
import org.libspark.flickrsphere.threads.PapervisionControlThread;
import org.libspark.flickrsphere.threads.ResizeHandlingThread;
import org.libspark.flickrsphere.threads.SearchControlThread;
import org.libspark.flickrsphere.tweener.ParticleShortcuts;
import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.Thread;
import org.papervision3d.cameras.Camera3D;
import org.papervision3d.materials.WireframeMaterial;
import org.papervision3d.objects.primitives.Sphere;
import org.papervision3d.render.BasicRenderEngine;
import org.papervision3d.scenes.Scene3D;
import org.papervision3d.view.Viewport3D;

/**
	 * FlickrSphere クラスは、FlickrSphere のメインとなるクラスです.
	 */
class FlickrSphere extends Sprite
{
    public function new()
    {
        super();
        // ステージに追加されたら初期化する
        addEventListener(Event.ADDED_TO_STAGE, initialize);
    }
    
    private function initialize(e : Event) : Void
    {
        removeEventListener(Event.ADDED_TO_STAGE, initialize);
        
        // Tweener のスペシャルプロパティを登録
        ParticleShortcuts.initialize();
        
        // スレッドライブラリを初期化
        Thread.initialize(new EnterFrameThreadExecutor());
        
        // コンテキスト
        var context : Context = new Context();
        
        context.stage = stage;
        context.layer = this;
        
        // Papervision3D 関連
        var viewport : Viewport3D = cast((addChildAt(new Viewport3D(800, 600, false), 0)), Viewport3D);
        var renderer : BasicRenderEngine = new BasicRenderEngine();
        var camera : Camera3D = new Camera3D();
        camera.z = 512;
        var scene : Scene3D = new Scene3D();
        var mat : WireframeMaterial = new WireframeMaterial(0x333333);
        mat.doubleSided = true;
        var sphere : Sphere = new Sphere(mat, 128, 8, 6);
        scene.addChild(sphere);
        
        context.viewport = viewport;
        context.renderer = renderer;
        context.camera = camera;
        context.scene = scene;
        context.sphere = sphere;
        
        indicator.visible = false;
        
        // リサイズ監視用スレッド
        new ResizeHandlingThread(context).start();
        // 検索制御用スレッド
        new SearchControlThread(context).start();
        // 初期アニメーション等を行うスレッド
        new IntroThread(context).start();
        // 3D 制御用スレッド
        new PapervisionControlThread(context).start();
    }
    
    // fla ファイルによって定義
    public var keywordField : DisplayObject;
    
    // fla ファイルによって定義
    public var searchButton : DisplayObject;
    
    // fla ファイルによって定義
    public var indicator : DisplayObject;
    
    // fla ファイルによって定義
    public var title : DisplayObject;
    
    // fla ファイルによって定義
    public var logos : DisplayObject;
    
    // fla ファイルによって定義
    public var guideClip : DisplayObject;
}
