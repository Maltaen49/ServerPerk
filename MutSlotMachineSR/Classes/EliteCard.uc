Class EliteCard extends SlotCard;

static function float ExecuteCard( Pawn Target )
{
	local Inventory M,Z,T,S,C,B,P,J,D,G,I,A;

	if( Vehicle(Target)!=None )
	{
		Target = Vehicle(Target).Driver;
		if( Target==None )
			return 0;
	}
	M = Target.FindInventoryType(Class'Elite1Medic');
	Z = Target.FindInventoryType(Class'Elite2Medic');
	T = Target.FindInventoryType(Class'EliteSupport');
	S = Target.FindInventoryType(Class'EliteSniper');
	C = Target.FindInventoryType(Class'EliteComm');
	B = Target.FindInventoryType(Class'EliteBers');
	P = Target.FindInventoryType(Class'EliteDemol');
	J = Target.FindInventoryType(Class'EliteJugger');
	D = Target.FindInventoryType(Class'EliteSaboteur');
	G = Target.FindInventoryType(Class'EliteGunf');
	I = Target.FindInventoryType(Class'Elite1Inf');
	A = Target.FindInventoryType(Class'Elite2Inf');
	if( M==None )
	{
		M = Target.Spawn(Class'Elite1Medic');

		if( M!=None )
		{
			M.GiveTo(Target);
			Weapon(M).ClientWeaponSet(true);
		}
	}
	if( Z==None )
	{
		Z = Target.Spawn(Class'Elite2Medic');

		if( Z!=None )
		{
			Z.GiveTo(Target);
			Weapon(Z).ClientWeaponSet(true);
		}
	}
	if( T==None )
	{
		T = Target.Spawn(Class'EliteSupport');

		if( T!=None )
		{
			T.GiveTo(Target);
			Weapon(T).ClientWeaponSet(true);
		}
	}
	if( S==None )
	{
		S = Target.Spawn(Class'EliteSniper');

		if( S!=None )
		{
			S.GiveTo(Target);
			Weapon(S).ClientWeaponSet(true);
		}
	}
	if( C==None )
	{
		C = Target.Spawn(Class'EliteComm');

		if( C!=None )
		{
			C.GiveTo(Target);
			Weapon(C).ClientWeaponSet(true);
		}
	}
	if( B==None )
	{
		B = Target.Spawn(Class'EliteBers');

		if( B!=None )
		{
			B.GiveTo(Target);
			Weapon(B).ClientWeaponSet(true);
		}
	}
	if( P==None )
	{
		P = Target.Spawn(Class'EliteDemol');

		if( P!=None )
		{
			P.GiveTo(Target);
			Weapon(P).ClientWeaponSet(true);
		}
	}
	if( J==None )
	{
		J = Target.Spawn(Class'EliteJugger');

		if( J!=None )
		{
			J.GiveTo(Target);
			Weapon(J).ClientWeaponSet(true);
		}
	}
	if( D==None )
	{
		D = Target.Spawn(Class'EliteSaboteur');

		if( D!=None )
		{
			D.GiveTo(Target);
			Weapon(D).ClientWeaponSet(true);
		}
	}
	if( G==None )
	{
		G = Target.Spawn(Class'EliteGunf');

		if( G!=None )
		{
			G.GiveTo(Target);
			Weapon(G).ClientWeaponSet(true);
		}
	}
	if( I==None )
	{
		I = Target.Spawn(Class'Elite1Inf');


		if( I!=None )
		{
			I.GiveTo(Target);
			Weapon(I).ClientWeaponSet(true);
		}
	}
	if( A==None )
	{
		A = Target.Spawn(Class'Elite2Inf');

		if( A!=None )
		{
			A.GiveTo(Target);
			Weapon(A).ClientWeaponSet(true);
		}
	}
	if( PlayerController(Target.Controller)!=None )
		PlayerController(Target.Controller).ReceiveLocalizedMessage(Class'EliteMessage');
	return 0;
}

defaultproperties
{
	CardMaterial=Texture'KillingFloor2HUD.Achievements.Achievement_225'
	Desireability=0.08
}