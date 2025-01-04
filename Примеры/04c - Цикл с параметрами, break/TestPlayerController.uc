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
    ClientMessage( "for loop with break demonstration" );
    for( i=0; i<4; i++ )
    {
        ClientMessage("Now i - " $ i );
        if(i==2)
        {
            ClientMessage( "Break at i=" $ i);
            break; //здесь будет вызод из цикла
        }
    }
    ClientMessage( "Finished at i=" $ i);
}