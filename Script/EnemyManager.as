class AEnemyManager : AActor
{
    protected float LeftCornerPositionX = -208.;
    protected float LeftCornerPositionZ = 208;

    void BeginMatch()
    {
        UPaperSprite TankSprite = Cast<UPaperSprite>(LoadObject(nullptr, "/Game/Textures/Enemy/tankEnemy_Sprite.tankEnemy_Sprite"));

        FVector SpawnPosition;

        for (int32 i = 0; i < 3; ++i)
        {
            if (GetSpawnPosition(SpawnPosition))
            {
                AEnemyActor Enemy = Cast<AEnemyActor>(SpawnActor(AEnemyActor::StaticClass(), SpawnPosition, FRotator(-90., 0., 0.)));
                if (IsValid(Enemy) && IsValid(TankSprite))
                {
                    Enemy.SetTankData(TankSprite, 60.);
                }
            }
        }
    }

    bool GetSpawnPosition(FVector& Position)
    {
        FVector FindPosition(LeftCornerPositionX + 16., 0., LeftCornerPositionZ - 16.);
        for (int32 i = 0; i < 3; i++)
        {
            FHitResult      HitResult;
            FCollisionShape CollisionShape;
            CollisionShape.ShapeType = ECollisionShape::Box;
            CollisionShape.SetBox(FVector(10., 10., 10.));
            FindPosition = FindPosition + FVector::ForwardVector * 5.5 * 21. * i;
            if (!System::SweepSingleByChannel(HitResult, FindPosition, FindPosition, FRotator::ZeroRotator.Quaternion(), ECollisionChannel::ECC_Camera, CollisionShape))
            {
                Position = FindPosition;
                return true;
            }
        }
        return false;
    }

    UFUNCTION()
    void PauseAllEnemyTanks(bool bPause)
    {
        TArray<AEnemyActor> AllEnemyTanks;
        GetAllActorsOfClass(AEnemyActor::StaticClass(), AllEnemyTanks);
        for(auto& Item : AllEnemyTanks)
        {
            Item.PauseSelf(true);
        }
    }

    void BoomAllEnemyTanks()
    {
        TArray<AEnemyActor> AllEnemyTanks;
        GetAllActorsOfClass(AEnemyActor::StaticClass(), AllEnemyTanks);
        for(auto& Item : AllEnemyTanks)
        {
            Item.DestroyActor();
        }
    }
};