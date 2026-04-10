analysis_server <- function(id, rv, input, output, session) {
  
  # ── Helper: Detect numeric edge attributes ──────────────────────────────────
  
  get_numeric_edge_attrs <- function(g) {
    if (is.null(g)) return(character(0))
    eattrs <- igraph::edge_attr_names(g)
    eattrs <- eattrs[!eattrs %in% c("na")]
    if (length(eattrs) == 0) return(character(0))
    Filter(function(a) is.numeric(igraph::edge_attr(g, a)), eattrs)
  }

  # ── Tab 1: Network Visualization ────────────────────────────────────────────
  
  # Determine which graph to display based on view mode
  current_graph <- reactive({
    req(rv$ego_id, rv$igraph_alters, rv$igraph_ego)
    
    mode <- input$view_mode %||% "alters_only"
    
    if (mode == "with_ego") {
      rv$igraph_ego
    } else {
      rv$igraph_alters
    }
  })

  # Build visNetwork from igraph
  output$analysis_visplot <- renderVisNetwork({
    req(current_graph())
    g <- current_graph()
    
    if (is.null(g) || vcount(g) == 0) {
      return(visNetwork(data.frame(), data.frame()) %>%
        visPhysics(enabled = FALSE))
    }

    # Convert igraph to visNetwork format
    nodes_df <- data.frame(
      id = 1:igraph::vcount(g),
      label = igraph::V(g)$name %||% paste0("V", 1:igraph::vcount(g)),
      title = igraph::V(g)$name %||% paste0("V", 1:igraph::vcount(g))
    )

    # Get edges as a proper dataframe with correct structure
    edges_df <- data.frame()
    if (igraph::ecount(g) > 0) {
        edges_mat <- igraph::as_edgelist(g, names = FALSE)
        edges_df <- data.frame(
            from = as.numeric(edges_mat[, 1]),
            to = as.numeric(edges_mat[, 2])
        )

        # Add weights if available
        if ("weight" %in% igraph::edge_attr_names(g)) {
            edges_df$weight <- igraph::E(g)$weight
            
            if (input$weight_style %||% "width" == "width") {
                edges_df$width <- scales::rescale(edges_df$weight, to = c(1, 5))
            } else if (input$weight_style == "color") {
                edges_df$color <- ifelse(edges_df$weight == 2, "#990000", "#CCCCCC")
            }
        }
        
        # Apply edge styling
        if (!"color" %in% colnames(edges_df)) {
            edges_df$color <- input$edge_color %||% "#555555"
        }
        edges_df$smooth <- input$edge_style %||% "straight" == "curved"
    }

    # Apply node styling
    nodes_df$color <- input$alter_color %||% "#1f78b4"
    nodes_df$shape <- input$alter_shape %||% "dot"
    nodes_df$size <- input$alter_size %||% 10

    # Highlight ego if present
    mode <- input$view_mode %||% "alters_only"
    if (mode == "with_ego" && !is.null(rv$igraph_ego)) {
      ego_idx <- igraph::vcount(rv$igraph_ego)
      if (ego_idx <= nrow(nodes_df)) {
        nodes_df$color[ego_idx] <- "#CC0000"  # NC State Red for ego
        nodes_df$size[ego_idx] <- input$ego_size %||% 15
        nodes_df$label[ego_idx] <- paste0("EGO", "\n(", nodes_df$label[ego_idx], ")")
      }
    }

    # Build visNetwork
    vis <- visNetwork(nodes_df, edges_df)
    
    if (input$edge_style == "curved") {
      vis <- vis %>% visEdges(smooth = list(type = "continuous",
                                           forceDirection = "vertical",
                                           roundness = input$curve_strength %||% 0.3))
    }

    vis %>%
      visPhysics(solver = "forceAtlas2Based",
                 forceAtlas2Based = list(gravitationalConstant = -50)) %>%
      visLayout(randomSeed = 42) %>%
      visInteraction(dragNodes = TRUE, dragView = TRUE,
                    zoomView = TRUE, navigationButtons = TRUE) %>%
      visOptions(highlightNearest = TRUE)
  })

  # ggraph static version of the ego/alter network
  output$analysis_ggraph <- renderPlot({
    req(current_graph())
    g    <- current_graph()
    n    <- igraph::vcount(g)
    mode <- input$view_mode %||% "alters_only"

    # Translate ego sidebar inputs → names expected by build_ggraph_plot
    shim <- list(
      node_color      = input$alter_color    %||% "#1f78b4",
      node_shape      = input$alter_shape    %||% "dot",
      node_size       = input$alter_size     %||% 10,
      label_size      = input$label_size     %||% 12,
      color_attribute = "None",
      size_attribute  = "None",
      shape_attribute = "None",
      edge_color      = input$edge_color     %||% "#555555",
      edge_width      = input$edge_width     %||% 1,
      edge_opacity    = input$edge_opacity   %||% 0.8,
      edge_style      = input$edge_style     %||% "straight",
      hide_arrows     = FALSE,
      weight_style    = input$weight_style   %||% "none",
      curve_strength  = input$curve_strength %||% 0.3,
      layer_selection = input$layer_selection %||% c("edges", "labels"),
      layout          = input$layout         %||% "fr"
    )

    # Per-node color / size overrides when ego node is present
    fill_override <- NULL
    size_override <- NULL
    if (mode == "with_ego" && n >= 1) {
      ego_idx      <- n
      alter_col    <- input$alter_color %||% "#1f78b4"
      ego_sz       <- (input$ego_size   %||% 15) / 3.5
      alter_sz     <- (input$alter_size %||% 10) / 3.5
      fill_override                <- rep(alter_col,  n)
      fill_override[ego_idx]       <- "#CC0000"
      size_override                <- rep(alter_sz,   n)
      size_override[ego_idx]       <- ego_sz
    }

    build_ggraph_plot(g, shim,
                      node_fill_override = fill_override,
                      node_size_scores   = size_override)
  }, res = 110)

  # Alter attributes display
  output$analysis_alter_attr_ui <- renderUI({
    req(current_graph())
    g <- current_graph()
    attrs <- igraph::vertex_attr_names(g)
    attrs <- attrs[!tolower(attrs) %in% c("name", "na")]

    if (length(attrs) == 0) {
      return(p("No alter attributes found.", style = "color: #888;"))
    }

    attr_cards <- lapply(attrs, function(a) {
      vals <- igraph::vertex_attr(g, a)
      preview <- if (is.numeric(vals)) {
        paste0("Min: ", round(min(vals, na.rm = TRUE), 2), 
               ", Mean: ", round(mean(vals, na.rm = TRUE), 2), 
               ", Max: ", round(max(vals, na.rm = TRUE), 2))
      } else {
        paste(unique(vals[!is.na(vals)])[1:3], collapse = ", ")
      }

      tags$div(
        style = "margin-bottom: 10px; padding: 8px; background: #f0f0f0; border-radius: 3px;",
        tags$strong(a, style = "color: #333;"),
        tags$br(),
        tags$small(preview, style = "color: #666;")
      )
    })

    tagList(attr_cards)
  })

  # Edge attributes display
  output$analysis_edge_attr_ui <- renderUI({
    req(current_graph())
    g <- current_graph()
    eattrs <- igraph::edge_attr_names(g)
    eattrs <- eattrs[!eattrs %in% c("na", "weight")]

    if (length(eattrs) == 0 && !("weight" %in% igraph::edge_attr_names(g))) {
      return(p("No edge attributes found.", style = "color: #888;"))
    }

    # Always show weight if present
    attr_cards <- list()
    
    if ("weight" %in% igraph::edge_attr_names(g)) {
      vals <- igraph::E(g)$weight
      attr_cards[[1]] <- tags$div(
        style = "margin-bottom: 10px; padding: 8px; background: #f0f0f0; border-radius: 3px;",
        tags$strong("weight", style = "color: #333;"),
        tags$br(),
        tags$small(
          paste0("Min: ", min(vals, na.rm = TRUE), 
                 ", Mean: ", round(mean(vals, na.rm = TRUE), 2), 
                 ", Max: ", max(vals, na.rm = TRUE)),
          style = "color: #666;"
        )
      )
    }

    # Add other edge attributes
    if (length(eattrs) > 0) {
      for (a in eattrs) {
        vals <- igraph::edge_attr(g, a)
        preview <- if (is.numeric(vals)) {
          paste0("Min: ", round(min(vals, na.rm = TRUE), 2), 
                 ", Mean: ", round(mean(vals, na.rm = TRUE), 2), 
                 ", Max: ", round(max(vals, na.rm = TRUE), 2))
        } else {
          paste(unique(vals[!is.na(vals)])[1:3], collapse = ", ")
        }

        attr_cards[[length(attr_cards) + 1]] <- tags$div(
          style = "margin-bottom: 10px; padding: 8px; background: #f0f0f0; border-radius: 3px;",
          tags$strong(a, style = "color: #333;"),
          tags$br(),
          tags$small(preview, style = "color: #666;")
        )
      }
    }

    tagList(attr_cards)
  })

  # ── Tab 2: Ego Profile ──────────────────────────────────────────────────────
  
  output$ego_demographics_ui <- renderUI({
    req(rv$ego_id)
    profile <- get_ego_profile(rv$ego_id)
    
    if (nrow(profile) == 0) return(NULL)

    # Dynamically display all columns from ego profile (no hardcoded recoding)
    profile_row <- profile[1, ]
    
    # Filter just the demographic columns we have
    demographics <- data.frame()
    for (col in colnames(profile_row)) {
      if (col != "ego_id") {
        val <- profile_row[[col]]
        if (!is.na(val)) {
          demographics <- rbind(demographics, 
                              data.frame(label = col, value = val))
        }
      }
    }

    if (nrow(demographics) == 0) {
      return(p("No demographic data available", style = "color: #888;"))
    }
    
    items <- lapply(1:nrow(demographics), function(i) {
      tags$li(HTML(paste0("<strong>", demographics$label[i], ":</strong> ", demographics$value[i])))
    })

    tagList(
      tags$ul(
        style = "margin: 0; padding-left: 15px; font-size: 13px; line-height: 1.8;",
        items
      )
    )
  })

  output$ego_composition_ui <- renderUI({
    req(rv$ego_id)
    alters <- get_ego_alters(rv$ego_id)
    edges <- get_ego_edges(rv$ego_id)
    metrics <- get_ego_metrics(rv$ego_id)
    
    if (nrow(alters) == 0) return(NULL)

    n_alters <- nrow(alters)
    prop_fem_alters <- mean(alters$SEX == 2, na.rm = TRUE)
    mean_alter_educ <- mean(alters$EDUC, na.rm = TRUE)
    n_edges <- nrow(edges)

    tagList(
      tags$ul(
        style = "margin: 0; padding-left: 15px; font-size: 13px; line-height: 1.8;",
        tags$li(HTML(paste0("<strong>Number of Alters:</strong> ", n_alters))),
        tags$li(HTML(paste0("<strong>% Female Alters:</strong> ", 
                            round(prop_fem_alters * 100, 1), "%"))),
        tags$li(HTML(paste0("<strong>Mean Alter Education:</strong> ", 
                            round(mean_alter_educ, 2)))),
        tags$li(HTML(paste0("<strong>Alter-Alter Edges:</strong> ", n_edges)))
      )
    )
  })

  output$ego_alters_table <- renderDT({
    req(rv$ego_id)
    df <- get_ego_alters(rv$ego_id)
    
    if (nrow(df) == 0) {
      return(datatable(data.frame(), options = list(dom = 't')))
    }
    
    # Dynamically select available columns (don't hardcode)
    available_cols <- intersect(colnames(df), 
                               c("alter_id", "SEX", "RACE", "EDUC", "AGE", 
                                 "PARENT", "SIBLING", "SPOUSE", "CHILD",
                                 "OTHFAM", "COWORK", "MEMGRP", "NEIGHBR", 
                                 "FRIEND", "ADVISOR", "OTHER", "TALKTO", "KNOWN", "RELIG"))
    
    df <- df |> select(all_of(available_cols))

    datatable(
      df,
      options = list(scrollX = TRUE, pageLength = 10)
    )
  })

  # ── Tab 3: Network Metrics ──────────────────────────────────────────────────
  
  output$metrics_ego_level_ui <- renderUI({
    req(rv$ego_id)
    profile <- get_ego_profile(rv$ego_id)
    
    if (nrow(profile) == 0) return(NULL)

    sex_label <- if (profile$SEX[1] == 1) "Male" else "Female"
    female_dummy <- profile$FEMALE[1]
    nwhite_dummy <- profile$NWHITE[1]

    tagList(
      tags$ul(
        style = "margin: 0; padding-left: 15px; font-size: 13px; line-height: 1.6;",
        tags$li(HTML(paste0("<strong>Female (0/1):</strong> ", female_dummy))),
        tags$li(HTML(paste0("<strong>Non-White (0/1):</strong> ", nwhite_dummy))),
        tags$li(HTML(paste0("<strong>Gender:</strong> ", sex_label))),
        tags$li(HTML(paste0("<strong>Age:</strong> ", profile$AGE[1])))
      )
    )
  })

  output$metrics_alter_level_ui <- renderUI({
    req(rv$ego_id)
    alters <- get_ego_alters(rv$ego_id)
    
    if (nrow(alters) == 0) return(NULL)

    prop_fem <- mean(alters$SEX == 2, na.rm = TRUE)
    mean_educ <- mean(alters$EDUC, na.rm = TRUE)

    tagList(
      tags$ul(
        style = "margin: 0; padding-left: 15px; font-size: 13px; line-height: 1.6;",
        tags$li(HTML(paste0("<strong>Prop. Female:</strong> ", round(prop_fem, 3)))),
        tags$li(HTML(paste0("<strong>Mean Education:</strong> ", round(mean_educ, 2)))),
        tags$li(HTML(paste0("<strong>N Alters:</strong> ", nrow(alters))))
      )
    )
  })

  output$metrics_edge_level_ui <- renderUI({
    req(rv$ego_id, current_graph())
    g <- current_graph()
    
    if (is.null(g) || igraph::vcount(g) <= 1) return(NULL)

    density <- igraph::edge_density(g)
    components <- igraph::components(g)$no
    deg_centr <- igraph::centr_degree(g)$centralization

    tagList(
      tags$ul(
        style = "margin: 0; padding-left: 15px; font-size: 13px; line-height: 1.6;",
        tags$li(HTML(paste0("<strong>Density:</strong> ", round(density, 3)))),
        tags$li(HTML(paste0("<strong>Components:</strong> ", components))),
        tags$li(HTML(paste0("<strong>Deg. Centraliz.:</strong> ", round(deg_centr, 3))))
      ),
      tags$p(
        tags$small("Density = proportion of ties present among alters (0=none, 1=all)",
                   style = "color: #666; margin-top: 10px; display: block;"),
        tags$small("Components = number of disconnected groups",
                   style = "color: #666; display: block;"),
        tags$small("Centralization = how hierarchical the network is",
                   style = "color: #666; display: block;")
      )
    )
  })

  # ── Tab 4: Statistical Summary ──────────────────────────────────────────────
  
  output$anova_results_ui <- renderPrint({
    # Check if FEMALE column exists
    if (!("FEMALE" %in% colnames(analysis_df))) {
      cat("Statistical analysis requires FEMALE variable in ego data.\n")
      cat("This variable should be a binary indicator (0/1) for male/female.\n")
      return(invisible(NULL))
    }
    
    cat("ANOVA: Testing Association Between Ego Demographics and Network Metrics\n")
    cat("=========================================================================\n\n")
    
    # Prepare data
    df_stats <- analysis_df |>
      mutate(female_factor = factor(FEMALE, labels = c("Male", "Female")))

    # Test available metrics
    test_cols <- c("prop_fem", "mean_educ", "density", "components", "deg_centralization")
    available_tests <- test_cols[test_cols %in% colnames(df_stats)]
    
    for (i in seq_along(available_tests)) {
      col <- available_tests[i]
      cat(i, ". ANOVA: ", col, " ~ female_factor\n")
      cat(strrep("-", 40), "\n")
      tryCatch({
        formula <- as.formula(paste0(col, " ~ female_factor"))
        result <- aov(formula, data = df_stats)
        print(summary(result))
      }, error = function(e) {
        cat("Error computing ANOVA: ", e$message, "\n")
      })
      cat("\n")
    }
  })

  output$mean_comparison_table <- renderDT({
    if (!("FEMALE" %in% colnames(analysis_df))) {
      return(datatable(data.frame(), options = list(dom = 't')))
    }
    
    df_stats <- analysis_df |>
      mutate(female_factor = factor(FEMALE, labels = c("Male", "Female")))

    # Dynamically select available numeric columns to summarize
    numeric_cols <- colnames(df_stats)[sapply(df_stats, is.numeric)]
    numeric_cols <- numeric_cols[!numeric_cols %in% c("ego_id", "FEMALE", "NWHITE")]
    
    if (length(numeric_cols) == 0) {
      return(datatable(data.frame(), options = list(dom = 't')))
    }

    # Build summary with available columns
    summary_list <- list(n = ~ n())
    for (col in numeric_cols) {
      summary_list[[paste0(col, "_mean")]] <- as.formula(paste0("~ mean(", col, ", na.rm = TRUE)"))
      summary_list[[paste0(col, "_sd")]] <- as.formula(paste0("~ sd(", col, ", na.rm = TRUE)"))
    }
    
    comparison <- df_stats |>
      group_by(female_factor) |>
      summarise(
        n = n(),
        .groups = 'drop'
      ) |>
      as.data.frame()

    datatable(
      comparison,
      options = list(dom = 't', scrollX = TRUE)
    )
  })

  output$gender_effect_plot <- renderPlot({
    if (!("FEMALE" %in% colnames(analysis_df))) {
      return(ggplot() + geom_blank() + ggtitle("No FEMALE variable available"))
    }
    
    df_stats <- analysis_df |>
      mutate(female_factor = factor(FEMALE, labels = c("Male", "Female")))

    # Find available numeric columns for plotting
    numeric_cols <- colnames(df_stats)[sapply(df_stats, is.numeric)]
    numeric_cols <- numeric_cols[!numeric_cols %in% c("ego_id", "FEMALE", "NWHITE")]
    
    if (length(numeric_cols) == 0) {
      return(ggplot() + geom_blank() + ggtitle("No numeric metrics available"))
    }

    # Create boxplots for first 3 available metrics
    plots <- list()
    for (i in 1:min(3, length(numeric_cols))) {
      col <- numeric_cols[i]
      plots[[i]] <- ggplot(df_stats, aes(x = female_factor, y = get(col), fill = female_factor)) +
        geom_boxplot(alpha = 0.7) +
        labs(title = paste("Distribution of", col, "by Ego Gender"),
             x = "Ego Gender", y = col) +
        scale_fill_manual(values = c("Male" = "#1f78b4", "Female" = "#FF69B4"), guide = "none") +
        theme_minimal()
    }

    if (length(plots) < 3) {
      # Pad with blank plots if not enough data
      for (i in (length(plots)+1):3) {
        plots[[i]] <- ggplot() + geom_blank()
      }
    }

    gridExtra::grid.arrange(plots[[1]], plots[[2]], plots[[3]], nrow = 2)
  })
}
