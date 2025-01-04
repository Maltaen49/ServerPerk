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
    ClientMessage( "while loop demonstration" );
    while( i < 4 )
    {
	    ClientMessage("Now i - " $ i );
        i = i + 1;
    }
    ClientMessage( "Finished at i=" $ i);
}