class ACanDamageActor : AActor
{
    UFUNCTION()
    bool CanDamagedByBullet(ABulletActor Bullet, UPrimitiveComponent HitComp)
    {
        UWallSpriteComponent WallSpriteComp = Cast<UWallSpriteComponent>(HitComp);
        if (IsValid(WallSpriteComp))
        {
            return WallSpriteComp.Hited();
        }

        return true;
    }
};