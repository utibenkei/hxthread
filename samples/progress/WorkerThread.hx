
import org.libspark.thread.Thread;
import org.libspark.thread.utils.IProgress;
import org.libspark.thread.utils.IProgressNotifier;
import org.libspark.thread.utils.Progress;

/**
 * このスレッドは、時間のかかる処理をしつつ、その進捗状況を通知する機能を持ちます。
 * 
 * 進捗状況を通知するためには、 IProgressNotifier インターフェイスを実装し、
 * pgoress プロパティを返すようにします。
 * 
 * progress プロパティは IProgress インターフェイスの実装クラスである必要があり、
 * Progress クラスを使用するのが最も簡単です。
 */
class WorkerThread extends Thread implements IProgressNotifier
{
	public var progress(get, never):IProgress;

	public function new(name:String)
	{
		super();
		this.name = "[" + name + "]";
		
		// この WorkerThread が行う仕事の量をランダムで決めます
		_task = Math.floor(Math.random() * 3) + 2;
		// 進捗状況を通知するための Progress クラスのインスタンスを作成します
		_progress = new Progress();
	}
	
	private var _task:Int;
	private var _worked:Int = 0;
	private var _progress:Progress;
	
	/**
	 * このプロパティは IProgressNotifier インターフェイスによって定義されます。
	 * 進捗状況を通知可能にするために、 IProgress インターフェイスのインスタンスを返します。
	 */
	private function get_Progress():IProgress
	{
		return _progress;
	}
	
	/**
	 * スレッドの処理は run メソッドをオーバーライドして記述します
	 */
	override private function run():Void
	{
		// 仕事の開始を通知します
		// 引数には、行うべき仕事量の合計を渡します
		_progress.start(_task);
		
		// デバッグ用
		trace(name + " Start (task=" + _task + ")");
		
		// 次は実際に仕事をします
		next(work);
	}
	
	private function work():Void
	{
		// 仕事をします
		++_worked;
		
		// 仕事が進行したことを通知します
		_progress.progress(_worked);
		
		// デバッグ用
		trace(name + " Progress (worked=" + _worked + ")");
		
		// 仕事が完了した場合
		if (_worked == _task) {
			// 仕事が完了したことを通知します
			_progress.complete();
			// デバッグ用
			trace(name + " Complete");
			// スレッドを終了します
			return;
		}  // 500ms 休みます (時間のかかる処理をシミュレートするためです)  
		
		
		
		sleep(500);
		
		// そしてまた仕事をします
		next(work);
	}
}
