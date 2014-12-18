import async.tests.AsyncTestRunner;
import org.libspark.thread.AuxiliaryTest;
import org.libspark.thread.EventTest;
import org.libspark.thread.ExceptionTest;
import org.libspark.thread.InterruptionTest;
import org.libspark.thread.MonitorTest;
import org.libspark.thread.TesterThreadTest;
import org.libspark.thread.ThreadExceptionTest;


/**
 * ...
 * @author satoo
 */
class TestMain
{
	public static function main() 
	{
		trace('NOTE: It may tooks over 10 seconds until result will be shown (because there are async tests). Please have some coffee and wait. :)');
		
		var r = new AsyncTestRunner(onComplete);
		r.add(new AuxiliaryTest());
		r.add(new EventTest());
		r.add(new ExceptionTest());
		r.add(new InterruptionTest());
		r.add(new MonitorTest());
		r.add(new TesterThreadTest());
		r.add(new ThreadExceptionTest());
		r.run();
		
	}
	
	static function onComplete() {
		#if (cpp || neko || php)
		Sys.exit(0);
		#end
	}
	
}