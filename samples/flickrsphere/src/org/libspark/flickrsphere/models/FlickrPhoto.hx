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
package org.libspark.flickrsphere.models;


/**
 * FlickrPhoto クラスは、Flickr の写真データのモデルクラスです.
 */
class FlickrPhoto
{
	public var id(get, set):String;
	public var secret(get, set):String;
	public var serverId(get, set):String;
	public var farmId(get, set):String;
	public var smallSquareImageURL(get, never):String;

	private var _id:String = "";
	private var _secret:String = "";
	private var _serverId:String = "";
	private var _farmId:String = "";
	
	private function get_Id():String
	{
		return _id;
	}
	
	private function set_Id(value:String):String
	{
		_id = value;
		return value;
	}
	
	private function get_Secret():String
	{
		return _secret;
	}
	
	private function set_Secret(value:String):String
	{
		_secret = value;
		return value;
	}
	
	private function get_ServerId():String
	{
		return _serverId;
	}
	
	private function set_ServerId(value:String):String
	{
		_serverId = value;
		return value;
	}
	
	private function get_FarmId():String
	{
		return _farmId;
	}
	
	private function set_FarmId(value:String):String
	{
		_farmId = value;
		return value;
	}
	
	private function get_SmallSquareImageURL():String
	{
		return "http://farm" + farmId + ".static.flickr.com/" + serverId + "/" + id + "_" + secret + "_s.jpg";
	}

	public function new()
	{
	}
}
