-- Author      : generalwrex (Natop on Myzrael)
-- Create Date : 2/6/2022 10:35:32 AM

if not WowSimsExporter then WowSimsExporter = {} end

WowSimsExporter.slotNames = {
    "HeadSlot",
    "NeckSlot",
    "ShoulderSlot",
    "BackSlot",
    "ChestSlot",
    "WristSlot",
    "HandsSlot",
    "WaistSlot",
    "LegsSlot",
    "FeetSlot",
    "Finger0Slot",
    "Finger1Slot",
    "Trinket0Slot",
    "Trinket1Slot",
    "MainHandSlot",
    "SecondaryHandSlot",
	"RangedSlot",
    "AmmoSlot",
}


WowSimsExporter.specializations = {

	-- shaman
	{comparator = function(A,B,C) return A > B and A > C end, spec="elemental", class="shaman"},
	{comparator = function(A,B,C) return B > A and B > C end, spec="enhancement", class="shaman"},
	-- hunter
	{comparator = function(A,B,C) return A > B and A > C end, spec="beastmastery", class="hunter"},
	{comparator = function(A,B,C) return B > A and B > C end, spec="marksman", class="hunter"},
	{comparator = function(A,B,C) return C > A and C > B end, spec="survival", class="hunter"},
	{comparator = function(A,B,C) return true            end, spec="hunter", class="hunter", custom = "single"},
	-- druid
	{comparator = function(A,B,C) return A > B and A > C end, spec="balance", class="hunter"},
	{comparator = function(A,B,C) return B > A and B > C end, spec="feral", class="hunter"},
	-- warlock
	{comparator = function(A,B,C) return A > B and A > C end, spec="affliction", class="warlock"},
	{comparator = function(A,B,C) return B > A and B > C end, spec="demonology", class="warlock"},
	{comparator = function(A,B,C) return C > A and C > B end, spec="destruction", class="warlock"},
	-- rogue
	{comparator = function(A,B,C) return A > B and A > C end, spec="assassination", class="rogue"},
	{comparator = function(A,B,C) return B > A and B > C end, spec="combat", class="rogue"},
	{comparator = function(A,B,C) return C > A and C > B end, spec="subtlety", class="rogue"},
	-- mage
	{comparator = function(A,B,C) return A > B and A > C end, spec="arcane", class="mage"},
	{comparator = function(A,B,C) return B > A and B > C end, spec="fire", class="mage"},
	{comparator = function(A,B,C) return C > A and C > B end, spec="frost", class="mage"},
	-- warrior
	{comparator = function(A,B,C) return A > B and A > C end, spec="arms", class="warrior"},
	{comparator = function(A,B,C) return B > A and B > C end, spec="fury", class="warrior"},
	-- paladin
	{comparator = function(A,B,C) return true            end, spec="retribution", class="paladin", custom = "single"},
	-- priest
	{comparator = function(A,B,C) return true            end, spec="shadow", class="priest", custom = "single"},
}