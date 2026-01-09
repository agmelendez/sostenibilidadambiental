# =========================================================
# 1. Cargar librerías
# =========================================================
library(sf)
library(dplyr)
library(units)
sf::sf_use_s2(FALSE)  # evitar errores por geometrías no válidas

# =========================================================
# 2. Leer los shapefiles
# =========================================================
# Ajustá las rutas a tus archivos
kba <- st_read("C:/Users/yany_/Documents/II-2025/Practica profesional II/EPI-Ambiente/Mis documentos/Geoespacial/Terrestrial_KBA/KBA_Terrestrial_CR2025.shp")
asp <- st_read("C:/Users/yany_/Documents/II-2025/Practica profesional II/EPI-Ambiente/Mis documentos/Geoespacial/AREAS_PROTEGIDAS_2025/Areas_Silvestres _Protegidas _2025.shp")
cant <- st_read("C:/Users/yany_/Documents/II-2025/Practica profesional II/EPI-Ambiente/Mis documentos/Geoespacial/limitecantonal_5k/limitecantonal_5kPolygon.shp")

st_crs(asp) <- 5367
st_crs(asp)
kba <- st_transform(kba, 5367)
kba_asp <- st_intersection(kba, asp)
st_crs(cant) <- 5367


# Repara geometrías si es necesario
kba <- st_make_valid(kba)
asp <- st_make_valid(asp)
cant <- st_make_valid(cant)

# --- 0) Union de ASP (evita bordes internos y solapes)
asp_u <- st_union(asp)                      # geometría única
asp_u <- st_make_valid(asp_u)

# --- 1) DENOMINADOR: KBA recortada por cantón (KBA ∩ Cantón)
kba_cant <- st_intersection(kba, cant)

# si tu campo tiene tilde, estandariza
names(kba_cant)[names(kba_cant) == "CANTÓN"] <- "CANTON"

kba_cant_area <- kba_cant |>
  mutate(area_total_ha = as.numeric(st_area(geometry)) / 10000) |>
  st_set_geometry(NULL) |>
  group_by(PROVINCIA, CANTON) |>
  summarise(area_total_ha = sum(area_total_ha, na.rm = TRUE), .groups = "drop")

# --- 2) NUMERADOR: (KBA ∩ Cantón) ∩ ASP_union
kba_cant_prot <- st_intersection(st_make_valid(kba_cant), asp_u)

kba_cant_prot_area <- kba_cant_prot |>
  mutate(area_protegida_ha = as.numeric(st_area(geometry)) / 10000) |>
  st_set_geometry(NULL) |>
  group_by(PROVINCIA, CANTON) |>
  summarise(area_protegida_ha = sum(area_protegida_ha, na.rm = TRUE), .groups = "drop")

# --- 3) Unir y calcular %
kba_cant_result <- kba_cant_area |>
  left_join(kba_cant_prot_area, by = c("PROVINCIA","CANTON")) |>
  mutate(area_protegida_ha = ifelse(is.na(area_protegida_ha), 0, area_protegida_ha),
         pct_kba_protegida = ifelse(area_total_ha > 0,
                                    100 * area_protegida_ha / area_total_ha, NA_real_))

# Revisa resultados
summary(kba_cant_result$pct_kba_protegida)
head(kba_cant_result[order(kba_cant_result$pct_kba_protegida), ], 10)
head(kba_cant_result[order(-kba_cant_result$pct_kba_protegida), ], 10)

write.csv(kba_cant_result, "KBA_Proteccion_Cantonal.csv", row.names = FALSE)
