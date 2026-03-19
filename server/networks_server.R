networks_server <- function(input, output, session, rv) {

  # ── Helpers inside server ──────────────────────────────────────────────────

  # Detect numeric edge attributes
  get_numeric_edge_attrs <- function(g) {
    eattrs <- igraph::edge_attr_names(g)
    eattrs <- eattrs[!eattrs %in% c("na")]
    if (length(eattrs) == 0) return(character(0))
    Filter(function(a) is.numeric(igraph::edge_attr(g, a)), eattrs)
  }

  # Reactive: numeric edge attributes
  numeric_edge_attrs <- reactive({
    req(rv$igraph)
    get_numeric_edge_attrs(rv$igraph)
  })

  # Reactive: is weighted (has at least one numeric edge attribute)
  is_weighted_net <- reactive({
    req(rv$igraph)
    length(numeric_edge_attrs()) > 0
  })

  # Reactive: network type label
  net_type_label <- reactive({
    req(rv$igraph)
    g   <- rv$igraph
    dir <- igraph::is_directed(g)
    wt  <- is_weighted_net()
    dplyr::case_when(
      dir  & wt  ~ "DNW",
      dir  & !wt ~ "DN",
      !dir & wt  ~ "UNW",
      TRUE       ~ "UN"
    )
  })

  # ── Subtab 1 outputs ───────────────────────────────────────────────────────

  # Network type badge
  output$network_type_badge <- renderUI({
    req(rv$igraph)
    g     <- rv$igraph
    label <- net_type_label()

    badge_color <- switch(label,
      "UN"  = "#5bc0de",
      "UNW" = "#5cb85c",
      "DN"  = "#f0ad4e",
      "DNW" = "#d9534f"
    )

    full_label <- switch(label,
      "UN"  = "Undirected · Unweighted",
      "UNW" = "Undirected · Weighted",
      "DN"  = "Directed · Unweighted",
      "DNW" = "Directed · Weighted"
    )

    tagList(
      tags$span(
        label,
        style = paste0(
          "background-color:", badge_color, ";",
          "color: white;",
          "padding: 6px 14px;",
          "border-radius: 12px;",
          "font-size: 1.1em;",
          "font-weight: bold;",
          "display: inline-block;",
          "margin-bottom: 8px;"
        )
      ),
      br(),
      tags$small(full_label, style = "color: #555;")
    )
  })

  # Loop check + simplify button
  output$loop_warning_ui <- renderUI({
    req(rv$igraph)
    g         <- rv$igraph
    has_loops <- any(igraph::which_loop(g))

    if (has_loops) {
      n_loops <- sum(igraph::which_loop(g))
      tagList(
        tags$span(
          icon("exclamation-triangle"),
          paste(n_loops, "loop(s) detected."),
          style = "color: #d9534f; font-weight: bold;"
        ),
        br(), br(),
        tags$small(
          "Loops (self-ties) can affect network metrics.
           Click below to remove them.",
          style = "color: #555;"
        ),
        br(), br(),
        actionButton(
          inputId = "simplify_graph_btn",
          label   = "Remove Loops",
          icon    = icon("cut"),
          class   = "btn-danger btn-sm"
        )
      )
    } else {
      tagList(
        tags$span(
          icon("check-circle"),
          " No loops detected.",
          style = "color: #5cb85c; font-weight: bold;"
        )
      )
    }
  })

  # Simplify button — permanently modifies rv$igraph
  observeEvent(input$simplify_graph_btn, {
    req(rv$igraph)
    rv$igraph <- igraph::simplify(rv$igraph, remove.loops = TRUE, remove.multiple = FALSE)
    showNotification("Loops removed from network.", type = "message", duration = 3)
  })

  # Density
  output$density_ui <- renderUI({
    req(rv$igraph)
    g   <- rv$igraph
    den <- round(igraph::edge_density(g), 4)

    tagList(
      tags$span(
        style = "font-size: 1.8em; font-weight: bold; color: #CC0000;",
        den
      ),
      br(),
      tags$small(
        "Proportion of possible edges that exist.",
        style = "color: #555;"
      )
    )
  })

  # Basic counts
  output$basic_counts_ui <- renderUI({
    req(rv$igraph)
    g        <- rv$igraph
    n        <- igraph::vcount(g)
    e        <- igraph::ecount(g)
    den      <- round(igraph::edge_density(g), 4)
    directed <- igraph::is_directed(g)

    possible <- if (directed) n * (n - 1) else n * (n - 1) / 2
    formula  <- if (directed) "n×(n−1)" else "n×(n−1)/2"

    tagList(
      tags$ul(
        style = "padding-left: 18px;",
        tags$li(tags$b("Nodes: "), n),
        tags$li(tags$b("Edges: "), e),
        tags$li(tags$b("Possible Edges: "), possible,
                tags$small(paste0(" (", formula, ")"), style = "color: #888;")),
        tags$li(tags$b("Density: "),
                tags$span(den, style = "color: #CC0000; font-weight: bold;"),
                tags$small(paste0(" (", e, "/", possible, ")"), style = "color: #888;"))
      )
    )
  })

  # Isolates
  output$isolates_ui <- renderUI({
    req(rv$igraph)
    g         <- rv$igraph
    iso_idx   <- which(igraph::degree(g) == 0)
    n_iso     <- length(iso_idx)

    # Fall back to vertex index if no name attribute
    all_names <- if (!is.null(igraph::V(g)$name)) igraph::V(g)$name else as.character(seq_len(igraph::vcount(g)))
    iso_names <- all_names[iso_idx]

    if (n_iso == 0) {
      tags$span(icon("check-circle"), " No isolates.", style = "color: #5cb85c;")
    } else {
      tagList(
        tags$b(paste(n_iso, "isolate(s)")),
        br(),
        tags$details(
          tags$summary(
            "Show node names",
            style = "cursor: pointer; color: #CC0000;"
          ),
          do.call(tags$ul,
            c(list(style = "padding-left: 18px; margin-top: 6px;"),
              lapply(iso_names, function(nm) tags$li(nm))
            )
          )
        )
      )
    }
  })

  # Pendants
  output$pendants_ui <- renderUI({
    req(rv$igraph)
    g         <- rv$igraph
    pen_idx   <- which(igraph::degree(g) == 1)
    n_pen     <- length(pen_idx)

    # Fall back to vertex index if no name attribute
    all_names <- if (!is.null(igraph::V(g)$name)) igraph::V(g)$name else as.character(seq_len(igraph::vcount(g)))
    pen_names <- all_names[pen_idx]

    if (n_pen == 0) {
      tags$span(icon("check-circle"), " No pendants.", style = "color: #5cb85c;")
    } else {
      tagList(
        tags$b(paste(n_pen, "pendant(s)")),
        br(),
        tags$details(
          tags$summary(
            "Show node names",
            style = "cursor: pointer; color: #CC0000;"
          ),
          do.call(tags$ul,
            c(list(style = "padding-left: 18px; margin-top: 6px;"),
              lapply(pen_names, function(nm) tags$li(nm))
            )
          )
        )
      )
    }
  })

  # Cache layout — only recomputes when graph or layout type changes
  vis_base <- reactive({
    req(rv$igraph)
    igraph_to_visNetwork(rv$igraph, input$layout)
  })

  # visNetwork plot
  output$networks_visplot <- renderVisNetwork({
    req(rv$igraph)
    g <- rv$igraph
    vis_data <- vis_base()

    # 1. Use igraph_to_visNetwork instead of inline build
    # vis_data <- igraph_to_visNetwork(g, input$layout)

    # 2. Layer selection
    vis_data <- apply_layer_selection(vis_data, input$layer_selection)

    # 3. Global node styling
    vis_data <- apply_node_styling(vis_data,
      node_color = input$node_color,
      node_shape = input$node_shape,
      node_size  = input$node_size,
      label_size = input$label_size
    )

    # 3b. Attribute-based overrides (aes mapping)
    if (!is.null(input$color_attribute) && input$color_attribute != "None")
      vis_data <- color_nodes_by_attribute(vis_data, g, input$color_attribute)

    if (!is.null(input$size_attribute) && input$size_attribute != "None")
      vis_data <- size_nodes_by_attribute(vis_data, g, input$size_attribute,
                                          min_size = input$node_size * 0.4,
                                          max_size = input$node_size * 2.5)

    if (!is.null(input$shape_attribute) && input$shape_attribute != "None")
      vis_data <- shape_nodes_by_attribute(vis_data, g, input$shape_attribute)

    # 4. Edge styling
    edge_result <- apply_edge_styling(vis_data, g,
      hide_arrows    = input$hide_arrows,
      edge_color     = input$edge_color,
      edge_width     = input$edge_width,
      edge_opacity   = input$edge_opacity,
      edge_style     = input$edge_style,
      curve_strength = input$curve_strength %||% 0.3
    )
    vis_data <- edge_result$vis_data

    # 5. Weight style
    weight_result <- apply_weight_style(vis_data, g, input$weight_style)
    vis_data <- weight_result$vis_data

    # 6. Highlight options
    vis_data <- apply_highlight_options(vis_data, g,
      highlight_isolates  = input$highlight_isolates,
      highlight_bridges   = input$highlight_bridges,
      highlight_cutpoints = input$highlight_cutpoints,
      show_components     = input$show_components
    )

    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visEdges(smooth = edge_result$smooth) %>%
      visPhysics(solver = "forceAtlas2Based",
                forceAtlas2Based = list(gravitationalConstant = -50)) %>%
      visLayout(randomSeed = 42) %>%
      visInteraction(dragNodes = TRUE, dragView = TRUE,
                    zoomView = TRUE, navigationButtons = TRUE) %>%
      visOptions(highlightNearest = TRUE)
  })

  # Vertex attributes
  output$vertex_attr_ui <- renderUI({
    req(rv$igraph)
    g      <- rv$igraph
    vattrs <- igraph::vertex_attr_names(g)
    vattrs <- vattrs[!tolower(vattrs) %in% c("name", "na", "vertex.names")]  # exclude name, shown separately

    if (length(vattrs) == 0) {
      return(tags$p("No vertex attributes found.", style = "color: #888;"))
    }

    attr_cards <- lapply(vattrs, function(a) {
      vals <- igraph::vertex_attr(g, a)

      preview <- if (is.numeric(vals)) {
        paste0("Range: ", round(min(vals, na.rm = TRUE), 3),
               " – ", round(max(vals, na.rm = TRUE), 3))
      } else {
        uniqs <- unique(vals)
        if (length(uniqs) > 5) {
          paste0("Values: ", paste(head(uniqs, 5), collapse = ", "), ", ...")
        } else {
          paste0("Values: ", paste(uniqs, collapse = ", "))
        }
      }

      tags$div(
        style = "margin-bottom: 10px; padding: 8px;
                 border-left: 4px solid #CC0000; background: #fafafa;",
        tags$b(a),
        tags$span(
          style = "font-size:0.75em; margin-left:6px; color:#888;",
          if (is.numeric(vals)) "(numeric)" else "(categorical)"
        ),
        br(),
        tags$small(preview, style = "color: #555;")
      )
    })

    tagList(attr_cards)
  })

  # Edge attributes
  output$edge_attr_ui <- renderUI({
    req(rv$igraph)
    g      <- rv$igraph
    eattrs <- igraph::edge_attr_names(g)
    eattrs <- eattrs[!eattrs %in% c("na", "weight")]

    if (length(eattrs) == 0) {
      return(tags$p("No edge attributes found.", style = "color: #888;"))
    }

    attr_cards <- lapply(eattrs, function(a) {
      vals <- igraph::edge_attr(g, a)

      preview <- if (is.numeric(vals)) {
        paste0("Range: ", round(min(vals, na.rm = TRUE), 3),
               " – ", round(max(vals, na.rm = TRUE), 3))
      } else {
        uniqs <- unique(vals)
        if (length(uniqs) > 5) {
          paste0("Values: ", paste(head(uniqs, 5), collapse = ", "), ", ...")
        } else {
          paste0("Values: ", paste(uniqs, collapse = ", "))
        }
      }

      tags$div(
        style = "margin-bottom: 10px; padding: 8px;
                 border-left: 4px solid #CC0000; background: #fafafa;",
        tags$b(a),
        tags$span(
          style = "font-size:0.75em; margin-left:6px; color:#888;",
          if (is.numeric(vals)) "(numeric)" else "(categorical)"
        ),
        br(),
        tags$small(preview, style = "color: #555;")
      )
    })

    tagList(attr_cards)
  })

  # ── Subtab 2 : Matrix View ─────────────────────────────────────────────────

  # Directed network note
  output$matrix_directed_note <- renderUI({
    req(rv$igraph)
    if (igraph::is_directed(rv$igraph)) {
      tags$div(
        class = "alert alert-info",
        icon("info-circle"),
        tags$b(" Directed Network: "),
        "Rows represent the sending node and columns represent the
         receiving node. An asymmetric matrix indicates that ties are
         not necessarily reciprocated."
      )
    }
  })

  # Dynamic matrix inner tabsetPanel
  output$matrix_tabs_ui <- renderUI({
    req(rv$igraph)
    g        <- rv$igraph
    num_attrs <- numeric_edge_attrs()

    # Unweighted — single binary matrix tab
    if (length(num_attrs) == 0) {
      tagList(
        # h4("Binary Matrix:"),
        DTOutput("matrix_binary")
      )
    } else {
      do.call(tagList, lapply(num_attrs, function(a) {
        output_id <- paste0("matrix_attr_", make.names(a))
        tagList(
          h4(paste("Matrix:", a)),
          DTOutput(output_id),
          br()
        )
      }))
    }
  })

  # Binary matrix render
  output$matrix_binary <- renderDT({
    req(rv$igraph)
    g   <- rv$igraph
    mat <- as.data.frame(igraph::as_adjacency_matrix(g, sparse = FALSE))
    datatable(
      mat,
      options = list(
        scrollX    = TRUE,
        pageLength = 15
      )
    )
  })

  # Weighted matrix renders (one per numeric edge attribute)
  observe({
    req(rv$igraph)
    g         <- rv$igraph
    num_attrs <- numeric_edge_attrs()

    lapply(num_attrs, function(a) {
      output_id <- paste0("matrix_attr_", make.names(a))
      output[[output_id]] <- renderDT({
        mat <- as.data.frame(
          igraph::as_adjacency_matrix(g, attr = a, sparse = FALSE)
        )
        datatable(
          mat,
          options = list(
            scrollX    = TRUE,
            pageLength = 15
          )
        )
      })
    })
  })

  # ── Subtab 3 : Data Frames ─────────────────────────────────────────────────

  # Vertex attributes table
  output$vertex_attr_table <- renderDT({
    req(rv$igraph)
    g  <- rv$igraph
    df <- igraph::as_data_frame(g, what = "vertices")
    datatable(
      df,
      options = list(scrollX = TRUE, pageLength = 15)
    )
  })

  # Edge list + all edge attributes table
  output$edge_attr_table <- renderDT({
    req(rv$igraph)
    g  <- rv$igraph
    df <- igraph::as_data_frame(g, what = "edges")

    # Rename first two columns to From/To for clarity
    if (ncol(df) >= 2) {
      colnames(df)[1:2] <- c("From", "To")
    }

    datatable(
      df,
      options = list(scrollX = TRUE, pageLength = 15)
    )
  })
}