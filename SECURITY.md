# 🔒 Política de Seguridad - IDAC

## Versiones Soportadas

Este proyecto está actualmente en su versión inicial. La siguiente tabla muestra las versiones que reciben actualizaciones de seguridad:

| Versión | Soporte |
| ------- | ------- |
| 1.0.x   | ✅ Soportada |

## Medidas de Seguridad Implementadas

### 1. Seguridad del Navegador

#### Content Security Policy (CSP)
```
default-src 'self';
script-src 'self' 'unsafe-inline';
style-src 'self' 'unsafe-inline';
img-src 'self' data:;
font-src 'self';
```

#### Protección contra Clickjacking
- **X-Frame-Options**: DENY
- Previene que la página sea cargada en un iframe

#### Protección contra MIME Sniffing
- **X-Content-Type-Options**: nosniff
- Evita que navegadores interpreten archivos de forma incorrecta

#### XSS Protection
- **X-XSS-Protection**: 1; mode=block
- Habilita filtro XSS del navegador

### 2. Seguridad en el Código

#### JavaScript
- Modo estricto habilitado (`'use strict'`)
- Protección contra clickjacking
- Sanitización de entradas HTML
- Validación de parámetros en funciones
- Prevención de directory traversal en descargas

#### HTML
- Separación de código y contenido
- Sin eventos inline (onclick, etc.) en lo posible
- Uso de atributos `rel="noopener noreferrer"` en enlaces externos

### 3. Gestión de Datos

- **Datos Públicos**: Todos los datos en este repositorio son públicos
- **Sin Credenciales**: No se almacenan credenciales o información sensible
- **Validación de Rutas**: Validación de paths para prevenir directory traversal

### 4. Configuración del Servidor

Si despliegas este proyecto en un servidor web, el archivo `.htaccess` proporciona:

- Headers de seguridad adicionales
- Protección contra inyección SQL
- Deshabilitación de listado de directorios
- Compresión GZIP
- Cache del navegador optimizado
- Protección de archivos sensibles

## Reportar una Vulnerabilidad

Si descubres una vulnerabilidad de seguridad, por favor:

### NO:
- ❌ Abras un issue público en GitHub
- ❌ Publiques la vulnerabilidad en redes sociales
- ❌ Explotes la vulnerabilidad

### SÍ:
- ✅ Contacta a la Universidad de Costa Rica - Escuela de Estadística
- ✅ Proporciona detalles técnicos de la vulnerabilidad
- ✅ Permite tiempo razonable para un parche antes de divulgación pública

### Proceso de Reporte

1. **Contacto Inicial**: Envía un email describiendo la vulnerabilidad
2. **Confirmación**: Recibirás confirmación de recepción en 48 horas
3. **Evaluación**: Evaluaremos la vulnerabilidad en 7 días
4. **Parche**: Trabajaremos en un parche si la vulnerabilidad es confirmada
5. **Divulgación**: Coordinaremos la divulgación pública responsable

### Información a Incluir

- Tipo de vulnerabilidad (XSS, CSRF, inyección, etc.)
- Ubicación exacta del problema (archivo, línea)
- Pasos para reproducir
- Impacto potencial
- Sugerencias de remediación (si las tienes)

## Buenas Prácticas para Usuarios

### Al Desplegar el Proyecto

1. **HTTPS**: Siempre usa HTTPS en producción
   ```apache
   # Habilita HSTS en .htaccess
   Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
   ```

2. **Actualizaciones**: Mantén tu servidor web actualizado
   - Apache: última versión estable
   - PHP (si usas): versión soportada
   - Sistema operativo: patches de seguridad aplicados

3. **Permisos de Archivos**:
   ```bash
   # Archivos: 644
   find . -type f -exec chmod 644 {} \;

   # Directorios: 755
   find . -type d -exec chmod 755 {} \;

   # Scripts ejecutables: 755
   chmod 755 scripts/*.R
   ```

4. **Copias de Seguridad**: Implementa backups regulares
   ```bash
   # Ejemplo: backup diario
   tar -czf idac-backup-$(date +%Y%m%d).tar.gz /path/to/project
   ```

### Al Usar los Datos

1. **Validación**: Valida todos los datos antes de usarlos
2. **Sanitización**: Sanitiza datos si los vas a mostrar en web
3. **Citas**: Cita apropiadamente la fuente de los datos

## Limitaciones de Seguridad Conocidas

### 1. Archivos Grandes
- Los archivos PDF/Excel pueden ser grandes (>10MB)
- Considera usar Git LFS para mejor manejo
- No hay límite de tamaño de descarga implementado

### 2. Inline Scripts
- Algunos event handlers inline por compatibilidad
- Plan de migración a event listeners en v2.0

### 3. Validación del Cliente
- Validación principalmente del lado del cliente
- En entornos de producción, implementa validación del servidor

## Checklist de Seguridad

Antes de desplegar en producción:

- [ ] HTTPS configurado y funcionando
- [ ] Certificado SSL válido y no expirado
- [ ] Headers de seguridad activos (verificar con securityheaders.com)
- [ ] Archivos sensibles no accesibles (.git, .env, etc.)
- [ ] Listado de directorios deshabilitado
- [ ] Logs de error no visibles públicamente
- [ ] Copias de seguridad configuradas
- [ ] Monitoreo de seguridad activo
- [ ] Plan de respuesta a incidentes documentado

## Recursos de Seguridad

### Herramientas Recomendadas

- [OWASP ZAP](https://www.zaproxy.org/) - Scanner de vulnerabilidades
- [Mozilla Observatory](https://observatory.mozilla.org/) - Análisis de seguridad web
- [Security Headers](https://securityheaders.com/) - Verificación de headers
- [SSL Labs](https://www.ssllabs.com/) - Test de configuración SSL/TLS

### Referencias

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [MDN Web Security](https://developer.mozilla.org/en-US/docs/Web/Security)
- [CWE - Common Weakness Enumeration](https://cwe.mitre.org/)

## Actualizaciones de Seguridad

Este documento será actualizado cuando:
- Se implementen nuevas medidas de seguridad
- Se descubran vulnerabilidades
- Se lancen nuevas versiones

**Última actualización**: Diciembre 2024
**Versión del documento**: 1.0
