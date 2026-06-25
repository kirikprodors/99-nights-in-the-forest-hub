-- ====================================================================
-- 99 Nights in the Forest Hub v1.7 (Smart Farm & Auto-Scale Fix)
-- Разработчик: Кирилл (Оптимизировано ИИ)
-- ====================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Безопасное определение родительского контейнера
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

-- Главный контейнер
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NightsInForestHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

local BASE_WIDTH, BASE_HEIGHT = 550, 370 -- Слегка увеличили высоту под новое удобное меню

-- ==========================================
-- 1. ИНТРО АНИМАЦИЯ
-- ==========================================
local IntroLabel = Instance.new("TextLabel")
IntroLabel.Size = UDim2.new(0, 300, 0, 50)
IntroLabel.Position = UDim2.new(0, -350, 0.1, 0)
IntroLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
IntroLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroLabel.Text = "Хаб v1.7 успешно запущен!"
IntroLabel.Font = Enum.Font.SourceSansBold
IntroLabel.TextSize = 18
IntroLabel.BorderSizePixel = 0
IntroLabel.Parent = ScreenGui
Instance.new("UICorner", IntroLabel).CornerRadius = UDim.new(0, 8)

local IntroGradient = Instance.new("UIGradient")
IntroGradient.Color = ColorSequence.new(Color3.fromRGB(0, 170, 255), Color3.fromRGB(0, 85, 255))
IntroGradient.Parent = IntroLabel

-- ==========================================
-- 2. ГЛАВНОЕ ОКНО
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, BASE_WIDTH, 0, BASE_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -BASE_WIDTH/2, 0.5, -BASE_HEIGHT/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Масштабирование окна (UIScale)
local UiScale = Instance.new("UIScale")
UiScale.Scale = 1
UiScale.Parent = MainFrame

-- Топбар
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 250, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "99 Nights Forest Hub v1.7"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

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

-- Боковое меню и область контента
local SideBar = Instance.new("Frame", MainFrame)
SideBar.Size = UDim2.new(0, 120, 1, -40)
SideBar.Position = UDim2.new(0, 0, 0, 40)
SideBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SideBar.BorderSizePixel = 0

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -120, 1, -40)
ContentFrame.Position = UDim2.new(0, 120, 0, 40)
ContentFrame.BackgroundTransparency = 1

local SideLayout = Instance.new("UIListLayout", SideBar)
SideLayout.Padding = UDim.new(0, 5)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local SidePadding = Instance.new("UIPadding", SideBar)
SidePadding.PaddingTop = UDim.new(0, 10)

-- Скрипт перетаскивания окна (Учитывает UIScale)
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
-- 3. ДИНАМИЧЕСКАЯ СИСТЕМА ВКЛАДОК
-- ==========================================
local tabs = {"Home", "Settings", "Farm", "AFK", "TP"}
local pages, tabButtons = {}, {}

for i, tabName in ipairs(tabs) do
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

-- ==========================================
-- 4. HOME И SETTINGS
-- ==========================================
local HomeLabel = Instance.new("TextLabel", pages["Home"])
HomeLabel.Size = UDim2.new(1, -20, 1, -20)
HomeLabel.Position = UDim2.new(0, 10, 0, 10)
HomeLabel.BackgroundTransparency = 1
HomeLabel.Text = "Добро пожаловать в 99 Nights in the Forest Hub!\n\nРазработчик: Кирилл\nВерсия: 1.7 (Smart Select & Auto-Scale Fix)\n\nИспользуй вкладки слева для конфигурации функций."
HomeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
HomeLabel.Font = Enum.Font.SourceSans
HomeLabel.TextSize = 15
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
-- УВЕДОМЛЕНИЯ
-- ==========================================
local currentNotif = nil
local function showNotification(text)
    if currentNotif then pcall(function() currentNotif:Destroy() end) end

    local NotifFrame = Instance.new("Frame", ScreenGui)
    currentNotif = NotifFrame
    NotifFrame.Size = UDim2.new(0, 280, 0, 45)
    NotifFrame.Position = UDim2.new(1, 10, 0.85, 0)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    NotifFrame.BorderSizePixel = 0
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
-- 5. ЛОГИКА ФАРМА (УМНАЯ)
-- ==========================================
local ITEM_CONFIGS = {
    ["Дерево (Logs)"]   = { match = "Outer", sizeFilter = true },
    ["Уголь (Coal)"]    = { match = "Coal" },
    ["Морсель (Morsel)"]= { match = "Morsel" },
    ["Мясо (Meat)"]     = { match = "Meat" },
    ["Микроволновка"]   = { match = "Broken Microwave", requirePart = "Main" },
    ["Радио"]           = { match = "Old Radio", requirePart = "Main" },
    ["Канистра (Fuel)"] = { match = "Fuel Canister", requirePart = "Main" },
    ["Бочка (Oil)"]     = { match = "Oil Barrel", requirePart = "Main" },
    ["Бинты (Bandage)"] = { match = "Bandage", requirePart = "Handle" }
}

local selectedItemKey = nil

local function getTargetPosition(targetMode)
    if targetMode == "Player" then
        local p = Players.LocalPlayer
        return (p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")) and p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4) or nil
    elseif targetMode == "Campfire" then
        local mainFire = workspace:FindFirstChild("MainFire", true)
        if mainFire then
            local logCyl = mainFire:FindFirstChild("log_Cylinder", true)
            return logCyl and logCyl.CFrame or mainFire:GetPivot()
        end
    elseif targetMode == "Workbench" then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("workbench") or obj.Name:lower():find("grinder") then
                return obj:IsA("Model") and obj:GetPivot() or obj.CFrame
            end
        end
    end
    return nil
end

local function executeFarm(targetMode)
    if not selectedItemKey then
        showNotification("Сначала выберите предмет из списка!")
        return
    end

    local config = ITEM_CONFIGS[selectedItemKey]
    local targetCFrame = getTargetPosition(targetMode)
    local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not hrp or not targetCFrame then
        showNotification("Не удалось найти цель телепортации!")
        return
    end

    -- Умный поиск предметов
    local itemsFound = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == config.match then
            local partToMove = nil

            if config.requirePart then
                if obj:IsA("Model") then partToMove = obj:FindFirstChild(config.requirePart) end
                if obj:IsA("BasePart") and obj.Name == config.requirePart then partToMove = obj end
            else
                if obj:IsA("BasePart") then partToMove = obj
                elseif obj:IsA("Model") then partToMove = obj:FindFirstChildWhichIsA("BasePart") end
            end

            if partToMove then
                -- Mammoth size filter
                if config.sizeFilter and (partToMove.Size.X >= 10 or partToMove.Size.Z >= 10) then continue end
                if not table.find(itemsFound, partToMove) then table.insert(itemsFound, partToMove) end
            end
        end
    end

    if #itemsFound == 0 then
        showNotification("Предметы '" .. selectedItemKey .. "' не найдены!")
        return
    end

    showNotification("Сбор: " .. #itemsFound .. " шт.")

    -- Процесс сбора (телепортации)
    task.spawn(function()
        for _, part in ipairs(itemsFound) do
            if not part or not part.Parent then continue end

            if part:FindFirstChild("BodyPosition") then part.BodyPosition:Destroy() end
            if part:FindFirstChild("BodyGyro") then part.BodyGyro:Destroy() end

            pcall(function()
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
                part.CanCollide = true
            end)

            if targetMode == "Player" then
                part.CFrame = targetCFrame * CFrame.new(math.random(-1, 1) * 1.5, 0, math.random(-1, 1) * 1.5)
            else
                -- Сначала к игроку для захвата контроля над физикой
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

-- ==========================================
-- 6. ИНТЕРФЕЙС ВКЛАДКИ FARM (Выбор + Направление)
-- ==========================================
local FarmPage = pages["Farm"]

-- Верхняя часть (Список предметов с сеткой)
local ItemsFrame = Instance.new("ScrollingFrame", FarmPage)
ItemsFrame.Size = UDim2.new(1, -20, 1, -125)
ItemsFrame.Position = UDim2.new(0, 10, 0, 10)
ItemsFrame.BackgroundTransparency = 1
ItemsFrame.BorderSizePixel = 0
ItemsFrame.ScrollBarThickness = 4
ItemsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y -- ИСПРАВЛЕНИЕ: Авто-скроллинг, больше ничего не обрезается!

local Grid = Instance.new("UIGridLayout", ItemsFrame)
Grid.CellSize = UDim2.new(0.5, -6, 0, 35) -- 2 колонки
Grid.CellPadding = UDim2.new(0, 8, 0, 8)
Grid.SortOrder = Enum.SortOrder.LayoutOrder

local itemsList = {
    "Дерево (Logs)", "Уголь (Coal)", "Морсель (Morsel)", "Мясо (Meat)",
    "Микроволновка", "Радио", "Канистра (Fuel)", "Бочка (Oil)", "Бинты (Bandage)"
}

local itemBtns = {}
for i, itemKey in ipairs(itemsList) do
    local btn = Instance.new("TextButton", ItemsFrame)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = itemKey
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    itemBtns[itemKey] = btn

    btn.MouseButton1Click:Connect(function()
        selectedItemKey = itemKey
        for k, b in pairs(itemBtns) do
            if k == itemKey then
                b.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                b.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                b.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
    end)
end

-- Нижняя часть (Кнопки направлений)
local ActionsFrame = Instance.new("Frame", FarmPage)
ActionsFrame.Size = UDim2.new(1, -20, 0, 110)
ActionsFrame.Position = UDim2.new(0, 10, 1, -115)
ActionsFrame.BackgroundTransparency = 1

local ActLayout = Instance.new("UIListLayout", ActionsFrame)
ActLayout.Padding = UDim.new(0, 5)
ActLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

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

createDestBtn("Телепортировать Выбранное К СЕБЕ", Color3.fromRGB(0, 170, 255), "Player")
createDestBtn("Телепортировать Выбранное К КОСТРУ", Color3.fromRGB(50, 150, 50), "Campfire")
createDestBtn("Телепортировать Выбранное В ДРОБИЛКУ", Color3.fromRGB(150, 50, 50), "Workbench")

-- ==========================================
-- 7. СВЕРТЫВАНИЕ И ЗАКРЫТИЕ
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
-- 8. ИНТРО АНИМАЦИЯ
-- ==========================================
task.spawn(function()
    TweenService:Create(IntroLabel, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 20, 0.1, 0)}):Play()
    task.wait(2.8)
    local tweenOut = TweenService:Create(IntroLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0, -350, 0.1, 0)})
    tweenOut:Play() tweenOut.Completed:Wait()
    IntroLabel:Destroy()
    MainFrame.Visible = true
end)
