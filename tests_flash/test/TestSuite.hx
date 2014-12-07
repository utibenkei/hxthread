import massive.munit.TestSuite;

import org.libspark.thread.AuxiliaryTest;
import org.libspark.thread.EventTest;
import org.libspark.thread.ExceptionTest;
import org.libspark.thread.InterruptionTest;
import org.libspark.thread.MonitorTest;
import org.libspark.thread.TesterThreadTest;
import org.libspark.thread.ThreadExceptionTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(org.libspark.thread.AuxiliaryTest);
		add(org.libspark.thread.EventTest);
		add(org.libspark.thread.ExceptionTest);
		add(org.libspark.thread.InterruptionTest);
		add(org.libspark.thread.MonitorTest);
		add(org.libspark.thread.TesterThreadTest);
		add(org.libspark.thread.ThreadExceptionTest);
	}
}
