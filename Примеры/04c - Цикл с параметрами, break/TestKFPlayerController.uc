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
    ClientMessage( "for loop with break demonstration" );
    for( i=0; i<4; i++ )
    {
        ClientMessage("Now i - " $ i );
        if(i==2)
        {
            ClientMessage( "Break at i=" $ i);
            break; //����� ����� ����� �� �����
        }
    }
    ClientMessage( "Finished at i=" $ i);
}