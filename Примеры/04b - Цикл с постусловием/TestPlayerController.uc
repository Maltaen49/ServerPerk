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
    local int i;
    i = 0;
    ClientMessage( "do until loop demonstration" );
    do
    {
	    ClientMessage("Now i - " $ i );
        i = i + 1;
    }
    until( i > 4 );
    ClientMessage( "Finished at i=" $ i);
}