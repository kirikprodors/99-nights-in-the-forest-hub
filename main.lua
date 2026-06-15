-- ====================================================================
-- 99 Nights in the Forest Hub v1.3 (Fixed Logs & Clean UI)
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
IntroLabel.Text = "Хаб успешно запущен!"
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

-- Элемент UIScale для пропорционального изменения ВСЕГО интерфейса
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
Title.Text = "99 Nights Forest Hub v1.3"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Кнопка Закрыть (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Кнопка Свернуть (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -75, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 14
MinimizeBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

-- Боковое меню для вкладок
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

-- ==========================================
-- СКРИПТ ПЕРЕТАСКИВАНИЯ (С подстройкой под UIScale)
-- ==========================================
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
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
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
    
    local TabBtnCorner = Instance.new("UICorner")
    TabBtnCorner.CornerRadius = UDim.new(0, 6)
    TabBtnCorner.Parent = TabBtn

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

for i, tabName in ipairs(tabs) do
    createTab(tabName, i)
end

pages["Home"].Visible = true
tabButtons["Home"].TextColor3 = Color3.fromRGB(0, 170, 255)

-- ==========================================
-- 4. НАПОЛНЕНИЕ ВКЛАДКИ HOME
-- ==========================================
local HomeLabel = Instance.new("TextLabel")
HomeLabel.Size = UDim2.new(1, -20, 1, -20)
HomeLabel.Position = UDim2.new(0, 10, 0, 10)
HomeLabel.BackgroundTransparency = 1
HomeLabel.Text = "Добро пожаловать в 99 Nights in the Forest Hub!\n\nРазработчик: Кирилл\nВерсия: 1.3 (Исправленная)\n\nИспользуй вкладки слева для конфигурации функций."
HomeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
HomeLabel.Font = Enum.Font.SourceSans
HomeLabel.TextSize = 14
HomeLabel.TextWrapped = true
HomeLabel.TextYAlignment = Enum.TextYAlignment.Top
HomeLabel.TextXAlignment = Enum.TextXAlignment.Left
HomeLabel.Parent = pages["Home"]

-- ==========================================
-- 5. НАПОЛНЕНИЕ ВКЛАДКИ SETTINGS (МАСШТАБИРОВАНИЕ)
-- ==========================================
local SettingsLabel = Instance.new("TextLabel")
SettingsLabel.Size = UDim2.new(1, -20, 0, 30)
SettingsLabel.Position = UDim2.new(0, 10, 0, 10)
SettingsLabel.BackgroundTransparency = 1
SettingsLabel.Text = "Изменение масштаба хаба (например: 0.8, 1, 1.3):"
SettingsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SettingsLabel.Font = Enum.Font.SourceSans
SettingsLabel.TextSize = 14
SettingsLabel.TextXAlignment = Enum.TextXAlignment.Left
SettingsLabel.Parent = pages["Settings"]

local ScaleInput = Instance.new("TextBox")
ScaleInput.Size = UDim2.new(0, 100, 0, 30)
ScaleInput.Position = UDim2.new(0, 10, 0, 45)
ScaleInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ScaleInput.Text = "1"
ScaleInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ScaleInput.Font = Enum.Font.SourceSansBold
ScaleInput.TextSize = 14
ScaleInput.Parent = pages["Settings"]

local ScaleCorner = Instance.new("UICorner")
ScaleCorner.CornerRadius = UDim.new(0, 6)
ScaleCorner.Parent = ScaleInput

ScaleInput.FocusLost:Connect(function(enterPressed)
    local num = tonumber(ScaleInput.Text)
    if num and num >= 0.3 and num <= 3 then
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(UiScale, tweenInfo, {Scale = num}):Play()
    else
        ScaleInput.Text = tostring(UiScale.Scale)
    end
end)

-- ==========================================
-- 6. НАПОЛНЕНИЕ ВКЛАДКИ FARM (МЕНЮ СБОРА)
-- ==========================================
local FarmPage = pages["Farm"]

local ModeLabel = Instance.new("TextLabel")
ModeLabel.Size = UDim2.new(1, -20, 0, 30)
ModeLabel.Position = UDim2.new(0, 10, 0, 10)
ModeLabel.BackgroundTransparency = 1
ModeLabel.Text = "Сбор и телепортация бревен (Outer):"
ModeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ModeLabel.Font = Enum.Font.SourceSans
ModeLabel.TextSize = 14
ModeLabel.TextXAlignment = Enum.TextXAlignment.Left
ModeLabel.Parent = FarmPage

-- Кнопка телепорта к Игроку
local TpPlayerBtn = Instance.new("TextButton")
TpPlayerBtn.Size = UDim2.new(1, -20, 0, 45)
TpPlayerBtn.Position = UDim2.new(0, 10, 0, 50)
TpPlayerBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
TpPlayerBtn.Text = "Телепортировать бревна к Себе"
TpPlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpPlayerBtn.Font = Enum.Font.SourceSansBold
TpPlayerBtn.TextSize = 14
TpPlayerBtn.Parent = FarmPage

local TpPlayerCorner = Instance.new("UICorner")
TpPlayerCorner.CornerRadius = UDim.new(0, 6)
TpPlayerCorner.Parent = TpPlayerBtn

-- Кнопка телепорта к Костру
local TpCampfireBtn = Instance.new("TextButton")
TpCampfireBtn.Size = UDim2.new(1, -20, 0, 45)
TpCampfireBtn.Position = UDim2.new(0, 10, 0, 110)
TpCampfireBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TpCampfireBtn.Text = "Телепортировать бревна к Костру"
TpCampfireBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpCampfireBtn.Font = Enum.Font.SourceSansBold
TpCampfireBtn.TextSize = 14
TpCampfireBtn.Parent = FarmPage

local TpCampfireCorner = Instance.new("UICorner")
TpCampfireCorner.CornerRadius = UDim.new(0, 6)
TpCampfireCorner.Parent = TpCampfireBtn

-- Кнопка телепорта к Верстаку/Дробилке
local TpWorkbenchBtn = Instance.new("TextButton")
TpWorkbenchBtn.Size = UDim2.new(1, -20, 0, 45)
TpWorkbenchBtn.Position = UDim2.new(0, 10, 0, 170)
TpWorkbenchBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TpWorkbenchBtn.Text = "Телепортировать бревна в Дробилку"
TpWorkbenchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpWorkbenchBtn.Font = Enum.Font.SourceSansBold
TpWorkbenchBtn.TextSize = 14
TpWorkbenchBtn.Parent = FarmPage

local TpWorkbenchCorner = Instance.new("UICorner")
TpWorkbenchCorner.CornerRadius = UDim.new(0, 6)
TpWorkbenchCorner.Parent = TpWorkbenchBtn


-- ==========================================
-- 7. ЛОГИКА ОПРЕДЕЛЕНИЯ ЦЕЛЕЙ И ПЕРЕНОСА ОБЪЕКТОВ
-- ==========================================

-- Получение точной позиции костра
local function getCampfirePosition()
    local map = workspace:FindFirstChild("Map")
    local campground = map and map:FindFirstChild("Campground")
    local mainFire = campground and campground:FindFirstChild("MainFire")
    local model = mainFire and mainFire:FindFirstChild("Model")
    local logCylinder = model and model:FindFirstChild("Meshes/log_Cylinder")
    
    if logCylinder and logCylinder:IsA("BasePart") then
        return logCylinder.CFrame + Vector3.new(0, 3, 0)
    end
    
    if mainFire then
        return mainFire:GetPivot() + Vector3.new(0, 3, 0)
    end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "MainFire" then
            return obj:GetPivot() + Vector3.new(0, 3, 0)
        end
    end
    return nil
end

-- Получение точной позиции центра дробилки (верстака)
local function getWorkbenchPosition()
    local leftPart, rightPart
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj.Name == "GrindersLeft" then leftPart = obj end
            if obj.Name == "GrindersRight" then rightPart = obj end
        end
        if leftPart and rightPart then break end
    end
    
    if leftPart and rightPart then
        return CFrame.new((leftPart.Position + rightPart.Position) / 2) + Vector3.new(0, 2, 0)
    end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("workbench") or obj.Name:lower():find("grinder") then
            if obj:IsA("Model") then
                return obj:GetPivot() + Vector3.new(0, 2, 0)
            elseif obj:IsA("BasePart") then
                return obj.CFrame + Vector3.new(0, 2, 0)
            end
        end
    end
    return nil
end

-- Функция сбора бревен (прямое перемещение деталей Outer без вмешательства в Родителя)
local function collectAllLogs(targetMode)
    local targetCFrame
    
    if targetMode == "Player" then
        local player = Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Телепортируем бревна чуть-чуть впереди игрока, чтобы они аккуратно лежали на земле перед тобой
            targetCFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4)
        end
    elseif targetMode == "Campfire" then
        targetCFrame = getCampfirePosition()
    elseif targetMode == "Workbench" then
        targetCFrame = getWorkbenchPosition()
    end
    
    if not targetCFrame then return end
    
    -- Ищем бревна в контейнере дропов или по всей карте
    local itemContainer = workspace:FindFirstChild("Drops") or workspace:FindFirstChild("ItemSpawns") or workspace:FindFirstChild("Loot") or workspace
    
    local function processItem(item)
        -- Перемещаем бревна (детали Outer)
        if item:IsA("BasePart") and item.Name == "Outer" then
            if item:FindFirstChild("BodyPosition") then item.BodyPosition:Destroy() end
            if item:FindFirstChild("BodyGyro") then item.BodyGyro:Destroy() end
            
            pcall(function()
                item.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                item.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end)
            
            -- Прямое перемещение БЕЗ PivotTo (чтобы не двигать весь Workspace как модель!)
            item.CanCollide = true
            item.CFrame = targetCFrame
        end
    end
    
    for _, item in pairs(itemContainer:GetChildren()) do
        processItem(item)
    end
    
    if itemContainer == workspace then
        for _, item in pairs(workspace:GetDescendants()) do
            processItem(item)
        end
    end
end

-- Подключение кнопок сбора к функциям
TpPlayerBtn.MouseButton1Click:Connect(function()
    collectAllLogs("Player")
end)

TpCampfireBtn.MouseButton1Click:Connect(function()
    collectAllLogs("Campfire")
end)

TpWorkbenchBtn.MouseButton1Click:Connect(function()
    collectAllLogs("Workbench")
end)


-- ==========================================
-- 8. СВЕРТЫВАНИЕ И ЗАКРЫТИЕ ХАБА
-- ==========================================
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

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
-- 9. СТАРТ АНИМАЦИИ ИНТРО И ОТКРЫТИЕ ОКНА
-- ==========================================
task.spawn(function()
    if not IntroLabel or not ScreenGui then return end
    
    local tweenIn = TweenService:Create(IntroLabel, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 20, 0.1, 0)
    })
    tweenIn:Play()
    tweenIn.Completed:Wait()
    
    task.wait(2)
    
    if not ScreenGui or not ScreenGui.Parent or not IntroLabel then return end
    
    local tweenOut = TweenService:Create(IntroLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0, -350, 0.1, 0)
    })
    tweenOut:Play()
    tweenOut.Completed:Wait()
    
    if IntroLabel then IntroLabel:Destroy() end
    if MainFrame then
        MainFrame.Visible = true
        MainFrame.ClipsDescendants = true
    end
end)
