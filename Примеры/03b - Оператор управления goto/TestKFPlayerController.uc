class TestKFPlayerController extends KFPlayerController;

var string s;

exec function Fire(optional float F)
{
	super.Fire(F);
	TestFunc();
}

function TestFunc()
{
    ClientMessage( "Goto Example" );
	goto m1; //переход к m1
m2:
	ClientMessage( "On m2" );
	goto m3; //переход к m3
m1:
    ClientMessage( "On m1" );
	goto m2; //переход к m2
m3:
	ClientMessage( "On m3" );
}