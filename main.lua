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

-- ==========================================
-- 1. АНИМИРОВАННОЕ ПРИВЕТСТВИЕ (ВЫЕЗЖАЮЩАЯ НАДПИСЬ)
-- ==========================================
local IntroLabel = Instance.new("TextLabel")
IntroLabel.Size = UIDim2.new(0, 300, 0, 50)
-- Начальная позиция: за левой границей экрана
IntroLabel.Position = UIDim2.new(0, -350, 0.1, 0)
IntroLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
IntroLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroLabel.Text = "Хаб успешно запущен!"
IntroLabel.Font = Enum.Font.GothamBold
IntroLabel.TextSize = 18
IntroLabel.BorderSizePixel = 0
IntroLabel.Parent = ScreenGui

-- Скругление для приветствия
local IntroCorner = Instance.new("UICorner")
IntroCorner.CornerRadius = UDim.new(0, 8)
IntroCorner.Parent = IntroLabel

-- Градиент для красоты
local IntroGradient = Instance.new("UIGradient")
IntroGradient.Color = ColorSequence.new(Color3.fromRGB(0, 170, 255), Color3.fromRGB(0, 85, 255))
IntroGradient.Parent = IntroLabel

-- ==========================================
-- 2. ГЛАВНОЕ ОКНО ХАБА
-- ==========================================
local MainFrame = Instance.new("Frame")
-- Базовый размер хаба, который мы будем масштабировать
local BASE_WIDTH, BASE_HEIGHT = 550, 350
MainFrame.Size = UIDim2.new(0, BASE_WIDTH, 0, BASE_HEIGHT)
MainFrame.Position = UIDim2.new(0.5, -BASE_WIDTH/2, 0.5, -BASE_HEIGHT/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false -- Скрыто, пока идет интро
MainFrame.Active = true
MainFrame.Draggable = true -- Позволяет перетаскивать окно мышкой/пальцем
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
Title.Size = UIDim2.new(0, 200, 1, 0)
Title.Position = UIDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "99 Nights Forest Hub"
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

-- Контейнер для страниц
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UIDim2.new(1, -120, 1, -40)
ContentFrame.Position = UIDim2.new(0, 120, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- UI List для автоматического выстраивания кнопок вкладок
local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 5)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent = SideBar

-- Padding сверху для бокового меню
local SidePadding = Instance.new("UIPadding")
SidePadding.PaddingTop = UDim.new(0, 10)
SidePadding.Parent = SideBar

-- ==========================================
-- 3. СОЗДАНИЕ СИСТЕМЫ ВКЛАДОК И СТРАНИЦ
-- ==========================================
local tabs = {"Home", "Settings", "Farm", "AFK", "TP"}
local pages = {}
local activeTab = nil

local function createTab(tabName, order)
    -- Кнопка во вкладках
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

    -- Страница под эту вкладку
    local Page = Instance.new("Frame")
    Page.Size = UIDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = ContentFrame
    
    pages[tabName] = Page

    -- Логика переключения
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        for _, b in pairs(SideBar:GetChildren()) do 
            if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(180, 180, 180) end 
        end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
    end)
end

for i, tabName in ipairs(tabs) do
    createTab(tabName, i)
end

-- Делаем Home активной по умолчанию
pages["Home"].Visible = true
SideBar:FindFirstChild("Home").TextColor3 = Color3.fromRGB(0, 170, 255)

-- ==========================================
-- 4. НАПОЛНЕНИЕ СТРАНИЦЫ HOME
-- ==========================================
local HomeLabel = Instance.new("TextLabel")
HomeLabel.Size = UIDim2.new(1, -20, 1, -20)
HomeLabel.Position = UIDim2.new(0, 10, 0, 10)
HomeLabel.BackgroundTransparency = 1
HomeLabel.Text = "Добро пожаловать в 99 Nights in the Forest Hub!\n\nРазработчик: Кирил\nВерсия: 1.0\n\nИспользуйте вкладки слева для управления функциями."
HomeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
HomeLabel.Font = Enum.Font.Gotham
HomeLabel.TextSize = 14
HomeLabel.TextWrapped = true
HomeLabel.TextYAlignment = Enum.TextYAlignment.Top
HomeLabel.TextXAlignment = Enum.TextXAlignment.Left
HomeLabel.Parent = pages["Home"]

-- ==========================================
-- 5. НАПОЛНЕНИЕ СТРАНИЦЫ SETTINGS (МАСШТАБИРОВАНИЕ)
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

-- Функция изменения размера всего хаба
ScaleInput.FocusLost:Connect(function(enterPressed)
    local num = tonumber(ScaleInput.Text)
    if num and num > 0.2 and num < 3 then -- Ограничение, чтобы окно не исчезло и не стало гигантским
        -- Высчитываем новый размер на основе базового
        local newWidth = BASE_WIDTH * num
        local newHeight = BASE_HEIGHT * num
        
        -- Плавно анимируем изменение размера хаба
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local sizeTween = TweenService:Create(MainFrame, tweenInfo, {
            Size = UIDim2.new(0, newWidth, 0, newHeight)
        })
        sizeTween:Play()
    else
        ScaleInput.Text = "1" -- Сброс, если ввели ерунду
    end
end)

-- ==========================================
-- 6. КНОПКИ УПРАВЛЕНИЯ И СВЕРТЫВАНИЕ
-- ==========================================
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        -- Сворачиваем: прячем всё, кроме топбара
        ContentFrame.Visible = false
        SideBar.Visible = false
        MainFrame.Size = UIDim2.new(0, MainFrame.Size.X.Offset, 0, 40)
        MinimizeBtn.Text = "+"
    else
        -- Разворачиваем обратно с учетом текущего масштаба в TextBox
        local num = tonumber(ScaleInput.Text) or 1
        MainFrame.Size = UIDim2.new(0, BASE_WIDTH * num, 0, BASE_HEIGHT * num)
        ContentFrame.Visible = true
        SideBar.Visible = true
        MinimizeBtn.Text = "-"
    end
end)

-- ==========================================
-- 7. ЗАПУСК АНИМАЦИИ ПРИВЕТСТВИЯ
-- ==========================================
task.spawn(function()
    -- Выезжает вправо
    local tweenIn = TweenService:Create(IntroLabel, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UIDim2.new(0, 20, 0.1, 0)
    })
    tweenIn:Play()
    tweenIn.Completed:Wait()
    
    task.wait(2.5) -- Висит на экране
    
    -- Уезжает дальше влево назад
    local tweenOut = TweenService:Create(IntroLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UIDim2.new(0, -350, 0.1, 0)
    })
    tweenOut:Play()
    tweenOut.Completed:Wait()
    
    IntroLabel:Destroy() -- Удаляем надпись за ненадобностью
    
    -- Показываем главное окно хаба
    MainFrame.Visible = true
    MainFrame.ClipsDescendants = true
end)
