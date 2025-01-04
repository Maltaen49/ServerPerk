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
    local AlarmClock c1;
    c1 = new class'AlarmClock';
    ClientMessage(c1.Ring());
}