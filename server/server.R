# Source all chapter UIs
source(here::here("server", "overview_server.R"))
source(here::here("server", "networks_server.R"))
source(here::here("server", "connectivity", "connectivity_server.R"))
source(here::here("server", "centrality_server.R"))
source(here::here("server", "communities_server.R"))
source(here::here("server", "assortativity_server.R"))
source(here::here("server", "roles_server.R"))
source(here::here("server", "simulation_server.R"))

source(here::here("helpers", "ui_helpers.R"))
source(here::here("helpers", "network_helpers.R"))
source(here::here("helpers", "plot_helpers.R"))

server <- function(input, output, session) {
  
  # Initialize reactive value for current tab
  current_tab <- reactiveVal("overview")
  
  # Update current_tab when input changes
  observeEvent(input$current_tab, {
    req(input$current_tab)
    cat("Server received tab change to:", input$current_tab, "\n")
    current_tab(input$current_tab)
  }, ignoreNULL = TRUE, ignoreInit = FALSE)
  
  # Debug observer
  observe({
    cat("Current tab is now:", current_tab(), "\n")
  })

    # ── Filter dataset choices and apply chapter default when tab changes ───────
  observeEvent(current_tab(), {
    tab <- current_tab()
    if (tab == "simulation") return()   # simulation generates its own networks

    compatible <- Filter(function(ds) tab %in% ds$chapters, dataset_registry)
    choices    <- setNames(names(compatible), sapply(compatible, `[[`, "label"))

    # Use the chapter's canonical default if it's compatible; else first choice
    default  <- chapter_defaults[[tab]]
    selected <- if (!is.null(default) && default$dataset %in% choices)
                  default$dataset
                else
                  unname(choices)[1]

    updateSelectInput(session, "dataset", choices = choices, selected = selected)

    # Pre-select the default object for multi-object datasets (e.g. hi_tech → htf)
    if (!is.null(default) && !is.null(default$object)) {
      ds <- dataset_registry[[selected]]
      if (!is.null(ds) && length(ds$objects) > 1) {
        updateSelectInput(session, "dataset_object", selected = default$object)
      }
    }
  }, ignoreInit = TRUE)

  # Disable sidebar controls that don't apply to directed graphs
  observe({
    req(rv$igraph)
    directed <- is_directed(rv$igraph)
    weighted <- "weight" %in% edge_attr_names(rv$igraph)

    # Bridges: undirected only
    if (directed) shinyjs::disable("highlight_bridges") else shinyjs::enable("highlight_bridges")

    # Hide arrows: directed only
    if (directed) {
      shinyjs::enable("hide_arrows")
      updateCheckboxInput(session, "hide_arrows", value = FALSE)
    } else {
      shinyjs::disable("hide_arrows")
      updateCheckboxInput(session, "hide_arrows", value = FALSE)
    }

    # Weight style: always show for directed (reciprocity), only if weighted for undirected
    if (directed || weighted) {
      shinyjs::enable("weight_style")
      # Add reciprocity choice only for directed graphs
      choices <- c("None (ignore weights)" = "none",
                  "Line Width"            = "width",
                  "Dashed vs. Solid"      = "linetype",
                  "Color"                 = "color")
      if (directed) choices <- c(choices, "Reciprocity" = "reciprocity")
      updateSelectInput(session, "weight_style", choices = choices, selected = "none")
    } else {
      shinyjs::disable("weight_style")
      updateSelectInput(session, "weight_style", selected = "none")
    }
  })

  output$attribute_controls <- renderUI({
    req(rv$igraph)
    g     <- rv$igraph
    attrs <- vertex_attr_names(g)
    attrs <- attrs[!attrs %in% c("name", "na")]

    if (length(attrs) == 0)
      return(p("No node attributes available", style = "padding-left: 15px;"))

    # Color: all attributes
    color_choices <- c("None", attrs)

    # Size: numeric only (scaling only meaningful for numbers)
    numeric_attrs <- Filter(function(a) is.numeric(vertex_attr(g, a)), attrs)
    size_choices  <- if (length(numeric_attrs) > 0) c("None", numeric_attrs) else c("None")

    # Shape: categorical with <= 6 unique non-NA values only (only 6 shapes exist)
    shape_attrs <- Filter(function(a) {
      vals <- vertex_attr(g, a)
      length(unique(vals[!is.na(vals)])) <= 6
    }, attrs)
    shape_choices <- if (length(shape_attrs) > 0) c("None", shape_attrs) else c("None")

    tagList(
      selectInput("color_attribute", "Color by Attribute:",
                  choices = color_choices, selected = "None"),
      selectInput("size_attribute", "Size by Attribute:",
                  choices = size_choices, selected = "None"),
      if (length(shape_attrs) == 0)
        tagList(
          tags$label("Shape by Attribute:", style = "font-weight: normal; font-size: 14px;"),
          p(tags$small("No attributes with ≤ 6 unique values available."),
            style = "color: #888; margin-top: 2px;")
        )
      else
        selectInput("shape_attribute", "Shape by Attribute:",
                    choices = shape_choices, selected = "None")
    )
  })

  output$attribute_legend_ui <- renderUI({
    req(rv$igraph)
    g <- rv$igraph

    color_attr <- input$color_attribute
    shape_attr <- input$shape_attribute
    size_attr  <- input$size_attribute

    active <- c(
      !is.null(color_attr) && color_attr != "None",
      !is.null(shape_attr) && shape_attr != "None",
      !is.null(size_attr)  && size_attr  != "None"
    )
    if (!any(active)) return(NULL)

    ncstate_colors <- c("#CC0000", "#4156A1", "#990000", "#5E72B0",
                        "#555555", "#777777", "#AAAAAA", "#FF3333")
    shape_opts <- c("dot", "square", "triangle", "diamond", "star", "triangleDown")

    items <- tagList()

    # ── Color legend ────────────────────────────────────────────────────────────
    if (!is.null(color_attr) && color_attr != "None") {
      vals        <- vertex_attr(g, color_attr)
      unique_vals <- sort(unique(vals[!is.na(vals)]))

      if (is.numeric(vals) && length(unique_vals) > 8) {
        # Continuous numeric: show range only
        items <- tagList(items,
          strong(paste("Color →", color_attr), style = "font-size: 11px; color: #aaa;"),
          tags$p(tags$small(paste("Continuous —", round(min(vals, na.rm=TRUE), 2),
                                  "to", round(max(vals, na.rm=TRUE), 2))),
                style = "padding-left:5px; margin-bottom:6px;")
        )
      } else {
        # Categorical (or low-cardinality numeric): show color swatches
        color_map <- setNames(ncstate_colors[seq_along(unique_vals)], as.character(unique_vals))
        items <- tagList(items,
          strong(paste("Color →", color_attr), style = "font-size: 11px; color: #aaa;"),
          tags$ul(style = "list-style:none; padding-left:5px; margin-bottom:6px;",
            lapply(names(color_map), function(v) tags$li(
              tags$span(style = paste0(
                "display:inline-block;width:10px;height:10px;border-radius:50%;",
                "background:", color_map[[v]], ";margin-right:6px;vertical-align:middle;"
              )),
              tags$small(v)
            ))
          )
        )
      }
    }

    # ── Shape legend ────────────────────────────────────────────────────────────
    if (!is.null(shape_attr) && shape_attr != "None") {
      vals        <- vertex_attr(g, shape_attr)
      unique_vals <- sort(unique(vals[!is.na(vals)]))
      shape_map   <- setNames(shape_opts[seq_along(unique_vals)], as.character(unique_vals))
      items <- tagList(items,
        strong(paste("Shape →", shape_attr), style = "font-size: 11px; color: #aaa;"),
        tags$ul(style = "padding-left:15px; margin-bottom:6px;",
          lapply(names(shape_map), function(v)
            tags$li(tags$small(paste(v, "=", shape_map[[v]])))
          )
        )
      )
    }

    # ── Size legend ─────────────────────────────────────────────────────────────
    if (!is.null(size_attr) && size_attr != "None") {
      vals <- vertex_attr(g, size_attr)
      if (is.numeric(vals)) {
        items <- tagList(items,
          strong(paste("Size →", size_attr), style = "font-size: 11px; color: #aaa;"),
          tags$p(tags$small(paste("Scaled from", round(min(vals, na.rm=TRUE), 2),
                                  "to", round(max(vals, na.rm=TRUE), 2))),
                style = "padding-left:5px; margin-bottom:6px;")
        )
      }
    }

    tagList(
      hr(),
      h4("🎨 Attribute Legend", id = "heading"),
      div(style = "padding-left: 15px;", items)
    )
  })

  # ── Render the per-object sub-picker for multi-object .rda files ───────────
  output$network_object_ui <- renderUI({
    req(input$dataset)
    ds <- dataset_registry[[input$dataset]]
    if (is.null(ds) || length(ds$objects) <= 1) return(NULL)

    selectInput(
      "dataset_object",
      "Select Network:",
      choices  = setNames(names(ds$objects), unlist(ds$objects)),
      selected = names(ds$objects)[1]
    )
  })
  
  # Render tab content dynamically
  output$tab_content <- renderUI({
    tab <- current_tab()
    cat("Rendering UI for tab:", tab, "\n")
    
    # Return content directly from switch
    switch(tab,
      "overview" = tagList(
        tags$div(id = "tab-overview", class = "tab-inner", overview_ui)
      ),
      "networks" = tagList(
        tags$div(id = "tab-networks", class = "tab-inner", networks_ui)
      ),
      "visualization" = tagList(
        tags$div(id = "tab-visualization", class = "tab-inner", visualization_ui)
      ),
      "connectivity" = tagList(
        tags$div(id = "tab-connectivity", class = "tab-inner", connectivity_ui)
      ),
      "centrality" = tagList(
        tags$div(id = "tab-centrality", class = "tab-inner", centrality_ui)
      ),
      "communities" = tagList(
        tags$div(id = "tab-communities", class = "tab-inner", communities_ui)
      ),
      "assortativity" = tagList(
        tags$div(id = "tab-assortativity", class = "tab-inner", assortativity_ui)
      ),
      "roles" = tagList(
        tags$div(id = "tab-roles", class = "tab-inner", roles_ui)
      ),
      "simulation" = tagList(
        tags$div(id = "tab-simulation", class = "tab-inner", simulation_ui)
      ),
      "about" = tagList(
        tags$div(
          id = "tab-about", 
          class = "tab-inner",
          fluidRow(
            box(
              title = "ℹ️ About This App",
              width = 12,
              solidHeader = TRUE,
              status = "danger",
              p("This interactive application accompanies the Social Network Analysis textbook."),
              hr(),
              tags$ul(
                tags$li(strong("Course:"), "Social Network Analysis (Sociology & Anthropology, NCSU)"),
                tags$li(strong("Professor:"), "Dr. Steve McDonald"),
                tags$li(strong("Developed by:"), "Dr. Aditi Mallavarapu, Gaurav Sheth"),
                tags$li(strong("Version:"), "1.0.0"),
                tags$li(strong("Last Updated:"), format(Sys.Date(), "%B %d, %Y"))
              )
            )
          )
        )
      ),
      # Default fallback
      {
        cat("WARNING: Unknown tab", tab, "- defaulting to overview\n")
        tagList(
          tags$div(id = "tab-overview", class = "tab-inner", overview_ui)
        )
      }
    )
  })

  rv <- reactiveValues(
    network = NULL,
    igraph = NULL,
    centrality_results = list(),
    community_results = NULL,
    selected_node = NULL,
    simulated_network = NULL,
    erdos_graphs = NULL,
    sw_network = NULL,
    ba_network = NULL,
    walk_path = NULL,
    walk_frequencies = NULL,
    cug_simulations = NULL,
    cug_observed = NULL,
    equiv_groups   = NULL,
    profile_dist   = NULL,
    blockmodel_res = NULL
  )

    # ── Load network when dataset family or specific object changes ─────────────
  observeEvent(list(input$dataset, input$dataset_object), {
    req(input$dataset)
    ds <- dataset_registry[[input$dataset]]
    if (is.null(ds)) return()

    # Pick the object to load; fall back to first if object picker not yet rendered
    obj_name <- if (length(ds$objects) > 1) {
      candidate <- input$dataset_object %||% names(ds$objects)[1]
      if (candidate %in% names(ds$objects)) candidate else names(ds$objects)[1]
    } else {
      names(ds$objects)[1]
    }

    net <- tryCatch(
      load_network_data(ds$file, obj_name),
      error = function(e) {
        showNotification(paste("Error loading dataset:", e$message), type = "error")
        NULL
      }
    )
    if (is.null(net)) return()

    rv$igraph  <- ensure_igraph(net)
    rv$network <- ensure_network(net)

    # Clear previous analysis results
    rv$centrality_results <- list()
    rv$community_results  <- NULL
    rv$selected_node      <- NULL

    rv$equiv_groups   <- NULL
    rv$profile_dist   <- NULL
    rv$blockmodel_res <- NULL

    # Reset all sidebar controls to defaults
    updateCheckboxGroupInput(session, "layer_selection", selected = c("edges", "labels"))
    updateSelectInput(session,  "layout",       selected = "stress")
    updateSelectInput(session,  "node_color",   selected = "#CC0000")
    updateSelectInput(session,  "node_shape",   selected = "dot")
    updateSliderInput(session,  "node_size",    value = 10)
    updateSliderInput(session,  "label_size",   value = 12)
    updateSelectInput(session,  "edge_color",   selected = "#555555")
    updateSelectInput(session,  "edge_style",   selected = "straight")
    updateSliderInput(session,  "edge_width",   value = 1)
    updateSliderInput(session,  "edge_opacity", value = 0.5)
    updateCheckboxInput(session, "hide_arrows",  value = FALSE)
    updateSelectInput(session,  "weight_style", selected = "none")
  }, ignoreInit = FALSE)
  
  # Call chapter-specific server modules
  overview_server(input, output, session, rv)
  networks_server(input, output, session, rv)
  connectivity_server(input, output, session, rv)
  centrality_server(input, output, session, rv)
  communities_server(input, output, session, rv)
  assortativity_server(input, output, session, rv)
  roles_server(input, output, session, rv)
  simulation_server(input, output, session, rv)

  output$download_csv <- downloadHandler(
    filename = function() {
      obj <- input$dataset_object %||% input$dataset
      paste0(obj, "_edgelist_", Sys.Date(), ".csv")
    },
    content = function(file) {
      el <- as_edgelist(rv$igraph, names = TRUE)
      df <- data.frame(From = el[, 1], To = el[, 2])
      write.csv(df, file, row.names = FALSE)
    }
  )
}