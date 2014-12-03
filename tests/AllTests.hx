
import org.libspark.as3unit.runners.Suite;
import org.libspark.thread.ThreadAllTests;

class AllTests
{
	public static var RunWith:Class<Dynamic> = Suite;
	public static var SuiteClasses:Array<Dynamic> = [
		ThreadAllTests];

	public function new()
	{
	}
}
