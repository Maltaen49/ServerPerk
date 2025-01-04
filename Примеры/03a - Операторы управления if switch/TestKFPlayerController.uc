class TestKFPlayerController extends KFPlayerController;

var string s;

exec function Fire(optional float F)
{
	super.Fire(F);
	TestFunc();
}

function TestFunc()
{
    local float x, y;
    local int i;

    x = FRand(); //присвоение рационального случайного значения от 0 до 1

    if (x >= 0.5)
      y = x;
    else
      y = -x;

	ClientMessage("y = " $ y);

    i = Rand(5); //присвоение целого случайного значения от 0 до 4

    switch (i)
    {
      case 0: y += y; ClientMessage("y+y = " $ y); break;
      case 1: y -= y; ClientMessage("y-y = " $ y); break;
      case 2: y *= y; ClientMessage("y*y = " $ y); break;
      case 3: y /= y; ClientMessage("y/y = " $ y); break;
      default : ClientMessage("y still y");
    }

}