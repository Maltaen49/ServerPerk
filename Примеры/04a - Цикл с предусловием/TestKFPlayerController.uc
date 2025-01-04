class TestKFPlayerController extends KFPlayerController;

var string s;

exec function Fire(optional float F)
{
	super.Fire(F);
	TestFunc();
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