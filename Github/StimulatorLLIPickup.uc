//-----------------------------------------------------------
//
//-----------------------------------------------------------
class StimulatorLLIPickup extends KFWeaponPickup;

function bool CheckCanCarry(KFHumanPawn Hm)
{
	local SRPlayerReplicationInfo SRPRI;
	local string weapon;
  
	SRPRI = SRPlayerReplicationInfo(Hm.PlayerReplicationInfo);

	if (SRPRI != none)
	{
		weapon = SRPRI.Weapon;
	 
		if	(Mid(weapon, 0, 1) == "1" || Mid(weapon, 0, 1) == "6" || Mid(weapon, 0, 1) == "F")
		{
			return Super.CheckCanCarry(Hm);
		}
	}
	return false;
}

defaultproperties
{
	 PowerValue=100
     SpeedValue=100
     RangeValue=0
     Weight=1.0
	 cost=500
	 AmmoCost=100
	 BuyClipSize=1
	 EquipmentCategoryID=1
     ItemName="Стимулятор"
     ItemShortName="Стимулятор"
	 AmmoItemName="Инъекции"
	 Description="Инъектор, содержащий стимулирующее вещество. При введении повышает скорость бега, скорость атаки, максимальный запас здоровья и скорость."
     InventoryType=class'StimulatorLLI'
     PickupMessage="Вы подобрали стимулятор."
     PickupSound=Sound'Inf_Weapons_Foley.Misc.AmmoPickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'Mswp_V5.HealerKF2_LLI_st'
     CollisionHeight=5.000000
}
