simulation_server <- function(input, output, session, rv) {
  
  # Simulation parameters (dynamic based on model)
  output$simulation_params <- renderUI({
    req(input$sim_model)
    
    if (input$sim_model == "erdos") {
      tagList(
        sliderInput("sim_nodes", "Nodes:", min = 10, max = 200, value = 50, step = 5),
        sliderInput("sim_prob", "Edge Probability:", min = 0.01, max = 0.5, value = 0.1, step = 0.01)
      )
    } else if (input$sim_model == "smallworld") {
      tagList(
        sliderInput("sim_nodes", "Nodes:", min = 20, max = 200, value = 50, step = 5),
        sliderInput("sim_nei", "Neighbors:", min = 2, max = 10, value = 4, step = 1),
        sliderInput("sim_rewire", "Rewiring Prob:", min = 0, max = 1, value = 0.1, step = 0.05)
      )
    } else if (input$sim_model == "barabasi") {
      tagList(
        sliderInput("sim_nodes", "Nodes:", min = 20, max = 200, value = 100, step = 10),
        sliderInput("sim_power", "Power:", min = 0.5, max = 2.0, value = 1.0, step = 0.1),
        sliderInput("sim_m", "Connections:", min = 1, max = 5, value = 2, step = 1)
      )
    }
  })
  
  # Random walk network selection
  output$rw_network_select <- renderUI({
    selectInput("rw_base_network", "Select Base Network:",
                choices = c("Current Network" = "current"))
  })
  
  output$rw_start_node <- renderUI({
    req(rv$igraph)
    node_names <- V(rv$igraph)$name %||% as.character(1:vcount(rv$igraph))
    selectInput("rw_start", "Starting Node:", 
                choices = c("Random", node_names), selected = "Random")
  })

  # BUILT-IN GRAPH TYPES
  
  observeEvent(input$generate_builtin, {
    req(input$builtin_type, input$builtin_nodes)
    
    n <- input$builtin_nodes
    
    g <- switch(input$builtin_type,
      "empty" = make_empty_graph(n),
      "full" = make_full_graph(n),
      "star" = make_star(n),
      "ring" = make_ring(n),
      "tree" = make_tree(n, children = 2, mode = "undirected"),
      "lattice" = make_lattice(c(8, 8)),
      make_star(n)
    )
    
    V(g)$name <- paste0("Node", 1:vcount(g))
    rv$simulated_network <- g
  })

  output$builtin_plot <- renderVisNetwork({
    req(rv$simulated_network)
    
    vis_data <- igraph_to_visNetwork(rv$simulated_network, "nicely")
    vis_data$nodes$size <- input$node_size
    vis_data$nodes$color <- list(background = "#CC0000", border = "#990000")
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visInteraction(navigationButtons = TRUE)
  })

  output$builtin_properties <- renderUI({
    req(rv$simulated_network)
    g <- rv$simulated_network

    comp <- igraph::components(g)  # ✅ Fixed - use igraph package
    
    tagList(
      tags$ul(
        tags$li(strong("Nodes: "), vcount(g)),
        tags$li(strong("Edges: "), ecount(g)),
        tags$li(strong("Density: "), round(edge_density(g), 3)),
        tags$li(strong("Components: "), comp$no),
        tags$li(strong("Diameter: "), 
                if (comp$no == 1) diameter(g) else "N/A (disconnected)")
      )
    )
  })

  # ERDŐS-RÉNYI RANDOM GRAPHS
  
  observeEvent(input$generate_erdos, {
    req(input$erdos_nodes, input$erdos_prob, input$erdos_num_graphs)
    
    set.seed(input$random_seed)
    n_graphs <- as.numeric(input$erdos_num_graphs)
    
    graphs <- lapply(1:n_graphs, function(i) {
      g <- sample_gnp(input$erdos_nodes, input$erdos_prob)
      V(g)$name <- paste0("Node", 1:vcount(g))
      g
    })
    
    rv$erdos_graphs <- graphs
  })
  
  output$erdos_graphs_ui <- renderUI({
    req(rv$erdos_graphs)
    
    n_graphs <- length(rv$erdos_graphs)
    
    if (n_graphs == 1) {
      visNetworkOutput("erdos_plot_1", height = "500px")
    } else if (n_graphs == 2) {
      fluidRow(
        column(6, visNetworkOutput("erdos_plot_1", height = "400px")),
        column(6, visNetworkOutput("erdos_plot_2", height = "400px"))
      )
    } else {
      fluidRow(
        column(6, visNetworkOutput("erdos_plot_1", height = "350px")),
        column(6, visNetworkOutput("erdos_plot_2", height = "350px")),
        column(6, visNetworkOutput("erdos_plot_3", height = "350px")),
        column(6, visNetworkOutput("erdos_plot_4", height = "350px"))
      )
    }
  })
  
  # Generate individual Erdős plots
  lapply(1:4, function(i) {
    output[[paste0("erdos_plot_", i)]] <- renderVisNetwork({
      req(rv$erdos_graphs)
      if (i <= length(rv$erdos_graphs)) {
        g <- rv$erdos_graphs[[i]]
        vis_data <- igraph_to_visNetwork(g, "fr")
        vis_data$nodes$size <- 8
        vis_data$nodes$color <- list(background = "#CC0000", border = "#990000")
        
        visNetwork(vis_data$nodes, vis_data$edges)
      }
    })
  })
  
  # SMALL WORLD (Watts-Strogatz)
  
  observeEvent(input$generate_sw, {
    req(input$sw_nodes, input$sw_neighbors, input$sw_rewire)
    
    set.seed(input$random_seed)
    g <- sample_smallworld(1, input$sw_nodes, input$sw_neighbors, input$sw_rewire)
    V(g)$name <- paste0("Node", 1:vcount(g))
    
    rv$sw_network <- g
  })
  
  output$sw_plot <- renderVisNetwork({
    req(rv$sw_network)
    
    vis_data <- igraph_to_visNetwork(rv$sw_network, "circle")
    vis_data$nodes$size <- 10
    vis_data$nodes$color <- list(background = "#CC0000", border = "#990000")
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visInteraction(navigationButtons = TRUE)
  })
  
  output$sw_properties <- renderUI({
    req(rv$sw_network)
    g <- rv$sw_network
    
    avg_path <- mean_distance(g)
    clustering <- transitivity(g, type = "global")
    diam <- diameter(g)
    
    tagList(
      tags$ul(
        tags$li(strong("Average Path Length: "), round(avg_path, 2)),
        tags$li(strong("Clustering Coefficient: "), round(clustering, 3)),
        tags$li(strong("Diameter: "), diam)
      )
    )
  })
  
  # PREFERENTIAL ATTACHMENT (Barabási-Albert)
  
  observeEvent(input$generate_ba, {
    req(input$ba_nodes, input$ba_power, input$ba_connections)
    
    set.seed(input$random_seed)
    g <- sample_pa(input$ba_nodes, power = input$ba_power, m = input$ba_connections, directed = FALSE)
    V(g)$name <- paste0("Node", 1:vcount(g))
    
    rv$ba_network <- g
  })
  
  output$ba_plot <- renderVisNetwork({
    req(rv$ba_network)
    
    vis_data <- igraph_to_visNetwork(rv$ba_network, "fr")
    
    # Size nodes by degree
    degrees <- igraph::degree(rv$ba_network)
    vis_data$nodes$value <- degrees
    
    # Color high-degree nodes (degree > 7) in NC State red
    vis_data$nodes$color <- lapply(degrees, function(d) {
      if (d > 7) list(background = "#CC0000", border = "#990000")
      else list(background = "#000000", border = "#555555")
    })
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visInteraction(navigationButtons = TRUE)
  })
  
  output$ba_degree_dist <- renderPlotly({
    req(rv$ba_network)
    
    degrees <- igraph::degree(rv$ba_network)
    
    plot_ly(x = degrees, type = "histogram") %>%
      layout(
        title = "Degree Distribution (Log-Log Scale)",
        xaxis = list(title = "Degree", type = "log"),
        yaxis = list(title = "Frequency", type = "log")
      )
  })
  
  # RANDOM WALK SIMULATION
  
  observeEvent(input$start_walk, {
    req(rv$igraph, input$rw_start, input$rw_steps)
    
    g <- rv$igraph
    start_idx <- which(V(g)$name == input$rw_start)[1]
    if (is.na(start_idx)) start_idx <- 1
    
    set.seed(input$random_seed)
    walk_path <- random_walk(g, start = start_idx, steps = input$rw_steps, mode = "out")
    
    rv$walk_path <- walk_path
    rv$walk_frequencies <- table(walk_path)
  })
  
  output$rw_plot <- renderVisNetwork({
    req(rv$igraph, rv$walk_path)
    
    g <- rv$igraph
    vis_data <- igraph_to_visNetwork(g, "fr")
    
    # Color nodes based on walk frequency (NC State colors)
    walk_freq <- as.numeric(rv$walk_frequencies[as.character(1:vcount(g))])
    walk_freq[is.na(walk_freq)] <- 0
    
    max_freq <- max(walk_freq)
    node_colors <- sapply(walk_freq, function(f) {
      if (f == 0) "#CCCCCC"
      else if (f == max_freq) "#CC0000"
      else if (f > max_freq/2) "#FF3333"
      else "#000000"
    })
    
    vis_data$nodes$color <- list(background = node_colors)
    vis_data$nodes$size <- 8 + (walk_freq / max_freq) * 15
    vis_data$nodes$font <- list(size = 12)
    vis_data$edges$color <- list(color = "#000000", opacity = 0.3)
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visInteraction(navigationButtons = TRUE)
  })
  
  output$rw_stats <- renderUI({
    req(rv$walk_path, rv$walk_frequencies)
    
    g <- rv$igraph
    walk_freq <- rv$walk_frequencies
    
    # Eigenvector centrality correlation
    eigen_cent <- eigen_centrality(g, directed = is_directed(g))$vector
    nodes_visited <- as.numeric(names(walk_freq))
    correlation <- cor(walk_freq, eigen_cent[nodes_visited])
    
    tagList(
      h5("Walk Summary:"),
      tags$ul(
        tags$li(strong("Total Steps: "), length(rv$walk_path) - 1),
        tags$li(strong("Unique Nodes Visited: "), length(walk_freq)),
        tags$li(strong("Most Visited Node: "), V(g)$name[as.numeric(names(which.max(walk_freq)))]),
        tags$li(strong("Visits to Most Visited: "), max(walk_freq))
      ),
      h5("Correlation with Eigenvector Centrality:"),
      p(strong(round(correlation, 3)), style = "font-size: 18px; color: #CC0000;"),
      p("High correlation suggests walk frequency predicts centrality")
    )
  })
  
  # CUG TESTS (Conditional Uniform Graph)
  
  observeEvent(input$run_cug, {
    req(rv$igraph)
    
    g <- rv$igraph
    n_sims <- as.numeric(input$cug_simulations)
    
    # Observed statistics
    obs_density <- edge_density(g)
    obs_transitivity <- transitivity(g, type = "global")
    obs_diameter <- diameter(g, directed = is_directed(g))
    obs_centralization <- centr_eigen(g)$centralization
    
    # Generate random networks
    set.seed(input$random_seed)
    
    sim_results <- data.frame(
      density = numeric(n_sims),
      transitivity = numeric(n_sims),
      diameter = numeric(n_sims),
      centralization = numeric(n_sims)
    )
    
    withProgress(message = 'Running simulations...', value = 0, {
      for (i in 1:n_sims) {
        sim_g <- sample_gnp(vcount(g), obs_density)
        
        sim_results$density[i] <- edge_density(sim_g)
        sim_results$transitivity[i] <- transitivity(sim_g, type = "global")
        sim_results$diameter[i] <- tryCatch(diameter(sim_g), error = function(e) NA)
        sim_results$centralization[i] <- centr_eigen(sim_g)$centralization
        
        incProgress(1/n_sims)
      }
    })
    
    rv$cug_simulations <- sim_results
    rv$cug_observed <- data.frame(
      density = obs_density,
      transitivity = obs_transitivity,
      diameter = obs_diameter,
      centralization = obs_centralization
    )
  })
  
  output$cug_distributions <- renderPlot({
    req(rv$cug_simulations, rv$cug_observed)
    
    sim_data <- rv$cug_simulations
    obs_data <- rv$cug_observed
    
    # Create plots using NC State colors
    p1 <- ggplot(sim_data, aes(x = density)) +
      geom_density(fill = "#CCCCCC", alpha = 0.7) +
      geom_vline(xintercept = mean(sim_data$density, na.rm = TRUE), 
                 color = "#000000", linetype = "dashed", size = 1) +
      geom_vline(xintercept = obs_data$density, 
                 color = "#CC0000", size = 1.5) +
      labs(title = "Density", x = "Density", y = "Density") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))
    
    p2 <- ggplot(sim_data, aes(x = transitivity)) +
      geom_density(fill = "#CCCCCC", alpha = 0.7) +
      geom_vline(xintercept = mean(sim_data$transitivity, na.rm = TRUE), 
                 color = "#000000", linetype = "dashed", size = 1) +
      geom_vline(xintercept = obs_data$transitivity, 
                 color = "#CC0000", size = 1.5) +
      labs(title = "Transitivity", x = "Transitivity", y = "Density") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))
    
    p3 <- ggplot(sim_data, aes(x = diameter)) +
      geom_density(fill = "#CCCCCC", alpha = 0.7) +
      geom_vline(xintercept = mean(sim_data$diameter, na.rm = TRUE), 
                 color = "#000000", linetype = "dashed", size = 1) +
      geom_vline(xintercept = obs_data$diameter, 
                 color = "#CC0000", size = 1.5) +
      labs(title = "Diameter", x = "Diameter", y = "Density") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))
    
    p4 <- ggplot(sim_data, aes(x = centralization)) +
      geom_density(fill = "#CCCCCC", alpha = 0.7) +
      geom_vline(xintercept = mean(sim_data$centralization, na.rm = TRUE), 
                 color = "#000000", linetype = "dashed", size = 1) +
      geom_vline(xintercept = obs_data$centralization, 
                 color = "#CC0000", size = 1.5) +
      labs(title = "Centralization", x = "Centralization", y = "Density") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))
    
    gridExtra::grid.arrange(p1, p2, p3, p4, ncol = 2,
                            top = "Network Metric Distributions\n(Black dashed = simulated mean, Red = observed)")
  })
  
  output$cug_results_table <- renderDT({
    req(rv$cug_simulations, rv$cug_observed)
    
    sim_data <- rv$cug_simulations
    obs_data <- rv$cug_observed
    
    results <- data.frame(
      Metric = c("Density", "Transitivity", "Diameter", "Centralization"),
      Observed = c(obs_data$density, obs_data$transitivity, 
                   obs_data$diameter, obs_data$centralization),
      Sim_Mean = c(mean(sim_data$density, na.rm = TRUE),
                   mean(sim_data$transitivity, na.rm = TRUE),
                   mean(sim_data$diameter, na.rm = TRUE),
                   mean(sim_data$centralization, na.rm = TRUE)),
      Sim_SD = c(sd(sim_data$density, na.rm = TRUE),
                 sd(sim_data$transitivity, na.rm = TRUE),
                 sd(sim_data$diameter, na.rm = TRUE),
                 sd(sim_data$centralization, na.rm = TRUE))
    )
    
    # P-values
    results$P_Value <- c(
      mean(sim_data$density >= obs_data$density, na.rm = TRUE),
      mean(sim_data$transitivity >= obs_data$transitivity, na.rm = TRUE),
      mean(sim_data$diameter >= obs_data$diameter, na.rm = TRUE),
      mean(sim_data$centralization >= obs_data$centralization, na.rm = TRUE)
    )
    
    # Z-scores
    results$Z_Score <- (results$Observed - results$Sim_Mean) / results$Sim_SD
    
    # Significance
    results$Significant <- ifelse(abs(results$Z_Score) > 1.96, "Yes (*)", "No")
    
    datatable(results, 
              options = list(pageLength = 10, dom = 't'),
              rownames = FALSE) %>%
      formatRound(columns = 2:6, digits = 3)
  })
  
  output$cug_interpretation <- renderUI({
    req(rv$cug_simulations, rv$cug_observed)
    
    tagList(
      h5("How to Interpret:"),
      tags$ul(
        tags$li(strong("Red line: "), "Observed value in your network"),
        tags$li(strong("Black dashed line: "), "Mean of simulated random networks"),
        tags$li(strong("Gray area: "), "Distribution of random network values"),
        tags$li(strong("P-value: "), "Proportion of simulations ≥ observed (closer to 0 or 1 = more significant)"),
        tags$li(strong("Z-score > 1.96 or < -1.96: "), "Statistically significant difference")
      ),
      h5("Statistical Significance:"),
      p("Values marked with (*) are significantly different from random networks at p < 0.05 level."),
      p("This suggests the observed network has structural properties that differ from what we'd expect by chance.")
    )
  })
}