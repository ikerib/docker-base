# Docker Base Multi-Platform

Este proyecto genera imágenes Docker para múltiples plataformas (Linux AMD64 y ARM64/Mac) por defecto.

## Configuración inicial

Antes de construir imágenes multi-plataforma, necesitas configurar Docker Buildx:

```bash
make setup-buildx
```

## Comandos disponibles

### Construcción multi-plataforma (por defecto)
```bash
make build
```

### Construcción local (solo Linux AMD64)
```bash
make build-local
```

### Push multi-plataforma (por defecto)
Para construir y subir las imágenes para ambas plataformas:
```bash
make push
```

### Push local
Para subir imágenes construidas localmente:
```bash
make push-local
```

## Plataformas soportadas

- `linux/amd64` - Para servidores Linux x86_64
- `linux/arm64` - Para Mac M1/M2 y servidores ARM64

## Cambios realizados

1. **Makefile modificado** para soportar Docker Buildx por defecto
2. **Dockerfiles actualizados** para detectar automáticamente la arquitectura en la configuración LDAP
3. **Multi-arquitectura por defecto** en los comandos principales

## Workflow recomendado

1. Configurar buildx una sola vez: `make setup-buildx`
2. Para desarrollo y distribución: `make build` (siempre multi-plataforma)
3. Para subir: `make push` (construye y sube ambas arquitecturas)
