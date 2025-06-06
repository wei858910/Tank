class AMapManager : ACanDamageActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    protected float LeftCornerPositionX = -208.;
    protected float LeftCornerPositionZ = 208;
    protected float UnitSize = 32.;
    protected int32 BrickNums = 14;
    protected float BrickWidth = 16.;
    protected float HalfBrickWidth = 8.;
    protected int32 SingleLineCells = 26;
    protected int32 MapGridCells = SingleLineCells * SingleLineCells;

    protected TMap<int32, UWallSpriteComponent> MapData;

    UPROPERTY(DefaultComponent)
    UBoxComponent UpBoxComp;
    default UpBoxComp.SetCollisionProfileName(n"InvisibleWall");
    default UpBoxComp.SetRelativeLocation(FVector(0., 0., 7.5 * UnitSize));
    default UpBoxComp.SetBoxExtent(FVector(7 * UnitSize, 32., 32.));

    UPROPERTY(DefaultComponent)
    UBoxComponent DownBoxComp;
    default DownBoxComp.SetCollisionProfileName(n"InvisibleWall");
    default DownBoxComp.SetRelativeLocation(FVector(0., 0., -7.5 * UnitSize));
    default DownBoxComp.SetBoxExtent(FVector(7 * UnitSize, 32., 32.));

    UPROPERTY(DefaultComponent)
    UBoxComponent LeftBoxComp;
    default LeftBoxComp.SetCollisionProfileName(n"InvisibleWall");
    default LeftBoxComp.SetRelativeLocation(FVector(-7.5 * UnitSize, 0., 0.));
    default LeftBoxComp.SetBoxExtent(FVector(32., 32., 7 * UnitSize));

    UPROPERTY(DefaultComponent)
    UBoxComponent RightBoxComp;
    default RightBoxComp.SetCollisionProfileName(n"InvisibleWall");
    default RightBoxComp.SetRelativeLocation(FVector(7.5 * UnitSize, 0., 0.));
    default RightBoxComp.SetBoxExtent(FVector(32., 32., 7 * UnitSize));

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        DrawGuidLine();
    }

    protected void DrawGuidLine()
    {
        for (int32 i = 0; i < BrickNums; ++i)
        {
            // 画横线
            FVector Start = FVector(LeftCornerPositionX, 0., LeftCornerPositionZ - i * UnitSize);
            FVector End = FVector(LeftCornerPositionX + (BrickNums - 1) * UnitSize, 0., LeftCornerPositionZ - i * UnitSize);
            System::DrawDebugLine(Start, End, FLinearColor::White);

            // 画纵线
            Start = FVector(LeftCornerPositionX + i * UnitSize, 0., LeftCornerPositionZ);
            End = FVector(LeftCornerPositionX + i * UnitSize, 0., LeftCornerPositionZ - (BrickNums - 1) * UnitSize);
            System::DrawDebugLine(Start, End, FLinearColor::White);
        }
    }

    void GetMapGridCoordinate(FVector Location, int32& GridX, int32& GridY)
    {
        GridX = (Location.X - LeftCornerPositionX) / UnitSize;
        GridY = (LeftCornerPositionZ - Location.Z) / UnitSize;
    }

    FVector ComputeEditModeTankPosition(int32 GridX, int32 GridY)
    {
        float X = GridX * UnitSize + LeftCornerPositionX + BrickWidth;
        float Y = LeftCornerPositionZ - GridY * UnitSize - BrickWidth;
        return FVector(X, 0., Y);
    }

    int32 GetGridIndex32(int32 GridX, int32 GridY)
    {
        return GridY * (BrickNums - 1) + GridX;
    }

    int32 GetGridIndex16(int32 GridX, int32 GridY)
    {
        return GridY * (BrickNums - 1) * 2 + GridX;
    }

    void SpawnWallFromPlayer(FVector Location, EWallType Type = EWallType::EWT_RedWall)
    {
        int32 GridX = 0;
        int32 GridY = 0;
        GetMapGridCoordinate(Location, GridX, GridY);
        GridX *= 2;
        GridY *= 2;

        Print(f"({GridX}, {GridY})");
        for (int32 i = 0; i < 4; ++i)
        {
            int32 TempGridX = i % 2;
            int32 TempGridY = i / 2;

            int32 GridIndex = GetGridIndex16(GridX + TempGridX, GridY + TempGridY);
            if (MapData.Contains(GridIndex) && IsValid(MapData[GridIndex]))
            {
                if (Type == EWallType::EWT_None)
                {
                    MapData[GridIndex].DestroyComponent(MapData[GridIndex]);
                    MapData.Remove(GridIndex);
                }
                else
                {
                    MapData[GridIndex].SetWallType(Type);
                }
            }
            else
            {
                UWallSpriteComponent Wall = Cast<UWallSpriteComponent>(CreateComponent(UWallSpriteComponent::StaticClass()));
                Wall.SetWallType(Type);
                Wall.AttachToComponent(Root, AttachmentRule = EAttachmentRule::SnapToTarget);
                Wall.SetWorldLocation(FVector(Location.X + (i % 2) * BrickWidth - HalfBrickWidth, Wall.GetSelfYPosition(), Location.Z - (i / 2) * BrickWidth + HalfBrickWidth));
                // MapData[GridIndex] = Wall;
                MapData.Add(GridIndex, Wall);
            }
        }
    }

    void SaveMapData(const FString& MapName)
    {
        FString MapStr;
        for (int32 i = 0; i < MapGridCells; ++i)
        {
            if (MapData.Contains(i))
            {
                MapStr.Append(FString(f"{int32(MapData[i].GetCurrentWallType())}"));
            }
            else
            {
                MapStr.Append("0");
            }

            if (i != MapGridCells - 1)
            {
                MapStr.Append(",");
            }
        }
        Print(MapStr);

        FFileHelper::SaveStringToFile(MapStr, Paths::ProjectSavedDir() + MapName + ".mp");
    }

    void LoadMapData(const FString& MapName)
    {
        ClearMapData();
        FString MapStr;
        if (FFileHelper::LoadFileToString(MapStr, Paths::ProjectSavedDir() + MapName + ".mp"))
        {
            Print(MapStr);
            TArray<FString> MapFlagArray;
            MapStr.ParseIntoArray(MapFlagArray, ",");
            for (int32 i = 0; i < MapFlagArray.Num(); ++i)
            {
                int32 NumType = String::Conv_StringToInt(MapFlagArray[i]);
                if (NumType != 0)
                {
                    int32 GridX = i % SingleLineCells;
                    int32 GridY = i / SingleLineCells;

                    UWallSpriteComponent Wall = Cast<UWallSpriteComponent>(CreateComponent(UWallSpriteComponent::StaticClass()));
                    Wall.SetWallType(EWallType(NumType));
                    Wall.AttachToComponent(Root, AttachmentRule = EAttachmentRule::SnapToTarget);
                    Wall.SetWorldLocation(FVector(LeftCornerPositionX + GridX * BrickWidth + HalfBrickWidth, Wall.GetSelfYPosition(), LeftCornerPositionZ - GridY * BrickWidth - HalfBrickWidth));
                    // MapData[GridIndex] = Wall;
                    MapData.Add(i, Wall);
                }
            }
        }
    }

    void ClearMapData()
    {
        for (auto Item : MapData)
        {
            Item.Value.DestroyComponent(Item.Value);
        }

        MapData.Reset();
    }
};