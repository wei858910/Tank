enum EPowerupItemType
{
    EPIT_Life,
    EPIT_Time,
    EPIT_Chovel,
    EPIT_Boom,
    EPIT_Star,
    EPIT_Helmet
}

class APowerupItem : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    UPaperSpriteComponent ItemRenderComp;
    default ItemRenderComp.SetCollisionProfileName(n"OverlapAll");
    default ItemRenderComp.OnComponentBeginOverlap.AddUFunction(this, n"OnItemBeginOverlap");

    protected EPowerupItemType ItemType;

    UFUNCTION()
    private void OnItemBeginOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int OtherBodyIndex, bool bFromSweep, const FHitResult&in SweepResult)
    {
        ATankPawn TankPawn = Cast<ATankPawn>(OtherActor);
        if (IsValid(TankPawn))
        {
            ATankGameMode TankGameMode = Cast<ATankGameMode>(Gameplay::GetGameMode());
            if (IsValid(TankGameMode))
            {
                TankGameMode.GetSoundManager().PlayGameSound(SoundName::PowerupItemSound);
            }

            switch (ItemType)
            {
                case EPowerupItemType::EPIT_Life:
                    break;
                case EPowerupItemType::EPIT_Time:
                    break;
                case EPowerupItemType::EPIT_Chovel:
                    break;
                case EPowerupItemType::EPIT_Boom:
                    break;
                case EPowerupItemType::EPIT_Star:
                    break;
                case EPowerupItemType::EPIT_Helmet:
                    break;
                default:
                    break;
            }
            DestroyActor();
        }
    }

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
    }

    void SetItemType(EPowerupItemType Type)
    {
        FString      SpritePath = FString(f"/Game/Textures/Item/tankItem{int32(Type)}.tankItem{int32(Type)}");
        UPaperSprite ItemSprite = Cast<UPaperSprite>(LoadObject(nullptr, SpritePath));
        if (IsValid(ItemSprite))
        {
            ItemRenderComp.SetSprite(ItemSprite);
            ItemType = Type;
        }
    }
};