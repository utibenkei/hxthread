package org.libspark.thread;


import org.libspark.as3unit.runners.Suite;

class ThreadAllTests
{
    public static var RunWith : Class<Dynamic> = Suite;
    public static var SuiteClasses : Array<Dynamic> = [
        TesterThreadTest, 
        ThreadExecutionTest, 
        MonitorTest, 
        AuxiliaryTest, 
        ExceptionTest, 
        EventTest, 
        InterruptionTest];

    public function new()
    {
    }
}
