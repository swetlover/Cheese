-- Heating Up：火系法术首次暴击后显示半格弧提示（下一次暴击即触发法术连击瞬发炎爆）
-- 显示：火球 / 火冲 / 灼烧 / 活动炸弹 / 霜火箭 暴击
-- 隐藏：同列表法术未暴击、获得或失去法术连击(48108)、超时兜底、进/出世界、玩家死亡
local OVERLAY_KEY = "CHEESE_HEATING_UP";	-- 虚拟 spellID，避免与真 Hot Streak(48108) 冲突
local TEXTURE = "INTERFACE\\ADDONS\\CHEESE\\TEXTURES\\SPELLACTIVATIONOVERLAYS\\HOT_STREAK.BLP";
local HOT_STREAK_SPELL_ID = 48108;
local TRACKED_SPELL_IDS = { 42833, 42873, 42859, 44457, 47610 };	-- 火球术 火焰冲击 灼烧 活动炸弹 霜火之箭
local TIMEOUT = 12;	-- 兜底：连击本体只有 10 秒，避免提示长期残留

local spellNames = {};
local playerGUID;
local shown = false;
local expireAt;

local function ShowHeatingUp()
	expireAt = GetTime() + TIMEOUT;
	if ( not shown ) then
		shown = true;
		Cheese_FireOverlayShow(OVERLAY_KEY, TEXTURE, "Left + Right (Flipped)", 0.5, 255, 255, 255);
	end
end

local function HideHeatingUp()
	expireAt = nil;
	if ( shown ) then
		shown = false;
		Cheese_FireOverlayHide(OVERLAY_KEY);
	end
end

local frame = CreateFrame("Frame");
frame:RegisterEvent("PLAYER_LOGIN");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_DEAD");
frame:SetScript("OnEvent", function(self, event, ...)
	if ( event == "PLAYER_LOGIN" ) then
		local _, class = UnitClass("player");
		if ( class ~= "MAGE" ) then return; end	-- 非法师不注册 CLEU，避免性能开销
		for i = 1, #TRACKED_SPELL_IDS do
			local name = GetSpellInfo(TRACKED_SPELL_IDS[i]);
			if ( name ) then spellNames[name] = true; end
		end
		playerGUID = UnitGUID("player");
		self:UnregisterEvent("PLAYER_LOGIN");
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
		return;
	end
	if ( event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_DEAD" ) then
		HideHeatingUp();
		return;
	end
	-- COMBAT_LOG_EVENT_UNFILTERED（3.3.5 参数布局，无 raidFlags）
	-- 位置：3=来源GUID，6=目标GUID，9=spellId，10=spellName，18=critical
	local _, subevent, sourceGUID, _, _, destGUID, _, _, spellId, spellName, _, _, _, _, _, _, _, critical = ...;
	if ( subevent == "SPELL_DAMAGE" ) then
		if ( sourceGUID == playerGUID and spellNames[spellName] ) then
			if ( critical ) then ShowHeatingUp(); else HideHeatingUp(); end
		end
	elseif ( subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" or subevent == "SPELL_AURA_REMOVED" ) then
		-- 只看目标是否为玩家：部分服务端脚本施加光环时来源GUID为 0，不能依赖 sourceGUID
		if ( destGUID == playerGUID and spellId == HOT_STREAK_SPELL_ID ) then HideHeatingUp(); end
	end
end);
frame:SetScript("OnUpdate", function(self, elapsed)
	if ( expireAt and GetTime() >= expireAt ) then HideHeatingUp(); end
end);
