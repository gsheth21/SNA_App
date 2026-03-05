assortativity_server <- function(input, output, session, rv) {
  
  # ============================================================
  # DEGREE ASSORTATIVITY
  # ============================================================
  
  observeEvent(input$calc_degree_assort, {
    req(rv$igraph)
    g <- ensure_igraph(rv$igraph)
    
    # Calculate degree assortativity
    assort_coeff <- igraph::assortativity_degree(g)
    
    rv$degree_assortativity <- assort_coeff
  })
  
  output$degree_assort_result <- renderUI({
    req(rv$degree_assortativity)
    
    coeff <- rv$degree_assortativity
    
    # Interpretation
    if (coeff > 0.2) {
      interpretation <- "Strong positive: High-degree nodes strongly prefer high-degree neighbors (assortative)"
    } else if (coeff > 0) {
      interpretation <- "Weak positive: Slight tendency for similar degrees to connect"
    } else if (coeff > -0.1) {
      interpretation <- "Near zero: No clear preference pattern"
    } else if (coeff > -0.3) {
      interpretation <- "Weak negative: Slight tendency for dissimilar degrees (disassortative)"
    } else {
      interpretation <- "Strong negative: High-degree nodes prefer low-degree neighbors (disassortative)"
    }
    
    tagList(
      tags$ul(
        tags$li(strong("Coefficient: "), round(coeff, 4)),
        tags$li(strong("Interpretation: "), interpretation)
      ),
      p(em("Note: Most social networks have positive assortativity; most biological/technological networks are disassortative."))
    )
  })
  
  output$degree_assort_scatter <- renderPlotly({
    req(rv$igraph)
    g <- rv$igraph
    
    # Get all edges
    edges <- as_edgelist(g)
    degrees <- degree(g)
    
    # Create scatter plot: degree of source vs degree of target
    from_deg <- degrees[edges[, 1]]
    to_deg <- degrees[edges[, 2]]
    
    plot_ly(x = from_deg, y = to_deg, mode = "markers", type = "scatter") %>%
      add_trace(x = from_deg, y = to_deg, mode = "text", text = "", 
                marker = list(size = 5, color = "#CC0000", opacity = 0.5),
                showlegend = FALSE) %>%
      layout(
        title = "Degree Assortativity: Source vs Target Degree",
        xaxis = list(title = "Source Node Degree"),
        yaxis = list(title = "Target Node Degree"),
        hovermode = "closest"
      )
  })
  
  output$neighbor_degree_dist <- renderPlotly({
    req(rv$igraph)
    g <- rv$igraph
    
    # Calculate average neighbor degree for each node
    avg_neighbor_deg <- sapply(1:vcount(g), function(i) {
      neighbors_deg <- degree(g, neighbors(g, i))
      if (length(neighbors_deg) > 0) mean(neighbors_deg) else 0
    })
    
    node_deg <- degree(g)
    
    plot_ly(x = node_deg, y = avg_neighbor_deg, mode = "markers", type = "scatter") %>%
      add_trace(x = node_deg, y = avg_neighbor_deg, mode = "text", text = "",
                marker = list(size = 6, color = "#000000", opacity = 0.6),
                showlegend = FALSE) %>%
      layout(
        title = "Average Neighbor Degree vs Node Degree",
        xaxis = list(title = "Node Degree"),
        yaxis = list(title = "Average Neighbor Degree"),
        hovermode = "closest"
      )
  })
  
  # ============================================================
  # ATTRIBUTE ASSORTATIVITY
  # ============================================================
  
  output$assortativity_attribute_select <- renderUI({
    req(rv$igraph)
    attrs <- vertex_attr_names(rv$igraph)
    attrs <- attrs[attrs != "name"]
    
    if (length(attrs) > 0) {
      radioButtons("assort_attribute", "Select Attribute:", 
                   choices = attrs, selected = attrs[1], inline = TRUE)
    } else {
      p("No categorical attributes available for assortativity analysis")
    }
  })
  
  observeEvent(input$calc_attr_assort, {
    req(rv$igraph, input$assort_attribute)
    g <- ensure_igraph(rv$igraph)
    
    attr_values <- igraph::vertex_attr(g, input$assort_attribute)
    
    # Calculate assortativity for this attribute
    assort_coeff <- igraph::assortativity(g, types = as.numeric(factor(attr_values)))
    
    rv$attr_assortativity <- list(
      coefficient = assort_coeff,
      attribute = input$assort_attribute,
      values = attr_values
    )
  })
  
  output$attr_assort_result <- renderUI({
    req(rv$attr_assortativity)
    
    coeff <- rv$attr_assortativity$coefficient
    attr_name <- rv$attr_assortativity$attribute
    
    if (coeff > 0.2) {
      interpretation <- "Strong: Nodes with same attribute strongly prefer each other"
    } else if (coeff > 0) {
      interpretation <- "Weak: Slight preference for same attribute"
    } else if (coeff > -0.1) {
      interpretation <- "None: No clear preference"
    } else {
      interpretation <- "Negative: Nodes prefer different attribute values"
    }
    
    tagList(
      h5(paste(attr_name, "Assortativity:")),
      tags$ul(
        tags$li(strong("Coefficient: "), round(coeff, 4)),
        tags$li(strong("Interpretation: "), interpretation)
      )
    )
  })
  
  output$attr_assort_plot <- renderVisNetwork({
    req(rv$igraph, rv$attr_assortativity)
    g <- rv$igraph
    attr_name <- rv$attr_assortativity$attribute
    attr_values <- rv$attr_assortativity$values
    
    vis_data <- igraph_to_visNetwork(g, input$layout)
    
    # Color nodes by attribute value
    unique_vals <- unique(attr_values)
    colors <- rainbow(length(unique_vals))
    color_map <- setNames(colors, unique_vals)
    vis_data$nodes$color <- color_map[as.character(attr_values)]
    vis_data$nodes$size <- input$node_size
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
  })
  
  output$attr_connection_bar <- renderPlotly({
    req(rv$igraph, rv$attr_assortativity)
    g <- rv$igraph
    attr_values <- rv$attr_assortativity$values
    edges <- as_edgelist(g)
    
    # Count connections between attribute groups
    from_attr <- attr_values[edges[, 1]]
    to_attr <- attr_values[edges[, 2]]
    
    same_attr <- sum(from_attr == to_attr)
    diff_attr <- sum(from_attr != to_attr)
    
    plot_ly(
      labels = c("Same Attribute", "Different Attributes"),
      values = c(same_attr, diff_attr),
      type = "pie"
    ) %>%
      layout(title = "Connections by Attribute Similarity")
  })
  
  # ============================================================
  # MIXING MATRIX
  # ============================================================
  
  output$mixing_attribute_select <- renderUI({
    req(rv$igraph)
    attrs <- vertex_attr_names(rv$igraph)
    attrs <- attrs[attrs != "name"]
    
    if (length(attrs) > 0) {
      selectInput("mixing_attribute", "Select Attribute:", 
                  choices = attrs, selected = attrs[1])
    } else {
      p("No categorical attributes available")
    }
  })
  
  observeEvent(input$calc_mixing_matrix, {
    req(rv$igraph, input$mixing_attribute)
    g <- rv$igraph
    
    attr_values <- vertex_attr(g, input$mixing_attribute)
    edges <- as_edgelist(g)
    
    from_attr <- attr_values[edges[, 1]]
    to_attr <- attr_values[edges[, 2]]
    
    # Create mixing matrix
    unique_vals <- unique(attr_values)
    mixing_matrix <- table(from_attr, to_attr)
    
    rv$mixing_matrix <- mixing_matrix
  })
  
  output$mixing_matrix_counts <- renderDT({
    req(rv$mixing_matrix)
    
    mix_mat <- rv$mixing_matrix
    df <- as.data.frame.matrix(mix_mat)
    df <- cbind(Category = rownames(df), df)
    
    datatable(df, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  output$mixing_matrix_proportions <- renderDT({
    req(rv$mixing_matrix)
    
    mix_mat <- rv$mixing_matrix
    # Convert to proportions
    prop_mat <- prop.table(mix_mat, margin = 1)
    df <- as.data.frame.matrix(round(prop_mat, 4))
    df <- cbind(Category = rownames(df), df)
    
    datatable(df, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  output$mixing_matrix_heatmap <- renderPlotly({
    req(rv$mixing_matrix)
    
    mix_mat <- rv$mixing_matrix
    
    plot_ly(
      x = colnames(mix_mat),
      y = rownames(mix_mat),
      z = mix_mat,
      type = "heatmap",
      colorscale = "Viridis"
    ) %>%
      layout(
        title = "Mixing Matrix Heatmap",
        xaxis = list(title = "To Category"),
        yaxis = list(title = "From Category")
      )
  })
  
  # ============================================================
  # NUMERICAL ASSORTATIVITY
  # ============================================================
  
  output$numerical_attribute_select <- renderUI({
    req(rv$igraph)
    attrs <- vertex_attr_names(rv$igraph)
    attrs <- attrs[attrs != "name"]
    
    # Filter to only numeric attributes
    numeric_attrs <- c()
    for (attr in attrs) {
      values <- vertex_attr(rv$igraph, attr)
      if (is.numeric(values)) {
        numeric_attrs <- c(numeric_attrs, attr)
      }
    }
    
    if (length(numeric_attrs) > 0) {
      selectInput("numerical_assort_attr", "Select Numerical Attribute:", 
                  choices = numeric_attrs)
    } else {
      p("No numerical attributes available")
    }
  })
  
  observeEvent(input$calc_numerical_assort, {
    req(rv$igraph, input$numerical_assort_attr)
    g <- rv$igraph
    
    attr_values <- as.numeric(vertex_attr(g, input$numerical_assort_attr))
    edges <- as_edgelist(g)
    
    from_val <- attr_values[edges[, 1]]
    to_val <- attr_values[edges[, 2]]
    
    # Calculate Pearson correlation
    correlation <- cor(from_val, to_val, use = "complete.obs")
    
    rv$numerical_assortativity <- list(
      correlation = correlation,
      attribute = input$numerical_assort_attr,
      from = from_val,
      to = to_val
    )
  })
  
  output$numerical_assort_result <- renderUI({
    req(rv$numerical_assortativity)
    
    corr <- rv$numerical_assortativity$correlation
    attr_name <- rv$numerical_assortativity$attribute
    
    if (corr > 0.5) {
      interpretation <- "Strong positive: nodes prefer neighbors with similar values"
    } else if (corr > 0.2) {
      interpretation <- "Moderate positive: weak preference for similarity"
    } else if (corr > -0.2) {
      interpretation <- "Weak/none: no clear pattern"
    } else if (corr > -0.5) {
      interpretation <- "Moderate negative: weak disassortative pattern"
    } else {
      interpretation <- "Strong negative: nodes prefer neighbors with dissimilar values"
    }
    
    tagList(
      h5(paste(attr_name, "Correlation:")),
      tags$ul(
        tags$li(strong("Pearson r: "), round(corr, 4)),
        tags$li(strong("Interpretation: "), interpretation)
      )
    )
  })
  
  output$connected_values_plot <- renderPlotly({
    req(rv$numerical_assortativity)
    
    from <- rv$numerical_assortativity$from
    to <- rv$numerical_assortativity$to
    attr_name <- rv$numerical_assortativity$attribute
    
    plot_ly(x = from, y = to, mode = "markers", type = "scatter") %>%
      add_trace(x = from, y = to, mode = "text", text = "",
                marker = list(size = 5, color = "#CC0000", opacity = 0.5),
                showlegend = FALSE) %>%
      layout(
        title = paste("Connected Nodes:", attr_name),
        xaxis = list(title = paste("Source", attr_name)),
        yaxis = list(title = paste("Target", attr_name)),
        hovermode = "closest"
      )
  })
}