class TestKFPlayerController extends KFPlayerController;

exec function Fire(optional float F)
{
	super.Fire(F);
	TestFunc();
}

function TestFunc()
{
    //����� ����� ������ ��� �������� 
	ClientMessage("Test");
}