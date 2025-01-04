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