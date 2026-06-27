-- ====================================================================
-- 99 Nights in the Forest Hub v1.8 (Custom Items & Base64 Save)
-- Разработчик: Кирилл (Оптимизировано ИИ)
-- ====================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- ==========================================
-- Утилиты Base64 для сохранения
-- ==========================================
local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function base64Encode(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

local function base64Decode(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- ==========================================
-- Безопасная загрузка UI
-- ==========================================
local parentGui
local success, err = pcall(function() parentGui = (gethui and gethui()) or game:GetService("CoreGui") end)
if not success or not parentGui then parentGui = Players.LocalPlayer:WaitForChild("PlayerGui") end

if parentGui:FindFirstChild("NightsInForestHub") then
    parentGui:FindFirstChild("NightsInForestHub"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NightsInForestHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

local BASE_WIDTH, BASE_HEIGHT = 550, 400

-- ==========================================
-- Базовый интерфейс
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, BASE_WIDTH, 0, BASE_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -BASE_WIDTH/2, 0.5, -BASE_HEIGHT/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local UiScale = Instance.new("UIScale", MainFrame)
UiScale.Scale = 1

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0, 250, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "99 Nights Forest Hub v1.8"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local MinimizeBtn = Instance.new("TextButton", TopBar)
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -75, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 14
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local SideBar = Instance.new("ScrollingFrame", MainFrame)
SideBar.Size = UDim2.new(0, 120, 1, -40)
SideBar.Position = UDim2.new(0, 0, 0, 40)
SideBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SideBar.BorderSizePixel = 0
SideBar.ScrollBarThickness = 2

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -120, 1, -40)
ContentFrame.Position = UDim2.new(0, 120, 0, 40)
ContentFrame.BackgroundTransparency = 1

local SideLayout = Instance.new("UIListLayout", SideBar)
SideLayout.Padding = UDim.new(0, 5)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", SideBar).PaddingTop = UDim.new(0, 10)

-- Драг окна
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos = true, input.Position, MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = (input.Position - dragStart) / UiScale.Scale
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- Уведомления
-- ==========================================
local currentNotif = nil
local function showNotification(text)
    if currentNotif then pcall(function() currentNotif:Destroy() end) end
    local NotifFrame = Instance.new("Frame", ScreenGui)
    currentNotif = NotifFrame
    NotifFrame.Size = UDim2.new(0, 280, 0, 45)
    NotifFrame.Position = UDim2.new(1, 10, 0.85, 0)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", NotifFrame).Color = Color3.fromRGB(0, 170, 255)
    Instance.new("UIStroke", NotifFrame).Thickness = 1.5

    local Label = Instance.new("TextLabel", NotifFrame)
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -290, 0.85, 0)}):Play()
    task.delay(3, function()
        if NotifFrame and NotifFrame.Parent then
            local t = TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 10, 0.85, 0)})
            t:Play() t.Completed:Wait()
            if NotifFrame then NotifFrame:Destroy() end
        end
    end)
end

-- ==========================================
-- Система Вкладок
-- ==========================================
local tabs = {"Home", "Farm", "Custom", "Settings"}
local pages, tabButtons = {}, {}

for _, tabName in ipairs(tabs) do
    local TabBtn = Instance.new("TextButton", SideBar)
    TabBtn.Size = UDim2.new(0, 105, 0, 32)
    TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.TextSize = 14
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("Frame", ContentFrame)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    pages[tabName] = Page
    tabButtons[tabName] = TabBtn

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        for _, b in pairs(tabButtons) do b.TextColor3 = Color3.fromRGB(180, 180, 180) end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
    end)
end
pages["Home"].Visible = true
tabButtons["Home"].TextColor3 = Color3.fromRGB(0, 170, 255)

local HomeLabel = Instance.new("TextLabel", pages["Home"])
HomeLabel.Size = UDim2.new(1, -20, 1, -20)
HomeLabel.Position = UDim2.new(0, 10, 0, 10)
HomeLabel.BackgroundTransparency = 1
HomeLabel.Text = "Добро пожаловать в 99 Nights in the Forest Hub!\n\nРазработчик: Кирилл\nВерсия: 1.8 (Custom Items & Config)\n\nСюда добавлены новые предметы, вкладка кастомных предметов и система сохранения настроек!"
HomeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
HomeLabel.Font = Enum.Font.SourceSans
HomeLabel.TextSize = 15
HomeLabel.TextXAlignment = Enum.TextXAlignment.Left
HomeLabel.TextYAlignment = Enum.TextYAlignment.Top

-- ==========================================
-- Логика предметов и Сетки
-- ==========================================
-- Стандартные предметы
local defaultItems = {
    { name = "Дерево (Logs)", match = "Outer", requirePart = nil, sizeFilter = true },
    { name = "Уголь (Coal)", match = "Coal" },
    { name = "Морсель (Morsel)", match = "Morsel", requirePart = "Meat" },
    { name = "Стейк (Steak)", match = "Steak", requirePart = "Main" },
    { name = "Двигатель", match = "Old Car Engine", requirePart = "Main" },
    { name = "Стул (Chair)", match = "Chair", requirePart = "Part" },
    { name = "Болт (Bolt)", match = "Bolt", requirePart = "Main" },
    { name = "Микроволновка", match = "Broken Microwave", requirePart = "Main" },
    { name = "Радио", match = "Old Radio", requirePart = "Main" },
    { name = "Канистра (Fuel)", match = "Fuel Canister", requirePart = "Main" },
    { name = "Бочка (Oil)", match = "Oil Barrel", requirePart = "Main" },
    { name = "Бинты (Bandage)", match = "Bandage", requirePart = "Handle" }
}
local customItems = {} -- Хранилище для пользовательских предметов
local selectedItemConfig = nil

-- Фарм вкладка
local FarmPage = pages["Farm"]
local ItemsFrame = Instance.new("ScrollingFrame", FarmPage)
ItemsFrame.Size = UDim2.new(1, -20, 1, -125)
ItemsFrame.Position = UDim2.new(0, 10, 0, 10)
ItemsFrame.BackgroundTransparency = 1
ItemsFrame.BorderSizePixel = 0
ItemsFrame.ScrollBarThickness = 4
ItemsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local Grid = Instance.new("UIGridLayout", ItemsFrame)
Grid.CellSize = UDim2.new(0.5, -6, 0, 35)
Grid.CellPadding = UDim2.new(0, 8, 0, 8)
Grid.SortOrder = Enum.SortOrder.LayoutOrder

local itemBtns = {}

-- Функция отрисовки кнопок (вызывается при старте и после добавления кастомных)
local function refreshFarmGrid()
    for _, btn in pairs(itemBtns) do btn:Destroy() end
    itemBtns = {}
    selectedItemConfig = nil

    local allItems = {}
    for _, v in ipairs(defaultItems) do table.insert(allItems, v) end
    for _, v in ipairs(customItems) do table.insert(allItems, v) end

    for _, config in ipairs(allItems) do
        local btn = Instance.new("TextButton", ItemsFrame)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.Text = config.name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 13
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        itemBtns[config.name] = btn

        btn.MouseButton1Click:Connect(function()
            selectedItemConfig = config
            for k, b in pairs(itemBtns) do
                if k == config.name then
                    b.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                    b.TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    b.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
        end)
    end
end
refreshFarmGrid()

-- ==========================================
-- Механизм телепортации (Farm)
-- ==========================================
local function executeFarm(targetMode)
    if not selectedItemConfig then return showNotification("Сначала выберите предмет!") end

    local targetCFrame = nil
    local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if targetMode == "Player" then
        targetCFrame = hrp and hrp.CFrame * CFrame.new(0, 0, -4)
    elseif targetMode == "Campfire" then
        local mainFire = workspace:FindFirstChild("MainFire", true)
        if mainFire then targetCFrame = (mainFire:FindFirstChild("log_Cylinder", true) or mainFire):GetPivot() end
    elseif targetMode == "Workbench" then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("workbench") or obj.Name:lower():find("grinder") then
                targetCFrame = obj:IsA("Model") and obj:GetPivot() or obj.CFrame break
            end
        end
    end

    if not hrp or not targetCFrame then return showNotification("Цель не найдена!") end

    local itemsFound = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == selectedItemConfig.match then
            local partToMove = nil
            if selectedItemConfig.requirePart and selectedItemConfig.requirePart ~= "" then
                if obj:IsA("Model") then partToMove = obj:FindFirstChild(selectedItemConfig.requirePart) end
                if obj:IsA("BasePart") and obj.Name == selectedItemConfig.requirePart then partToMove = obj end
            else
                partToMove = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            end

            if partToMove then
                if selectedItemConfig.sizeFilter and (partToMove.Size.X >= 10 or partToMove.Size.Z >= 10) then continue end
                if not table.find(itemsFound, partToMove) then table.insert(itemsFound, partToMove) end
            end
        end
    end

    if #itemsFound == 0 then return showNotification("Предмет '" .. selectedItemConfig.name .. "' не найден на карте!") end
    showNotification("Сбор: " .. #itemsFound .. " шт.")

    task.spawn(function()
        for _, part in ipairs(itemsFound) do
            if not part or not part.Parent then continue end
            if part:FindFirstChild("BodyPosition") then part.BodyPosition:Destroy() end
            if part:FindFirstChild("BodyGyro") then part.BodyGyro:Destroy() end
            pcall(function() part.AssemblyLinearVelocity, part.AssemblyAngularVelocity = Vector3.zero, Vector3.zero; part.CanCollide = true end)

            if targetMode == "Player" then
                part.CFrame = targetCFrame * CFrame.new(math.random(-1, 1) * 1.5, 0, math.random(-1, 1) * 1.5)
            else
                part.CFrame = hrp.CFrame * CFrame.new(0, 6, 0)
                task.wait(0.02)
                if part and part.Parent then
                    pcall(function()
                        part.AssemblyLinearVelocity = Vector3.new(0, -6, 0)
                        part.CFrame = targetCFrame * CFrame.new(math.random(-1, 1) * 0.5, 3, math.random(-1, 1) * 0.5)
                    end)
                end
            end
            task.wait(0.03)
        end
    end)
end

local ActionsFrame = Instance.new("Frame", FarmPage)
ActionsFrame.Size = UDim2.new(1, -20, 0, 110)
ActionsFrame.Position = UDim2.new(0, 10, 1, -115)
ActionsFrame.BackgroundTransparency = 1
local ActLayout = Instance.new("UIListLayout", ActionsFrame)
ActLayout.Padding = UDim.new(0, 5)

local function createDestBtn(text, color, targetMode)
    local btn = Instance.new("TextButton", ActionsFrame)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() executeFarm(targetMode) end)
end

createDestBtn("Телепортировать К СЕБЕ", Color3.fromRGB(0, 170, 255), "Player")
createDestBtn("Телепортировать К КОСТРУ", Color3.fromRGB(50, 150, 50), "Campfire")
createDestBtn("Телепортировать В ДРОБИЛКУ", Color3.fromRGB(150, 50, 50), "Workbench")


-- ==========================================
-- Вкладка CUSTOM (Добавление предметов)
-- ==========================================
local CustomPage = pages["Custom"]
local CustomLayout = Instance.new("UIListLayout", CustomPage)
CustomLayout.Padding = UDim.new(0, 8)
Instance.new("UIPadding", CustomPage).PaddingTop = UDim.new(0, 10)
Instance.new("UIPadding", CustomPage).PaddingLeft = UDim.new(0, 10)

local function makeCustomInput(placeholder)
    local tb = Instance.new("TextBox", CustomPage)
    tb.Size = UDim2.new(1, -20, 0, 35)
    tb.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    tb.PlaceholderText = placeholder
    tb.Text = ""
    tb.TextColor3 = Color3.fromRGB(255, 255, 255)
    tb.Font = Enum.Font.SourceSans
    tb.TextSize = 14
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
    return tb
end

local CustomInfo = Instance.new("TextLabel", CustomPage)
CustomInfo.Size = UDim2.new(1, -20, 0, 20)
CustomInfo.BackgroundTransparency = 1
CustomInfo.Text = "Добавьте свой путь, например: Workspace.Items.Apple.Handle"
CustomInfo.TextColor3 = Color3.fromRGB(180, 180, 180)
CustomInfo.Font = Enum.Font.SourceSansBold
CustomInfo.TextSize = 14
CustomInfo.TextXAlignment = Enum.TextXAlignment.Left

local InputModel = makeCustomInput("Имя модели (напр. Apple)")
local InputPart = makeCustomInput("Деталь модели (напр. Handle, или пусто)")
local InputName = makeCustomInput("Название кнопки (напр. Яблоко)")

local AddCustomBtn = Instance.new("TextButton", CustomPage)
AddCustomBtn.Size = UDim2.new(1, -20, 0, 40)
AddCustomBtn.BackgroundColor3 = Color3.fromRGB(170, 85, 255)
AddCustomBtn.Text = "+ ДОБАВИТЬ ВО ВКЛАДКУ FARM"
AddCustomBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AddCustomBtn.Font = Enum.Font.SourceSansBold
AddCustomBtn.TextSize = 14
Instance.new("UICorner", AddCustomBtn).CornerRadius = UDim.new(0, 6)

AddCustomBtn.MouseButton1Click:Connect(function()
    local mdl, prt, nm = InputModel.Text, InputPart.Text, InputName.Text
    if mdl == "" or nm == "" then return showNotification("Имя модели и кнопки обязательны!") end
    
    table.insert(customItems, { name = nm, match = mdl, requirePart = (prt ~= "" and prt or nil) })
    refreshFarmGrid()
    showNotification("Добавлено: " .. nm)
    InputModel.Text, InputPart.Text, InputName.Text = "", "", ""
end)

-- ==========================================
-- Вкладка SETTINGS (Масштаб + Base64 Сохранение)
-- ==========================================
local SettingsPage = pages["Settings"]
local SetLayout = Instance.new("UIListLayout", SettingsPage)
SetLayout.Padding = UDim.new(0, 8)
Instance.new("UIPadding", SettingsPage).PaddingTop = UDim.new(0, 10)
Instance.new("UIPadding", SettingsPage).PaddingLeft = UDim.new(0, 10)

local ScaleLabel = Instance.new("TextLabel", SettingsPage)
ScaleLabel.Size = UDim2.new(1, -20, 0, 20)
ScaleLabel.BackgroundTransparency = 1
ScaleLabel.Text = "Масштаб интерфейса:"
ScaleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ScaleLabel.Font = Enum.Font.SourceSansBold
ScaleLabel.TextSize = 14
ScaleLabel.TextXAlignment = Enum.TextXAlignment.Left

local ScaleInput = Instance.new("TextBox", SettingsPage)
ScaleInput.Size = UDim2.new(1, -20, 0, 35)
ScaleInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ScaleInput.Text = "1"
ScaleInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ScaleInput.Font = Enum.Font.SourceSansBold
ScaleInput.TextSize = 14
Instance.new("UICorner", ScaleInput).CornerRadius = UDim.new(0, 6)

ScaleInput.FocusLost:Connect(function()
    local num = tonumber(ScaleInput.Text)
    if num and num >= 0.3 and num <= 3 then TweenService:Create(UiScale, TweenInfo.new(0.3), {Scale = num}):Play()
    else ScaleInput.Text = tostring(UiScale.Scale) end
end)

local SaveLabel = Instance.new("TextLabel", SettingsPage)
SaveLabel.Size = UDim2.new(1, -20, 0, 20)
SaveLabel.BackgroundTransparency = 1
SaveLabel.Text = "Сохранение/Загрузка (Base64 код):"
SaveLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SaveLabel.Font = Enum.Font.SourceSansBold
SaveLabel.TextSize = 14
SaveLabel.TextXAlignment = Enum.TextXAlignment.Left

local BaseCodeInput = Instance.new("TextBox", SettingsPage)
BaseCodeInput.Size = UDim2.new(1, -20, 0, 35)
BaseCodeInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
BaseCodeInput.PlaceholderText = "Сюда вставлять или отсюда копировать код..."
BaseCodeInput.Text = ""
BaseCodeInput.ClearTextOnFocus = false
BaseCodeInput.TextWrapped = true
BaseCodeInput.TextColor3 = Color3.fromRGB(0, 255, 127)
BaseCodeInput.Font = Enum.Font.Code
BaseCodeInput.TextSize = 12
Instance.new("UICorner", BaseCodeInput).CornerRadius = UDim.new(0, 6)

local BtnArea = Instance.new("Frame", SettingsPage)
BtnArea.Size = UDim2.new(1, -20, 0, 35)
BtnArea.BackgroundTransparency = 1

local SaveBtn = Instance.new("TextButton", BtnArea)
SaveBtn.Size = UDim2.new(0.48, 0, 1, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SaveBtn.Text = "СОХРАНИТЬ КОД"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.Font = Enum.Font.SourceSansBold
SaveBtn.TextSize = 14
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 6)

local LoadBtn = Instance.new("TextButton", BtnArea)
LoadBtn.Size = UDim2.new(0.48, 0, 1, 0)
LoadBtn.Position = UDim2.new(0.52, 0, 0, 0)
LoadBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
LoadBtn.Text = "ЗАГРУЗИТЬ КОД"
LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadBtn.Font = Enum.Font.SourceSansBold
LoadBtn.TextSize = 14
Instance.new("UICorner", LoadBtn).CornerRadius = UDim.new(0, 6)

SaveBtn.MouseButton1Click:Connect(function()
    local dataTable = { s = UiScale.Scale, i = customItems }
    local success, json = pcall(function() return HttpService:JSONEncode(dataTable) end)
    if success and json then
        local b64 = base64Encode(json)
        BaseCodeInput.Text = b64
        if setclipboard then pcall(function() setclipboard(b64) end) end
        showNotification("Сохранено (скопируй код из поля!)")
    end
end)

LoadBtn.MouseButton1Click:Connect(function()
    local code = BaseCodeInput.Text
    if code == "" then return showNotification("Вставьте код в поле!") end
    local success, json = pcall(function() return base64Decode(code) end)
    if success and json and json ~= "" then
        local decodeSuccess, decodedTbl = pcall(function() return HttpService:JSONDecode(json) end)
        if decodeSuccess and type(decodedTbl) == "table" then
            if decodedTbl.s then ScaleInput.Text = tostring(decodedTbl.s); TweenService:Create(UiScale, TweenInfo.new(0.3), {Scale = decodedTbl.s}):Play() end
            if decodedTbl.i then customItems = decodedTbl.i; refreshFarmGrid() end
            showNotification("Настройки и предметы успешно загружены!")
            return
        end
    end
    showNotification("Ошибка: Неверный или битый Base64 код!")
end)

-- Свертывание и Закрытие
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
local min = false
MinimizeBtn.MouseButton1Click:Connect(function()
    min = not min
    if min then ContentFrame.Visible, SideBar.Visible, MainFrame.Size, MinimizeBtn.Text = false, false, UDim2.new(0, BASE_WIDTH, 0, 40), "+"
    else MainFrame.Size, ContentFrame.Visible, SideBar.Visible, MinimizeBtn.Text = UDim2.new(0, BASE_WIDTH, 0, BASE_HEIGHT), true, true, "-" end
end)
