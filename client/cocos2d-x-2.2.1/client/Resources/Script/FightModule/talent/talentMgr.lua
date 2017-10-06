--region talentMgr.lua
--Author : shenl
--Date   : 2014/10/27
--此文件由[BabeLua]插件自动生成

require "talentResult"

talentMgr = {}

local ENUM_PASSIVE_PERMENT = 1

--增加硬属性 
function talentMgr.addRoleAttr(OriginAttr,roleTalentTb)
    local newAttr = CommonFunc_table_copy_table(OriginAttr)
    local tltb = roleTalentTb
   
    for key,talent in pairs(tltb) do
        local trigger = talent:getConfig("talent_trigger_Info")
        local result = talent:getConfig("talent_result_tb")[ENUM_PASSIVE_PERMENT]
        if trigger:getConfig("trigger_type") == "passive_permanent" then     --是被动永久的天赋
           newAttr = result:addAttribute(newAttr)        
        end 
    end 
    return newAttr
end 
--role:战斗时特有 修改战斗状态
function talentMgr.addFightstatus(role)
    local tltb = role:getConfig("role_talent") or {}
    for key,talent in pairs(tltb) do
        local trigger = talent:getConfig("talent_trigger_Info")
        local result = talent:getConfig("talent_result_tb")[ENUM_PASSIVE_PERMENT]
        if trigger:getConfig("trigger_type") == "passive_status" then       --是被动永久的状态
           if role ~= nil then 
              result:addReduce(role)
           end      
        end 
    end 
end 

--天赋施放技能
function talentMgr.castSkill(caster, defenser,id, level,tanlentlevel, timer)
    --MagicAttack.fight(caster, target, id, level, timer)
   return talentMgr.MagicAttackFight(caster, defenser,id, level, tanlentlevel,timer)
end 

function talentMgr.MagicAttackFight(caster, target, id, level, tanlentlevel,timer)--施法者,指向性目标,技能id,技能等级


--执行所有结果 damageResult：伤害结果
function talentMgr.excultAllResult(resultTb,trigger,caster,damageResult,defenser,skillLevel,skillBaseInfo)
    local pResult = nil 
    for k,result in pairs(resultTb) do
        local pRet,extraParam = result:executResult(caster,defenser,damageResult,skillLevel,skillBaseInfo)
        --最终触发成功
        if pRet then 
            pResult = trigger:addConfig("trigger_times_index", 1)
            pResult = pResult or true
        end 
    end 

    return pResult
end 
--event: 事件类型
--每回合开始时触发             RoundBegin
--每次翻开格子的时候触发         OpenGrid
--每次普通攻击时触发         CommonAttack
--每次被普通攻击时触发         CommonAttack
--角色濒死                     onDying
--每次释放技能之前              onBeforeCastSkill
--damageResult ：被击打时用到（其他传nil），用于做限制闪避  --defenser 防御者 偷换技能 被用到 Skilllevel 技能等级(篡改ID时才有值)
function talentMgr.excultOnEvent(caster,event,damageResult,defenser,Skilllevel)
    Skilllevel = Skilllevel or 0

    local specialResults = nil 
    --local tltb = ModelPlayer.getPlayerTalent()

    local tltb = caster:getConfig("role_talent") or {}
    --param
    local remainlife = caster:getDataInfo("attr"):remianRate("life")    --当前生命
    local curRoundIndex = FightDateCache.getData("fb_round_count")

    for key,talent in pairs(tltb) do
         local trigger = talent:getConfig("talent_trigger_Info")
         local triggerType = trigger:getConfig("trigger_type")
         local resultTb = talent:getConfig("talent_result_tb")
         local pRet = false
         if event == "onDying" then 
            pRet = trigger:isHappennedOnDie()  
            specialResults = pRet
         elseif event == "RoundBegin" then 
            pRet = trigger:isHappennedOnRoundBegin(remainlife,curRoundIndex,caster)
            specialResults = pRet
         elseif  event == "OpenGrid" then 
            pRet = trigger:isHappennedOnGridOpen()
         elseif  event == "CommonAttack" then 
            pRet = trigger:isHappennedCommonAttack()
         elseif  event == "BeCommonAttack" then 
            pRet = trigger:isHappennedBeCommonAttack()
         elseif  event == "BeCommonAttackBefore" then 
            pRet = trigger:isHappennedBeCommonAttackBefore()
         --elseif  event ==  "onBeforeCastSkill" then --特殊处理了
           -- Log(trigger)
            --pRet = trigger:isHappennedOnBeforeCastSkill()
         end 

         if pRet then 
            talentMgr.excultAllResult(resultTb,trigger,caster,damageResult,defenser,Skilllevel,nil)
         end 
    end
    return specialResults
end 


function talentMgr.BeforeCastSkill(caster,defenser,Skilllevel,skillBaseInfo)
    local tltb = caster:getConfig("role_talent") or {}
    local pRet = false
    local pResult = nil 

    for key,talent in pairs(tltb) do
        local trigger = talent:getConfig("talent_trigger_Info")
        local resultTb = talent:getConfig("talent_result_tb")


        pRet = trigger:isHappennedOnBeforeCastSkill(skillBaseInfo.skills_typelist)

        if pRet then 
            pResult = talentMgr.excultAllResult(resultTb,trigger,caster,nil,defenser,Skilllevel,skillBaseInfo)
        end 
    end 

    return pResult
end 


--endregion