class TestPlayerController extends PlayerController;

//���������� ���������� ����������
var string s;

/* ��� ������������� ��� �����������
����� ����������� ��� ������� ���������
� ���������� ���������� ��������� ������� ���������*/

auto state PlayerWaiting
{
	exec function StartFire( optional byte FireModeNum )
	{
		TestFunc();
	}
}

function TestFunc()
{
	//���������� ��������� ���������� 
    local float f;
	//���������� ���������� ��������
    s="f = ";
    f=10;
	//����� �������� ����������
	ClientMessage(s $ f);
}