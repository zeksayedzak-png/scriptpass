-- ============================================
-- 🔥 GAMEPASS CODE FORCE EXTRACTOR - يجيب كل شيء داخل كل GamePass
-- للهاتف: loadstring(game:HttpGet(""))()
-- ============================================

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

print("🔥 GAMEPASS CODE EXTRACTOR LOADING...")

-- قاعدة بيانات كاملة لكل الأكواد
local CODE_DATABASE = {
    GAMEPASSES = {},           -- كل GamePasses مع أكوادها
    ALL_SCRIPTS = {},          -- كل النصوص البرمجية
    ALL_MODULES = {},          -- كل ModuleScripts
    ALL_REMOTES = {},          -- كل RemoteEvents/Functions
    ALL_LOCALS = {},           -- كل LocalScripts
    TOTAL_CODES = 0            -- إجمالي الأكواد
}

-- 🔥 استخراج قسري لكل الأكواد من GamePass
function FORCE_EXTRACT_ALL_CODES()
    print("🔥 FORCE EXTRACTING ALL CODES FROM ALL GAMEPASSES...")
    
    -- إعادة تهيئة
    CODE_DATABASE = {
        GAMEPASSES = {},
        ALL_SCRIPTS = {},
        ALL_MODULES = {},
        ALL_REMOTES = {},
        ALL_LOCALS = {},
        TOTAL_CODES = 0
    }
    
    local extractStart = tick()
    local totalGamePassesFound = 0
    
    -- 1. 🔥 البحث عن كل GamePasses في اللعبة
    local allGamePassObjects = {}
    
    -- البحث في ReplicatedStorage
    if game:FindFirstChild("ReplicatedStorage") then
        print("🔥 Searching ReplicatedStorage...")
        for _, obj in pairs(game.ReplicatedStorage:GetDescendants()) do
            local nameLower = obj.Name:lower()
            if nameLower:find("gamepass") or nameLower:find("pass") or 
               nameLower:find("unlock") or nameLower:find("vip") or
               nameLower:find("premium") or nameLower:find("buy") then
                table.insert(allGamePassObjects, obj)
            end
        end
    end
    
    -- البحث في Workspace
    print("🔥 Searching Workspace...")
    for _, obj in pairs(workspace:GetDescendants()) do
        local nameLower = obj.Name:lower()
        if nameLower:find("gamepass") or nameLower:find("pass") or 
           nameLower:find("shop") or nameLower:find("store") then
            table.insert(allGamePassObjects, obj)
        end
    end
    
    -- البحث في PlayerGui
    if localPlayer:FindFirstChild("PlayerGui") then
        print("🔥 Searching PlayerGui...")
        for _, gui in pairs(localPlayer.PlayerGui:GetDescendants()) do
            if gui:IsA("TextButton") then
                local text = gui.Text:lower()
                if text:find("gamepass") or text:find("buy") or text:find("purchase") then
                    table.insert(allGamePassObjects, gui)
                end
            end
        end
    end
    
    -- 2. 🔥 استخراج الأكواد من كل GamePass
    for _, gamepassObj in pairs(allGamePassObjects) do
        local gamepassData = {
            Name = gamepassObj.Name,
            Type = gamepassObj.ClassName,
            Object = gamepassObj,
            GamePassId = EXTRACT_GAMEPASS_ID(gamepassObj),
            Scripts = {},
            Modules = {},
            Remotes = {},
            LocalScripts = {},
            AllCodes = "",
            TotalCodes = 0
        }
        
        -- استخراج كل الأكواد داخل الـ GamePass
        EXTRACT_CODES_FROM_OBJECT(gamepassObj, gamepassData)
        
        -- إذا وجدنا أكواد، نضيفه للقاعدة
        if gamepassData.TotalCodes > 0 then
            table.insert(CODE_DATABASE.GAMEPASSES, gamepassData)
            totalGamePassesFound = totalGamePassesFound + 1
            CODE_DATABASE.TOTAL_CODES = CODE_DATABASE.TOTAL_CODES + gamepassData.TotalCodes
            
            print(string.format("✅ Extracted %d codes from: %s", 
                  gamepassData.TotalCodes, gamepassObj.Name))
        end
    end
    
    -- 3. 🔥 البحث عن ModuleScripts خاصة بالـ GamePass
    print("🔥 Searching for GamePass ModuleScripts...")
    if game:FindFirstChild("ReplicatedStorage") then
        for _, module in pairs(game.ReplicatedStorage:GetDescendants()) do
            if module:IsA("ModuleScript") then
                local nameLower = module.Name:lower()
                if nameLower:find("gamepass") or nameLower:find("pass") or 
                   nameLower:find("shop") or nameLower:find("store") then
                    
                    local source = ""
                    pcall(function()
                        source = require(module)
                        if type(source) == "table" then
                            source = HttpService:JSONEncode(source)
                        end
                    end)
                    
                    if source and source ~= "" then
                        local moduleData = {
                            Name = module.Name,
                            Type = "ModuleScript",
                            Source = tostring(source),
                            Path = module:GetFullName()
                        }
                        
                        table.insert(CODE_DATABASE.ALL_MODULES, moduleData)
                        CODE_DATABASE.TOTAL_CODES = CODE_DATABASE.TOTAL_CODES + 1
                        print("✅ Found GamePass Module: " .. module.Name)
                    end
                end
            end
        end
    end
    
    -- 4. 🔥 البحث عن RemoteEvents خاصة بالـ GamePass
    print("🔥 Searching for GamePass RemoteEvents...")
    for _, remote in pairs(game:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local nameLower = remote.Name:lower()
            if nameLower:find("gamepass") or nameLower:find("buy") or 
               nameLower:find("purchase") or nameLower:find("unlock") then
                
                local remoteData = {
                    Name = remote.Name,
                    Type = remote.ClassName,
                    Path = remote:GetFullName()
                }
                
                table.insert(CODE_DATABASE.ALL_REMOTES, remoteData)
                print("✅ Found GamePass Remote: " .. remote.Name)
            end
        end
    end
    
    local extractTime = tick() - extractStart
    print(string.format("\n🔥 EXTRACTION COMPLETE in %.2f seconds!", extractTime))
    print("🔥 Found: " .. totalGamePassesFound .. " GamePasses with codes")
    print("🔥 Total codes extracted: " .. CODE_DATABASE.TOTAL_CODES)
    
    return CODE_DATABASE
end

-- 🔥 استخراج GamePass ID
function EXTRACT_GAMEPASS_ID(obj)
    local gamepassId = nil
    
    -- البحث في الخصائص
    pcall(function()
        if obj:FindFirstChild("GamePassId") then
            gamepassId = obj.GamePassId.Value
        elseif obj:FindFirstChild("ID") then
            gamepassId = obj.ID.Value
        elseif obj:FindFirstChild("PassId") then
            gamepassId = obj.PassId.Value
        end
    end)
    
    -- البحث في النص
    if not gamepassId and (obj:IsA("TextLabel") or obj:IsA("TextButton")) then
        local text = obj.Text
        if text then
            local idMatch = string.match(text, "%d+")
            if idMatch and #idMatch >= 6 then
                gamepassId = tonumber(idMatch)
            end
        end
    end
    
    return gamepassId
end

-- 🔥 استخراج كل الأكواد من كائن
function EXTRACT_CODES_FROM_OBJECT(obj, gamepassData)
    local codesFound = 0
    
    -- مسح كل Descendants
    for _, child in pairs(obj:GetDescendants()) do
        -- Script
        if child:IsA("Script") then
            local source = ""
            pcall(function()
                source = child.Source
            end)
            
            if source and source ~= "" then
                local scriptData = {
                    Name = child.Name,
                    Type = "Script",
                    Source = source,
                    Path = child:GetFullName()
                }
                
                table.insert(gamepassData.Scripts, scriptData)
                table.insert(CODE_DATABASE.ALL_SCRIPTS, scriptData)
                codesFound = codesFound + 1
                
                -- إضافة إلى النص الكلي
                gamepassData.AllCodes = gamepassData.AllCodes .. 
                    "=== SCRIPT: " .. child.Name .. " ===\n" .. 
                    source .. "\n\n"
            end
        
        -- LocalScript
        elseif child:IsA("LocalScript") then
            local source = ""
            pcall(function()
                source = child.Source
            end)
            
            if source and source ~= "" then
                local localData = {
                    Name = child.Name,
                    Type = "LocalScript",
                    Source = source,
                    Path = child:GetFullName()
                }
                
                table.insert(gamepassData.LocalScripts, localData)
                table.insert(CODE_DATABASE.ALL_LOCALS, localData)
                codesFound = codesFound + 1
                
                gamepassData.AllCodes = gamepassData.AllCodes .. 
                    "=== LOCAL SCRIPT: " .. child.Name .. " ===\n" .. 
                    source .. "\n\n"
            end
        
        -- ModuleScript
        elseif child:IsA("ModuleScript") then
            local source = ""
            pcall(function()
                source = require(child)
                if type(source) == "table" then
                    source = HttpService:JSONEncode(source)
                end
            end)
            
            if source and source ~= "" then
                local moduleData = {
                    Name = child.Name,
                    Type = "ModuleScript",
                    Source = tostring(source),
                    Path = child:GetFullName()
                }
                
                table.insert(gamepassData.Modules, moduleData)
                table.insert(CODE_DATABASE.ALL_MODULES, moduleData)
                codesFound = codesFound + 1
                
                gamepassData.AllCodes = gamepassData.AllCodes .. 
                    "=== MODULE: " .. child.Name .. " ===\n" .. 
                    source .. "\n\n"
            end
        
        -- RemoteEvent/RemoteFunction
        elseif child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            local remoteData = {
                Name = child.Name,
                Type = child.ClassName,
                Path = child:GetFullName()
            }
            
            table.insert(gamepassData.Remotes, remoteData)
            table.insert(CODE_DATABASE.ALL_REMOTES, remoteData)
            codesFound = codesFound + 1
            
            gamepassData.AllCodes = gamepassData.AllCodes .. 
                "=== REMOTE: " .. child.Name .. " (" .. child.ClassName .. ") ===\n" ..
                "Path: " .. child:GetFullName() .. "\n\n"
        end
    end
    
    gamepassData.TotalCodes = codesFound
    return codesFound
end

-- 🎨 واجهة استخراج الأكواد
function CREATE_CODE_EXTRACTOR_UI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CodeExtractorUI"
    gui.ResetOnSpawn = false
    gui.Parent = localPlayer:WaitForChild("PlayerGui")
    
    -- الإطار الرئيسي
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.95, 0, 0.9, 0)
    mainFrame.Position = UDim2.new(0.025, 0, 0.05, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    
    -- العنوان
    local title = Instance.new("TextLabel")
    title.Text = "🔥 GAMEPASS CODE EXTRACTOR"
    title.Size = UDim2.new(1, 0, 0.07, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextScaled = true
    title.Parent = mainFrame
    
    -- زر الاستخراج القسري
    local extractBtn = Instance.new("TextButton")
    extractBtn.Name = "ExtractBtn"
    extractBtn.Text = "🔥 EXTRACT ALL CODES NOW!"
    extractBtn.Size = UDim2.new(0.95, 0, 0.1, 0)
    extractBtn.Position = UDim2.new(0.025, 0, 0.08, 0)
    extractBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    extractBtn.TextColor3 = Color3.new(1, 1, 1)
    extractBtn.Font = Enum.Font.GothamBlack
    extractBtn.TextSize = 18
    extractBtn.TextScaled = true
    extractBtn.Parent = mainFrame
    
    -- الإحصائيات
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.Text = "Press EXTRACT to force extract all codes!"
    statsLabel.Size = UDim2.new(0.95, 0, 0.05, 0)
    statsLabel.Position = UDim2.new(0.025, 0, 0.19, 0)
    statsLabel.BackgroundTransparency = 1
    statsLabel.TextColor3 = Color3.new(0, 1, 1)
    statsLabel.Font = Enum.Font.GothamBold
    statsLabel.TextSize = 12
    statsLabel.TextXAlignment = Enum.TextXAlignment.Center
    statsLabel.Parent = mainFrame
    
    -- منطقة النتائج
    local resultsFrame = Instance.new("ScrollingFrame")
    resultsFrame.Name = "ResultsFrame"
    resultsFrame.Size = UDim2.new(0.95, 0, 0.7, 0)
    resultsFrame.Position = UDim2.new(0.025, 0, 0.25, 0)
    resultsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    resultsFrame.BackgroundTransparency = 0.1
    resultsFrame.BorderSizePixel = 0
    resultsFrame.ScrollBarThickness = 8
    resultsFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
    resultsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    resultsFrame.Parent = mainFrame
    
    -- زر الإغلاق
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0.08, 0, 0.07, 0)
    closeBtn.Position = UDim2.new(0.92, 0, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBlack
    closeBtn.TextSize = 16
    closeBtn.Parent = mainFrame
    
    -- عرض النتائج
    function DISPLAY_EXTRACTED_CODES()
        resultsFrame:ClearAllChildren()
        
        if #CODE_DATABASE.GAMEPASSES == 0 then
            local noData = Instance.new("TextLabel")
            noData.Text = "No GamePass codes extracted yet.\nPress EXTRACT ALL CODES NOW!"
            noData.Size = UDim2.new(0.9, 0, 0.2, 0)
            noData.Position = UDim2.new(0.05, 0, 0.4, 0)
            noData.BackgroundTransparency = 1
            noData.TextColor3 = Color3.new(1, 1, 0)
            noData.Font = Enum.Font.GothamBold
            noData.TextSize = 14
            noData.TextWrapped = true
            noData.TextXAlignment = Enum.TextXAlignment.Center
            noData.Parent = resultsFrame
            return
        end
        
        local yOffset = 5
        
        for i, gamepass in ipairs(CODE_DATABASE.GAMEPASSES) do
            -- إطار لكل GamePass
            local gpFrame = Instance.new("Frame")
            gpFrame.Name = "GP_" .. i
            gpFrame.Size = UDim2.new(0.94, 0, 0, 80)
            gpFrame.Position = UDim2.new(0.03, 0, 0, yOffset)
            gpFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            gpFrame.BackgroundTransparency = 0.2
            gpFrame.BorderSizePixel = 0
            gpFrame.Parent = resultsFrame
            
            -- اسم GamePass
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Text = "🎫 " .. gamepass.Name
            nameLabel.Size = UDim2.new(0.65, 0, 0.25, 0)
            nameLabel.Position = UDim2.new(0.02, 0, 0.05, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 12
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.Parent = gpFrame
            
            -- GamePass ID
            local idLabel = Instance.new("TextLabel")
            idLabel.Text = "ID: " .. (gamepass.GamePassId or "???")
            idLabel.Size = UDim2.new(0.65, 0, 0.2, 0)
            idLabel.Position = UDim2.new(0.02, 0, 0.3, 0)
            idLabel.BackgroundTransparency = 1
            idLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            idLabel.Font = Enum.Font.GothamBold
            idLabel.TextSize = 11
            idLabel.TextXAlignment = Enum.TextXAlignment.Left
            idLabel.Parent = gpFrame
            
            -- إحصائيات الأكواد
            local codesLabel = Instance.new("TextLabel")
            codesLabel.Text = string.format("📜 Codes: %d total", gamepass.TotalCodes)
            codesLabel.Size = UDim2.new(0.65, 0, 0.2, 0)
            codesLabel.Position = UDim2.new(0.02, 0, 0.5, 0)
            codesLabel.BackgroundTransparency = 1
            codesLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            codesLabel.Font = Enum.Font.GothamBold
            codesLabel.TextSize = 11
            codesLabel.TextXAlignment = Enum.TextXAlignment.Left
            codesLabel.Parent = gpFrame
            
            -- تفاصيل الأكواد
            local detailsLabel = Instance.new("TextLabel")
            local detailsText = string.format("📝 Scripts: %d | 🧩 Modules: %d | 📡 Remotes: %d | 💻 Locals: %d",
                #gamepass.Scripts, #gamepass.Modules, #gamepass.Remotes, #gamepass.LocalScripts)
            detailsLabel.Text = detailsText
            detailsLabel.Size = UDim2.new(0.65, 0, 0.2, 0)
            detailsLabel.Position = UDim2.new(0.02, 0, 0.7, 0)
            detailsLabel.BackgroundTransparency = 1
            detailsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            detailsLabel.Font = Enum.Font.Gotham
            detailsLabel.TextSize = 9
            detailsLabel.TextXAlignment = Enum.TextXAlignment.Left
            detailsLabel.TextTruncate = Enum.TextTruncate.AtEnd
            detailsLabel.Parent = gpFrame
            
            -- زر نسخ كل الأكواد
            local copyAllBtn = Instance.new("TextButton")
            copyAllBtn.Name = "CopyAll_" .. i
            copyAllBtn.Text = "📋 ALL CODES"
            copyAllBtn.Size = UDim2.new(0.3, 0, 0.5, 0)
            copyAllBtn.Position = UDim2.new(0.68, 0, 0.25, 0)
            copyAllBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
            copyAllBtn.TextColor3 = Color3.new(1, 1, 1)
            copyAllBtn.Font = Enum.Font.GothamBold
            copyAllBtn.TextSize = 10
            copyAllBtn.TextScaled = true
            copyAllBtn.Parent = gpFrame
            
            -- زر نسخ GamePass ID فقط
            local copyIdBtn = Instance.new("TextButton")
            copyIdBtn.Text = "🎫 ID ONLY"
            copyIdBtn.Size = UDim2.new(0.12, 0, 0.5, 0)
            copyIdBtn.Position = UDim2.new(0.85, 0, 0.25, 0)
            copyIdBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
            copyIdBtn.TextColor3 = Color3.new(1, 1, 1)
            copyIdBtn.Font = Enum.Font.GothamBold
            copyIdBtn.TextSize = 9
            copyIdBtn.TextScaled = true
            copyIdBtn.Parent = gpFrame
            
            -- أحداث النسخ
            copyAllBtn.MouseButton1Click:Connect(function()
                local allCodesText = "🔥 GAMEPASS ALL CODES EXTRACTION\n"
                allCodesText = allCodesText .. string.rep("=", 50) .. "\n\n"
                allCodesText = allCodesText .. "🎫 GamePass: " .. gamepass.Name .. "\n"
                allCodesText = allCodesText .. "📁 Type: " .. gamepass.Type .. "\n"
                
                if gamepass.GamePassId then
                    allCodesText = allCodesText .. "🔢 GamePass ID: " .. gamepass.GamePassId .. "\n"
                end
                
                allCodesText = allCodesText .. string.format("📊 Total Codes: %d\n", gamepass.TotalCodes)
                allCodesText = allCodesText .. string.rep("-", 50) .. "\n\n"
                
                -- إضافة كل الأكواد
                if gamepass.AllCodes and gamepass.AllCodes ~= "" then
                    allCodesText = allCodesText .. gamepass.AllCodes
                else
                    allCodesText = allCodesText .. "No source codes found in this GamePass.\n"
                end
                
                allCodesText = allCodesText .. string.rep("=", 50) .. "\n"
                allCodesText = allCodesText .. "✅ Extraction complete - All codes from: " .. gamepass.Name
                
                -- عرض للنسخ
                SHOW_COPY_WINDOW("ALL CODES: " .. gamepass.Name, allCodesText)
            end)
            
            copyIdBtn.MouseButton1Click:Connect(function()
                local idText = "🎫 GAMEPASS ID INFORMATION\n"
                idText = idText .. string.rep("=", 40) .. "\n\n"
                idText = idText .. "Name: " .. gamepass.Name .. "\n"
                idText = idText .. "Type: " .. gamepass.Type .. "\n"
                
                if gamepass.GamePassId then
                    idText = idText .. "🔢 GamePass ID: " .. gamepass.GamePassId .. "\n\n"
                    idText = idText .. "📊 Code Statistics:\n"
                    idText = idText .. "• Scripts: " .. #gamepass.Scripts .. "\n"
                    idText = idText .. "• Modules: " .. #gamepass.Modules .. "\n"
                    idText = idText .. "• RemoteEvents/Functions: " .. #gamepass.Remotes .. "\n"
                    idText = idText .. "• LocalScripts: " .. #gamepass.LocalScripts .. "\n"
                    idText = idText .. "• Total Codes: " .. gamepass.TotalCodes .. "\n"
                else
                    idText = idText .. "⚠️ No GamePass ID found\n"
                    idText = idText .. "Found " .. gamepass.TotalCodes .. " codes inside\n"
                end
                
                SHOW_COPY_WINDOW("GAMEPASS ID: " .. gamepass.Name, idText)
            end)
            
            yOffset = yOffset + 85
        end
        
        -- تحديث الإحصائيات
        statsLabel.Text = string.format(
            "🔥 Extracted: %d GamePasses | %d Total Codes",
            #CODE_DATABASE.GAMEPASSES,
            CODE_DATABASE.TOTAL_CODES
        )
    end
    
    -- نافذة النسخ
    function SHOW_COPY_WINDOW(title, text)
        local copyGui = Instance.new("ScreenGui")
        copyGui.Parent = localPlayer.PlayerGui
        
        local copyFrame = Instance.new("Frame")
        copyFrame.Size = UDim2.new(0.95, 0, 0.85, 0)
        copyFrame.Position = UDim2.new(0.025, 0, 0.075, 0)
        copyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
        copyFrame.Parent = copyGui
        
        local copyTitle = Instance.new("TextLabel")
        copyTitle.Text = "📋 " .. title
        copyTitle.Size = UDim2.new(0.9, 0, 0.06, 0)
        copyTitle.Position = UDim2.new(0.05, 0, 0.02, 0)
        copyTitle.BackgroundTransparency = 1
        copyTitle.TextColor3 = Color3.new(1, 1, 1)
        copyTitle.Font = Enum.Font.GothamBlack
        copyTitle.TextSize = 14
        copyTitle.TextXAlignment = Enum.TextXAlignment.Center
        copyTitle.Parent = copyFrame
        
        local copyBox = Instance.new("TextBox")
        copyBox.Text = text
        copyBox.Size = UDim2.new(0.9, 0, 0.8, 0)
        copyBox.Position = UDim2.new(0.05, 0, 0.1, 0)
        copyBox.MultiLine = true
        copyBox.TextWrapped = false
        copyBox.ClearTextOnFocus = false
        copyBox.BackgroundTransparency = 1
        copyBox.TextColor3 = Color3.new(0, 1, 0)
        copyBox.Font = Enum.Font.Code
        copyBox.TextSize = 11
        copyBox.TextXAlignment = Enum.TextXAlignment.Left
        copyBox.TextYAlignment = Enum.TextYAlignment.Top
        copyBox.Parent = copyFrame
        
        -- تحديد النص للنسخ
        copyBox:CaptureFocus()
        copyBox.SelectionStart = 1
        copyBox.CursorPosition = #text
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Text = "✓ TEXT SELECTED - COPY NOW"
        closeBtn.Size = UDim2.new(0.9, 0, 0.07, 0)
        closeBtn.Position = UDim2.new(0.05, 0, 0.93, 0)
        closeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.Parent = copyFrame
        
        closeBtn.MouseButton1Click:Connect(function()
            copyGui:Destroy()
        end)
    end
    
    -- حدث الاستخراج القسري
    extractBtn.MouseButton1Click:Connect(function()
        extractBtn.Text = "⏳ FORCE EXTRACTING ALL CODES..."
        extractBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        statsLabel.Text = "🔥 Forcing extraction of ALL codes from ALL GamePasses..."
        
        task.spawn(function()
            FORCE_EXTRACT_ALL_CODES()
            DISPLAY_EXTRACTED_CODES()
            
            extractBtn.Text = "✅ EXTRACTION COMPLETE!"
            extractBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            
            task.wait(2)
            extractBtn.Text = "🔥 EXTRACT ALL CODES NOW!"
            extractBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end)
    end)
    
    -- حدث الإغلاق
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- الاستخراج التلقائي الأولي
    task.spawn(function()
        wait(1)
        extractBtn.Text = "⏳ AUTO EXTRACTING..."
        FORCE_EXTRACT_ALL_CODES()
        DISPLAY_EXTRACTED_CODES()
        extractBtn.Text = "🔥 EXTRACT ALL CODES NOW!"
        extractBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end)
    
    return gui
end

-- ============================================
-- 🚀 التشغيل الفوري
-- ============================================

CREATE_CODE_EXTRACTOR_UI()

print("\n" .. string.rep("🔥", 70))
print("🔥 GAMEPASS CODE FORCE EXTRACTOR LOADED!")
print("⚡ Force Extracts ALL codes from ALL GamePasses")
print("📱 Mobile Interface Ready")
print("✨ Features:")
print("   • EXTRACT ALL CODES NOW! - one click force extraction")
print("   • Extracts ALL Lua codes from EVERY GamePass")
print("   • Shows Scripts, Modules, RemoteEvents, LocalScripts")
print("   • Two copy buttons: 📋 ALL CODES and 🎫 ID ONLY")
print("   • Detailed code statistics for each GamePass")
print(string.rep("🔥", 70))

print("\n🎯 What it extracts:")
print("   1. ALL Script source codes from GamePasses")
print("   2. ALL ModuleScript codes from GamePasses")
print("   3. ALL RemoteEvents/Functions in GamePasses")
print("   4. ALL LocalScript codes from GamePasses")
print("   5. GamePass IDs and all internal data")

print("\n📝 Usage:")
print("   1. Press 🔥 EXTRACT ALL CODES NOW! button")
print("   2. Wait for force extraction to complete")
print("   3. Press 📋 ALL CODES to copy ALL codes from a GamePass")
print("   4. Press 🎫 ID ONLY to copy GamePass ID and statistics")
print("   5. Copy text from phone")
