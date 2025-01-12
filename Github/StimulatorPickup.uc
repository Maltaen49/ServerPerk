//-----------------------------------------------------------
//
//-----------------------------------------------------------
class StimulatorPickup extends KFWeaponPickup;


function bool CheckCanCarry(KFHumanPawn P)
{
	local KFPlayerReplicationInfo KFPRI;

	KFPRI = KFPlayerReplicationInfo(P.PlayerReplicationInfo);

	if (KFPRI != none)
	{
		if ( KFPRI.ClientVeteranSkillLevel > 25 && KFPRI.ClientVeteranSkill.default.PerkIndex == 0 )
		{
			return Super.CheckCanCarry(P);
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
	 Description="Инъектор, содержащий стимулирующее вещество. При введении повышает скорость бега, скорость атаки, максимальный запас здоровья и урон."
     InventoryType=class'Stimulator'
     PickupMessage="Вы подобрали стимулятор."
     PickupSound=Sound'Inf_Weapons_Foley.Misc.AmmoPickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.equipment.Syringe_pickup'
	 Skins(0)=Texture'mswp_04.Lethalinjection.Lethalinjection_3rd'
     CollisionHeight=5.000000
}
