--[[
    👻 TITANIUM GHOST v5.0 (VOID WALK EDITION)
    • True Invisibility: Gerçek beden Void'e gider, kimse seni göremez.
    • Ghost Control: Yerel bir klon ile gezersin.
    • Teleport Back: Kapattığında gerçek beden klonun yerine gelir.
    • Reduced Bloom: Göz yormayan hafif parlama.
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // AYARLAR \\ --
local VOID_POSITION = Vector3.new(0, 10000, 0) -- Gerçek bedenin saklanacağı güvenli yükseklik
local GHOST_COLOR = Color3.fromRGB(100, 255, 255) -- Hayalet rengi (Buz Mavisi)
local GHOST_TRANSPARENCY = 0.4

-- // 1. TEMİZLİK \\ --
local guiName = "TitaniumGhost_v5"
for _, gui in pairs(CoreGui:GetChildren()) do
    if gui.Name == guiName then gui:Destroy() end
end
if gethui then
    for _, gui in pairs(gethui():GetChildren()) do
        if gui.Name == guiName then gui:Destroy() end
    end
end

-- // 2. GUI OLUŞTURMA \\ --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

local MainButton = Instance.new("TextButton")
MainButton.Name = "INVISIBLE"
MainButton.Parent = ScreenGui
MainButton.AnchorPoint = Vector2.new(0.5, 0.5)
MainButton.Position = UDim2.new(0.5, 0, 0.35, 0)
MainButton.Size = UDim2.new(0, 0, 0, 0)
MainButton.BackgroundColor3 = Color3.fromRGB(11, 18, 21) -- Daha koyu gri zemin
MainButton.BackgroundTransparency = 0
MainButton.Text = ""
MainButton.AutoButtonColor = false

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = MainButton

-- Kontur (Stroke) - Parlaklığı Azaltıldı
local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainButton
UIStroke.Color = Color3.fromRGB(150, 150, 150) -- Parlak beyaz yerine gri
UIStroke.Thickness = 1.6 -- İncelttik
UIStroke.Transparency = 0.6 -- Biraz daha şeffaf
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Gölge (Glow) - Ciddi oranda azaltıldı
local Shadow = Instance.new("ImageLabel")
Shadow.Parent = MainButton
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(1.2, 0, 1.2, 0) -- Boyutu küçüldü
Shadow.BackgroundTransparency = 0.8
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.fromRGB(255, 255, 255)
Shadow.ImageTransparency = 1 -- ÇOK HAFİF bir parlama (Eskisi 0.5 idi)
Shadow.ZIndex = -1

local Label = Instance.new("TextLabel")
Label.Parent = MainButton
Label.Size = UDim2.new(1, 0, 1, 0)
Label.BackgroundTransparency = 1
Label.Text = "INVISIBLE"
Label.TextColor3 = Color3.fromRGB(200, 200, 200)
Label.Font = Enum.Font.GothamBold
Label.TextSize = 16
Label.TextTransparency = 0

-- // 3. DRAGGING SİSTEMİ \\ --
local dragging, dragInput, dragStart, startPos
local isMoved = false

local function Update(input)
    local delta = input.Position - dragStart
    MainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    if delta.Magnitude > 5 then isMoved = true end
end

MainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        isMoved = false
        dragStart = input.Position
        startPos = MainButton.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)

MainButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then Update(input) end end)

-- // 4. GÖRÜNMEZLİK & KLON MANTIĞI \\ --
local isGhostMode = false
local RealCharacter = nil
local GhostCharacter = nil
local GhostConnection = nil

local function EnableGhostMode()
    RealCharacter = LocalPlayer.Character
    if not RealCharacter or not RealCharacter:FindFirstChild("HumanoidRootPart") then return end
    
    RealCharacter.Archivable = true -- Klonlamak için izin ver
    local CurrentCFrame = RealCharacter.HumanoidRootPart.CFrame
    
    -- 1. KLONU YARAT (Senin kontrol edeceğin beden)
    GhostCharacter = RealCharacter:Clone()
    GhostCharacter.Name = "Ghost_" .. LocalPlayer.Name
    GhostCharacter.Parent = Workspace
    
    -- Klonun rengini ve şeffaflığını ayarla (Hayalet Efekti)
    for _, part in pairs(GhostCharacter:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = GHOST_COLOR
            part.Transparency = GHOST_TRANSPARENCY
            part.Material = Enum.Material.ForceField -- Daha havalı görünüm
            part.CanCollide = false -- Duvardan geçebilmek için (İstersen true yap)
            if part.Name == "HumanoidRootPart" then part.Transparency = 1 end
        elseif part:IsA("Decal") then
            part:Destroy() -- Yüzü sil
        end
    end
    
    -- 2. GERÇEK BEDENİ VOID'E GÖNDER VE KİLİTLE (ANCHOR)
    RealCharacter.HumanoidRootPart.CFrame = CFrame.new(VOID_POSITION)
    RealCharacter.HumanoidRootPart.Anchored = true -- Havada asılı kalsın, düşmesin
    
    -- 3. KONTROLÜ KLONA VER
    LocalPlayer.Character = GhostCharacter
    Camera.CameraSubject = GhostCharacter.Humanoid
    
    -- GUI Güncelleme
    TweenService:Create(MainButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(11, 18, 21)}):Play() -- Koyu Yeşil
    TweenService:Create(UIStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(0, 66, 37)}):Play()
    Label.Text = "INVISIBLE"
    isGhostMode = true
end

local function DisableGhostMode()
    if not isGhostMode or not GhostCharacter then return end
    
    -- 1. KLONUN KONUMUNU AL
    local TargetCFrame = GhostCharacter.HumanoidRootPart.CFrame
    
    -- 2. KLONU SİL
    GhostCharacter:Destroy()
    GhostCharacter = nil
    
    -- 3. GERÇEK BEDENİ GERİ GETİR
    if RealCharacter and RealCharacter:FindFirstChild("HumanoidRootPart") then
        RealCharacter.HumanoidRootPart.Anchored = false -- Kilidi aç
        RealCharacter.HumanoidRootPart.CFrame = TargetCFrame -- Klonun olduğu yere ışınla
        LocalPlayer.Character = RealCharacter
        Camera.CameraSubject = RealCharacter.Humanoid
    end
    
    -- GUI Güncelleme
    TweenService:Create(MainButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(11, 18, 21)}):Play()
    TweenService:Create(UIStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(128, 0, 32)}):Play()
    Label.Text = "INVISIBLE"
    isGhostMode = false
end

-- // 5. TIKLAMA OLAYI \\ --
MainButton.MouseButton1Up:Connect(function()
    if isMoved then isMoved = false return end -- Sürüklediyse tıklama
    
    if isGhostMode then
        DisableGhostMode()
    else
        EnableGhostMode()
    end
end)

-- Öldüğünde sistemi sıfırla
LocalPlayer.CharacterAdded:Connect(function(newChar)
    if isGhostMode then
        isGhostMode = false
        if GhostCharacter then GhostCharacter:Destroy() end
        -- GUI Reset
        TweenService:Create(MainButton, TweenInfo.new(0), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        Label.Text = "INVISIBLE"
    end
end)

-- // BAŞLANGIÇ ANİMASYONU \\ --
local function Intro()
    TweenService:Create(MainButton, TweenInfo.new(0.8, Enum.EasingStyle.Elastic), {Size = UDim2.new(0, 180, 0, 50)}):Play()
end
Intro()
