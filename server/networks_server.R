# networks_server <- function(input, output, session, rv) {
  
#   output$network_properties <- renderUI({
#     req(rv$igraph)
#     g <- rv$igraph
    
#     n_nodes <- vcount(g)
#     n_edges <- ecount(g)
#     density <- edge_density(g)
#     is_directed <- is_directed(g)
    
#     tagList(
#       tags$ul(
#         tags$li(strong("Nodes: "), n_nodes),
#         tags$li(strong("Edges: "), n_edges),
#         tags$li(strong("Type: "), ifelse(is_directed, "Directed", "Undirected")),
#         tags$li(strong("Density: "), round(density, 3))
#       )
#     )
#   })
  
#   output$dataset_info <- renderUI({
#     req(input$dataset)
#     description <- get_dataset_description(input$dataset)
#     p(description)
#   })
  
#   output$data_table <- renderDT({
#     req(rv$igraph)
#     g <- rv$igraph
    
#     if (input$data_view == "Edgelist") {
#       el <- as_edgelist(g, names = TRUE)
#       df <- data.frame(From = el[, 1], To = el[, 2])
#     } else if (input$data_view == "Adjacency Matrix") {
#       adj <- as_adjacency_matrix(g, sparse = FALSE)
#       df <- as.data.frame(adj)
#     } else { # Nodes
#       node_names <- V(g)$name %||% as.character(1:vcount(g))
#       df <- data.frame(Node = node_names)
      
#       # Add attributes if they exist
#       attrs <- vertex_attr_names(g)
#       attrs <- attrs[attrs != "name"]
#       for (attr in attrs) {
#         df[[attr]] <- vertex_attr(g, attr)
#       }
#     }
    
#     datatable(df, options = list(pageLength = 10, scrollX = TRUE))
#   })
# }

networks_server <- function(input, output, session, rv) {

  # ── Helpers inside server ──────────────────────────────────────────────────

  # Detect numeric edge attributes
  get_numeric_edge_attrs <- function(g) {
    eattrs <- igraph::edge_attr_names(g)
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
    g <- rv$igraph
    tagList(
      tags$ul(
        style = "padding-left: 18px;",
        tags$li(tags$b("Nodes: "), igraph::vcount(g)),
        tags$li(tags$b("Edges: "), igraph::ecount(g))
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

  # visNetwork plot
  output$networks_visplot <- renderVisNetwork({
    req(rv$igraph)
    g      <- rv$igraph
    layout <- input$networks_layout

    # Compute layout coordinates
    layout_fn <- switch(layout,
      "layout_with_fr"   = igraph::layout_with_fr,
      "layout_with_kk"   = igraph::layout_with_kk,
      "layout_nicely"    = igraph::layout_nicely,
      "layout_in_circle" = igraph::layout_in_circle,
      "layout_randomly"  = igraph::layout_randomly
    )
    coords <- layout_fn(g)

    # Build nodes dataframe
    nodes <- data.frame(
      id    = as.integer(igraph::V(g)),
      label = if (!is.null(igraph::V(g)$name)) igraph::V(g)$name else as.character(igraph::V(g)),
      x     = coords[, 1] * 100,
      y     = coords[, 2] * 100,
      stringsAsFactors = FALSE
    )

    # Build edges dataframe
    el <- igraph::as_edgelist(g, names = FALSE)
    edges <- data.frame(
      from   = el[, 1],
      to     = el[, 2],
      arrows = if (igraph::is_directed(g)) "to" else "",
      stringsAsFactors = FALSE
    )

    visNetwork(nodes, edges) |>
      visNodes(
        color = list(
          background = "#CC0000",
          border     = "#800000",
          highlight  = list(background = "#FF6666", border = "#800000")
        ),
        font = list(size = 14, color = "#333333")
      ) |>
      visEdges(
        color  = list(color = "#888888", highlight = "#CC0000"),
        smooth = list(enabled = TRUE, type = "dynamic")
      ) |>
      visPhysics(
        solver = "forceAtlas2Based",
        forceAtlas2Based = list(gravitationalConstant = -50)
      ) |>
      visInteraction(
        dragNodes     = TRUE,
        dragView      = TRUE,
        zoomView      = TRUE,
        navigationButtons = TRUE
      ) |>
      visOptions(highlightNearest = TRUE)
  })

  # Vertex attributes
  output$vertex_attr_ui <- renderUI({
    req(rv$igraph)
    g      <- rv$igraph
    vattrs <- igraph::vertex_attr_names(g)
    vattrs <- vattrs[vattrs != "name"]   # exclude name, shown separately

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
      tabsetPanel(
        tabPanel(
          title = "Binary Matrix",
          br(),
          DTOutput("matrix_binary")
        )
      )
    } else {
      # One tab per numeric edge attribute
      tab_list <- lapply(num_attrs, function(a) {
        output_id <- paste0("matrix_attr_", make.names(a))
        tabPanel(
          title = paste("Matrix:", a),
          br(),
          DTOutput(output_id)
        )
      })
      do.call(tabsetPanel, tab_list)
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
        scrollY    = "400px",
        pageLength = -1,         # show all rows
        dom        = "t"
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
            scrollY    = "400px",
            pageLength = -1,
            dom        = "t"
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