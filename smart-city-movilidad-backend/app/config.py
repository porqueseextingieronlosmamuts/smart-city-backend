from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = "mysql+pymysql://root:@localhost:3306/Paraderos"

    sla_completitud_verde: float = 95.0
    sla_completitud_amarillo: float = 90.0

    sla_freshness_verde_dias: int = 10
    sla_freshness_amarillo_dias: int = 15

    sla_unicidad_verde: float = 100.0
    sla_unicidad_amarillo: float = 98.0

    sla_pipeline_verde_seg: int = 180
    sla_pipeline_amarillo_seg: int = 240

    sla_uptime_verde: float = 99.0
    sla_uptime_amarillo: float = 95.0


settings = Settings()
