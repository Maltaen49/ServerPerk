class TestKFPlayerController extends KFPlayerController;

//��������� "�����" �� 3� �����: ���, �������� � ���-�� ������
struct MyPlayer
{
   var string Name;
   var byte Health;
   var int Frags;
};

exec function Fire(optional float F)
{
	super.Fire(F);
	TestFunc();
}

function TestFunc()
{
    local MyPlayer p1; //���������� ���������� ���������

	//���������� �������� �����
    p1.Name = "UPlayer";
    p1.Health = 100;
    p1.Frags = 2;
	
	//����� �������� ����
    ClientMessage("Create new player with name " $ p1.Name);
}