class ATankGameMode : AGameMode
{
    default DefaultPawnClass = ATankPawn::StaticClass();

    AMapManager MapManager;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        MapManager = Cast<AMapManager>(SpawnActor(AMapManager::StaticClass()));
    }
};