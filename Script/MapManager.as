class AMapManager : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    protected float LeftCornerPositionX = -208.;
    protected float LeftCornerPositionZ = 208;
    protected float UnitSize = 32.;
    protected int32 MapSize = 14;

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
        for (int32 i = 0; i < MapSize; ++i)
        {
            // 画横线
            FVector Start = FVector(LeftCornerPositionX, 0., LeftCornerPositionZ - i * UnitSize);
            FVector End = FVector(LeftCornerPositionX + (MapSize - 1) * UnitSize, 0., LeftCornerPositionZ - i * UnitSize);
            System::DrawDebugLine(Start, End, FLinearColor::White);

            // 画纵线
            Start = FVector(LeftCornerPositionX + i * UnitSize, 0., LeftCornerPositionZ);
            End = FVector(LeftCornerPositionX + i * UnitSize, 0., LeftCornerPositionZ - (MapSize - 1) * UnitSize);
            System::DrawDebugLine(Start, End, FLinearColor::White);
        }
    }

    void SpawnWallFromPlayer(FVector Location)
    {
        Print("生成墙壁");
        UWallSpriteComponent Wall = Cast<UWallSpriteComponent>(CreateComponent(UWallSpriteComponent::StaticClass()));
        Wall.SetWallType(EWallType::EWT_RedWall);
        Wall.AttachToComponent(Root, AttachmentRule = EAttachmentRule::SnapToTarget);
        Wall.SetWorldLocation(Location);
    }
};