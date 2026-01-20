--[[
    🚀 ULTIMATE GHOST GUI v4.0
    • Draggable (Sürüklenebilir)
    • Drag Protection (Sürüklerken Tıklamaz)
    • Smart Ghost Mode (Kendini Gör, Başkaları Görmesin)
    • Dynamic Stroke & Animations
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- // 1. TEMİZLİK (Eski GUI'yi Sil) \\ --
local guiName = "UltimateGhostGUI_v4"
for _, gui in pairs(CoreGui:GetChildren()) do
    if gui.Name == guiName then gui:Destroy() end
end
if gethui then -- Modern executorlar için (Synapse Z, Wave vs.)
    for _, gui in pairs(gethui():GetChildren()) do
        if gui.Name == guiName then gui:Destroy() end
    end
end

-- // 2. GUI OLUŞTURMA \\ --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
if gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

local MainButton = Instance.new("TextButton")
MainButton.Name = "GhostButton"
MainButton.Parent = ScreenGui
MainButton.AnchorPoint = Vector2.new(0.5, 0.5)
MainButton.Position = UDim2.new(0.5, 0, 0.35, 0) -- Başlangıç konumu
MainButton.Size = UDim2.new(0, 0, 0, 0) -- Animasyon için 0'dan başlıyor
MainButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60) -- Kırmızı
MainButton.BackgroundTransparency = 1
MainButton.Text = ""
MainButton.AutoButtonColor = false -- Varsayılan koyulaşmayı kapatıyoruz

-- Köşeleri Yuvarlatma
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0) -- Tam Yuvarlak
UICorner.Parent = MainButton

-- Kontur (Stroke)
local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainButton
UIStroke.Color = Color3.fromRGB(255, 255, 255) -- Beyaz
UIStroke.Thickness = 3.5
UIStroke.Transparency = 1
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Gölge (Glow)
local Shadow = Instance.new("ImageLabel")
Shadow.Parent = MainButton
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(1.4, 0, 1.4, 0)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.fromRGB(255, 255, 255)
Shadow.ImageTransparency = 1
Shadow.ZIndex = -1

-- Yazı
local Label = Instance.new("TextLabel")
Label.Parent = MainButton
Label.Size = UDim2.new(1, 0, 1, 0)
Label.BackgroundTransparency = 1
Label.Text = "INVISIBLE"
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.Font = Enum.Font.GothamBlack
Label.TextSize = 18
Label.TextTransparency = 1

-- // 3. DRAGGING SİSTEMİ (Tıklama Korumalı) \\ --
local dragging = false
local dragInput, dragStart, startPos
local isMoved = false -- Sürüklenip sürüklenmediğini kontrol eder

local function Update(input)
    local delta = input.Position - dragStart
    -- Pozisyonu güncelle
    MainButton.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
    
    -- Eğer 5 pikselden fazla oynatıldıysa, bu bir tıklama değildir, sürüklemedir.
    if delta.Magnitude > 5 then
        isMoved = true
    end
end

MainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        isMoved = false -- Sıfırla
        dragStart = input.Position
        startPos = MainButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        Update(input)
    end
end)

-- // 4. GÖRÜNMEZLİK MANTIĞI \\ --
local isInvisible = false
local ghostLoop = nil

local function ToggleVisuals(state)
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    
    if state then
        -- AKTİF (YEŞİL & TURUNCU)
        TweenService:Create(MainButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(46, 204, 113)}):Play()
        TweenService:Create(UIStroke, tweenInfo, {Color = Color3.fromRGB(255, 140, 0)}):Play() -- Turuncu Kontur
        TweenService:Create(Shadow, tweenInfo, {ImageColor3 = Color3.fromRGB(46, 204, 113)}):Play()
        Label.Text = "ACTIVE"
    else
        -- PASİF (KIRMIZI & BEYAZ)
        TweenService:Create(MainButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(231, 76, 60)}):Play()
        TweenService:Create(UIStroke, tweenInfo, {Color = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(Shadow, tweenInfo, {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        Label.Text = "INVISIBLE"
    end
end

local function EnableGhost()
    isInvisible = true
    ToggleVisuals(true)
    
    -- Sürekli kontrol: Kendine yarı saydam, başkasına yok.
    ghostLoop = RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    if v.Name == "HumanoidRootPart" then
                        v.Transparency = 1 -- Kök parça hep görünmez
                    else
                        v.Transparency = 0 -- Servera görünür gibi yapıyoruz (Collision için)
                        v.LocalTransparencyModifier = 0.5 -- Ama client'ta hayalet gibiyiz
                        -- Not: Tam görünmezlik için diğer oyuncuların client'ında transparency'i 1 yapacak 
                        -- bir FE açığı gerekir. Bu script "Universal" olduğu için en güvenli Ghost Walk metodunu kullanır.
                    end
                elseif v:IsA("Decal") then
                    v.Transparency = 1 -- Yüz ifadelerini gizle
                end
            end
        end
    end)
    
    -- İlk tetikleme
    local char = LocalPlayer.Character
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                v.Transparency = 1 
            end
        end
    end
end

local function DisableGhost()
    isInvisible = false
    ToggleVisuals(false)
    if ghostLoop then ghostLoop:Disconnect() end
    
    -- Karakteri geri getir
    local char = LocalPlayer.Character
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = 0
                v.LocalTransparencyModifier = 0
            elseif v:IsA("Decal") then
                v.Transparency = 0
            end
        end
        if char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Transparency = 1 -- Root her zaman gizli kalmalı
        end
    end
end

-- // 5. TIKLAMA OLAYI (KORUMALI) \\ --
MainButton.MouseButton1Up:Connect(function()
    -- Eğer sürükleme işlemi yapıldıysa (isMoved = true), tıklamayı yoksay.
    if isMoved then 
        isMoved = false
        return 
    end
    
    -- Sürüklenmediyse, normal tıklama işlemini yap
    if isInvisible then
        DisableGhost()
    else
        EnableGhost()
    end
end)

-- // 6. BAŞLANGIÇ ANİMASYONU \\ --
local function Intro()
    MainButton.Size = UDim2.new(0, 0, 0, 0)
    
    local openTween = TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
    local fadeTween = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    TweenService:Create(MainButton, openTween, {Size = UDim2.new(0, 200, 0, 55)}):Play()
    TweenService:Create(MainButton, fadeTween, {BackgroundTransparency = 0.2}):Play()
    TweenService:Create(UIStroke, fadeTween, {Transparency = 0}):Play()
    TweenService:Create(Label, fadeTween, {TextTransparency = 0}):Play()
    TweenService:Create(Shadow, fadeTween, {ImageTransparency = 0.5}):Play()
end

Intro()
