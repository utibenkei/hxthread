
import flash.display.Sprite;
import org.libspark.as3unit.runner.AS3UnitCore;

class RunTests extends Sprite
{
    public function new()
    {
        super();
        AS3UnitCore.main(AllTests);
    }
}
