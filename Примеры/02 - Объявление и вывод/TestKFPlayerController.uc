class TestKFPlayerController extends KFPlayerController;

//���������� ���������� ���������� 
var string s;

/* ��� ������������� ��� �����������
����� ����������� ��� ������� ���������
� ���������� ���������� ��������� ������� ���������*/

exec function Fire(optional float F)
{
	super.Fire(F);
	TestFunc();
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