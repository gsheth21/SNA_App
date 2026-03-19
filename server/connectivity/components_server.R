components <- function(input, output, session, rv, g, components_result) {
  output$component_stats <- renderUI({
    g <- g()
    comp <- components_result()

    n_components <- comp$no
    sizes <- comp$csize
    main_size <- max(sizes)
    isolates <- sum(igraph::degree(g) == 0)
    
    tagList(
      tags$ul(
        tags$li(strong("Number of Components: "), n_components),
        tags$li(strong("Main Component Size: "), main_size, " nodes"),
        tags$li(strong("Isolates: "), isolates, " nodes"),
        tags$li(strong("Network Connectivity: "), ifelse(n_components == 1, "Fully Connected", "Fragmented"))
      )
    )
  })
  
  output$component_size_dist <- renderPlotly({
    req(rv$igraph)
    
    g <- g()
    comp <- components_result()
    sizes <- sort(comp$csize, decreasing = TRUE)
    
    plot_ly(x = 1:length(sizes), y = sizes, type = "bar") %>%
      layout(
        title = "Component Size Distribution",
        xaxis = list(title = "Component ID"),
        yaxis = list(title = "Size (Number of Nodes)")
      )
  })
  
  output$components_plot <- renderVisNetwork({
    req(rv$igraph)
    
    g <- g()
    comp <- components_result()
    
    colors <- rainbow(comp$no)
    node_colors <- colors[comp$membership]
    
    vis_data <- igraph_to_visNetwork(g, input$layout)
    vis_data$nodes$color <- node_colors
    vis_data$nodes$size <- input$node_size
    
    visNetwork(vis_data$nodes, vis_data$edges) %>%
      visOptions(highlightNearest = TRUE) %>%
      visInteraction(navigationButtons = TRUE)
  })
  
  output$component_membership_table <- renderDT({
    req(rv$igraph)
    
    g <- g()
    comp <- components_result()
    node_names <- igraph::V(g)$name %||% as.character(1:igraph::vcount(g))
    
    df <- data.frame(
      Node = node_names,
      Component = comp$membership,
      Component_Size = comp$csize[comp$membership]
    )
    
    df <- df[order(df$Component, df$Node), ]
    
    datatable(df, options = list(pageLength = 10, scrollX = TRUE))
  })
}