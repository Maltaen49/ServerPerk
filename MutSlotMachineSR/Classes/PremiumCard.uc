Class PremiumCard extends SlotCard;

static function float ExecuteCard( Pawn Target )
{
	local Inventory M,Z,T,S,C,B,P,J,D,G,I,A;

	if( Vehicle(Target)!=None )
	{
		Target = Vehicle(Target).Driver;
		if( Target==None )
			return 0;
	}
	M = Target.FindInventoryType(Class'PremMedic');
	Z = Target.FindInventoryType(Class'PremMedBot');
	T = Target.FindInventoryType(Class'PremSupport');
	S = Target.FindInventoryType(Class'PremSniper');
	C = Target.FindInventoryType(Class'PremComm');
	B = Target.FindInventoryType(Class'PremBers');
	P = Target.FindInventoryType(Class'PremDemol');
	J = Target.FindInventoryType(Class'PremJugger');
	D = Target.FindInventoryType(Class'PremSaboteur');
	G = Target.FindInventoryType(Class'PremGunf');
	I = Target.FindInventoryType(Class'Prem1Inf');
	A = Target.FindInventoryType(Class'Prem2Inf');
	if( M==None )
	{
		M = Target.Spawn(Class'PremMedic');

		if( M!=None )
		{
			M.GiveTo(Target);
			Weapon(M).ClientWeaponSet(true);
		}
	}
	if( Z==None )
	{
		Z = Target.Spawn(Class'PremMedBot');

		if( Z!=None )
		{
			Z.GiveTo(Target);
			Weapon(Z).ClientWeaponSet(true);
		}
	}
	if( T==None )
	{
		T = Target.Spawn(Class'PremSupport');

		if( T!=None )
		{
			T.GiveTo(Target);
			Weapon(T).ClientWeaponSet(true);
		}
	}
	if( S==None )
	{
		S = Target.Spawn(Class'PremSniper');

		if( S!=None )
		{
			S.GiveTo(Target);
			Weapon(S).ClientWeaponSet(true);
		}
	}
	if( C==None )
	{
		C = Target.Spawn(Class'PremComm');

		if( C!=None )
		{
			C.GiveTo(Target);
			Weapon(C).ClientWeaponSet(true);
		}
	}
	if( B==None )
	{
		B = Target.Spawn(Class'PremBers');

		if( B!=None )
		{
			B.GiveTo(Target);
			Weapon(B).ClientWeaponSet(true);
		}
	}
	if( P==None )
	{
		P = Target.Spawn(Class'PremDemol');

		if( P!=None )
		{
			P.GiveTo(Target);
			Weapon(P).ClientWeaponSet(true);
		}
	}
	if( J==None )
	{
		J = Target.Spawn(Class'PremJugger');

		if( J!=None )
		{
			J.GiveTo(Target);
			Weapon(J).ClientWeaponSet(true);
		}
	}
	if( D==None )
	{
		D = Target.Spawn(Class'PremSaboteur');

		if( D!=None )
		{
			D.GiveTo(Target);
			Weapon(D).ClientWeaponSet(true);
		}
	}
	if( G==None )
	{
		G = Target.Spawn(Class'PremGunf');

		if( G!=None )
		{
			G.GiveTo(Target);
			Weapon(G).ClientWeaponSet(true);
		}
	}
	if( I==None )
	{
		I = Target.Spawn(Class'Prem1Inf');


		if( I!=None )
		{
			I.GiveTo(Target);
			Weapon(I).ClientWeaponSet(true);
		}
	}
	if( A==None )
	{
		A = Target.Spawn(Class'Prem2Inf');

		if( A!=None )
		{
			A.GiveTo(Target);
			Weapon(A).ClientWeaponSet(true);
		}
	}
	if( PlayerController(Target.Controller)!=None )
		PlayerController(Target.Controller).ReceiveLocalizedMessage(Class'PremiumMessage');
	return 0;
}

defaultproperties
{
	CardMaterial=Texture'KillingFloor2HUD.Achievements.Achievement_222'
	Desireability=0.08
}