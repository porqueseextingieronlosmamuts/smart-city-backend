def estado_semaforo(valor, umbral_verde, umbral_amarillo, mayor_es_mejor=True):
    """verde/amarillo/rojo según si el valor está sobre o bajo los umbrales."""
    if valor is None:
        return "rojo"  # sin datos = rojo, no se asume lo mejor
    if mayor_es_mejor:
        if valor >= umbral_verde:
            return "verde"
        if valor >= umbral_amarillo:
            return "amarillo"
        return "rojo"
    else:
        if valor <= umbral_verde:
            return "verde"
        if valor <= umbral_amarillo:
            return "amarillo"
        return "rojo"


def estado_general(*estados: str) -> str:
    if "rojo" in estados:
        return "rojo"
    if "amarillo" in estados:
        return "amarillo"
    return "verde"
