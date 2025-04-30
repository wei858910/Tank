class AMapManager : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    protected float LeftCornerPositionX = -208.;
    protected float LeftCornerPositionZ = 208;
    protected float UnitSize = 32.;
    protected int32 BrickNums = 14;
    protected float BrickWidth = 16.;
    protected float HalfBrickWidth = 8.;

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

    void SpawnWallFromPlayer(FVector Location, EWallType Type = EWallType::EWT_RedWall)
    {
        for (int32 i = 0; i < 4; ++i)
        {
            UWallSpriteComponent Wall = Cast<UWallSpriteComponent>(CreateComponent(UWallSpriteComponent::StaticClass()));
            Wall.SetWallType(Type);
            Wall.AttachToComponent(Root, AttachmentRule = EAttachmentRule::SnapToTarget);
            Wall.SetWorldLocation(FVector(Location.X + (i % 2) * BrickWidth - HalfBrickWidth, 1., Location.Z - (i / 2) * BrickWidth + HalfBrickWidth));
        }
    }
};