class TestPlayerController extends PlayerController;

auto state PlayerWaiting
{
	exec function StartFire( optional byte FireModeNum )
	{
		TestFunc();
	}
}

function TestFunc()
{
    local float x, y;
    local int i;

    x = FRand(); //���������� ������������� ���������� �������� �� 0 �� 1

    if (x >= 0.5)
      y = x;
    else
      y = -x;

	ClientMessage("y = " $ y);

    i = Rand(5); //���������� ������ ���������� �������� �� 0 �� 4

    switch (i)
    {
      case 0: y += y; ClientMessage("y+y = " $ y); break;
      case 1: y -= y; ClientMessage("y-y = " $ y); break;
      case 2: y *= y; ClientMessage("y*y = " $ y); break;
      case 3: y /= y; ClientMessage("y/y = " $ y); break;
      default : ClientMessage("y still y");
    }

}