distance <- function(input, output, session, rv, g, components_result, vis_base) {
  distance_matrix <- reactive({
    igraph::distances(g())
  })
  
  
  output$distance_properties <- renderUI({
    dist_mat <- igraph::distances(g())
    
    comp <- components_result()
    
    # Only compute for finite distances
    finite_dist <- dist_mat[is.finite(dist_mat)]
    
    tagList(
      tags$ul(
        tags$li(strong("Network Diameter: "), ifelse(comp$no == 1, max(finite_dist), "Inf (disconnected)")),
        tags$li(strong("Average Shortest Path: "), round(mean(finite_dist), 3)),
        tags$li(strong("Median Distance: "), median(finite_dist)),
        tags$li(strong("Max Distance: "), max(finite_dist))
      )
    )
  })
  
  output$distance_heatmap <- renderPlotly({
    dist_mat <- distance_matrix()
    node_names <- igraph::V(g())$name %||% as.character(1:igraph::vcount(g()))
    
    # Replace Inf with max finite value for visualization
    dist_mat_vis <- dist_mat
    max_finite <- max(dist_mat_vis[is.finite(dist_mat_vis)])
    dist_mat_vis[is.infinite(dist_mat_vis)] <- max_finite + 1
    
    plot_ly(
      x = node_names,
      y = node_names,
      z = dist_mat_vis,
      type = "heatmap",
      colorscale = "Viridis"
    ) %>%
      layout(
        title = "Distance Heatmap (all pairwise shortest paths)",
        xaxis = list(title = "Node"),
        yaxis = list(title = "Node")
      )
  })
  
  output$distance_histogram <- renderPlotly({
    dist_mat <- distance_matrix()
    finite_dist <- dist_mat[is.finite(dist_mat) & dist_mat > 0]
    
    plot_ly(x = finite_dist, type = "histogram") %>%
      layout(
        title = "Distribution of Shortest Path Lengths",
        xaxis = list(title = "Path Length"),
        yaxis = list(title = "Frequency")
      )
  })
}