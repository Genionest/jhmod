
function SaveIndex:EraseCurrent(cb)
    scheduler:ExecuteInTime(2, function() 
        TheFrontEnd:Fade(false, 1)
        scheduler:ExecuteInTime(1, function()
            StartNextInstance({
                reset_action=GLOBAL.RESET_ACTION.LOAD_SLOT, 
                save_slot = GLOBAL.SaveGameIndex:GetCurrentSaveSlot()
            }, true)
        end)
    end)
end
