class TestKFPlayerController extends KFPlayerController;

exec function Fire(optional float F)
{
	super.Fire(F);
	TestFunc();
}

function TestFunc()
{
    local float a;
    a = FRand()*10;
    CircleFunc(a); //����� ���������������� �������
}

//������� ����������� ���������� ���������� �� ��������� �������
function CircleFunc(float r)
{
     ClientMessage("R = " $ r);
     ClientMessage("D = " $ 2*r);
     ClientMessage("C = " $ 2*PI*r);
     ClientMessage("S = " $ PI*r*r);
}