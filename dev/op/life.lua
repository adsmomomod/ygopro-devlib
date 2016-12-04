-- 
-- ================================================================================
--
--  !! オブジェクト
--
-- ================================================================================
--
--[[
	GetCount
	GetFirst, GetNext
]]

-- ========================================================
-- ライフポイント : 数字の1 / lp_object
--

-- 
dev.lp_object = dev.new_class(
{
	__init = function( self, val, p )
		self.player = p
		self.value = val
		if self.player>1 then dev.print("lp_object 引数の順番=(数値、プレイヤー)") end
	end,
	GetCount = function( self )
		return self.value
	end,
	GetMax = function( self )
		return Duel.GetLP( self.player )
	end,
	Set = function( self, v )
		self.value = v
	end,	
})

--
-- 固定のライフ値
-- 
dev.lifepoint = dev.new_class(
{
	__init = function( self, args )
		self.player = dev.option_arg( args.player, dev.you )
		self.value = dev.option_arg( args.value, 100 )
		self.proportion = args.div
	end,
	
	GetAll = function( self, est )
		local p=self.player:GetPlayer( est )
		return dev.lp_object( Duel.GetLP(p), p )
	end,
	
	GetMinMax = function( self, est )
		return 0, self:Eval( est )
	end,
	
	Exists = function( self, est, outvalue )
		if self.proportion then 
			return true 
		end
		local p=self.player:GetPlayer(est)
		local v=dev.option_arg( dev.eval( self.value, est ), outvalue )
		return dev.IsOperable( dev.lp_object(v, p), est )
	end,
	
	Select = function( self, est )
		local v=dev.eval( self.value, est )
		if self.proportion then
			v=math.floor( self:Eval(est) / self.proportion )
		end
		local p=self.player:GetPlayer(est)
		return dev.lp_object( v, p )
	end,
	
	SelectImpl = function( self, est, istarget, tp, selmin, selmax, gsel )
		local t={}
		local v=selmin
		local vmax=math.min( selmax, self:Eval(est) )
		while true do
			if vmax < v then
				break
			end
			table.insert(t, v)
			v=v+dev.eval( self.value, est )
		end
		local sel=Duel.AnnounceNumber( tp, table.unpack(t) )
	
		local p=self.player:GetPlayer(est)
		return dev.lp_object( sel, p )
	end,

	--
	Eval = function( self, est )
		local p=self.player:GetPlayer( est )
		return Duel.GetLP(p)
	end,
})

-- eval
function dev.your_lifepoint( args )
	args = dev.option_arg( args, {} )
	args.player = dev.you
	return dev.lifepoint( args )
end
function dev.opponent_lifepoint( args )
	args = dev.option_arg( args, {} )
	args.player = dev.opponent
	return dev.lifepoint( args )
end

-- 
-- ================================================================================
--
--  !! 動作
--
-- ================================================================================
--

dev.do_pay_life = dev.new_class(dev.action,
{	
	__init = function(self)
		dev.super_init( self, 0, nil )
	end,
	CheckOperable = function( self, est, lpobj )
		return Duel.CheckLPCost( lpobj.player, lpobj.value )
	end,
	Execute = function( self, est, lpobj )
		Duel.PayLPCost( lpobj.player, lpobj.value )
		return lpobj.value
	end,
})

dev.do_damage_life = dev.new_class(dev.action,
{	
	__init = function(self)
		dev.super_init( self, CATEGORY_DAMAGE, nil )
	end,
	Execute = function( self, est, lpobj )
		Duel.Damage( lpobj.player, lpobj.value, est:GetTimingReason() )
		return lpobj.value
	end,
})

dev.do_restore_life = dev.new_class(dev.action,
{	
	__init = function(self)
		dev.super_init( self, CATEGORY_DAMAGE, nil )
	end,
	Execute = function( self, est, lpobj )
		Duel.Recover( lpobj.player, lpobj.value, est:GetTimingReason() )
		return lpobj.value
	end,
})

dev.do_set_life = dev.new_class(dev.action,
{	
	__init = function(self)
		dev.super_init( self, CATEGORY_DAMAGE, nil )
	end,
	Execute = function( self, est, lpobj )
		Duel.SetLP( lpobj.player, lpobj.value, est:GetTimingReason() )
		return lpobj.value
	end,
})


--[[
dev.player_target_op = (
	dev.do_damage_life(),
	dev.target_lifepoint( dev.lifepoint({
		player = dev.opponent,
		value = 200
	}))
)
]]--