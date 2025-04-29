class ATankGameMode : AGameMode
{
    default DefaultPawnClass = ATankPawn::StaticClass();

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
    }
};