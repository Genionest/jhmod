local TpTechMachine = Class(function(self,inst)
	self.inst = inst
	self.tech = "pigking"
	inst:AddTag("tp_tech_machine")
end)

return TpTechMachine