diameter <- function(input, output, session, rv, g, components_result, vis_base) {
  dist_matrix <- reactive({
    igraph::distances(g())
  })

  diameter_result <- reactive({
    if (components_result()$no == 1) {
      diam <- igraph::diameter(g())
      avg_path <- igraph::mean_distance(g())
    } else {
      # Only for largest component
      comp <- components_result()
      largest_comp <- which.max(comp$csize)
      nodes_in_largest <- which(comp$membership == largest_comp)
      g_largest <- igraph::induced_subgraph(g(), nodes_in_largest)
      
      diam <- igraph::diameter(g_largest)
      avg_path <- igraph::mean_distance(g_largest)
    }
    
    list(diameter = diam, avg_path = avg_path)
  })
  
  output$diameter_metrics <- renderUI({    
    result <- diameter_result()
    
    tagList(
      tags$ul(
        tags$li(strong("Diameter: "), result$diameter),
        tags$li(strong("Average Path Length: "), round(result$avg_path, 3)),
        tags$li(strong("Interpretation: "), ifelse(result$diameter <= 3, "Small world network", "Sparse network"))
      )
    )
  })
  
  output$path_length_stats <- renderUI({
    req(dist_matrix())
    
    dist_mat <- dist_matrix()
    finite_dist <- dist_mat[is.finite(dist_mat) & dist_mat > 0]
    
    tagList(
      tags$ul(
        tags$li(strong("Shortest Path: "), min(finite_dist)),
        tags$li(strong("Longest Path: "), max(finite_dist)),
        tags$li(strong("Average: "), round(mean(finite_dist), 3)),
        tags$li(strong("Median: "), median(finite_dist))
      )
    )
  })
  
  output$avg_path_length_plot <- renderPlotly({
    req(dist_matrix())
    
    dist_mat <- dist_matrix()
    finite_dist <- dist_mat[is.finite(dist_mat) & dist_mat > 0]
    
    # Create cumulative distribution
    sorted_dist <- sort(unique(finite_dist))
    cum_nodes <- sapply(sorted_dist, function(d) sum(finite_dist <= d))
    
    plot_ly(x = sorted_dist, y = cum_nodes, type = "scatter", mode = "lines+markers") %>%
      layout(
        title = "Cumulative Distribution of Path Lengths",
        xaxis = list(title = "Path Length"),
        yaxis = list(title = "Number of Node Pairs")
      )
  })
}