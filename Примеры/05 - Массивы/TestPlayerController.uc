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
    local int A[2]; //����������� ������
    local array<int> B; //������������ ������
    local int i;
    i = 0;

	//����� ��������� ������������ �������
    for( i=0; i<2; i++ )
    {
        A[i] = Rand(101);
        ClientMessage( "A[" $ i $ "]=" $ A[i]);
    }

    B[0] = Rand(101);
    B[1] = Rand(101);

	//����� ��������� ������������� �������
    for( i=0; i<B.Length; i++ )
    {
        ClientMessage( "B[" $ i $ "]=" $ B[i]);
    }

	//�������� ������� �������� ������������� �������
    B.Remove(0,1);
    ClientMessage("Remove B[0]");

    for( i=0; i<B.Length; i++ )
    {
        ClientMessage( "B[" $ i $ "]=" $ B[i]);
    }
}