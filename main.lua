-- ====================================================================
-- 99 Nights in the Forest Hub v1.6 (Food & Coal Update)
-- Разработчик: Кирилл (Оптимизировано ИИ)
-- ====================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Безопасное определение родительского контейнера для UI
local parentGui
local success, err = pcall(function()
    parentGui = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not success or not parentGui then
    parentGui = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Очистка старых копий хаба
if parentGui:FindFirstChild("NightsInForestHub") then
    parentGui:FindFirstChild("NightsInForestHub"):Destroy()
end

-- Создание главного контейнера ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NightsInForestHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

local BASE_WIDTH, BASE_HEIGHT = 550, 350 -- Базовый размер хаба для масштабирования

-- ==========================================
-- 1. АНИМИРОВАННОЕ ПРИВЕТСТВИЕ (ИНТРО)
-- ==========================================
local IntroLabel = Instance.new("TextLabel")
IntroLabel.Size = UDim2.new(0, 300, 0, 50)
IntroLabel.Position = UDim2.new(0, -350, 0.1, 0)
IntroLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
IntroLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroLabel.Text = "Хаб v1.6 успешно запущен!"
IntroLabel.Font = Enum.Font.SourceSansBold
IntroLabel.TextSize = 18
IntroLabel.BorderSizePixel = 0
IntroLabel.Parent = ScreenGui

local IntroCorner = Instance.new("UICorner")
IntroCorner.CornerRadius = UDim.new(0, 8)
IntroCorner.Parent = IntroLabel

local IntroGradient = Instance.new("UIGradient")
IntroGradient.Color = ColorSequence.new(Color3.fromRGB(0, 170, 255), Color3.fromRGB(0, 85, 255))
IntroGradient.Parent = IntroLabel

-- ==========================================
-- 2. ГЛАВНОЕ ОКНО ХАБА
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, BASE_WIDTH, 0, BASE_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -BASE_WIDTH/2, 0.5, -BASE_HEIGHT/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local UiScale = Instance.new("UIScale")
UiScale.Scale = 1
UiScale.Parent = MainFrame

-- Верхняя панель (Топбар)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 250, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "99 Nights Forest Hub v1.6"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -75, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 14
MinimizeBtn.Parent = TopBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

-- Боковое меню
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 120, 1, -40)
SideBar.Position = UDim2.new(0, 0, 0, 40)
SideBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -120, 1, -40)
ContentFrame.Position = UDim2.new(0, 120, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 5)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent = SideBar

local SidePadding = Instance.new("UIPadding")
SidePadding.PaddingTop = UDim.new(0, 10)
SidePadding.Parent = SideBar

-- Скрипт перетаскивания окна
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = (input.Position - dragStart) / UiScale.Scale
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateDrag(input) end
end)

-- ==========================================
-- 3. ДИНАМИЧЕСКАЯ СИСТЕМА ВКЛАДОК
-- ==========================================
local tabs = {"Home", "Settings", "Farm", "AFK", "TP"}
local pages = {}
local tabButtons = {}

local function createTab(tabName, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 105, 0, 32)
    TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.Font = Enum.Font.SourceSans
    TabBtn.TextSize = 14
    TabBtn.LayoutOrder = order
    TabBtn.Parent = SideBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("Frame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = ContentFrame
    
    pages[tabName] = Page
    tabButtons[tabName] = TabBtn

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        for _, b in pairs(tabButtons) do b.TextColor3 = Color3.fromRGB(180, 180, 180) end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
    end)
end

for i, tabName in ipairs(tabs) do createTab(tabName, i) end
pages["Home"].Visible = true
tabButtons["Home"].TextColor3 = Color3.fromRGB(0, 170, 255)

-- ==========================================
-- 4 & 5. HOME И SETTINGS
-- ==========================================
local HomeLabel = Instance.new("TextLabel", pages["Home"])
HomeLabel.Size = UDim2.new(1, -20, 1, -20)
HomeLabel.Position = UDim2.new(0, 10, 0, 10)
HomeLabel.BackgroundTransparency = 1
HomeLabel.Text = "Добро пожаловать в 99 Nights in the Forest Hub!\n\nРазработчик: Кирилл\nВерсия: 1.6 (Food & Coal Update)\n\nИспользуй вкладки слева для конфигурации функций."
HomeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
HomeLabel.Font = Enum.Font.SourceSans
HomeLabel.TextSize = 14
HomeLabel.TextXAlignment = Enum.TextXAlignment.Left
HomeLabel.TextYAlignment = Enum.TextYAlignment.Top

local SettingsLabel = Instance.new("TextLabel", pages["Settings"])
SettingsLabel.Size = UDim2.new(1, -20, 0, 30)
SettingsLabel.Position = UDim2.new(0, 10, 0, 10)
SettingsLabel.BackgroundTransparency = 1
SettingsLabel.Text = "Изменение масштаба хаба (например: 0.8, 1, 1.3):"
SettingsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SettingsLabel.Font = Enum.Font.SourceSans
SettingsLabel.TextSize = 14
SettingsLabel.TextXAlignment = Enum.TextXAlignment.Left

local ScaleInput = Instance.new("TextBox", pages["Settings"])
ScaleInput.Size = UDim2.new(0, 100, 0, 30)
ScaleInput.Position = UDim2.new(0, 10, 0, 45)
ScaleInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ScaleInput.Text = "1"
ScaleInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ScaleInput.Font = Enum.Font.SourceSansBold
ScaleInput.TextSize = 14
Instance.new("UICorner", ScaleInput).CornerRadius = UDim.new(0, 6)

ScaleInput.FocusLost:Connect(function()
    local num = tonumber(ScaleInput.Text)
    if num and num >= 0.3 and num <= 3 then
        TweenService:Create(UiScale, TweenInfo.new(0.3), {Scale = num}):Play()
    else
        ScaleInput.Text = tostring(UiScale.Scale)
    end
end)


-- ==========================================
-- СИСТЕМА УВЕДОМЛЕНИЙ (Стек замещения)
-- ==========================================
local currentNotification = nil
local function showNotification(text)
    if currentNotification then pcall(function() currentNotification:Destroy() end) end

    local NotifFrame = Instance.new("Frame", ScreenGui)
    currentNotification = NotifFrame
    NotifFrame.Size = UDim2.new(0, 280, 0, 45)
    NotifFrame.Position = UDim2.new(1, 10, 0.85, 0)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    NotifFrame.BorderSizePixel = 0
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 6)
    
    local Stroke = Instance.new("UIStroke", NotifFrame)
    Stroke.Color = Color3.fromRGB(0, 170, 255)
    Stroke.Thickness = 1.5

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
            local tweenOut = TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 10, 0.85, 0)})
            tweenOut:Play()
            tweenOut.Completed:Wait()
            if NotifFrame then NotifFrame:Destroy() end
        end
    end)
end

-- ==========================================
-- 7. УНИВЕРСАЛЬНАЯ ЛОГИКА СБОРА
-- ==========================================
local function getCampfirePosition()
    local mainFire = workspace:FindFirstChild("MainFire", true)
    if mainFire then
        local logCylinder = mainFire:FindFirstChild("log_Cylinder", true)
        return logCylinder and logCylinder.CFrame or mainFire:GetPivot()
    end
    return nil
end

local function getWorkbenchPosition()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("workbench") or obj.Name:lower():find("grinder") then
            if obj:IsA("Model") then return obj:GetPivot()
            elseif obj:IsA("BasePart") then return obj.CFrame end
        end
    end
    return nil
end

-- Универсальная функция, собирающая ЛЮБОЙ переданный предмет ( itemName )
local function collectItems(targetMode, itemName)
    local player = Players.LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = player.Character.HumanoidRootPart
    local targetCFrame, destName = nil, ""
    
    if targetMode == "Player" then
        targetCFrame = hrp.CFrame * CFrame.new(0, 0, -4)
        destName = "Себе"
    elseif targetMode == "Campfire" then
        targetCFrame = getCampfirePosition()
        destName = "Костру"
    elseif targetMode == "Workbench" then
        targetCFrame = getWorkbenchPosition()
        destName = "Дробилке"
    end
    
    if not targetCFrame and targetMode ~= "Player" then return end
    
    local itemsFound = {}
    local itemContainer = workspace:FindFirstChild("Drops") or workspace:FindFirstChild("ItemSpawns") or workspace:FindFirstChild("Loot") or workspace
    
    local function scan(container)
        for _, item in pairs(container:GetChildren()) do
            if item:IsA("BasePart") and item.Name == itemName then
                -- Mammoth Filter: проверяем размер только если ищем бревна (Outer)
                if itemName == "Outer" and (item.Size.X >= 10 or item.Size.Z >= 10) then
                    continue 
                end
                table.insert(itemsFound, item)
            end
        end
    end
    
    scan(itemContainer)
    if itemContainer == workspace then
        for _, item in pairs(workspace:GetDescendants()) do
            if item:IsA("BasePart") and item.Name == itemName then
                if itemName == "Outer" and (item.Size.X >= 10 or item.Size.Z >= 10) then continue end
                if not table.find(itemsFound, item) then table.insert(itemsFound, item) end
            end
        end
    end
    
    if #itemsFound == 0 then
        showNotification("Не найдено предметов: " .. itemName .. "!")
        return
    end
    
    showNotification("Сбор: " .. tostring(#itemsFound) .. " " .. itemName .. " -> " .. destName)
    
    task.spawn(function()
        for i, item in ipairs(itemsFound) do
            if not item or not item.Parent then continue end
            
            if item:FindFirstChild("BodyPosition") then item.BodyPosition:Destroy() end
            if item:FindFirstChild("BodyGyro") then item.BodyGyro:Destroy() end
            
            pcall(function()
                item.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                item.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end)
            
            if targetMode == "Player" then
                item.CanCollide = true
                item.CFrame = targetCFrame * CFrame.new(math.random(-1, 1) * 1.5, 0, math.random(-1, 1) * 1.5)
            else
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    item.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 6, 0)
                end
                task.wait(0.02)
                if item and item.Parent then
                    pcall(function()
                        item.AssemblyLinearVelocity = Vector3.new(0, -6, 0)
                        item.CFrame = targetCFrame * CFrame.new(math.random(-1, 1) * 0.5, 3, math.random(-1, 1) * 0.5)
                    end)
                end
            end
            task.wait(0.03)
        end
    end)
end


-- ==========================================
-- 6. НАПОЛНЕНИЕ ВКЛАДКИ FARM (СКРОЛЛИНГ И КНОПКИ)
-- ==========================================
local FarmPage = pages["Farm"]

-- Создаем ScrollingFrame, чтобы кнопки не вылезали за пределы окна
local FarmScroll = Instance.new("ScrollingFrame")
FarmScroll.Size = UDim2.new(1, 0, 1, 0)
FarmScroll.BackgroundTransparency = 1
FarmScroll.BorderSizePixel = 0
FarmScroll.ScrollBarThickness = 4
FarmScroll.Parent = FarmPage

local FarmLayout = Instance.new("UIListLayout")
FarmLayout.Padding = UDim.new(0, 6)
FarmLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
FarmLayout.SortOrder = Enum.SortOrder.LayoutOrder
FarmLayout.Parent = FarmScroll

local FarmPadding = Instance.new("UIPadding")
FarmPadding.PaddingTop = UDim.new(0, 10)
FarmPadding.PaddingBottom = UDim.new(0, 10)
FarmPadding.Parent = FarmScroll

-- Автоматическое изменение размера зоны скроллинга
FarmLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    FarmScroll.CanvasSize = UDim2.new(0, 0, 0, FarmLayout.AbsoluteContentSize.Y + 20)
end)

-- Функции-помощники для создания секций и кнопок
local function createLabel(text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = FarmScroll
end

local function createButton(text, color, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 35)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.LayoutOrder = order
    btn.Parent = FarmScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(callback)
end

-- --- ГЕНЕРАЦИЯ КНОПОК ФАРМА ---

-- ДЕРЕВО
createLabel("🪵 Сбор дерева (Outer):", 1)
createButton("Бревна к Себе", Color3.fromRGB(0, 170, 255), 2, function() collectItems("Player", "Outer") end)
createButton("Бревна к Костру", Color3.fromRGB(45, 45, 45), 3, function() collectItems("Campfire", "Outer") end)
createButton("Бревна в Дробилку", Color3.fromRGB(45, 45, 45), 4, function() collectItems("Workbench", "Outer") end)

-- РУДА И УГОЛЬ
createLabel("🪨 Руда и Уголь:", 5)
createButton("Уголь (Coal) к Себе", Color3.fromRGB(0, 170, 255), 6, function() collectItems("Player", "Coal") end)

-- ЕДА
createLabel("🍖 Сбор еды:", 7)
createButton("Морсель (Morsel) к Себе", Color3.fromRGB(0, 170, 255), 8, function() collectItems("Player", "Morsel") end)
createButton("Мясо (Meat) к Себе", Color3.fromRGB(0, 170, 255), 9, function() collectItems("Player", "Meat") end)


-- ==========================================
-- 8. СВЕРТЫВАНИЕ И ЗАКРЫТИЕ ХАБА
-- ==========================================
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ContentFrame.Visible = false
        SideBar.Visible = false
        MainFrame.Size = UDim2.new(0, BASE_WIDTH, 0, 40)
        MinimizeBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, BASE_WIDTH, 0, BASE_HEIGHT)
        ContentFrame.Visible = true
        SideBar.Visible = true
        MinimizeBtn.Text = "-"
    end
end)

-- ==========================================
-- 9. СТАРТ АНИМАЦИИ ИНТРО
-- ==========================================
task.spawn(function()
    if not IntroLabel or not ScreenGui then return end
    
    local tweenIn = TweenService:Create(IntroLabel, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 20, 0.1, 0)})
    tweenIn:Play()
    tweenIn.Completed:Wait()
    
    task.wait(2)
    
    if not ScreenGui or not ScreenGui.Parent or not IntroLabel then return end
    
    local tweenOut = TweenService:Create(IntroLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0, -350, 0.1, 0)})
    tweenOut:Play()
    tweenOut.Completed:Wait()
    
    if IntroLabel then IntroLabel:Destroy() end
    if MainFrame then
        MainFrame.Visible = true
        MainFrame.ClipsDescendants = true
    end
end)
