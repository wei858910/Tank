enum EWallType
{
    EWT_None,
    EWT_RedWall,
    EWT_Iron,
    EWT_Grass,
    EWT_Water,
    EWT_Ice
}

class UWallSpriteComponent : UPaperSpriteComponent
{
    protected EWallType WallType = EWallType::EWT_None;

    EWallType GetCurrentWallType()
    {
        return WallType;
    }

    void SetWallType(EWallType Type)
    {
        if (WallType == Type)
        {
            return;
        }

        FString WallSpritePath;

        switch (Type)
        {
            case EWallType::EWT_None:
                return;

            case EWallType::EWT_RedWall:
                WallSpritePath = "/Game/Textures/red_wall_Sprite.red_wall_Sprite";
                break;

            case EWallType::EWT_Iron:
                WallSpritePath = "/Game/Textures/iron_wall_Sprite.iron_wall_Sprite";
                break;

            case EWallType::EWT_Grass:
                WallSpritePath = "/Game/Textures/grass_wall_Sprite.grass_wall_Sprite";
                break;

            case EWallType::EWT_Water:
                WallSpritePath = "/Game/Textures/water_wall_Sprite.water_wall_Sprite";
                break;

            case EWallType::EWT_Ice:
                WallSpritePath = "/Game/Textures/ice_wall_Sprite.ice_wall_Sprite";
                break;
        }

        UPaperSprite WallSprite = Cast<UPaperSprite>(LoadObject(nullptr, WallSpritePath));
        if (IsValid(WallSprite))
        {
            SetSprite(WallSprite);
        }

        WallType = Type;
    }

    float GetSelfYPosition()
    {
        if (WallType == EWallType::EWT_Grass)
        {
            return 20.;
        }
        else if (WallType == EWallType::EWT_Ice)
        {
            return -20.;
        }

        return 1.;
    }

    bool Hited()
    {
        if (WallType == EWallType::EWT_Iron)
        {
            return true;
        }
        else if (WallType == EWallType::EWT_Water)
        {
            return false;
        }

        DestroyComponent(this);
        return true;
    }
};