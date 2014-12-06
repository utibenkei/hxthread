import massive.munit.TestSuite;

import org.libspark.thread.ExceptionTest;
import org.libspark.thread.TesterThreadTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(org.libspark.thread.ExceptionTest);
		add(org.libspark.thread.TesterThreadTest);
	}
}
