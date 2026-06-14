-- Проверяем, если хаб уже запущен, чтобы не спавнить копии
if game:GetService("CoreGui"):FindFirstChild("NightsInForestHub") then
    game:GetService("CoreGui"):FindFirstChild("NightsInForestHub"):Destroy()
end

-- Основные сервисы
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NightsInForestHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Переменные для логики автоматического сбора брёвен
local currentTargetMode = "Player" -- "Player", "Campfire", "Workbench"
local farmActive = false

-- ==========================================
-- 1. АНИМИРОВАННОЕ ПРИВЕТСТВИЕ (ВЫЕЗЖАЮЩАЯ НАДПИСЬ)
-- ==========================================
local IntroLabel = Instance.new("TextLabel")
IntroLabel.Size = UIDim2.new(0, 300, 0, 50)
IntroLabel.Position = UIDim2.new(0, -350, 0.1, 0) -- Старт за экраном
IntroLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
IntroLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroLabel.Text = "Хаб успешно запущен!"
IntroLabel.Font = Enum.Font.GothamBold
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
local BASE_WIDTH, BASE_HEIGHT = 550, 350
MainFrame.Size = UIDim2.new(0, BASE_WIDTH, 0, BASE_HEIGHT)
MainFrame.Position = UIDim2.new(0.5, -BASE_WIDTH/2, 0.5, -BASE_HEIGHT/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false -- Скрыто до окончания анимации интро
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Верхняя панель (Топбар)
local TopBar = Instance.new("Frame")
TopBar.Size = UIDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UIDim2.new(0, 250, 1, 0)
Title.Position = UIDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "99 Nights Forest Hub v1.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Кнопка Закрыть
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UIDim2.new(0, 30, 0, 30)
CloseBtn.Position = UIDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Кнопка Свернуть
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UIDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UIDim2.new(1, -75, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

-- Панель бокового меню (Вкладки)
local SideBar = Instance.new("Frame")
SideBar.Size = UIDim2.new(0, 120, 1, -40)
SideBar.Position = UIDim2.new(0, 0, 0, 40)
SideBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UIDim2.new(1, -120, 1, -40)
ContentFrame.Position = UIDim2.new(0, 120, 0, 40)
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
-- 3. СОЗДАНИЕ СИСТЕМЫ ВКЛАДОК И СТРАНИЦ
-- ==========================================
local tabs = {"Home", "Settings", "Farm", "AFK", "TP"}
local pages = {}
local tabButtons = {}

local function createTab(tabName, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UIDim2.new(0, 105, 0, 32)
    TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 14
    TabBtn.LayoutOrder = order
    TabBtn.Parent = SideBar
    
    local TabBtnCorner = Instance.new("UICorner")
    TabBtnCorner.CornerRadius = UDim.new(0, 6)
    TabBtnCorner.Parent = TabBtn

    local Page = Instance.new("Frame")
    Page.Size = UIDim2.new(1, 0, 1, 0)
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

-- Делаем Home активной по умолчанию
pages["Home"].Visible = true
tabButtons["Home"].TextColor3 = Color3.fromRGB(0, 170, 255)

-- ==========================================
-- 4. НАПОЛНЕНИЕ СТРАНИЦЫ HOME
-- ==========================================
local HomeLabel = Instance.new("TextLabel")
HomeLabel.Size = UIDim2.new(1, -20, 1, -20)
HomeLabel.Position = UIDim2.new(0, 10, 0, 10)
HomeLabel.BackgroundTransparency = 1
HomeLabel.Text = "Добро пожаловать в 99 Nights in the Forest Hub!\n\nРазработчик: Кирилл\nВерсия: 1.0\n\nИспользуй вкладки слева для конфигурации."
HomeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
HomeLabel.Font = Enum.Font.Gotham
HomeLabel.TextSize = 14
HomeLabel.TextWrapped = true
HomeLabel.TextYAlignment = Enum.TextYAlignment.Top
HomeLabel.TextXAlignment = Enum.TextXAlignment.Left
HomeLabel.Parent = pages["Home"]

-- ==========================================
-- 5. НАПОЛНЕНИЕ СТРАНИЦЫ SETTINGS (МАСШТАБ)
-- ==========================================
local SettingsLabel = Instance.new("TextLabel")
SettingsLabel.Size = UIDim2.new(1, -20, 0, 30)
SettingsLabel.Position = UIDim2.new(0, 10, 0, 10)
SettingsLabel.BackgroundTransparency = 1
SettingsLabel.Text = "Изменение масштаба окна (например: 0.5, 1, 1.5):"
SettingsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SettingsLabel.Font = Enum.Font.Gotham
SettingsLabel.TextSize = 14
SettingsLabel.TextXAlignment = Enum.TextXAlignment.Left
SettingsLabel.Parent = pages["Settings"]

local ScaleInput = Instance.new("TextBox")
ScaleInput.Size = UIDim2.new(0, 100, 0, 30)
ScaleInput.Position = UIDim2.new(0, 10, 0, 45)
ScaleInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ScaleInput.Text = "1"
ScaleInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ScaleInput.Font = Enum.Font.GothamBold
ScaleInput.TextSize = 14
ScaleInput.Parent = pages["Settings"]

local ScaleCorner = Instance.new("UICorner")
ScaleCorner.CornerRadius = UDim.new(0, 6)
ScaleCorner.Parent = ScaleInput

ScaleInput.FocusLost:Connect(function(enterPressed)
    local num = tonumber(ScaleInput.Text)
    if num and num > 0.3 and num < 3 then
        local newWidth = BASE_WIDTH * num
        local newHeight = BASE_HEIGHT * num
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(MainFrame, tweenInfo, {Size = UIDim2.new(0, newWidth, 0, newHeight)}):Play()
    else
        ScaleInput.Text = "1"
    end
end)

-- ==========================================
-- 6. НАПОЛНЕНИЕ ВКЛАДКИ FARM (МОМЕНТАЛЬНЫЙ СБОР)
-- ==========================================
local FarmPage = pages["Farm"]

-- Заголовок выбора режима
local ModeLabel = Instance.new("TextLabel")
ModeLabel.Size = UIDim2.new(1, -20, 0, 20)
ModeLabel.Position = UIDim2.new(0, 10, 0, 10)
ModeLabel.BackgroundTransparency = 1
ModeLabel.Text = "Куда телепортировать бревна (Outer):"
ModeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ModeLabel.Font = Enum.Font.Gotham
ModeLabel.TextSize = 14
ModeLabel.TextXAlignment = Enum.TextXAlignment.Left
ModeLabel.Parent = FarmPage

-- Сетка/Список для кнопок выбора направления
local BtnContainer = Instance.new("Frame")
BtnContainer.Size = UIDim2.new(1, -20, 0, 40)
BtnContainer.Position = UIDim2.new(0, 10, 0, 35)
BtnContainer.BackgroundTransparency = 1
BtnContainer.Parent = FarmPage

local BtnLayout = Instance.new("UIListLayout")
BtnLayout.FillDirection = Enum.FillDirection.Horizontal
BtnLayout.Padding = UDim.new(0, 10)
BtnLayout.Parent = BtnContainer

local function styleSelectBtn(btn, text)
    btn.Size = UIDim2.new(0, 110, 0, 35)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    local crn = Instance.new("UICorner")
    crn.CornerRadius = UDim.new(0, 6)
    crn.Parent = btn
end

local TargetPlayerBtn = Instance.new("TextButton")
styleSelectBtn(TargetPlayerBtn, "К Игроку")
TargetPlayerBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
TargetPlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetPlayerBtn.Parent = BtnContainer

local TargetCampfireBtn = Instance.new("TextButton")
styleSelectBtn(TargetCampfireBtn, "К Костру")
TargetCampfireBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TargetCampfireBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
TargetCampfireBtn.Parent = BtnContainer

local TargetWorkbenchBtn = Instance.new("TextButton")
styleSelectBtn(TargetWorkbenchBtn, "К Верстаку")
TargetWorkbenchBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TargetWorkbenchBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
TargetWorkbenchBtn.Parent = BtnContainer

local function updateTargetVisuals(activeBtn)
    TargetPlayerBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TargetPlayerBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TargetCampfireBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TargetCampfireBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TargetWorkbenchBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TargetWorkbenchBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    
    activeBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

TargetPlayerBtn.MouseButton1Click:Connect(function() currentTargetMode = "Player" updateTargetVisuals(TargetPlayerBtn) end)
TargetCampfireBtn.MouseButton1Click:Connect(function() currentTargetMode = "Campfire" updateTargetVisuals(TargetCampfireBtn) end)
TargetWorkbenchBtn.MouseButton1Click:Connect(function() currentTargetMode = "Workbench" updateTargetVisuals(TargetWorkbenchBtn) end)

-- Главный Тумблер Включения Автофарма
local ToggleFarmBtn = Instance.new("TextButton")
ToggleFarmBtn.Size = UIDim2.new(0, 200, 0, 45)
ToggleFarmBtn.Position = UIDim2.new(0, 10, 0, 95)
ToggleFarmBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleFarmBtn.Text = "Auto Farm: OFF"
ToggleFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleFarmBtn.Font = Enum.Font.GothamBold
ToggleFarmBtn.TextSize = 15
ToggleFarmBtn.Parent = FarmPage

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleFarmBtn

ToggleFarmBtn.MouseButton1Click:Connect(function()
    farmActive = not farmActive
    if farmActive then
        ToggleFarmBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        ToggleFarmBtn.Text = "Auto Farm: ON"
    else
        ToggleFarmBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleFarmBtn.Text = "Auto Farm: OFF"
    end
end)

-- ==========================================
-- 7. МАТЕМАТИКА И ЛОГИКА ТЕЛЕПОРТАЦИИ ОБЪЕКТОВ
-- ==========================================
local function getTargetPosition()
    local player = game:GetService("Players").LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end

    if currentTargetMode == "Player" then
        return player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
        
    elseif currentTargetMode == "Campfire" then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name == "log_Cylinder" or obj.Name == "Meshes/log_Cylinder") then
                return obj.CFrame + Vector3.new(0, 2, 0)
            end
        end
        
    elseif currentTargetMode == "Workbench" then
        local leftPart, rightPart
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                if obj.Name == "GrindersLeft" then leftPart = obj end
                if obj.Name == "GrindersRight" then rightPart = obj end
            end
            if leftPart and rightPart then break end
        end
        
        if leftPart and rightPart then
            -- Средняя точка между левым и правым парт-компонентами
            return CFrame.new((leftPart.Position + rightPart.Position) / 2)
        end
    end
    return player.Character.HumanoidRootPart.CFrame
end

local function collectAllLogs()
    local targetCFrame = getTargetPosition()
    if not targetCFrame then return end

    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("BasePart") and item.Name == "Outer" then
            -- Мгновенный перенос в параллельном потоке, чтобы обработать всё одновременно
            task.spawn(function()
                if item:FindFirstChild("BodyPosition") then item.BodyPosition:Destroy() end
                if item:FindFirstChild("BodyGyro") then item.BodyGyro:Destroy() end
                item.CFrame = targetCFrame
            end)
        end
    end
end

-- Потоковый цикл проверки
task.spawn(function()
    while true do
        task.wait(0.3) -- Скорость проверки карты
        if farmActive then
            collectAllLogs()
        end
    end
end)

-- ==========================================
-- 8. СВЕРТЫВАНИЕ И ЗАКРЫТИЕ ХАБА
-- ==========================================
CloseBtn.MouseButton1Click:Connect(function()
    farmActive = false
    ScreenGui:Destroy()
end)

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ContentFrame.Visible = false
        SideBar.Visible = false
        MainFrame.Size = UIDim2.new(0, MainFrame.Size.X.Offset, 0, 40)
        MinimizeBtn.Text = "+"
    else
        local num = tonumber(ScaleInput.Text) or 1
        MainFrame.Size = UIDim2.new(0, BASE_WIDTH * num, 0, BASE_HEIGHT * num)
        ContentFrame.Visible = true
        SideBar.Visible = true
        MinimizeBtn.Text = "-"
    end
end)

-- ==========================================
-- 9. СТАРТ АНИМАЦИИ
-- ==========================================
task.spawn(function()
    local tweenIn = TweenService:Create(IntroLabel, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UIDim2.new(0, 20, 0.1, 0)
    })
    tweenIn:Play()
    tweenIn.Completed:Wait()
    
    task.wait(2)
    
    local tweenOut = TweenService:Create(IntroLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UIDim2.new(0, -350, 0.1, 0)
    })
    tweenOut:Play()
    tweenOut.Completed:Wait()
    
    IntroLabel:Destroy()
    
    MainFrame.Visible = true
    MainFrame.ClipsDescendants = true
end)
