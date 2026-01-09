# 🌿 IDAC - Índice de Desempeño Ambiental Cantonal

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Costa Rica](https://img.shields.io/badge/país-Costa%20Rica-blue.svg)](https://www.cr)
[![UCR](https://img.shields.io/badge/universidad-UCR-red.svg)](https://www.ucr.ac.cr)

## 📋 Descripción del Proyecto

El **Índice de Desempeño Ambiental Cantonal (IDAC)** es una herramienta metodológica desarrollada en la Universidad de Costa Rica (Escuela de Estadística) para evaluar y comparar de manera sistemática las condiciones ambientales de los 84 cantones de Costa Rica.

Este proyecto responde a la necesidad de contar con un instrumento actualizado, replicable y alineado con estándares internacionales como el Environmental Performance Index (EPI) de Yale University.

### 🎯 Objetivos Principales

- **Desarrollo Metodológico**: Crear una metodología robusta para calcular el IDAC utilizando datos ambientales cantonales actualizados
- **Adaptación Conceptual**: Adaptar el EPI al contexto costarricense subnacional
- **Generación de Información**: Producir un instrumento replicable para monitoreo territorial continuo
- **Orientación de Políticas**: Facilitar la toma de decisiones en gestión ambiental local y nacional

## 📊 Indicadores del IDAC

El IDAC se construye a partir de 5 indicadores ambientales clave:

| Código | Indicador | Definición | Dimensión |
|--------|-----------|------------|-----------|
| **FA** | Forest Area | % cobertura forestal del cantón | Ecosistemas |
| **TPA** | Territorial Protected Areas | % territorio bajo protección oficial (ASP SINAC) | Conservación |
| **TKP** | Terrestrial KBA Protection | % de áreas clave de biodiversidad protegidas | Biodiversidad |
| **WPC** | Waste Per Capita | Generación de residuos (ton/persona/año) | Gestión Residuos |
| **WRR** | Waste Recovery Rate | % residuos recuperados mediante valorización | Economía Circular |

## 📈 Resultados Clave

- **Promedio Nacional**: 0.27 (en escala 0-1)
- **Cantón Mejor Desempeño**: Dota (0.76)
- **Cantón Mayor Desafío**: San José (0.007)
- **Variabilidad**: Alta dispersión entre cantones (CV = 59.3%)

### 🏆 Top 5 Cantones

1. **Dota** (San José) - 0.760
2. **San Rafael** (Heredia) - 0.596
3. **Pococí** (Limón) - 0.559
4. **Heredia** (Heredia) - 0.554
5. **La Unión** (Cartago) - 0.545

## 🗂️ Estructura del Repositorio

```
sostenibilidadambiental/
├── index.html              # Página web principal del proyecto
├── README.md               # Este archivo
├── LICENSE                 # Licencia del proyecto
├── .gitattributes         # Configuración Git para archivos grandes
│
├── assets/                 # Recursos web
│   ├── css/
│   │   └── styles.css     # Estilos de la página
│   ├── js/
│   │   └── main.js        # JavaScript principal
│   └── images/            # Imágenes (futuro)
│
├── data/                   # Datos del proyecto
│   ├── indicadores/       # Datos de indicadores individuales
│   │   ├── Forest Area (FA).xlsx
│   │   ├── Terrestial Protected Areas (TPA).xlsx
│   │   ├── Terrestrial KBA Protection (TKP).csv
│   │   ├── WPC 2024.xlsx
│   │   └── WRR 2024.xlsx
│   └── calculos/          # Datos de cálculos y resultados
│       ├── IDAC (calc, norm).xlsx
│       ├── IDAC Ponderizacion.xlsx
│       ├── Calculo de Recuperado canton.xlsx
│       └── Calculo de Valorizables canton.xlsx
│
├── docs/                   # Documentación del proyecto
│   ├── Informe Final ISAC-CIOdD.pdf
│   ├── Ficha Metodológica IDAC.docx
│   └── Banner ISAC-CIOdD.pdf
│
└── scripts/                # Código fuente
    ├── CodigofuncionesEspaciales ver2_0.R
    └── Terrestrial KBA Protection Index Codigo.R
```

## 🚀 Visualización del Proyecto

Para visualizar el proyecto localmente:

1. **Clonar el repositorio**:
```bash
git clone https://github.com/agmelendez/sostenibilidadambiental.git
cd sostenibilidadambiental
```

2. **Abrir en el navegador**:
   - Simplemente abre el archivo `index.html` en tu navegador web
   - O usa un servidor local como `python -m http.server 8000`

3. **Navegar por las secciones**:
   - Proyecto General
   - Resultados Explícitos
   - Validación Estadística
   - Metodología
   - Recomendaciones
   - Descargas

## 📥 Descargas

Todos los datos, documentos y código están disponibles en las siguientes categorías:

### Documentación
- Informe Final IDAC
- Ficha Metodológica
- Banner del Proyecto

### Datos de Indicadores
- Forest Area (FA)
- Protected Areas (TPA)
- KBA Protection (TKP)
- Waste Per Capita (WPC)
- Waste Recovery Rate (WRR)

### Cálculos y Resultados
- IDAC Calculado y Normalizado
- Esquema de Ponderización
- Metodología de Cálculo de Residuos

### Código Fuente
- Scripts R para análisis espacial
- Código para cálculo de índices

## 🔬 Metodología

El IDAC utiliza:

1. **Normalización**: Min-Max (0-1) con funciones de desempeño EPI
2. **Agregación**: Media Geométrica para penalizar desbalances
3. **Ponderación**: Uniforme (20% cada indicador) por simplicidad y transparencia
4. **Validación**: Múltiples tests de robustez y coherencia estadística

### Fórmula del IDAC

```
IDAC = (FA × TPA × TKP × WPC × WRR)^(1/5)
```

O en forma logarítmica:
```
ln(IDAC) = (1/5) × [ln(FA) + ln(TPA) + ln(TKP) + ln(WPC) + ln(WRR)]
```

## ✅ Validación Estadística

El IDAC ha sido validado mediante:

- ✓ Análisis de distribución y dispersión
- ✓ Validación de normalización
- ✓ Validación de método de agregación
- ✓ Tests de robustez y sensibilidad
- ✓ Análisis de coherencia interna
- ✓ Evaluación de manejo de datos faltantes

**Conclusión**: El índice es robusto, coherente y confiable para uso en formulación de políticas públicas.

## 🎯 Recomendaciones Prioritarias

### Críticas (2025-2026)
1. Fortalecer gestión de residuos (WRR: 0.15 → 0.35)
2. Conservación forestal integral (FA: 0.51 → 0.60)

### Altas (2026-2027)
3. Expansión de áreas protegidas (TPA: 0.23 → 0.30)
4. Sistemas de información ambiental integrados

### Visión 2030
- **IDAC Promedio**: 0.27 → 0.42 (+56%)
- **Indicadores disponibles**: 5 → 10+ (incluir cambio climático)
- **Actualización**: Anual → Trimestral

## 👥 Equipo

- **Investigadora Principal**: Yanancy Navarro Cerdas
- **Institución**: Universidad de Costa Rica - Escuela de Estadística
- **Curso**: Práctica Profesional II (XS-4430)
- **Período**: II Semestre 2024

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.

Todos los datos y materiales son de libre acceso para fines de investigación, educación y análisis.

## 📚 Cómo Citar

Si utilizas este proyecto en tu investigación, por favor cita:

```
Navarro Cerdas, Y. (2024). Índice de Desempeño Ambiental Cantonal (IDAC) -
Costa Rica 2024. Escuela de Estadística, Universidad de Costa Rica.
https://github.com/agmelendez/sostenibilidadambiental
```

## 🔗 Enlaces Relevantes

- [Universidad de Costa Rica](https://www.ucr.ac.cr)
- [Escuela de Estadística UCR](https://estadistica.ucr.ac.cr)
- [Environmental Performance Index (EPI)](https://epi.yale.edu)
- [SINAC - Sistema Nacional de Áreas de Conservación](https://www.sinac.go.cr)

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Si deseas contribuir:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📧 Contacto

Para consultas sobre el proyecto, contacta a:
- Universidad de Costa Rica - Escuela de Estadística
- [Sitio Web UCR](https://www.ucr.ac.cr)

## 🔒 Seguridad

Este sitio implementa las siguientes medidas de seguridad:

- Content Security Policy (CSP)
- X-Frame-Options (protección contra clickjacking)
- X-Content-Type-Options (protección contra MIME sniffing)
- Sanitización de entradas en JavaScript
- Validación de rutas de descarga

---

**Última actualización**: Diciembre 2024
**Versión**: 1.0
**Estado**: ✅ Validado y Completo
