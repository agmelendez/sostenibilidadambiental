# ==============================================================================
# 1. PAQUETES REQUERIDOS
# ==============================================================================
# install.packages(c("shiny", "bslib", "sf", "leaflet", "DT", "zip", "shinyWidgets", "shinycssloaders", "dplyr", "shinyjs", "readr", "units"))

library(shiny)
library(bslib)
library(sf)
library(leaflet)
library(DT)
library(zip)
library(shinyWidgets)
library(shinycssloaders)
library(dplyr)
library(shinyjs)
library(readr)
library(units)

# ==============================================================================
# 2. CONFIGURACIÓN GLOBAL
# ==============================================================================
options(shiny.maxRequestSize = 800 * 1024^2)
sf::sf_use_s2(FALSE)

# ==============================================================================
# 3. INTERFAZ DE USUARIO (UI)
# ==============================================================================
ui <- page_sidebar(
  title = "Geoprocesador Vectorial Robusto",
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  useShinyjs(),
  
  sidebar = sidebar(
    width = 380,
    card(
      card_header("📁 1. Cargar Archivos (.zip)"),
      fileInput("shapefile1", "Capa Base", accept = ".zip"),
      uiOutput("layer1_status"),
      fileInput("shapefile2", "Capa de Operación", accept = ".zip"),
      uiOutput("layer2_status")
    ),
    card(
      card_header("⚙️ 2. Configurar Proceso"),
      selectInput("operation", "Operación Espacial:",
                  choices = list(
                    "Join Espacial (Atributos)" = "spatial_join", "Intersección" = "intersection",
                    "Clip/Corte" = "clip", "Diferencia (Erase)" = "difference",
                    "Unión (Geometrías)" = "union", "Buffer + Intersección" = "buffer_intersect"
                  )),
      conditionalPanel(
        "input.operation == 'buffer_intersect'",
        numericInput("buffer_distance", "Distancia de Buffer (metros):", value = 100, min = 1)
      ),
      hr(),
      h5("🔧 Optimización"),
      checkboxInput("validate_geom", "Validar y corregir geometrías", value = TRUE),
      checkboxInput("simplify_geom", "Simplificar para acelerar proceso", value = TRUE),
      conditionalPanel(
        "input.simplify_geom",
        sliderInput("tolerance", "Tolerancia de simplificación (metros):", min = 1, max = 1000, value = 50)
      )
    ),
    conditionalPanel(
      "output.bothLayersLoaded",
      actionButton("processData", "🔄 3. Procesar Capas", class = "btn-warning btn-lg w-100 fw-bold"),
      br(), br(),
      conditionalPanel(
        "output.resultReady",
        div(class = "d-grid gap-2",
            downloadButton("download_csv", "Descargar CSV (Excel)", icon = icon("table"), class = "btn-success btn-lg"),
            downloadButton("download_shp", "Descargar Shapefile (.zip)", icon = icon("file-zipper"), class = "btn-primary btn-lg")
        )
      )
    ),
    hr(),
    div(class = "d-grid gap-2",
        actionButton("clear_session", "🧹 Limpiar Sesión", icon = icon("trash-alt"), class = "btn-danger mt-2"),
        actionButton("show_log", "Ver Log de Errores", icon = icon("bug"), class = "btn-outline-secondary mt-2")
    )
  ),
  card(
    card_header("🗺️ Visualización y Resultados"),
    navset_card_tab(
      nav_panel("Mapa Interactivo", withSpinner(leafletOutput("map", height = "75vh"))),
      nav_panel("Análisis de Capas",
                fluidRow(
                  column(6, card(card_header("Info Capa Base"), verbatimTextOutput("layer1_info"))),
                  column(6, card(card_header("Info Capa Operación"), verbatimTextOutput("layer2_info")))
                ),
                conditionalPanel("output.resultReady", card(card_header("Info Resultado"), verbatimTextOutput("result_info")))),
      nav_panel("Tabla de Atributos (Resultado)", withSpinner(DTOutput("result_table")))
    )
  )
)

# ==============================================================================
# 4. LÓGICA DEL SERVIDOR (SERVER)
# ==============================================================================
server <- function(input, output, session) {
  
  values <- reactiveValues(
    layer1 = NULL, layer2 = NULL, result = NULL,
    layer1_loading = FALSE, layer2_loading = FALSE,
    error_log = character(0)
  )
  
  log_error <- function(title, detail = NULL) {
    timestamp <- format(Sys.time(), "[%Y-%m-%d %H:%M:%S]")
    full_message <- paste(timestamp, title)
    if (!is.null(detail)) { full_message <- paste(full_message, "\n  >", detail) }
    values$error_log <- c(values$error_log, full_message)
    showNotification(paste(title, "- Revise el 'Log de Errores' para detalles."), type = "error", duration = 10)
    print(paste("ERROR LOG:", full_message))
  }
  
  observeEvent(input$show_log, {
    showModal(modalDialog(
      title = "Log de Errores Detallados",
      if (length(values$error_log) > 0) pre(paste(rev(values$error_log), collapse = "\n\n")) else "No hay errores registrados.",
      footer = modalButton("Cerrar"), easyClose = TRUE
    ))
  })
  
  extract_shapefile <- function(file_path) {
    temp_dir <- file.path(tempdir(), paste0("shp_extract_", as.integer(Sys.time())))
    dir.create(temp_dir, showWarnings = FALSE, recursive = TRUE)
    tryCatch({
      zip::unzip(file_path, exdir = temp_dir)
      shp_files <- list.files(temp_dir, pattern = "\\.shp$", recursive = TRUE, full.names = TRUE, ignore.case = TRUE)
      if (length(shp_files) == 0) stop("No se encontró ningún archivo .shp en el .zip.")
      return(shp_files[1])
    }, error = function(e) {
      log_error("Error al extraer archivo .zip", e$message)
      return(NULL)
    })
  }
  
  optimize_geometry <- function(sf_obj, layer_name) {
    withProgress(message = paste('Optimizando', layer_name), value = 0.2, {
      tryCatch({
        if (is.na(st_crs(sf_obj))) sf_obj <- st_set_crs(sf_obj, 4326)
        
        sf_obj_proj <- st_transform(sf_obj, 5367)
        incProgress(0.3, detail = "Proyectando a CRTM05...")
        
        if (input$validate_geom) {
          incProgress(0.2, detail = "Corrigiendo geometrías...")
          sf_obj_proj <- st_make_valid(sf_obj_proj)
        }
        
        geom_type <- unique(st_geometry_type(sf_obj_proj))
        if (input$simplify_geom && !("POINT" %in% geom_type)) {
          incProgress(0.2, detail = "Simplificando en metros...")
          sf_obj_proj <- st_simplify(sf_obj_proj, dTolerance = input$tolerance, preserveTopology = TRUE)
        }
        
        incProgress(0.1, detail = "Transformando a WGS84...")
        sf_obj_final <- st_transform(sf_obj_proj, 4326)
        
        return(sf_obj_final)
        
      }, error = function(e) {
        log_error("Error durante la optimización", e$message)
        return(NULL)
      })
    })
  }
  
  load_layer_data <- function(file_info, layer_id, layer_name) {
    req(file_info)
    values[[paste0(layer_id, "_loading")]] <- TRUE
    on.exit(values[[paste0(layer_id, "_loading")]] <- FALSE)
    
    shp_path <- extract_shapefile(file_info$datapath)
    if (is.null(shp_path)) return()
    
    tryCatch({
      raw_layer <- st_read(shp_path, quiet = TRUE)
      if (nrow(raw_layer) > 0) {
        values[[layer_id]] <- optimize_geometry(raw_layer, layer_name)
      } else {
        showNotification(paste("La", layer_name, "está vacía."), type = "warning")
        values[[layer_id]] <- NULL
      }
    }, error = function(e) {
      log_error(paste("Error al leer capa", layer_name), e$message)
    })
  }
  
  observeEvent(input$shapefile1, { load_layer_data(input$shapefile1, "layer1", "Capa Base") })
  observeEvent(input$shapefile2, { load_layer_data(input$shapefile2, "layer2", "Capa de Operación") })
  
  observeEvent(input$processData, {
    req(values$layer1, values$layer2)
    withProgress(message = 'Ejecutando operación espacial...', value = 0.1, {
      tryCatch({
        incProgress(0.2, detail = "Proyectando capas a CRTM05...")
        l1_proj <- st_transform(values$layer1, 5367)
        l2_proj <- st_transform(values$layer2, 5367)
        
        if(input$validate_geom) {
          if(any(!st_is_valid(l1_proj))) l1_proj <- st_make_valid(l1_proj)
          if(any(!st_is_valid(l2_proj))) l2_proj <- st_make_valid(l2_proj)
        }
        
        incProgress(0.4, detail = "Calculando en metros...")
        result_proj <- switch(
          input$operation,
          "spatial_join"   = st_join(l1_proj, l2_proj, join = st_intersects),
          "intersection"   = st_intersection(l1_proj, l2_proj),
          "clip"           = st_intersection(l1_proj, st_union(l2_proj)),
          "difference"     = st_difference(l1_proj, st_union(l2_proj)),
          "union"          = st_union(st_union(l1_proj), st_union(l2_proj)),
          "buffer_intersect" = {
            buffer_l2 <- st_buffer(l2_proj, dist = set_units(input$buffer_distance, "m"))
            st_intersection(l1_proj, buffer_l2)
          }
        )
        
        incProgress(0.3, detail = "Finalizando y limpiando...")
        result_proj <- result_proj[!st_is_empty(result_proj), ]
        
        if (nrow(result_proj) > 0) {
          values$result <- st_transform(result_proj, 4326)
          showNotification("✓ Operación completada con éxito.", type = "message")
        } else {
          values$result <- NULL
          showNotification("La operación no produjo resultados.", type = "warning")
        }
      }, error = function(e) {
        log_error("Error en la operación espacial", e$message)
        values$result <- NULL
      })
    })
  })
  
  observeEvent(input$clear_session, {
    values$layer1 <- NULL; values$layer2 <- NULL; values$result <- NULL
    values$error_log <- character(0)
    reset("shapefile1"); reset("shapefile2")
    gc(full = TRUE)
    showNotification("🧹 Sesión limpiada. Puede cargar nuevos archivos.", type = "message")
  })
  
  output$layer1Loaded <- reactive({ !is.null(values$layer1) }); outputOptions(output, "layer1Loaded", suspendWhenHidden = FALSE)
  output$layer2Loaded <- reactive({ !is.null(values$layer2) }); outputOptions(output, "layer2Loaded", suspendWhenHidden = FALSE)
  output$bothLayersLoaded <- reactive({ !is.null(values$layer1) && !is.null(values$layer2) }); outputOptions(output, "bothLayersLoaded", suspendWhenHidden = FALSE)
  output$resultReady <- reactive({ !is.null(values$result) }); outputOptions(output, "resultReady", suspendWhenHidden = FALSE)
  
  output$layer1_status <- renderUI({
    if (values$layer1_loading) { div(class = "alert alert-warning py-1", withSpinner(span("Procesando..."), type = 6)) } 
    else if (!is.null(values$layer1)) { div(class = "alert alert-success py-1", "✓ Capa Base cargada") }
  })
  output$layer2_status <- renderUI({
    if (values$layer2_loading) { div(class = "alert alert-warning py-1", withSpinner(span("Procesando..."), type = 6)) } 
    else if (!is.null(values$layer2)) { div(class = "alert alert-success py-1", "✓ Capa Operación cargada") }
  })
  
  output$map <- renderLeaflet({
    leaflet() %>% addProviderTiles(providers$CartoDB.Positron) %>% setView(lng = -84.08, lat = 9.93, zoom = 7)
  })
  
  # <--- [CORRECCIÓN FINAL] La simplificación VISUAL ahora también usa proyección para eliminar el warning --->
  visualize_layer <- function(proxy, sf_obj, group, color) {
    req(sf_obj)
    
    viz_obj <- sf_obj # Empieza con el objeto original en WGS84
    geom_type <- unique(st_geometry_type(viz_obj))
    
    # Solo simplificar si es visualmente complejo (muchos objetos y no son puntos)
    if (!("POINT" %in% geom_type) && nrow(viz_obj) > 500) {
      showNotification(paste("Simplificando", group, "para visualización rápida..."), type = "message", duration = 2)
      
      # Proyectar a metros para simplificar
      viz_proj <- st_transform(viz_obj, 5367)
      
      # Simplificar con una tolerancia alta en metros (para que sea rápido)
      viz_proj_simple <- st_simplify(viz_proj, dTolerance = 150, preserveTopology = TRUE)
      
      # Devolver a WGS84 para que Leaflet lo pueda dibujar
      viz_obj <- st_transform(viz_proj_simple, 4326)
    }
    
    # Dibujar en el mapa
    if ("POINT" %in% geom_type) {
      proxy %>% addCircleMarkers(data = viz_obj, group = group, color = color, radius = 2, stroke = FALSE, fillOpacity = 0.7)
    } else {
      proxy %>% addPolygons(data = viz_obj, group = group, color = color, weight = 1.5, fillOpacity = 0.2)
    }
  }
  
  observe({
    proxy <- leafletProxy("map") %>% clearGroup(c("Capa Base", "Capa Operación", "Resultado"))
    visualize_layer(proxy, values$layer1, "Capa Base", "#0d6efd")
    visualize_layer(proxy, values$layer2, "Capa Operación", "#dc3545")
    visualize_layer(proxy, values$result, "Resultado", "#198754")
    proxy %>% addLayersControl(overlayGroups = c("Capa Base", "Capa Operación", "Resultado"), options = layersControlOptions(collapsed = FALSE))
  })
  
  render_info_text <- function(layer) {
    if (is.null(layer)) return("Capa no cargada.")
    paste(
      "Tipo de Geometría:", paste(unique(st_geometry_type(layer)), collapse = ", "),
      "\nObjetos (Features):", nrow(layer),
      "\nCRS:", st_crs(layer)$input,
      "\nColumnas:", ncol(layer) - 1,
      "\nTamaño en Memoria:", format(object.size(layer), units = "auto")
    )
  }
  
  output$layer1_info <- renderText({ render_info_text(values$layer1) })
  output$layer2_info <- renderText({ render_info_text(values$layer2) })
  output$result_info <- renderText({ render_info_text(values$result) })
  
  output$result_table <- renderDT({
    req(values$result)
    st_drop_geometry(values$result) %>%
      datatable(options = list(scrollX = TRUE, pageLength = 10), filter = 'top', rownames = FALSE)
  })
  
  output$download_csv <- downloadHandler(
    filename = function() { paste0("resultado_csv_", input$operation, "_", format(Sys.time(), "%Y%m%d"), ".csv") },
    content = function(file) {
      req(values$result)
      tryCatch({
        st_drop_geometry(values$result) %>% readr::write_csv(file)
        showNotification("✓ CSV exportado.", type = "message")
      }, error = function(e){ log_error("Error al escribir CSV", e$message) })
    }
  )
  
  output$download_shp <- downloadHandler(
    filename = function() { paste0("resultado_shp_", input$operation, "_", format(Sys.time(), "%Y%m%d"), ".zip") },
    content = function(file) {
      req(values$result)
      withProgress(message = 'Empaquetando Shapefile...', value = 0.2, {
        temp_dir <- file.path(tempdir(), "shp_download")
        if (dir.exists(temp_dir)) unlink(temp_dir, recursive = TRUE); dir.create(temp_dir)
        tryCatch({
          incProgress(0.3, detail = "Escribiendo archivos...")
          result_to_write <- values$result
          names(result_to_write) <- substr(make.unique(names(result_to_write)), 1, 10)
          st_write(result_to_write, dsn = file.path(temp_dir, "resultado.shp"), delete_layer = TRUE, quiet = TRUE, driver = "ESRI Shapefile")
          incProgress(0.3, detail = "Comprimiendo...")
          files_to_zip <- list.files(temp_dir, full.names = TRUE)
          zip::zip(zipfile = file, files = files_to_zip, root = temp_dir)
          showNotification("✓ Shapefile exportado.", type = "message")
        }, error = function(e){ log_error("Error al escribir o comprimir Shapefile", e$message) })
      })
    }
  )
}

# ==============================================================================
# 5. EJECUTAR LA APLICACIÓN
# ==============================================================================
shinyApp(ui = ui, server = server)
