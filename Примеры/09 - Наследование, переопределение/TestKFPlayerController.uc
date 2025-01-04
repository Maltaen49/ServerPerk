class TestKFPlayerController extends KFPlayerController;

exec function Fire(optional float F)
{
	super.Fire(F);
	TestFunc();
}

function TestFunc()
{
    local AlarmClock c1;
    c1 = new class'AlarmClock';
    ClientMessage(c1.Ring());
}